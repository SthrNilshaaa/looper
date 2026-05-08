import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/lyrics_service.dart';
import 'playback_notifier.dart';
import '../domain/lyric_models.dart';

class LyricsState {
  final String? rawLrc;
  final bool isLoading;
  final int? songId;
  final List<LyricLine> parsedLines;

  LyricsState({
    this.rawLrc,
    this.isLoading = false,
    this.songId,
    this.parsedLines = const [],
  });

  LyricsState copyWith({
    String? rawLrc,
    bool? isLoading,
    int? songId,
    List<LyricLine>? parsedLines,
  }) {
    return LyricsState(
      rawLrc: rawLrc ?? this.rawLrc,
      isLoading: isLoading ?? this.isLoading,
      songId: songId ?? this.songId,
      parsedLines: parsedLines ?? this.parsedLines,
    );
  }
}

class LyricsNotifier extends StateNotifier<LyricsState> {
  final Ref ref;
  final LyricsService _service = LyricsService();

  LyricsNotifier(this.ref) : super(LyricsState()) {
    // Listen to current song changes
    ref.listen(playbackProvider.select((s) => s.currentSong), (previous, next) {
      if (next != null && next.id != state.songId) {
        _fetchLyrics(next);
      }
    });
  }

  Future<void> _fetchLyrics(dynamic song) async {
    // Check if already in cache (simple in-memory cache for now)
    if (state.songId == song.id && state.rawLrc != null) return;

    state = state.copyWith(
      isLoading: true,
      songId: song.id,
      rawLrc: null,
      parsedLines: [],
    );

    final response = await _service.getLyrics(
      trackName: song.title.trim(),
      artistName: (song.artist ?? '').trim(),
      albumName: (song.album ?? '').trim(),
      durationSeconds: (song.duration ?? 0) ~/ 1000,
    );

    // Only update if we're still on the same song
    if (state.songId == song.id) {
      final lrc = response?.syncedLyrics ?? response?.plainLyrics;
      final lines = lrc != null
          ? LrcParser.parse(lrc, Duration(milliseconds: song.duration ?? 0))
          : <LyricLine>[];
      state = state.copyWith(rawLrc: lrc, isLoading: false, parsedLines: lines);
    }
  }
}

final lyricsProvider = StateNotifierProvider<LyricsNotifier, LyricsState>((
  ref,
) {
  return LyricsNotifier(ref);
});
