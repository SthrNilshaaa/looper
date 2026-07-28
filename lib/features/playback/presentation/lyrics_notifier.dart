import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import '../data/lyrics_fetcher.dart';
import '../domain/lyric_models.dart';

class LyricsState {
  final String? rawLrc;
  final bool isLoading;
  final int? songId;
  final List<LyricLine> parsedLines;
  final String? source;

  LyricsState({
    this.rawLrc,
    this.isLoading = false,
    this.songId,
    this.parsedLines = const [],
    this.source,
  });

  LyricsState copyWith({
    String? rawLrc,
    bool? isLoading,
    int? songId,
    List<LyricLine>? parsedLines,
    String? source,
  }) {
    return LyricsState(
      rawLrc: rawLrc ?? this.rawLrc,
      isLoading: isLoading ?? this.isLoading,
      songId: songId ?? this.songId,
      parsedLines: parsedLines ?? this.parsedLines,
      source: source ?? this.source,
    );
  }
}

class LyricsNotifier extends StateNotifier<LyricsState> {
  final Ref ref;

  LyricsNotifier(this.ref) : super(LyricsState());

  void fetchForSong(Song song, {bool force = false}) {
    _fetchLyrics(song, force: force);
  }

  Future<void> _fetchLyrics(Song song, {bool force = false}) async {
    if (!force && state.songId == song.id && state.rawLrc != null) return;

    state = LyricsState(
      isLoading: true,
      songId: song.id,
      rawLrc: null,
      parsedLines: [],
      source: null,
    );

    final lrc = await LyricsFetcher.fetchLyrics(song);

    if (state.songId == song.id) {
      String? source;
      String cleanLrc = lrc ?? '';
      if (lrc != null && lrc.startsWith('[source:')) {
        final sourceMatch = RegExp(r'^\[source:(.*)\]').firstMatch(lrc);
        if (sourceMatch != null) {
          source = sourceMatch.group(1);
          cleanLrc = lrc.replaceFirst(RegExp(r'^\[source:.*\]\n?'), '');
        }
      }

      final lines = lrc != null
          ? LrcParser.parse(cleanLrc, Duration(milliseconds: song.duration ?? 0))
          : <LyricLine>[];
      state = state.copyWith(rawLrc: cleanLrc, isLoading: false, parsedLines: lines, source: source);
    }
  }
}

final lyricsProvider = StateNotifierProvider<LyricsNotifier, LyricsState>((
  ref,
) {
  return LyricsNotifier(ref);
});

final lyricsManualScrollProvider = StateProvider<bool>((ref) => false);
