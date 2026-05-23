import 'dart:io';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import '../data/lyrics_fetcher.dart';
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

  LyricsNotifier(this.ref) : super(LyricsState()) {
    final currentSong = ref.read(playbackProvider).currentSong;
    if (currentSong != null) {
      _fetchLyrics(currentSong);
    }

    ref.listen(playbackProvider.select((s) => s.currentSong), (previous, next) {
      if (next != null && next.id != state.songId) {
        _fetchLyrics(next);
      }
    });
  }

  Future<void> _fetchLyrics(Song song) async {
    if (state.songId == song.id && state.rawLrc != null) return;

    state = state.copyWith(
      isLoading: true,
      songId: song.id,
      rawLrc: null,
      parsedLines: [],
    );

    final lrc = await LyricsFetcher.fetchLyrics(song);

    if (state.songId == song.id) {
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
