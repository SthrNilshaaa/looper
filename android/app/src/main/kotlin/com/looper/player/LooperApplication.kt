package com.looper.player

import io.flutter.app.FlutterApplication
import android.util.Log

class LooperApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        try {
            System.loadLibrary("mpv")
            Log.d("LooperApplication", "Looper Player: System.loadLibrary(\"mpv\") succeeded in Application onCreate")
        } catch (e: UnsatisfiedLinkError) {
            Log.e("LooperApplication", "Looper Player: UnsatisfiedLinkError loading libmpv.so", e)
        } catch (e: Exception) {
            Log.e("LooperApplication", "Looper Player: Exception loading libmpv.so", e)
        }
    }
}
