import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:looper_player/features/streaming/domain/models/online_track.dart';

class YouTubeStreamService {
  final YoutubeExplode _yt = YoutubeExplode();
  final Map<String, String> _streamCache = {};
  final Map<String, DateTime> _streamCacheTime = {};

  /// Searches YouTube Music for tracks matching [query]
  Future<List<OnlineTrack>> searchTracks(String query, {int limit = 20}) async {
    try {
      final searchResults = await _yt.search
          .search(query)
          .timeout(const Duration(seconds: 8));
      final tracks = <OnlineTrack>[];

      for (final video in searchResults.take(limit)) {
        if (video.duration != null && video.duration!.inSeconds < 10) continue;

        tracks.add(
          OnlineTrack(
            id: video.id.value,
            title: video.title,
            artist: video.author,
            album: 'YouTube Stream',
            thumbnailUrl: video.thumbnails.mediumResUrl,
            highResArtUrl: video.thumbnails.maxResUrl,
            duration: video.duration ?? Duration.zero,
          ),
        );
      }

      return tracks;
    } catch (e) {
      return [];
    }
  }

  /// Fetches popular trending music tracks
  Future<List<OnlineTrack>> getTrendingTracks() async {
    try {
      final searchResults = await _yt.search
          .search('top music hits 2026 trending')
          .timeout(const Duration(seconds: 8));
      final tracks = <OnlineTrack>[];

      for (final video in searchResults.take(25)) {
        if (video.duration != null && video.duration!.inSeconds < 30) continue;

        tracks.add(
          OnlineTrack(
            id: video.id.value,
            title: video.title,
            artist: video.author,
            album: 'Trending Music',
            thumbnailUrl: video.thumbnails.mediumResUrl,
            highResArtUrl: video.thumbnails.maxResUrl,
            duration: video.duration ?? Duration.zero,
          ),
        );
      }

      return tracks;
    } catch (e) {
      return [];
    }
  }

  /// Resolves direct audio stream HTTPS URL for [youtubeId]
  /// [quality]: 0 for Low (128kbps/Opus), 1 for High (256kbps/M4A)
  Future<String?> resolveAudioStreamUrl(String youtubeId, {int quality = 1}) async {
    // Check local memory cache (stream URLs are valid for ~4 hours)
    if (_streamCache.containsKey(youtubeId) &&
        _streamCacheTime.containsKey(youtubeId)) {
      final age = DateTime.now().difference(_streamCacheTime[youtubeId]!);
      if (age.inHours < 3) {
        return _streamCache[youtubeId];
      }
    }

    try {
      final manifest = await _yt.videos.streamsClient
          .getManifest(youtubeId)
          .timeout(const Duration(seconds: 8));
      final audioStreams = manifest.audioOnly;

      if (audioStreams.isEmpty) return null;

      AudioStreamInfo streamInfo;
      if (quality == 1) {
        streamInfo = audioStreams.withHighestBitrate();
      } else {
        streamInfo = audioStreams.first;
      }

      final url = streamInfo.url.toString();
      _streamCache[youtubeId] = url;
      _streamCacheTime[youtubeId] = DateTime.now();

      return url;
    } catch (e) {
      // On network failure or timeout, clear cached YoutubeExplode instance
      return null;
    }
  }

  /// Clean up network resources
  void dispose() {
    _yt.close();
  }
}
