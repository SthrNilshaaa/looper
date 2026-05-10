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
  final String? collectionImageUrl;
  final List<Song> collectionSongs;
  final List<NavigationState> history;

  NavigationState({
    required this.activeItem,
    this.collectionTitle,
    this.collectionSubtitle,
    this.collectionArt,
    this.collectionImageUrl,
    this.collectionSongs = const [],
    this.history = const [],
  });

  NavigationState copyWith({
    NavItem? activeItem,
    String? collectionTitle,
    String? collectionSubtitle,
    String? collectionArt,
    String? collectionImageUrl,
    List<Song>? collectionSongs,
    List<NavigationState>? history,
  }) {
    return NavigationState(
      activeItem: activeItem ?? this.activeItem,
      collectionTitle: collectionTitle ?? this.collectionTitle,
      collectionSubtitle: collectionSubtitle ?? this.collectionSubtitle,
      collectionArt: collectionArt ?? this.collectionArt,
      collectionImageUrl: collectionImageUrl ?? this.collectionImageUrl,
      collectionSongs: collectionSongs ?? this.collectionSongs,
      history: history ?? this.history,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState(activeItem: NavItem.home));

  void setItem(NavItem item) {
    if (state.activeItem == item) return;

    if (item == NavItem.home) {
      state = NavigationState(activeItem: NavItem.home);
      return;
    }

    // Push current state to history
    final newHistory = List<NavigationState>.from(state.history)
      ..add(_captureCurrentState());

    state = state.copyWith(
      activeItem: item,
      history: newHistory,
      // Clear collection data when switching to a main nav item
      collectionTitle: null,
      collectionSubtitle: null,
      collectionArt: null,
      collectionImageUrl: null,
      collectionSongs: [],
    );
  }

  void toggleItem(NavItem item) {
    if (state.activeItem == item) {
      goBack();
    } else {
      setItem(item);
    }
  }

  void showCollection({
    required String title,
    String? subtitle,
    String? art,
    String? imageUrl,
    required List<Song> songs,
  }) {
    // Push current state to history
    final newHistory = List<NavigationState>.from(state.history)
      ..add(_captureCurrentState());

    state = state.copyWith(
      activeItem: NavItem.collectionDetail,
      collectionTitle: title,
      collectionSubtitle: subtitle,
      collectionArt: art,
      collectionImageUrl: imageUrl,
      collectionSongs: songs,
      history: newHistory,
    );
  }

  void goBack() {
    if (state.history.isEmpty) {
      state = NavigationState(activeItem: NavItem.home);
      return;
    }

    final previousState = state.history.last;
    final newHistory = List<NavigationState>.from(state.history)..removeLast();

    state = previousState.copyWith(history: newHistory);
  }

  NavigationState _captureCurrentState() {
    return NavigationState(
      activeItem: state.activeItem,
      collectionTitle: state.collectionTitle,
      collectionSubtitle: state.collectionSubtitle,
      collectionArt: state.collectionArt,
      collectionImageUrl: state.collectionImageUrl,
      collectionSongs: state.collectionSongs,
    );
  }
}

final appNavigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
      return NavigationNotifier();
    });
