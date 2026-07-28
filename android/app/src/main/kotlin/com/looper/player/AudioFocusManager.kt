package com.looper.player

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import android.bluetooth.BluetoothDevice

class AudioFocusManager(
    private val context: Context,
    private val channel: MethodChannel
) {
    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val handler = Handler(Looper.getMainLooper())
    
    private var focusRequest: AudioFocusRequest? = null
    private var hasFocus = false
    
    // Configurable settings (synced from Dart)
    var isEnabled = true
    var pauseOnDuck = false
    var resumeOnBluetoothConnect = false

    // State tracking
    private var playbackWasInterrupted = false
    private var isDucked = false

    private val focusListener = AudioManager.OnAudioFocusChangeListener { focusChange ->
        if (!isEnabled) return@OnAudioFocusChangeListener
        handler.post {
            handleFocusChange(focusChange)
        }
    }

    private val audioReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent == null) return
            when (intent.action) {
                AudioManager.ACTION_AUDIO_BECOMING_NOISY -> {
                    Log.d("AudioFocusManager", "Audio becoming noisy (headset unplugged)")
                    playbackWasInterrupted = false
                    channel.invokeMethod("onBecomingNoisy", null)
                }
                BluetoothDevice.ACTION_ACL_CONNECTED -> {
                    val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
                    Log.d("AudioFocusManager", "Bluetooth device ACL connected: ${device?.name}")
                    if (resumeOnBluetoothConnect) {
                        channel.invokeMethod("onBluetoothConnected", null)
                    }
                }
            }
        }
    }

    private var receiversRegistered = false

    fun registerReceivers() {
        if (receiversRegistered) return
        val filter = IntentFilter().apply {
            addAction(AudioManager.ACTION_AUDIO_BECOMING_NOISY)
            addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(audioReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            context.registerReceiver(audioReceiver, filter)
        }
        receiversRegistered = true
    }

    fun unregisterReceivers() {
        if (!receiversRegistered) return
        try {
            context.unregisterReceiver(audioReceiver)
        } catch (e: Exception) {
            Log.e("AudioFocusManager", "Error unregistering receiver", e)
        }
        receiversRegistered = false
    }

    fun requestAudioFocus(): Boolean {
        if (!isEnabled) return true
        if (hasFocus) return true

        val result = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val attrs = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .build()

            val req = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                .setAudioAttributes(attrs)
                .setOnAudioFocusChangeListener(focusListener, handler)
                .setWillPauseWhenDucked(false)
                .setAcceptsDelayedFocusGain(true)
                .build()

            focusRequest = req
            audioManager.requestAudioFocus(req)
        } else {
            @Suppress("DEPRECATION")
            audioManager.requestAudioFocus(
                focusListener,
                AudioManager.STREAM_MUSIC,
                AudioManager.AUDIOFOCUS_GAIN
            )
        }

        hasFocus = result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        if (hasFocus) {
            registerReceivers()
        } else if (result == AudioManager.AUDIOFOCUS_REQUEST_DELAYED) {
            Log.d("AudioFocusManager", "Audio focus request delayed")
            playbackWasInterrupted = true
            channel.invokeMethod("onAudioFocusRequestDelayed", null)
        }
        return hasFocus
    }

    fun abandonAudioFocus() {
        if (!hasFocus) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            focusRequest?.let { audioManager.abandonAudioFocusRequest(it) }
            focusRequest = null
        } else {
            @Suppress("DEPRECATION")
            audioManager.abandonAudioFocus(focusListener)
        }
        hasFocus = false
        isDucked = false
    }

    fun setPlaybackInterrupted(interrupted: Boolean) {
        playbackWasInterrupted = interrupted
    }

    private fun handleFocusChange(focusChange: Int) {
        when (focusChange) {
            AudioManager.AUDIOFOCUS_GAIN -> {
                Log.d("AudioFocusManager", "AUDIOFOCUS_GAIN")
                hasFocus = true
                if (isDucked) {
                    isDucked = false
                    channel.invokeMethod("onRestoreVolume", null)
                }
                if (playbackWasInterrupted) {
                    playbackWasInterrupted = false
                    channel.invokeMethod("onResumePlayback", null)
                }
            }
            AudioManager.AUDIOFOCUS_LOSS -> {
                Log.d("AudioFocusManager", "AUDIOFOCUS_LOSS")
                hasFocus = false
                playbackWasInterrupted = false
                isDucked = false
                channel.invokeMethod("onPausePlayback", mapOf("permanent" to true))
                abandonAudioFocus()
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                Log.d("AudioFocusManager", "AUDIOFOCUS_LOSS_TRANSIENT")
                hasFocus = false
                playbackWasInterrupted = true
                isDucked = false
                channel.invokeMethod("onPausePlayback", mapOf("permanent" to false))
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                Log.d("AudioFocusManager", "AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK")
                if (pauseOnDuck) {
                    playbackWasInterrupted = true
                    channel.invokeMethod("onPausePlayback", mapOf("permanent" to false))
                } else {
                    isDucked = true
                    channel.invokeMethod("onDuckVolume", null)
                }
            }
        }
    }
}
