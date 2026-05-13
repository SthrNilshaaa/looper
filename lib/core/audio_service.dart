import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:media_kit/media_kit.dart';
import 'package:dbus/dbus.dart';
import 'mpris.dart';
import 'package:audio_service/audio_service.dart' as asrv;
import 'audio_handler.dart';

class AudioService {
  late final Player player;
  MPRISPlayer? _mprisPlayer;
  DBusClient? _dBusClient;
  MyAudioHandler? _audioHandler;

  // Callbacks for MPRIS controls
  void Function()? onNext;
  void Function()? onPrevious;

  AudioService() {
    player = Player(
      configuration: const PlayerConfiguration(title: 'Looper Player'),
    );
    _initMpris();
    _initAndroidAudioHandler();
  }

  Future<void> _initAndroidAudioHandler() async {
    if (!Platform.isAndroid) return;

    try {
      _audioHandler = await asrv.AudioService.init(
        builder: () => MyAudioHandler(player),
        config: const asrv.AudioServiceConfig(
          androidNotificationChannelId:
              'com.example.looper_player.channel.audio',
          androidNotificationChannelName: 'Audio Playback',
          androidNotificationOngoing: true,
        ),
      );

      _audioHandler?.onNext = () {
        if (onNext != null) onNext!();
      };

      _audioHandler?.onPrevious = () {
        if (onPrevious != null) onPrevious!();
      };
    } catch (e) {
      debugPrint('Failed to init audio handler: $e');
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
    await player.pause();
  }

  Future<void> resume() async {
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
  }

  void dispose() {
    player.dispose();
    _dBusClient?.close();
  }
}
