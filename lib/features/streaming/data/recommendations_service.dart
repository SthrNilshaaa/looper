import 'dart:math';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/streaming/data/youtube_stream_service.dart';
import 'package:looper_player/features/streaming/domain/models/online_track.dart';

class RecommendationsService {
  final YouTubeStreamService _streamService = YouTubeStreamService();

  /// Calculates SpatialFlow Track Score for local library tracks
  double calculateTrackScore(Song song) {
    final playCountScore = min(song.playCount / 50.0, 1.0) * 0.35;
    
    final daysSincePlayed = song.lastPlayed != null
        ? DateTime.now().difference(song.lastPlayed!).inDays
        : 30;
    final recencyScore = (1.0 / (daysSincePlayed + 1)) * 0.30;
    
    final favoriteScore = (song.isFavorite ? 1.0 : 0.0) * 0.20;
    
    return playCountScore + recencyScore + favoriteScore;
  }

  /// Ranks local tracks by SpatialFlow recommendation score
  List<Song> getQuickPicks(List<Song> allSongs, {int limit = 15}) {
    if (allSongs.isEmpty) return [];

    final sorted = List<Song>.from(allSongs)
      ..sort((a, b) => calculateTrackScore(b).compareTo(calculateTrackScore(a)));

    return sorted.take(limit).toList();
  }

  /// Fetches related online tracks for currently playing song
  Future<List<OnlineTrack>> getRelatedTracks(Song currentSong) async {
    final query = '${currentSong.title} ${currentSong.artist ?? ""} related audio';
    return await _streamService.searchTracks(query, limit: 12);
  }
}
