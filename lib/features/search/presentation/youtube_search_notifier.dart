import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/search/data/youtube_music_service.dart';
import 'package:looper_player/features/search/presentation/search_view.dart';

class YouTubeSearchNotifier
    extends StateNotifier<AsyncValue<List<YouTubeTrack>>> {
  final Ref _ref;

  YouTubeSearchNotifier(this._ref) : super(const AsyncValue.data([])) {
    _ref.listen<String>(searchQueryProvider, (previous, next) {
      if (next.isNotEmpty) {
        search(next);
      } else {
        state = const AsyncValue.data([]);
      }
    });
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(youtubeMusicServiceProvider);
      final results = await service.searchMusic(query);
      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final youtubeSearchResultsProvider =
    StateNotifierProvider<
      YouTubeSearchNotifier,
      AsyncValue<List<YouTubeTrack>>
    >((ref) {
      return YouTubeSearchNotifier(ref);
    });
