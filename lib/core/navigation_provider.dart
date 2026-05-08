import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/library/domain/models/models.dart';

enum NavItem {
  home,
  songs,
  albums,
  artists,
  playlists,
  search,
  favorites,
  recentlyPlayed,
  lyrics,
  settings,
  collectionDetail,
  queue,
}

class NavigationState {
  final NavItem activeItem;
  final String? collectionTitle;
  final String? collectionSubtitle;
  final String? collectionArt;
  final List<Song> collectionSongs;

  NavigationState({
    required this.activeItem,
    this.collectionTitle,
    this.collectionSubtitle,
    this.collectionArt,
    this.collectionSongs = const [],
  });

  NavigationState copyWith({
    NavItem? activeItem,
    String? collectionTitle,
    String? collectionSubtitle,
    String? collectionArt,
    List<Song>? collectionSongs,
  }) {
    return NavigationState(
      activeItem: activeItem ?? this.activeItem,
      collectionTitle: collectionTitle ?? this.collectionTitle,
      collectionSubtitle: collectionSubtitle ?? this.collectionSubtitle,
      collectionArt: collectionArt ?? this.collectionArt,
      collectionSongs: collectionSongs ?? this.collectionSongs,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState(activeItem: NavItem.home));

  void setItem(NavItem item) {
    state = state.copyWith(activeItem: item);
  }

  void toggleItem(NavItem item) {
    if (state.activeItem == item) {
      state = state.copyWith(activeItem: NavItem.home);
    } else {
      state = state.copyWith(activeItem: item);
    }
  }

  void showCollection({
    required String title,
    String? subtitle,
    String? art,
    required List<Song> songs,
  }) {
    state = state.copyWith(
      activeItem: NavItem.collectionDetail,
      collectionTitle: title,
      collectionSubtitle: subtitle,
      collectionArt: art,
      collectionSongs: songs,
    );
  }
}

final appNavigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
      return NavigationNotifier();
    });
