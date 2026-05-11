import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:media_kit/media_kit.dart';
import 'package:dbus/dbus.dart';
import 'mpris.dart';

class AudioService {
  late final Player player;
  MPRISPlayer? _mprisPlayer;
  DBusClient? _dBusClient;

  // Callbacks for MPRIS controls
  void Function()? onNext;
  void Function()? onPrevious;

  AudioService() {
    player = Player(
      configuration: const PlayerConfiguration(
        title: 'Looper Player',
        logLevel: MPVLogLevel.debug,
      ),
    );
    
    // Log errors for debugging
    player.stream.error.listen((error) {
      debugPrint('MediaKit Player Error: $error');
    });

    _initMpris();
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
    final headers = path.contains('youtube.com') || path.contains('googlevideo.com')
        ? {
            'User-Agent':
                'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
            'Referer': metadata?['videoId'] != null
                ? 'https://www.youtube.com/watch?v=${metadata!['videoId']}'
                : 'https://www.youtube.com/',
            'Origin': 'https://www.youtube.com',
            'Accept': '*/*',
            'Range': 'bytes=0-',
          }
        : {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
          };

    await player.open(Media(path, extras: extras, httpHeaders: headers));
    await player.play();

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
