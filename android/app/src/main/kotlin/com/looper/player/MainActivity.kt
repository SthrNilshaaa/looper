package com.looper.player

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Bundle
import android.media.AudioManager
import android.content.Context
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.util.Log
import android.graphics.Color
import android.os.PowerManager


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.looper.player/broadcast"
    private val WIDGET_CHANNEL = "com.looper.player/widget"
    private val WAKELOCK_CHANNEL = "com.looper.player/wakelock"
    private var wakeLock: PowerManager.WakeLock? = null


    companion object {
        var activeEngine: FlutterEngine? = null
        var stopOnTaskRemoved: Boolean = false

        fun sendWidgetAction(context: Context, action: String) {
            val engine = activeEngine
            if (engine != null) {
                val channel = MethodChannel(engine.dartExecutor.binaryMessenger, "com.looper.player/widget")
                channel.invokeMethod("onWidgetAction", action)
            } else {
                // If app is not running, click launches the app
                val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                launchIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(launchIntent)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        activeEngine = flutterEngine
        io.flutter.embedding.engine.FlutterEngineCache.getInstance().put("looper_cached_engine", flutterEngine)
        
        try {
            startService(Intent(this, LooperTaskService::class.java))
        } catch (e: Exception) {
            Log.e("LooperTaskService", "Failed to start LooperTaskService", e)
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "broadcastMetadata") {
                val title = call.argument<String>("title")
                val artist = call.argument<String>("artist")
                val album = call.argument<String>("album")
                val duration = (call.argument<Any>("duration") as? Number)?.toLong() ?: 0L
                val isPlaying = call.argument<Boolean>("isPlaying") ?: false

                sendPlaybackBroadcast(title, artist, album, duration, isPlaying)
                result.success(null)
            } else if (call.method == "setStopOnTaskRemoved") {
                val value = call.argument<Boolean>("value") ?: false
                stopOnTaskRemoved = value
                result.success(null)
            } else if (call.method == "isOnCall") {
                val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                val mode = audioManager.mode
                val isOnCall = (mode == AudioManager.MODE_IN_CALL || 
                                mode == AudioManager.MODE_IN_COMMUNICATION || 
                                mode == AudioManager.MODE_RINGTONE)
                result.success(isOnCall)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateWidgetState") {
                val title = call.argument<String>("title") ?: "No song playing"
                val artist = call.argument<String>("artist") ?: ""
                val isPlaying = call.argument<Boolean>("isPlaying") ?: false
                val isShuffle = call.argument<Boolean>("isShuffle") ?: false
                val repeatMode = (call.argument<Any>("repeatMode") as? Number)?.toInt() ?: 0
                val lyrics = call.argument<String>("lyrics") ?: ""
                val nextLyrics = call.argument<String>("nextLyrics") ?: ""
                val artPath = call.argument<String>("artPath") ?: ""
                var accentColor = (call.argument<Any>("accentColor") as? Number)?.toInt() ?: 0
                val position = (call.argument<Any>("position") as? Number)?.toLong() ?: 0L
                val duration = (call.argument<Any>("duration") as? Number)?.toLong() ?: 0L

                Log.d("PlayerWidget", "MainActivity: updateWidgetState: title=$title, artist=$artist, isPlaying=$isPlaying, accentColor=$accentColor")

                // If accentColor is transparent or zero, fallback to premium green
                if (accentColor == 0) {
                    accentColor = Color.parseColor("#55DF69")
                }

                val prefs = es.antonborri.home_widget.HomeWidgetPlugin.getData(this)
                val oldTitle = prefs.getString("title", "")
                prefs.edit().apply {
                    if (title != oldTitle) {
                        putInt("currentLyricIndex", 0)
                        putString("lastSavedLyric", "")
                    }
                    putString("title", title)
                    putString("artist", artist)
                    putBoolean("isPlaying", isPlaying)
                    putBoolean("isShuffle", isShuffle)
                    putInt("repeatMode", repeatMode)
                    putString("lyrics", lyrics)
                    putString("nextLyrics", nextLyrics)
                    putString("artPath", artPath)
                    putInt("accentColor", accentColor)
                    putLong("position", position)
                    putLong("duration", duration)
                    apply()
                }

                // Trigger widget update for all 4 providers
                val appWidgetManager = AppWidgetManager.getInstance(this)
                val providers = listOf(
                    PlayerWidgetProvider::class.java,
                    PlayerWidgetProviderSquareArtwork::class.java,
                    PlayerWidgetProviderSquareProgress::class.java,
                    PlayerWidgetProviderLargeLyrics::class.java
                )
                for (provider in providers) {
                    val componentName = ComponentName(this, provider)
                    val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
                    Log.d("PlayerWidget", "MainActivity: updating widget IDs count for ${provider.simpleName} = ${appWidgetIds.size}")
                    for (appWidgetId in appWidgetIds) {
                        PlayerWidgetProvider.updateWidget(this, appWidgetManager, appWidgetId, provider)
                    }
                }

                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WAKELOCK_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "acquire" -> {
                    acquireWakeLock()
                    result.success(null)
                }
                "release" -> {
                    releaseWakeLock()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun acquireWakeLock() {
        try {
            if (wakeLock == null) {
                val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "LooperPlayer:PlaybackWakeLock")
            }
            if (wakeLock?.isHeld == false) {
                wakeLock?.acquire()
                Log.d("LooperWakeLock", "Partial WakeLock acquired")
            }
        } catch (e: Exception) {
            Log.e("LooperWakeLock", "Error acquiring wakeLock", e)
        }
    }

    private fun releaseWakeLock() {
        try {
            if (wakeLock?.isHeld == true) {
                wakeLock?.release()
                Log.d("LooperWakeLock", "Partial WakeLock released")
            }
        } catch (e: Exception) {
            Log.e("LooperWakeLock", "Error releasing wakeLock", e)
        }
    }


    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return io.flutter.embedding.engine.FlutterEngineCache.getInstance().get("looper_cached_engine")
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        return stopOnTaskRemoved
    }

    override fun onDestroy() {
        releaseWakeLock()
        activeEngine = null
        if (stopOnTaskRemoved) {
            io.flutter.embedding.engine.FlutterEngineCache.getInstance().remove("looper_cached_engine")
        }
        super.onDestroy()
    }

    private fun sendPlaybackBroadcast(title: String?, artist: String?, album: String?, duration: Long, isPlaying: Boolean) {
        val intent = Intent("com.android.music.metadatachanged")
        intent.putExtra("track", title)
        intent.putExtra("artist", artist)
        intent.putExtra("album", album)
        intent.putExtra("duration", duration)
        intent.putExtra("playing", isPlaying)
        
        // Some apps listen to these specific keys
        intent.putExtra("id", 1L)
        intent.putExtra("list_size", 1)
        
        sendBroadcast(intent)

        // Also send playstatechanged
        val stateIntent = Intent("com.android.music.playstatechanged")
        stateIntent.putExtra("playing", isPlaying)
        stateIntent.putExtra("track", title)
        sendBroadcast(stateIntent)
    }
}
