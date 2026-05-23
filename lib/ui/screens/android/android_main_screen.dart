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

import 'tabs/android_home_tab.dart';
import 'tabs/android_search_tab.dart';
import 'tabs/android_library_tab.dart';
import 'tabs/android_songs_tab.dart';
import 'player/android_expanded_player.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'widgets/premium_navbar.dart';
import 'widgets/premium_section.dart';
import 'tabs/views/library_categories_views.dart';
import 'package:looper_player/features/library/presentation/smart_views.dart';
import 'package:looper_player/features/library/presentation/queue_view.dart';


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
    const AndroidSongsTab(),
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
    final rootItem = () {
      if (activeItem == NavItem.home ||
          activeItem == NavItem.songs ||
          activeItem == NavItem.playlists) {
        return activeItem;
      }
      for (final histState in nav.history.reversed) {
        final histActive = histState.activeItem;
        if (histActive == NavItem.home ||
            histActive == NavItem.songs ||
            histActive == NavItem.playlists) {
          return histActive;
        }
      }
      return NavItem.home;
    }();

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
      } else if (next.activeItem == NavItem.queue &&
          previous?.activeItem != NavItem.queue) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            const CategoryDetailWrapper(
              title: 'Queue',
              child: const QueueView(),
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
    final isWelcomeBypassed = ref.watch(welcomeBypassedProvider);

    final isSetupComplete = isWelcomeBypassed ||
                            settings.libraryFolders.isNotEmpty;

    if (!isSetupComplete) {
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
              content: Text(
                UiUtils.tr(context, 'Press back again to exit', 'बाहर निकलने के लिए फिर से वापस दबाएं'),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black87,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.only(
                bottom:  song != null? 180:100, // Above the navbar
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
        // drawer: Drawer(
        //   child: Container(
        //     color: Theme.of(context).colorScheme.surface,
        //     child: Sidebar(l10n: l10n),
        //   ),
        // ),
        body: Stack(
          children: [
            // Dynamic Background (Matched exactly with Lyrics Screen for consistency)
            if (settings.enableDynamicTheming) ...[
              if (song?.artPath != null) ...[
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(song!.artPath),
                    tween: Tween(begin: 1.0, end: 1.08),
                    duration: const Duration(seconds: 30),
                    curve: Curves.linear,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: 18,
                            sigmaY: 18,
                          ),
                          child: RepaintBoundary(
                            child: Image.file(
                              File(song.artPath!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,

                              // VERY IMPORTANT
                              filterQuality: FilterQuality.low,

                              // Massive optimization
                              cacheWidth: 80,
                              cacheHeight: 80,

                              gaplessPlayback: true,

                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Dark overlay
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.72),
                  ),
                ),
              ] else ...[
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 1.5,
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.18),
                          Theme.of(context).colorScheme.surface,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
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
                          final rootItem = () {
                            final active = nav.activeItem;
                            if (active == NavItem.home ||
                                active == NavItem.songs ||
                                active == NavItem.playlists) {
                              return active;
                            }
                            for (final histState in nav.history.reversed) {
                              final histActive = histState.activeItem;
                              if (histActive == NavItem.home ||
                                  histActive == NavItem.songs ||
                                  histActive == NavItem.playlists) {
                                return histActive;
                              }
                            }
                            return NavItem.home;
                          }();
                          int index = rootItem == NavItem.home
                              ? 0
                              : (rootItem == NavItem.songs ? 1 : 2);

                          return PageTransitionSwitcher(
                            duration: const Duration(milliseconds: 500),
                            reverse: false,
                            transitionBuilder:
                                (child, animation, secondaryAnimation) {
                                  return FadeThroughTransition(
                                    animation: animation,
                                    secondaryAnimation: secondaryAnimation,
                                    fillColor: Colors.transparent,
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
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [
                        0.0,
                        0.35,
                        0.7,
                        1.0,
                      ],
                    ),
                  ),
                ),
              ),
            ),
           

            // Mini Player & Navbar with Gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
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
                      currentIndex: rootItem == NavItem.home
                          ? 0
                          : (rootItem == NavItem.songs ? 1 : 2),
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
