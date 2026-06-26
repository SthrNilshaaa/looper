package com.looper.player

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.*
import android.os.Bundle
import android.view.KeyEvent
import android.view.View
import android.widget.RemoteViews
import android.util.Log

open class PlayerWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_PLAY_PAUSE = "com.looper.player.ACTION_PLAY_PAUSE"
        const val ACTION_NEXT = "com.looper.player.ACTION_NEXT"
        const val ACTION_PREV = "com.looper.player.ACTION_PREV"
        const val ACTION_SHUFFLE = "com.looper.player.ACTION_SHUFFLE"
        const val ACTION_REPEAT = "com.looper.player.ACTION_REPEAT"

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            providerClass: Class<out PlayerWidgetProvider> = PlayerWidgetProvider::class.java,
            options: Bundle? = null
        ) {
            try {
                val layoutId = when (providerClass.simpleName) {
                    "PlayerWidgetProviderSquareArtwork" -> R.layout.player_widget_square_artwork
                    "PlayerWidgetProviderSquareProgress" -> R.layout.player_widget_square_progress
                    "PlayerWidgetProviderLargeLyrics" -> R.layout.player_widget_large_lyrics
                    else -> R.layout.player_widget
                }
                
                // Pre-inflate the layout locally to catch inflation exceptions (e.g. invalid layouts/attributes)
                try {
                    val inflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as android.view.LayoutInflater
                    inflater.inflate(layoutId, null)
                    Log.d("PlayerWidget", "Pre-inflated layout successfully: ${context.resources.getResourceEntryName(layoutId)}")
                } catch (ie: Exception) {
                    Log.e("PlayerWidget", "CRITICAL: Layout pre-inflation failed for ${context.resources.getResourceEntryName(layoutId)}!", ie)
                }

                val views = RemoteViews(context.packageName, layoutId)
                val prefs = es.antonborri.home_widget.HomeWidgetPlugin.getData(context)

                val title = prefs.getString("title", "No song playing") ?: "No song playing"
                val artist = prefs.getString("artist", "") ?: ""
                val isPlaying = prefs.getBoolean("isPlaying", false)
                val lyrics = prefs.getString("lyrics", "") ?: ""
                val artPath = prefs.getString("artPath", "") ?: ""
                val accentColor = try {
                    prefs.getInt("accentColor", Color.parseColor("#55DF69"))
                } catch (e: ClassCastException) {
                    try {
                        prefs.getLong("accentColor", Color.parseColor("#55DF69").toLong()).toInt()
                    } catch (e2: Exception) {
                        Color.parseColor("#55DF69")
                    }
                }

                Log.d("PlayerWidget", "PlayerWidgetProvider: updateWidget: provider=${providerClass.simpleName}, id=$appWidgetId, title=$title, artist=$artist, isPlaying=$isPlaying, accentColor=$accentColor")

                val blendedBackgroundColor = Color.BLACK

                if (layoutId != R.layout.player_widget_square_artwork) {
                    views.setInt(R.id.widget_background_image, "setColorFilter", blendedBackgroundColor)
                }

                // Set song metadata
                views.setTextViewText(R.id.widget_title, title)
                views.setTextViewText(R.id.widget_artist, artist)

                // Set play/pause icon and play container background color
                if (isPlaying) {
                    views.setImageViewResource(R.id.widget_play_pause, R.drawable.ic_pause)
                } else {
                    views.setImageViewResource(R.id.widget_play_pause, R.drawable.ic_play)
                }
                
                // Apply accent colors dynamically to the circular background ImageView
                views.setInt(R.id.widget_play_pause_background, "setColorFilter", accentColor)

                // Progress bar binding for Square Progress layout
                if (layoutId == R.layout.player_widget_square_progress) {
                    val position = try {
                        prefs.getLong("position", 0L)
                    } catch (e: ClassCastException) {
                        try {
                            prefs.getInt("position", 0).toLong()
                        } catch (e2: Exception) {
                            0L
                        }
                    }
                    val duration = try {
                        prefs.getLong("duration", 0L)
                    } catch (e: ClassCastException) {
                        try {
                            prefs.getInt("duration", 0).toLong()
                        } catch (e2: Exception) {
                            0L
                        }
                    }
                    val progress = if (duration > 0) (position * 100 / duration).toInt() else 0
                    views.setProgressBar(R.id.widget_progress, 100, progress, false)
                }

                // Lyrics binding for Large Lyrics layout
                if (layoutId == R.layout.player_widget_large_lyrics) {
                    views.setTextViewText(R.id.widget_lyric_active, if (lyrics.isNotEmpty()) lyrics else "Lyrics will appear here...")
                }

                // Set artwork if the layout supports it
                if (layoutId == R.layout.player_widget || 
                    layoutId == R.layout.player_widget_square_artwork || 
                    layoutId == R.layout.player_widget_large_lyrics ||
                    layoutId == R.layout.player_widget_square_progress) {
                    Log.d("PlayerWidget", "artwork path: $artPath")
                    var cleanPath = artPath.trim()
                    if (cleanPath.startsWith("file://")) {
                        cleanPath = cleanPath.substring(7)
                    } else if (cleanPath.startsWith("file:")) {
                        cleanPath = cleanPath.substring(5)
                    }

                    if (cleanPath.isNotEmpty()) {
                        var file = java.io.File(cleanPath)
                        if (!file.isAbsolute) {
                            file = java.io.File(context.filesDir, cleanPath)
                        }
                        if (!file.exists()) {
                            file = java.io.File(context.filesDir, "album_art/" + file.name)
                        }
                        if (!file.exists()) {
                            file = java.io.File(context.filesDir, file.name)
                        }

                        Log.d("PlayerWidget", "Resolved artPath: ${file.absolutePath}, exists: ${file.exists()}")

                        if (file.exists()) {
                            try {
                                val bitmap = decodeSampledBitmapFromFile(file.absolutePath, 128, 128)
                                Log.d("PlayerWidget", "decoded bitmap: ${bitmap != null}")
                                if (bitmap != null) {
                                    val roundedBitmap = getRoundedCornerBitmap(bitmap, 24) // 24px rounding for 128x128
                                    views.setImageViewBitmap(R.id.widget_artwork, roundedBitmap)
                                } else {
                                    Log.w("PlayerWidget", "Bitmap decoding returned null for ${file.absolutePath}")
                                    views.setImageViewResource(R.id.widget_artwork, R.mipmap.ic_launcher)
                                }
                            } catch (e: Exception) {
                                Log.e("PlayerWidget", "Error decoding artwork bitmap", e)
                                views.setImageViewResource(R.id.widget_artwork, R.mipmap.ic_launcher)
                            }
                        } else {
                            Log.w("PlayerWidget", "Artwork file does not exist at: ${file.absolutePath}")
                            views.setImageViewResource(R.id.widget_artwork, R.mipmap.ic_launcher)
                        }
                    } else {
                        views.setImageViewResource(R.id.widget_artwork, R.mipmap.ic_launcher)
                    }
                }

                // Add PendingIntents for clicks
                views.setOnClickPendingIntent(R.id.widget_play_pause_container, getPendingIntent(context, ACTION_PLAY_PAUSE, providerClass))
                views.setOnClickPendingIntent(R.id.widget_next, getPendingIntent(context, ACTION_NEXT, providerClass))
                if (layoutId != R.layout.player_widget_large_lyrics) {
                    views.setOnClickPendingIntent(R.id.widget_prev, getPendingIntent(context, ACTION_PREV, providerClass))
                }

                // Launch app intent when title, artist or artwork is clicked
                val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                val launchPendingIntent = PendingIntent.getActivity(
                    context, 0, launchIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_title, launchPendingIntent)
                views.setOnClickPendingIntent(R.id.widget_artist, launchPendingIntent)
                if (layoutId == R.layout.player_widget || 
                    layoutId == R.layout.player_widget_square_artwork || 
                    layoutId == R.layout.player_widget_large_lyrics ||
                    layoutId == R.layout.player_widget_square_progress) {
                    views.setOnClickPendingIntent(R.id.widget_artwork, launchPendingIntent)
                }

                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (t: Throwable) {
                Log.e("PlayerWidget", "Error updating widget (id=$appWidgetId, providerClass=${providerClass.simpleName})", t)
            }
        }

        private fun decodeSampledBitmapFromFile(path: String, reqWidth: Int, reqHeight: Int): Bitmap? {
            try {
                val options = BitmapFactory.Options().apply {
                    inJustDecodeBounds = true
                }
                BitmapFactory.decodeFile(path, options)

                options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight)
                options.inJustDecodeBounds = false
                return BitmapFactory.decodeFile(path, options)
            } catch (e: Exception) {
                return null
            }
        }

        private fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, reqHeight: Int): Int {
            val height = options.outHeight
            val width = options.outWidth
            var inSampleSize = 1

            if (height > reqHeight || width > reqWidth) {
                val halfHeight = height / 2
                val halfWidth = width / 2
                while (halfHeight / inSampleSize >= reqHeight && halfWidth / inSampleSize >= reqWidth) {
                    inSampleSize *= 2
                }
            }
            return inSampleSize
        }

        private fun getPendingIntent(context: Context, action: String, providerClass: Class<out PlayerWidgetProvider>): PendingIntent {
            val intent = Intent(context, providerClass).apply {
                this.action = action
            }
            return PendingIntent.getBroadcast(
                context, action.hashCode() + providerClass.hashCode(), intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        private fun getRoundedCornerBitmap(bitmap: Bitmap, pixels: Int): Bitmap {
            val output = Bitmap.createBitmap(bitmap.width, bitmap.height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(output)

            val color = -0xbdbdbe
            val paint = Paint()
            val rect = Rect(0, 0, bitmap.width, bitmap.height)
            val rectF = RectF(rect)
            val roundPx = pixels.toFloat()

            paint.isAntiAlias = true
            canvas.drawARGB(0, 0, 0, 0)
            paint.color = color
            canvas.drawRoundRect(rectF, roundPx, roundPx, paint)

            paint.xfermode = PorterDuffXfermode(PorterDuff.Mode.SRC_IN)
            canvas.drawBitmap(bitmap, rect, rect, paint)

            return output
        }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId, javaClass)
        }
    }

    override fun onAppWidgetOptionsChanged(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int, newOptions: Bundle) {
        updateWidget(context, appWidgetManager, appWidgetId, javaClass, newOptions)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val action = intent.action ?: return

        when (action) {
            ACTION_PLAY_PAUSE -> {
                sendMediaButtonIntent(context, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE)
            }
            ACTION_NEXT -> {
                sendMediaButtonIntent(context, KeyEvent.KEYCODE_MEDIA_NEXT)
            }
            ACTION_PREV -> {
                sendMediaButtonIntent(context, KeyEvent.KEYCODE_MEDIA_PREVIOUS)
            }
            ACTION_SHUFFLE, ACTION_REPEAT -> {
                MainActivity.sendWidgetAction(context, action)
            }
        }
    }

    private fun sendMediaButtonIntent(context: Context, keycode: Int) {
        // Map keycodes to widget action strings so that MainActivity can
        // route them through the Flutter MethodChannel to PlaybackNotifier.
        // (com.ryanheise.audioservice.MediaButtonReceiver no longer exists
        //  since the migration to mpv_audio_kit.)
        val action = when (keycode) {
            KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE -> ACTION_PLAY_PAUSE
            KeyEvent.KEYCODE_MEDIA_NEXT       -> ACTION_NEXT
            KeyEvent.KEYCODE_MEDIA_PREVIOUS   -> ACTION_PREV
            else -> return
        }
        MainActivity.sendWidgetAction(context, action)
    }
}

class PlayerWidgetProviderSquareArtwork : PlayerWidgetProvider()
class PlayerWidgetProviderSquareProgress : PlayerWidgetProvider()
class PlayerWidgetProviderLargeLyrics : PlayerWidgetProvider()
