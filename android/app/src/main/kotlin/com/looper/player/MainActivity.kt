package com.looper.player

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Bundle

class MainActivity : AudioServiceActivity() {
    private val CHANNEL = "com.looper.player/broadcast"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "broadcastMetadata") {
                val title = call.argument<String>("title")
                val artist = call.argument<String>("artist")
                val album = call.argument<String>("album")
                val duration = (call.argument<Any>("duration") as? Number)?.toLong() ?: 0L
                val isPlaying = call.argument<Boolean>("isPlaying") ?: false

                sendPlaybackBroadcast(title, artist, album, duration, isPlaying)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
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
