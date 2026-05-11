import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yt_flutter_musicapi/yt_flutter_musicapi.dart';
import 'package:yt_flutter_musicapi/models/searchModel.dart';

class YouTubeTrack {
  final String videoId;
  final String title;
  final String artists;
  final String duration;
  final String thumbnailUrl;

  YouTubeTrack({
    required this.videoId,
    required this.title,
    required this.artists,
    required this.duration,
    required this.thumbnailUrl,
  });

  factory YouTubeTrack.fromSearchResult(SearchResult result) {
    return YouTubeTrack(
      videoId: result.videoId,
      title: result.title,
      artists: result.artists,
      duration: result.duration ?? '',
      thumbnailUrl: result.albumArt ?? '',
    );
  }
}

class YouTubeMusicService {
  final YtFlutterMusicapi _ytMusicApi = YtFlutterMusicapi();
  bool _initialized = false;

  Future<void> _init() async {
    if (!_initialized) {
      await _ytMusicApi.initialize(country: 'US');
      _initialized = true;
    }
  }

  Future<List<YouTubeTrack>> searchMusic(String query) async {
    await _init();
    try {
      final response = await _ytMusicApi.searchMusic(
        query: query,
        limit: 10,
        audioQuality: AudioQuality.high,
        thumbQuality: ThumbnailQuality.high,
        includeAudioUrl: true,
        includeAlbumArt: true,
      );

      final tracks = <YouTubeTrack>[];
      if (response.success && response.data != null) {
        for (final result in response.data!) {
          tracks.add(YouTubeTrack.fromSearchResult(result));
        }
      }
      return tracks;
    } catch (e) {
      print('Error searching YouTube Music: $e');
      return [];
    }
  }

  Future<String?> getStreamUrl(String videoId) async {
    await _init();
    try {
      final response = await _ytMusicApi.getAudioUrlFast(videoId: videoId);

      if (response.success && response.data != null) {
        return response.data;
      }

      // Fallback
      final fallbackResponse = await _ytMusicApi.getAudioUrlFlexible(
        videoId: videoId,
        audioQuality: AudioQuality.high,
      );
      if (fallbackResponse.success && fallbackResponse.data != null) {
        return fallbackResponse.data!.audioUrl;
      }

      return null;
    } catch (e) {
      print('Error getting stream URL: $e');
      return null;
    }
  }
}

final youtubeMusicServiceProvider = Provider((ref) => YouTubeMusicService());
