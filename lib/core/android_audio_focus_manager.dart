import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'logger_helper.dart';

final androidAudioFocusManagerProvider = Provider<AndroidAudioFocusManager>((ref) {
  return AndroidAudioFocusManager(ref);
});

class AndroidAudioFocusManager {
  final Ref _ref;
  static const _channel = MethodChannel('com.looper.player/audio_focus');

  AndroidAudioFocusManager(this._ref) {
    if (Platform.isAndroid) {
      _channel.setMethodCallHandler(_handleMethodCall);
      _syncSettings();
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    final playback = _ref.read(playbackProvider.notifier);
    final settings = _ref.read(settingsProvider);

    switch (call.method) {
      case 'onPausePlayback':
        final bool permanent = call.arguments?['permanent'] ?? false;
        LoggerHelper.write('AndroidAudioFocusManager: onPausePlayback (permanent: $permanent)');
        playback.pauseForInterruption(permanent: permanent);
        break;

      case 'onResumePlayback':
        LoggerHelper.write('AndroidAudioFocusManager: onResumePlayback');
        playback.resumeAfterInterruption();
        break;

      case 'onDuckVolume':
        LoggerHelper.write('AndroidAudioFocusManager: onDuckVolume');
        playback.duckVolume();
        break;

      case 'onRestoreVolume':
        LoggerHelper.write('AndroidAudioFocusManager: onRestoreVolume');
        playback.restoreVolume();
        break;

      case 'onBecomingNoisy':
        LoggerHelper.write('AndroidAudioFocusManager: onBecomingNoisy');
        playback.pauseForNoisy();
        break;

      case 'onBluetoothConnected':
        LoggerHelper.write('AndroidAudioFocusManager: onBluetoothConnected');
        if (settings.resumeOnBluetoothConnect) {
          playback.resumeOnBluetoothConnect();
        }
        break;
    }
  }

  Future<void> syncSettings() async {
    if (!Platform.isAndroid) return;
    await _syncSettings();
  }

  Future<void> _syncSettings() async {
    final settings = _ref.read(settingsProvider);
    try {
      await _channel.invokeMethod('syncSettings', {
        'enabled': settings.audioFocus,
        'pauseOnDuck': settings.pauseOnDuck,
        'resumeOnBluetoothConnect': settings.resumeOnBluetoothConnect,
      });
    } catch (e) {
      LoggerHelper.write('AndroidAudioFocusManager: Error syncing settings: $e');
    }
  }

  Future<bool> requestAudioFocus() async {
    if (!Platform.isAndroid) return true;
    try {
      final bool? granted = await _channel.invokeMethod<bool>('requestAudioFocus');
      return granted ?? true;
    } catch (e) {
      LoggerHelper.write('AndroidAudioFocusManager: Error requesting audio focus: $e');
      return true;
    }
  }

  Future<void> abandonAudioFocus() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('abandonAudioFocus');
    } catch (e) {
      LoggerHelper.write('AndroidAudioFocusManager: Error abandoning audio focus: $e');
    }
  }

  Future<void> setPlaybackInterrupted(bool interrupted) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('setPlaybackInterrupted', {
        'interrupted': interrupted,
      });
    } catch (e) {
      LoggerHelper.write('AndroidAudioFocusManager: Error setting playback interrupted: $e');
    }
  }
}
