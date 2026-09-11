package com.looper.player

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log

class LooperTaskService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_NOT_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        Log.d("LooperTaskService", "onTaskRemoved: App swiped away from recent apps list")
        if (MainActivity.stopOnTaskRemoved) {
            Log.d("LooperTaskService", "stopOnTaskRemoved is true, cleaning up MediaSession and terminating process")
            
            stopService(
                Intent().setClassName(
                    packageName,
                    "com.alesdrnz.mpv_audio_kit.media_session.MpvMediaSessionService"
                )
            )
            stopSelf()
            android.os.Process.killProcess(android.os.Process.myPid())
        } else {
            // Media3 already keeps its foreground media service alive while
            // playback is active. Restarting its internal manager here caused
            // duplicate notifications and races during task removal.
            Log.d("LooperTaskService", "Playback service remains owned by Media3")
        }
        super.onTaskRemoved(rootIntent)
    }
}
