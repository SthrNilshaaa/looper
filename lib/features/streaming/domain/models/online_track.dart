import 'package:looper_player/features/library/domain/models/models.dart';

class OnlineTrack {
  final String id; // YouTube video/track ID or URI
  final String title;
  final String artist;
  final String album;
  final String thumbnailUrl;
  final String? highResArtUrl;
  final Duration duration;
  final String? streamUrl;
  final int bitrate; // in kbps (e.g., 128, 256)
  final String audioFormat; // opus, m4a, mp3
  final bool isLiveStream;

  const OnlineTrack({
    required this.id,
    required this.title,
    required this.artist,
    this.album = 'YouTube Music',
    required this.thumbnailUrl,
    this.highResArtUrl,
    required this.duration,
    this.streamUrl,
    this.bitrate = 256,
    this.audioFormat = 'm4a',
    this.isLiveStream = false,
  });

  /// Converts an OnlineTrack into the application's standard [Song] entity for queueing & playback
  Song toSong({String? resolvedStreamUrl}) {
    final song = Song();
    // Unique negative/hash ID or path for Isar identification
    song.path = 'https://youtube.com/watch?v=$id';
    song.title = title;
    song.artist = artist;
    song.album = album;
    song.duration = duration.inMilliseconds;
    song.artPath = highResArtUrl ?? thumbnailUrl;
    song.dateAdded = DateTime.now();
    
    // SpatialFlow Online Streaming properties
    song.isOnlineStream = true;
    song.streamUrl = resolvedStreamUrl ?? streamUrl;
    song.youtubeId = id;
    song.onlineArtUrl = highResArtUrl ?? thumbnailUrl;
    song.streamQuality = bitrate >= 250 ? 1 : 0;
    
    return song;
  }

  factory OnlineTrack.fromMap(Map<String, dynamic> map) {
    return OnlineTrack(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Unknown Track',
      artist: map['artist'] ?? 'Unknown Artist',
      album: map['album'] ?? 'YouTube Music',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      highResArtUrl: map['highResArtUrl'],
      duration: Duration(milliseconds: map['durationMs'] ?? 0),
      streamUrl: map['streamUrl'],
      bitrate: map['bitrate'] ?? 256,
      audioFormat: map['audioFormat'] ?? 'm4a',
      isLiveStream: map['isLiveStream'] ?? false,
    );
  }
}
