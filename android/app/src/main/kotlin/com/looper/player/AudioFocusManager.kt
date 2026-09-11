package com.looper.player

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.AudioDeviceCallback
import android.media.AudioDeviceInfo
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.MethodChannel

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
    private val knownAudioDeviceIds = mutableSetOf<Int>()

    private val audioDeviceCallback = object : AudioDeviceCallback() {
        override fun onAudioDevicesAdded(addedDevices: Array<out AudioDeviceInfo>) {
            val newlyConnectedBluetoothAudio = addedDevices.any { device ->
                val isNew = knownAudioDeviceIds.add(device.id)
                isNew && isBluetoothAudioOutput(device)
            }
            if (newlyConnectedBluetoothAudio && resumeOnBluetoothConnect) {
                Log.d("AudioFocusManager", "Bluetooth audio output connected")
                try {
                    channel.invokeMethod("onBluetoothConnected", null)
                } catch (e: Exception) {
                    Log.e("AudioFocusManager", "Error invoking onBluetoothConnected", e)
                }
            }
        }

        override fun onAudioDevicesRemoved(removedDevices: Array<out AudioDeviceInfo>) {
            removedDevices.forEach { knownAudioDeviceIds.remove(it.id) }
        }
    }

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
                    try {
                        channel.invokeMethod("onBecomingNoisy", null)
                    } catch (e: Exception) {
                        Log.e("AudioFocusManager", "Error invoking onBecomingNoisy", e)
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
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Both actions are protected system broadcasts only the OS can send,
            // so there's no need to accept them from other apps too.
            context.registerReceiver(audioReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(audioReceiver, filter)
        }
        knownAudioDeviceIds.clear()
        audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
            .forEach { knownAudioDeviceIds.add(it.id) }
        audioManager.registerAudioDeviceCallback(audioDeviceCallback, handler)
        receiversRegistered = true
    }

    fun unregisterReceivers() {
        if (!receiversRegistered) return
        try {
            context.unregisterReceiver(audioReceiver)
        } catch (e: Exception) {
            Log.e("AudioFocusManager", "Error unregistering receiver", e)
        }
        audioManager.unregisterAudioDeviceCallback(audioDeviceCallback)
        knownAudioDeviceIds.clear()
        receiversRegistered = false
    }

    private fun isBluetoothAudioOutput(device: AudioDeviceInfo): Boolean {
        if (!device.isSink) return false
        if (device.type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP ||
            device.type == AudioDeviceInfo.TYPE_BLUETOOTH_SCO ||
            device.type == AudioDeviceInfo.TYPE_HEARING_AID
        ) return true
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
            (device.type == AudioDeviceInfo.TYPE_BLE_HEADSET ||
                device.type == AudioDeviceInfo.TYPE_BLE_SPEAKER)
        ) return true
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            device.type == AudioDeviceInfo.TYPE_BLE_BROADCAST
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
        if (result == AudioManager.AUDIOFOCUS_REQUEST_DELAYED) {
            Log.d("AudioFocusManager", "Audio focus request delayed")
            playbackWasInterrupted = true
            try {
                channel.invokeMethod("onAudioFocusRequestDelayed", null)
            } catch (e: Exception) {
                Log.e("AudioFocusManager", "Error invoking onAudioFocusRequestDelayed", e)
            }
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
                    try {
                        channel.invokeMethod("onRestoreVolume", null)
                    } catch (e: Exception) {
                        Log.e("AudioFocusManager", "Error invoking onRestoreVolume", e)
                    }
                }
                if (playbackWasInterrupted) {
                    playbackWasInterrupted = false
                    try {
                        channel.invokeMethod("onResumePlayback", null)
                    } catch (e: Exception) {
                        Log.e("AudioFocusManager", "Error invoking onResumePlayback", e)
                    }
                }
            }
            AudioManager.AUDIOFOCUS_LOSS -> {
                Log.d("AudioFocusManager", "AUDIOFOCUS_LOSS")
                hasFocus = false
                playbackWasInterrupted = false
                isDucked = false
                try {
                    channel.invokeMethod("onPausePlayback", mapOf("permanent" to true))
                } catch (e: Exception) {
                    Log.e("AudioFocusManager", "Error invoking onPausePlayback", e)
                }
                abandonAudioFocus()
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                Log.d("AudioFocusManager", "AUDIOFOCUS_LOSS_TRANSIENT")
                hasFocus = false
                playbackWasInterrupted = true
                isDucked = false
                try {
                    channel.invokeMethod("onPausePlayback", mapOf("permanent" to false))
                } catch (e: Exception) {
                    Log.e("AudioFocusManager", "Error invoking onPausePlayback", e)
                }
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                Log.d("AudioFocusManager", "AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK")
                if (pauseOnDuck) {
                    playbackWasInterrupted = true
                    try {
                        channel.invokeMethod("onPausePlayback", mapOf("permanent" to false))
                    } catch (e: Exception) {
                        Log.e("AudioFocusManager", "Error invoking onPausePlayback", e)
                    }
                } else {
                    isDucked = true
                    try {
                        channel.invokeMethod("onDuckVolume", null)
                    } catch (e: Exception) {
                        Log.e("AudioFocusManager", "Error invoking onDuckVolume", e)
                    }
                }
            }
        }
    }
}
