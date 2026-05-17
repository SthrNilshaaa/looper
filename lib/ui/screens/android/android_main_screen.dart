import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/core/app_icons.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_view.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_music_bar.dart';
import 'package:looper_player/ui/screens/home_screen.dart';
import 'package:looper_player/ui/screens/welcome_screen.dart';
import 'package:looper_player/ui/widgets/collection_detail_view.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'android_home_tab.dart';
import 'android_search_tab.dart';
import 'android_library_tab.dart';
import 'android_expanded_player.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'widgets/premium_navbar.dart';
import 'views/library_categories_views.dart';
import 'package:looper_player/features/library/presentation/smart_views.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:animations/animations.dart';

final androidNavigatorKeyProvider = Provider(
  (ref) => GlobalKey<NavigatorState>(),
);

class AndroidMainScreen extends ConsumerStatefulWidget {
  const AndroidMainScreen({super.key});

  @override
  ConsumerState<AndroidMainScreen> createState() => _AndroidMainScreenState();
}

class _AndroidMainScreenState extends ConsumerState<AndroidMainScreen> {
  DateTime? _lastBackPressTime;

  final List<Widget> _tabs = [
    const AndroidHomeTab(),
    Consumer(
      builder: (context, ref, _) {
        final library = ref.watch(libraryProvider);
        final settings = ref.watch(settingsProvider);
        return library.songs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppIcons.songs,
                      width: 64,
                      height: 64,
                      colorFilter: const ColorFilter.mode(
                        Colors.white24,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No songs found',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(libraryProvider.notifier).scanSavedFolders();
                      },
                      icon: SvgPicture.asset(
                        AppIcons.search,
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: const Text('Scan for Music'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Scaffold(
                backgroundColor: settings.enableDynamicTheming
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.surface,
                body: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Text(
                          'All Songs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: SongsList(songs: library.songs)),
                    ],
                  ),
                ),
              );
      },
    ),
    const AndroidLibraryTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final playback = ref.watch(playbackProvider);
    final song = playback.currentSong;
    final nav = ref.watch(appNavigationProvider);
    final activeItem = nav.activeItem;
    final navigatorKey = ref.read(androidNavigatorKeyProvider);

    // Handle Sub-view Navigation via Navigator (to enable Hero)
    ref.listen(appNavigationProvider, (previous, next) {
      if (next.activeItem == NavItem.home) {
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
      } else if (next.activeItem == NavItem.songs) {
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
      } else if (next.activeItem == NavItem.playlists) {
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
      } else if (next.activeItem == NavItem.collectionDetail &&
          next.collectionTitle != null &&
          previous?.collectionTitle != next.collectionTitle) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            CollectionDetailView(
              title: next.collectionTitle!,
              subtitle: next.collectionSubtitle,
              artPath: next.collectionArt,
              imageUrl: next.collectionImageUrl,
              songs: next.collectionSongs,
            ),
          ),
        );
      } else if (next.activeItem == NavItem.search &&
          previous?.activeItem != NavItem.search) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(const AndroidSearchTab()),
        );
      } else if (next.activeItem == NavItem.settings &&
          previous?.activeItem != NavItem.settings) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(const SettingsView()),
        );
      } else if (next.activeItem == NavItem.favorites &&
          previous?.activeItem != NavItem.favorites) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            const CategoryDetailWrapper(
              title: 'Favorites',
              child: FavoritesView(),
            ),
          ),
        );
      } else if (next.activeItem == NavItem.albums &&
          previous?.activeItem != NavItem.albums) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            const CategoryDetailWrapper(
              title: 'Albums',
              child: AlbumsGridView(),
            ),
          ),
        );
      } else if (next.activeItem == NavItem.artists &&
          previous?.activeItem != NavItem.artists) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            const CategoryDetailWrapper(
              title: 'Artists',
              child: ArtistsGridView(),
            ),
          ),
        );
      } else if (next.activeItem == NavItem.genres &&
          previous?.activeItem != NavItem.genres) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            const CategoryDetailWrapper(
              title: 'Genres',
              child: GenresGridView(),
            ),
          ),
        );
      } else if (next.activeItem == NavItem.folders &&
          previous?.activeItem != NavItem.folders) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            const CategoryDetailWrapper(
              title: 'Folders',
              child: FoldersListView(),
            ),
          ),
        );
      } else if (next.activeItem == NavItem.history &&
          previous?.activeItem != NavItem.history) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            const CategoryDetailWrapper(
              title: 'Recently Played',
              child: RecentlyPlayedView(),
            ),
          ),
        );
      } else if (next.history.length < (previous?.history.length ?? 0)) {
        if (navigatorKey.currentState?.canPop() ?? false) {
          navigatorKey.currentState?.pop();
        }
      }
    });

    final library = ref.watch(libraryProvider);
    final settings = ref.watch(settingsProvider);

    if (library.songs.isEmpty && !library.isScanning) {
      return const WelcomeScreen();
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        // 1. If player is expanded, collapse it
        if (nav.isPlayerExpanded) {
          ref.read(appNavigationProvider.notifier).setPlayerExpansion(false);
          return;
        }

        // 2. If we have navigation history or are in a sub-view (search/settings)
        if (nav.history.isNotEmpty ||
            nav.activeItem == NavItem.search ||
            nav.activeItem == NavItem.settings ||
            nav.activeItem == NavItem.collectionDetail) {
          ref.read(appNavigationProvider.notifier).goBack();
          return;
        }

        // 3. If we are on Songs or Library tab, go to Home tab
        if (nav.activeItem != NavItem.home) {
          ref.read(appNavigationProvider.notifier).setItem(NavItem.home);
          return;
        }

        // 4. Double press to exit
        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Press back again to exit',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black87,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.only(
                bottom: 100, // Above the navbar
                left: 20,
                right: 20,
              ),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: settings.enableDynamicTheming ? Colors.transparent : Theme.of(context).colorScheme.surface,
        drawer: Drawer(
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Sidebar(l10n: l10n),
          ),
        ),
        body: Stack(
          children: [
            // Dynamic Background (Matched exactly with Lyrics Screen for consistency)
            if (settings.enableDynamicTheming && song?.artPath != null) ...[
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(song!.artPath),
                  tween: Tween<double>(begin: 1.0, end: 1.1),
                  duration: const Duration(seconds: 30),
                  curve: Curves.linear,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: RepaintBoundary(
                        child: Image.file(
                          File(song.artPath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          cacheWidth: 100, // Low-res cache for optimal blur performance
                          cacheHeight: 100,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ),
            ],
            Positioned.fill(
              child: Navigator(
                key: navigatorKey,
                onGenerateRoute: (settings) {
                  return PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return Consumer(
                        builder: (context, ref, child) {
                          final nav = ref.watch(appNavigationProvider);
                          int index = 0;
                          if (nav.activeItem == NavItem.home)
                            index = 0;
                          else if (nav.activeItem == NavItem.songs)
                            index = 1;
                          else if (nav.activeItem == NavItem.playlists)
                            index = 2;

                          return PageTransitionSwitcher(
                            duration: const Duration(milliseconds: 500),
                            reverse: false,
                            transitionBuilder:
                                (child, animation, secondaryAnimation) {
                                  return FadeThroughTransition(
                                    animation: animation,
                                    secondaryAnimation: secondaryAnimation,
                                    child: child,
                                  );
                                },
                            child: KeyedSubtree(
                              key: ValueKey(index),
                              child: _tabs[index],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Mini Player & Navbar with Gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 48),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.6),
                      //Theme.of(context).colorScheme.surface,
                      Colors.black,
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: song != null
                          ? const PremiumMusicBar(key: ValueKey('music_bar'))
                          : const SizedBox(key: ValueKey('no_music')),
                    ),
                    const SizedBox(height: 4),
                    PremiumNavbar(
                      currentIndex: activeItem == NavItem.home
                          ? 0
                          : (activeItem == NavItem.songs
                                ? 1
                                : (activeItem == NavItem.playlists ? 2 : 0)),
                      onTap: (index) {
                        NavItem target;
                        switch (index) {
                          case 1:
                            target = NavItem.songs;
                            break;
                          case 2:
                            target = NavItem.playlists;
                            break;
                          case 0:
                          default:
                            target = NavItem.home;
                            break;
                        }
                        ref
                            .read(appNavigationProvider.notifier)
                            .setItem(target);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Route _createPremiumRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
    );
  }
}
