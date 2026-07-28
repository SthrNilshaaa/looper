package com.looper.player

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log

class LooperTaskService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        Log.d("LooperTaskService", "onTaskRemoved: App swiped away from recent apps list")
        if (MainActivity.stopOnTaskRemoved) {
            Log.d("LooperTaskService", "stopOnTaskRemoved is true, cleaning up MediaSession and terminating process")
            
            android.os.Handler(android.os.Looper.getMainLooper()).post {
                try {
                    val managerClass = Class.forName("com.alesdrnz.mpv_audio_kit.media_session.MediaSessionManager")
                    val instanceField = managerClass.getDeclaredField("INSTANCE")
                    instanceField.isAccessible = true
                    val instance = instanceField.get(null)
                    
                    val disableMethod = managerClass.getDeclaredMethod("disable")
                    disableMethod.isAccessible = true
                    disableMethod.invoke(instance)
                    Log.d("LooperTaskService", "Successfully disabled MediaSession via reflection")
                } catch (e: Exception) {
                    Log.e("LooperTaskService", "Failed to disable MediaSession via reflection", e)
                }
                
                // Allow a tiny delay (200ms) for media session state / service changes to broadcast to Android OS
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    stopSelf()
                    android.os.Process.killProcess(android.os.Process.myPid())
                }, 200)
            }
        } else {
            Log.d("LooperTaskService", "stopOnTaskRemoved is false, restarting MediaSessionService to persist notification")
            
            // Wait 600ms to let the default onTaskRemoved teardown in MpvMediaSessionService finish,
            // then restart it by invoking MediaSessionManager.startService() via reflection.
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                try {
                    val managerClass = Class.forName("com.alesdrnz.mpv_audio_kit.media_session.MediaSessionManager")
                    val instanceField = managerClass.getDeclaredField("INSTANCE")
                    instanceField.isAccessible = true
                    val instance = instanceField.get(null)
                    
                    val startServiceMethod = managerClass.getDeclaredMethod("startService")
                    startServiceMethod.isAccessible = true
                    startServiceMethod.invoke(instance)
                    Log.d("LooperTaskService", "Successfully restarted MediaSessionService via reflection")
                } catch (e: Exception) {
                    Log.e("LooperTaskService", "Failed to restart MediaSessionService via reflection", e)
                }
            }, 600)
        }
        super.onTaskRemoved(rootIntent)
    }
}
