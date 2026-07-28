import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/features/streaming/data/youtube_stream_service.dart';
import 'package:looper_player/features/streaming/domain/models/online_track.dart';

class StreamingState {
  final List<OnlineTrack> searchResults;
  final List<OnlineTrack> trendingTracks;
  final bool isLoadingSearch;
  final bool isLoadingTrending;
  final String searchQuery;
  final String? activeResolvingId;

  const StreamingState({
    this.searchResults = const [],
    this.trendingTracks = const [],
    this.isLoadingSearch = false,
    this.isLoadingTrending = false,
    this.searchQuery = '',
    this.activeResolvingId,
  });

  StreamingState copyWith({
    List<OnlineTrack>? searchResults,
    List<OnlineTrack>? trendingTracks,
    bool? isLoadingSearch,
    bool? isLoadingTrending,
    String? searchQuery,
    String? activeResolvingId,
  }) {
    return StreamingState(
      searchResults: searchResults ?? this.searchResults,
      trendingTracks: trendingTracks ?? this.trendingTracks,
      isLoadingSearch: isLoadingSearch ?? this.isLoadingSearch,
      isLoadingTrending: isLoadingTrending ?? this.isLoadingTrending,
      searchQuery: searchQuery ?? this.searchQuery,
      activeResolvingId: activeResolvingId,
    );
  }
}

class StreamingNotifier extends StateNotifier<StreamingState> {
  final Ref ref;
  final YouTubeStreamService _streamService = YouTubeStreamService();

  StreamingNotifier(this.ref) : super(const StreamingState()) {
    _init();
  }

  void _init() {
    fetchTrending();
  }

  /// Current active mode derived from AppSettings
  PlaybackMode get currentMode {
    final settings = ref.read(settingsProvider);
    return PlaybackMode.values[settings.playbackModeIndex.clamp(0, 2)];
  }

  /// Sets operational mode (0: hybrid, 1: localOnly, 2: onlineOnly)
  void setPlaybackMode(PlaybackMode mode) {
    ref.read(settingsProvider.notifier).updatePlaybackMode(mode.index);
  }

  /// Search online tracks
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: [], searchQuery: '');
      return;
    }

    state = state.copyWith(isLoadingSearch: true, searchQuery: query);

    final results = await _streamService.searchTracks(query);
    state = state.copyWith(
      searchResults: results,
      isLoadingSearch: false,
    );
  }

  /// Load trending songs
  Future<void> fetchTrending() async {
    state = state.copyWith(isLoadingTrending: true);
    final trending = await _streamService.getTrendingTracks();
    state = state.copyWith(
      trendingTracks: trending,
      isLoadingTrending: false,
    );
  }

  /// Resolve stream link for [track] and return a playable [Song] entity
  Future<Song?> resolveAndCreateSong(OnlineTrack track) async {
    state = state.copyWith(activeResolvingId: track.id);

    final settings = ref.read(settingsProvider);
    final streamUrl = await _streamService.resolveAudioStreamUrl(
      track.id,
      quality: settings.streamingQuality,
    );

    state = state.copyWith(activeResolvingId: null);

    if (streamUrl == null) return null;

    return track.toSong(resolvedStreamUrl: streamUrl);
  }

  @override
  void dispose() {
    _streamService.dispose();
    super.dispose();
  }
}

final streamingProvider = StateNotifierProvider<StreamingNotifier, StreamingState>(
  (ref) => StreamingNotifier(ref),
);
