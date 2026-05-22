import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:media_kit/media_kit.dart';
import 'package:dbus/dbus.dart';
import 'mpris.dart';
import 'package:audio_service/audio_service.dart' as asrv;
import 'package:audio_session/audio_session.dart' as asrv_sess;
import 'audio_handler.dart';
import 'db_service.dart';
import 'package:looper_player/features/library/domain/models/models.dart';

class AudioService {
  late final Player player;
  MPRISPlayer? _mprisPlayer;
  DBusClient? _dBusClient;
  MyAudioHandler? _audioHandler;
  bool _playOnInterruptionEnd = false;

  // Callbacks for controls
  void Function()? onNext;
  void Function()? onPrevious;
  void Function(Duration)? onSeek;
  void Function()? onFavoriteToggle;
  void Function()? onShuffleToggle;

  AudioService() {
    player = Player(
      configuration: const PlayerConfiguration(
        title: 'Looper Player',
      ),
    );
    // Set high-precision position updates for lyrics sync (15ms)
    if (Platform.isAndroid || Platform.isIOS || Platform.isLinux || Platform.isWindows) {
      try {
        // Using dynamic as some versions of media_kit don't expose setProperty in the interface
        (player as dynamic).setProperty('playback-time-update-interval', '0.015');
      } catch (e) {
        debugPrint('Failed to set playback-time-update-interval: $e');
      }
    }
    _initMpris();
    _initAndroidAudioHandler();
    _initAndroidBroadcasts();
    _initAudioSession();
  }

  void _initAndroidBroadcasts() {
    if (!Platform.isAndroid) return;

    player.stream.playing.listen((playing) {
      _sendAndroidBroadcast(playing);
    });

    player.stream.playlist.listen((_) {
      _sendAndroidBroadcast(player.state.playing);
    });
  }

  void _sendAndroidBroadcast(bool isPlaying) {
    if (!Platform.isAndroid) return;

    final media = player.state.playlist.medias.isNotEmpty &&
            player.state.playlist.index >= 0 &&
            player.state.playlist.index < player.state.playlist.medias.length
        ? player.state.playlist.medias[player.state.playlist.index]
        : null;

    if (media != null && media.extras != null) {
      const channel = MethodChannel('com.looper.player/broadcast');
      channel.invokeMethod('broadcastMetadata', {
        'title': media.extras!['title'],
        'artist': media.extras!['artist'],
        'album': media.extras!['album'],
        'duration': player.state.duration.inMilliseconds,
        'isPlaying': isPlaying,
      });
    }
  }

  Future<void> _initAndroidAudioHandler() async {
    if (!Platform.isAndroid) return;

    try {
      _audioHandler = await asrv.AudioService.init(
        builder: () => MyAudioHandler(player),
        config: const asrv.AudioServiceConfig(
          androidNotificationChannelId:
              'com.looper.player.channel.audio.v3',
          androidNotificationChannelName: 'Audio Playback',
          androidNotificationOngoing: true,
          androidNotificationIcon: 'drawable/ic_notification_session',
        ),
      );

      _audioHandler?.onNext = () {
        if (onNext != null) onNext!();
      };

      _audioHandler?.onPrevious = () {
        if (onPrevious != null) onPrevious!();
      };

      _audioHandler?.onSeek = (duration) {
        if (onSeek != null) onSeek!(duration);
      };

      _audioHandler?.onFavoriteToggle = () {
        if (onFavoriteToggle != null) onFavoriteToggle!();
      };

      _audioHandler?.onShuffleToggle = () {
        if (onShuffleToggle != null) onShuffleToggle!();
      };

      _audioHandler?.onPlay = () {
        resume();
      };

      _audioHandler?.onPause = () {
        pause();
      };
    } catch (e) {
      debugPrint('Failed to init audio handler: $e');
    }
  }

  Future<void> _initAudioSession() async {
    if (!Platform.isAndroid) return;
    try {
      final session = await asrv_sess.AudioSession.instance;
      await session.configure(const asrv_sess.AudioSessionConfiguration.music());

      session.interruptionEventStream.listen((event) {
        debugPrint('🎵 AudioSession: Interruption event received: begin=${event.begin}, type=${event.type}');
        _handleAudioInterruption(event);
      });

      session.becomingNoisyEventStream.listen((_) async {
        debugPrint('🎵 AudioSession: Becoming noisy (headphones unplugged). Pausing...');
        try {
          final settings = await DbService.isar.appSettings.get(0);
          if (settings == null || !settings.audioFocus) return;
          await pause();
        } catch (e) {
          debugPrint('Error handling noisy event: $e');
        }
      });
    } catch (e) {
      debugPrint('Failed to initialize AudioSession: $e');
    }
  }

  Future<void> _handleAudioInterruption(asrv_sess.AudioInterruptionEvent event) async {
    try {
      final settings = await DbService.isar.appSettings.get(0);
      if (settings == null || !settings.audioFocus) return;

      if (event.begin) {
        switch (event.type) {
          case asrv_sess.AudioInterruptionType.duck:
            player.setVolume(player.state.volume * 0.2);
            break;
          case asrv_sess.AudioInterruptionType.pause:
          case asrv_sess.AudioInterruptionType.unknown:
            if (player.state.playing) {
              _playOnInterruptionEnd = true;
              debugPrint('🎵 AudioSession: Interruption began. Will auto-resume on finish.');
            } else {
              _playOnInterruptionEnd = false;
            }
            await player.pause();
            break;
        }
      } else {
        switch (event.type) {
          case asrv_sess.AudioInterruptionType.duck:
            player.setVolume(settings.volume * 100);
            break;
          case asrv_sess.AudioInterruptionType.pause:
          case asrv_sess.AudioInterruptionType.unknown:
            if (_playOnInterruptionEnd) {
              _playOnInterruptionEnd = false;
              debugPrint('🎵 AudioSession: Interruption ended. Auto-resuming playback...');
              await resume();
            }
            break;
        }
      }
    } catch (e) {
      debugPrint('Error handling audio interruption: $e');
    }
  }

  Future<bool> _requestAudioFocus() async {
    try {
      final settings = await DbService.isar.appSettings.get(0);
      if (settings == null || !settings.audioFocus) return true;

      final session = await asrv_sess.AudioSession.instance;
      final success = await session.setActive(true);
      if (!success) {
        debugPrint('Audio focus request denied (e.g., active call).');
      }
      return success;
    } catch (e) {
      debugPrint('Error requesting audio focus: $e');
      return true;
    }
  }

  void updatePlaybackState({
    required bool isPlaying,
    required bool isFavorite,
    required bool isShuffle,
  }) {
    if (Platform.isAndroid && _audioHandler != null) {
      _audioHandler!.updateControls(
        isPlaying: isPlaying,
        isFavorite: isFavorite,
        isShuffle: isShuffle,
      );
    }
  }

  Future<void> _initMpris() async {
    if (!Platform.isLinux) return;
    try {
      _dBusClient = DBusClient.session();
      _mprisPlayer = MPRISPlayer();

      _mprisPlayer!.onPlay = () => player.play();
      _mprisPlayer!.onPause = () => player.pause();
      _mprisPlayer!.onPlayPause = () => player.playOrPause();
      _mprisPlayer!.onSeek = (offset) {
        final current = player.state.position;
        player.seek(current + Duration(microseconds: offset));
      };
      _mprisPlayer!.onNext = () {
        if (onNext != null) onNext!();
      };
      _mprisPlayer!.onPrevious = () {
        if (onPrevious != null) onPrevious!();
      };

      await _dBusClient!.requestName('org.mpris.MediaPlayer2.looper_player');
      await _dBusClient!.registerObject(_mprisPlayer!);

      // Set initial status
      _mprisPlayer!.updatePlaybackStatus(
        player.state.playing ? 'Playing' : 'Paused',
      );

      player.stream.playing.listen((playing) {
        _mprisPlayer!.updatePlaybackStatus(playing ? 'Playing' : 'Paused');
      });

      player.stream.position.listen((position) {
        _mprisPlayer!.position = position.inMicroseconds;
      });

      player.stream.duration.listen((duration) {
        _updateMprisMetadata(player.state.playlist.index);
      });
    } catch (e) {
      debugPrint('Failed to initialize MPRIS: $e');
    }
  }

  void _updateMprisMetadata(int index) {
    if (_mprisPlayer == null) return;

    // We update metadata when song changes or duration is loaded
    try {
      final currentMedia =
          player.state.playlist.medias.isNotEmpty &&
              index >= 0 &&
              index < player.state.playlist.medias.length
          ? player.state.playlist.medias[index]
          : null;

      if (currentMedia != null && currentMedia.extras != null) {
        final extras = currentMedia.extras!;
        final mprisMetadata = <String, DBusValue>{};
        final trackId =
            '/org/mpris/MediaPlayer2/Track/${currentMedia.uri.hashCode.abs()}';
        mprisMetadata['mpris:trackid'] = DBusObjectPath(trackId);

        if (extras['title'] != null) {
          mprisMetadata['xesam:title'] = DBusString(extras['title'].toString());
        }
        if (extras['artist'] != null) {
          mprisMetadata['xesam:artist'] = DBusArray.string([
            extras['artist'].toString(),
          ]);
        }
        if (extras['album'] != null) {
          mprisMetadata['xesam:album'] = DBusString(extras['album'].toString());
        }
        if (extras['artPath'] != null) {
          mprisMetadata['mpris:artUrl'] = DBusString(
            'file://${extras['artPath']}',
          );
        }

        // Use player duration if available, otherwise fallback to metadata
        final duration = player.state.duration;
        if (duration.inMilliseconds > 0) {
          mprisMetadata['mpris:length'] = DBusInt64(duration.inMicroseconds);
        } else if (extras['duration'] != null) {
          final durationMs = int.tryParse(extras['duration'].toString()) ?? 0;
          if (durationMs > 0) {
            mprisMetadata['mpris:length'] = DBusInt64(durationMs * 1000);
          }
        }

        _mprisPlayer!.updateMetadata(mprisMetadata);
      }
    } catch (e) {
      debugPrint('Error updating MPRIS metadata: $e');
    }
  }

  Future<void> play(String path, {Map<String, dynamic>? metadata}) async {
    _playOnInterruptionEnd = false; // Reset auto-resume on fresh manual play
    if (Platform.isAndroid) {
      _requestAudioFocus(); // Request focus, but don't let transient delay block the user
    }

    final extras = metadata?.map((k, v) => MapEntry(k, v.toString()));
    await player.open(Media(path, extras: extras));

    if (Platform.isAndroid && _audioHandler != null && metadata != null) {
      final item = asrv.MediaItem(
        id: path,
        album: metadata['album']?.toString(),
        title: metadata['title']?.toString() ?? 'Unknown Title',
        artist: metadata['artist']?.toString(),
        duration: metadata['duration'] != null
            ? Duration(
                milliseconds:
                    int.tryParse(metadata['duration'].toString()) ?? 0,
              )
            : null,
        artUri: metadata['artPath'] != null
            ? Uri.file(metadata['artPath'])
            : null,
      );
      _audioHandler?.updateMediaItem(item);
    }

    if (_mprisPlayer != null && metadata != null) {
      final mprisMetadata = <String, DBusValue>{};
      // Use a proper track ID instead of NoTrack to help some shells
      final trackId = '/org/mpris/MediaPlayer2/Track/${path.hashCode.abs()}';
      mprisMetadata['mpris:trackid'] = DBusObjectPath(trackId);

      if (metadata['title'] != null) {
        mprisMetadata['xesam:title'] = DBusString(metadata['title'].toString());
      }
      if (metadata['artist'] != null) {
        mprisMetadata['xesam:artist'] = DBusArray.string([
          metadata['artist'].toString(),
        ]);
      }
      if (metadata['album'] != null) {
        mprisMetadata['xesam:album'] = DBusString(metadata['album'].toString());
      }
      if (metadata['artPath'] != null) {
        mprisMetadata['mpris:artUrl'] = DBusString(
          'file://${metadata['artPath']}',
        );
      }
      if (metadata['duration'] != null) {
        final durationMs = int.tryParse(metadata['duration'].toString()) ?? 0;
        if (durationMs > 0) {
          mprisMetadata['mpris:length'] = DBusInt64(durationMs * 1000);
        }
      }

      await _mprisPlayer!.updateMetadata(mprisMetadata);
    }
  }

  Future<void> pause() async {
    _playOnInterruptionEnd = false; // User manually paused! Reset auto-resume
    await player.pause();
    if (Platform.isAndroid) {
      try {
        final session = await asrv_sess.AudioSession.instance;
        await session.setActive(false);
      } catch (e) {
        debugPrint('Error deactivating audio session: $e');
      }
    }
  }

  Future<void> resume() async {
    _playOnInterruptionEnd = false; // Reset auto-resume on manual resume
    if (Platform.isAndroid) {
      _requestAudioFocus(); // Request focus, but don't let transient delay block the user
    }
    await player.play();
  }

  Future<void> seek(Duration duration) async {
    await player.seek(duration);
  }

  Future<void> stop() async {
    await player.stop();
    if (_mprisPlayer != null) {
      _mprisPlayer!.updatePlaybackStatus('Stopped');
    }
    if (Platform.isAndroid) {
      try {
        final session = await asrv_sess.AudioSession.instance;
        await session.setActive(false);
      } catch (e) {
        debugPrint('Error deactivating audio session: $e');
      }
    }
  }

  void dispose() {
    player.dispose();
    _dBusClient?.close();
  }
}
