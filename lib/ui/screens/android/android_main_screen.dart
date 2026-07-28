import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_view.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_music_bar.dart';
import 'package:looper_player/ui/screens/welcome_screen.dart';
import 'package:looper_player/ui/widgets/collection_detail_view.dart';
import 'package:looper_player/features/playlists/presentation/playlist_view.dart';
import 'package:looper_player/ui/screens/android/tabs/views/library_categories_views.dart';

import 'tabs/android_home_tab.dart';
import 'tabs/android_search_tab.dart';
import 'tabs/android_library_tab.dart';
import 'tabs/android_songs_tab.dart';
import 'tabs/online_explore_tab.dart';
import 'package:looper_player/features/streaming/presentation/streaming_notifier.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/core/player_expand_provider.dart';
import 'widgets/premium_navbar.dart';
import 'widgets/premium_section.dart';
import 'package:looper_player/features/library/presentation/smart_views.dart';
import 'package:looper_player/features/library/presentation/queue_view.dart';


import 'package:animations/animations.dart';

final androidNavigatorKeyProvider = Provider(
  (ref) => GlobalKey<NavigatorState>(),
);

class AndroidMainScreen extends ConsumerStatefulWidget {
  const AndroidMainScreen({super.key});

  @override
  ConsumerState<AndroidMainScreen> createState() => _AndroidMainScreenState();
}

class _AndroidMainScreenState extends ConsumerState<AndroidMainScreen> with WidgetsBindingObserver {
  DateTime? _lastBackPressTime;
  bool _permissionsGranted = true;

  final List<Widget> _tabs = [
    const AndroidHomeTab(),
    const AndroidSongsTab(),
    const AndroidLibraryTab(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestNotificationPermissionIfNeeded();
    _checkAndroidPermissions();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(settingsProvider.notifier).initialization;
      ref.read(libraryProvider.notifier).scanSavedFolders(showVisualIndicator: false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndroidPermissions();
    }
  }

  Future<void> _checkAndroidPermissions() async {
    if (Platform.isAndroid) {
      int sdkInt = 0;
      try {
        final sdkMatch = RegExp(r'API\s+(\d+)').firstMatch(Platform.operatingSystemVersion);
        if (sdkMatch != null) {
          sdkInt = int.parse(sdkMatch.group(1)!);
        }
      } catch (_) {}

      final hasAudio = await Permission.audio.isGranted;
      final hasManage = await Permission.manageExternalStorage.isGranted;
      final hasStorage = sdkInt < 33 && await Permission.storage.isGranted;
      final isGranted = hasAudio || hasStorage || hasManage;
      if (mounted && _permissionsGranted != isGranted) {
        setState(() {
          _permissionsGranted = isGranted;
        });
        if (isGranted) {
          ref.read(libraryProvider.notifier).scanSavedFolders(showVisualIndicator: true);
        }
      }
    }
  }

  Future<void> _requestNotificationPermissionIfNeeded() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final song = ref.watch(playbackProvider.select((s) => s.currentSong));
    final nav = ref.watch(appNavigationProvider);
    final activeItem = nav.activeItem;
    final navigatorKey = ref.read(androidNavigatorKeyProvider);
    final rootItem = () {
      if (activeItem == NavItem.home ||
          activeItem == NavItem.songs ||
          activeItem == NavItem.library) {
        return activeItem;
      }
      for (final histState in nav.history.reversed) {
        final histActive = histState.activeItem;
        if (histActive == NavItem.home ||
            histActive == NavItem.songs ||
            histActive == NavItem.library) {
          return histActive;
        }
      }
      return NavItem.home;
    }();

    // Handle Sub-view Navigation via Navigator (to enable Hero)
    ref.listen(appNavigationProvider, (previous, next) {
      final isForward = next.history.length >= (previous?.history.length ?? 0);

      if (next.activeItem == NavItem.home) {
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
      } else if (next.activeItem == NavItem.songs) {
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
      } else if (next.activeItem == NavItem.library) {
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
      } else if (isForward && next.activeItem == NavItem.playlists) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            CategoryDetailWrapper(
              title: 'Playlists',
              child: PlaylistView(),
            ),
          ),
        );
      } else if (isForward && next.activeItem == NavItem.collectionDetail) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            CollectionDetailView(
              title: next.collectionTitle ?? 'Unknown',
              subtitle: next.collectionSubtitle,
              artPath: next.collectionArt,
              imageUrl: next.collectionImageUrl,
              songs: next.collectionSongs,
              playlist: next.activePlaylist,
            ),
          ),
        );
      } else if (isForward && next.activeItem == NavItem.search) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(const AndroidSearchTab()),
        );
      } else if (isForward && next.activeItem == NavItem.settings) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(const SettingsView()),
        );
      } else if (isForward && next.activeItem == NavItem.search) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            const OnlineExploreTab(),
          ),
        );
      } else if (isForward && next.activeItem == NavItem.favorites) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            const CategoryDetailWrapper(
              title: 'Favorites',
              child: FavoritesView(),
            ),
          ),
        );
      } else if (isForward && next.activeItem == NavItem.albums) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            const CategoryDetailWrapper(
              title: 'Albums',
              child: AlbumsGridView(),
            ),
          ),
        );
      } else if (isForward && next.activeItem == NavItem.artists) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            const CategoryDetailWrapper(
              title: 'Artists',
              child: ArtistsGridView(),
            ),
          ),
        );
      } else if (isForward && next.activeItem == NavItem.genres) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            const CategoryDetailWrapper(
              title: 'Genres',
              child: GenresGridView(),
            ),
          ),
        );
      } else if (isForward && next.activeItem == NavItem.folders) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            const CategoryDetailWrapper(
              title: 'Folders',
              child: FoldersListView(),
            ),
          ),
        );
      } else if (isForward && next.activeItem == NavItem.queue) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            const CategoryDetailWrapper(
              title: 'Queue',
              child: QueueView(),
            ),
          ),
        );
      } else if (isForward && (next.activeItem == NavItem.history || next.activeItem == NavItem.recentlyPlayed)) {
        navigatorKey.currentState?.push(
          _createPremiumRoute(
            const CategoryDetailWrapper(
              title: 'Recently Played',
              child: RecentlyPlayedView(),
            ),
          ),
        );
      } else if (!isForward) {
        if (navigatorKey.currentState?.canPop() ?? false) {
          navigatorKey.currentState?.pop();
        }
      }
    });

    final settings = ref.watch(settingsProvider);
    final isWelcomeBypassed = ref.watch(welcomeBypassedProvider);
    final showSupportUsSheet = ref.watch(supportUsSheetVisibleProvider);
    final double navbarHeight = 72.0 + 18.0 + MediaQuery.of(context).padding.bottom;

    final activeDarkness = () {
      final val = rootItem == NavItem.home
          ? settings.homeDarkness
          : rootItem == NavItem.songs
              ? settings.songsDarkness
              : rootItem == NavItem.library
                  ? settings.libraryDarkness
                  : 0.72;
      return val.isNaN ? 0.72 : val;
    }();

    final isSetupComplete = isWelcomeBypassed;

    if (!isSetupComplete) {
      return const WelcomeScreen();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // 1. If sliding player is open/expanded (vertical motion), collapse it
        final double slideProgress = ref.read(playerExpandProgressProvider);
        if (settings.enableSlideGesture && slideProgress > 0.0) {
          ref.read(playerCollapseTriggerProvider.notifier).update((state) => state + 1);
          return;
        }

        // 2. If non-sliding player is expanded, collapse it
        if (!settings.enableSlideGesture && nav.isPlayerExpanded) {
          ref.read(appNavigationProvider.notifier).setPlayerExpansion(false);
          return;
        }

        // 3. If local navigator has sub-pages (favorites, playlists, settings, categories, details), pop it
        final bool canPopNavigator = navigatorKey.currentState?.canPop() ?? false;
        if (canPopNavigator) {
          ref.read(appNavigationProvider.notifier).goBack();
          return;
        }

        // 4. If we have tab history, navigate back through the tabs
        if (nav.history.isNotEmpty) {
          ref.read(appNavigationProvider.notifier).goBack();
          return;
        }

        // 5. Double press to exit
        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.pressBackExit,
                style: AppFonts.jostStyle(color: Colors.white),
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
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        // drawer: Drawer(
        //   child: Container(
        //     color: Theme.of(context).colorScheme.surface,
        //     child: Sidebar(l10n: l10n),
        //   ),
        // ),
        body: Stack(
          children: [
            // Dynamic Background / Gradient Layer
            if (settings.enableDynamicTheming || settings.keepBackgroundGradient) ...[
              if (song?.artPath != null && settings.enableDynamicTheming) ...[
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: BlurredBackgroundArt(
                      key: ValueKey(song!.artPath),
                      song: song,
                    ),
                  ),
                ),

                // Dark overlay
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: activeDarkness),
                  ),
                ),
              ] else ...[
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 1.5,
                        colors: [
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
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
                                active == NavItem.library) {
                              return active;
                            }
                            for (final histState in nav.history.reversed) {
                              final histActive = histState.activeItem;
                              if (histActive == NavItem.home ||
                                  histActive == NavItem.songs ||
                                  histActive == NavItem.library) {
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
                                  final isTransitioning = !animation.isCompleted || !secondaryAnimation.isDismissed;
                                  return TransitionStatusProvider(
                                    isTransitioning: isTransitioning,
                                    child: FadeThroughTransition(
                                      animation: animation,
                                      secondaryAnimation: secondaryAnimation,
                                      fillColor: Colors.transparent,
                                      child: child,
                                    ),
                                  );
                                },
                            child: KeyedSubtree(
                              key: ValueKey('$index-${ref.watch(settingsProvider).playbackModeIndex}'),
                              child: () {
                                final mode = ref.watch(streamingProvider.notifier).currentMode;
                                if (mode == PlaybackMode.onlineOnly && index == 0) {
                                  return const OnlineExploreTab();
                                }
                                return _tabs[index];
                              }(),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            if (nav.activeItem != NavItem.settings)
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
                          Colors.black.withValues(alpha: 0.45),
                          Colors.black.withValues(alpha: 0.8),
                          Colors.black,
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
           

            if (settings.enableSlideGesture)
              Positioned.fill(
                child: Consumer(
                  builder: (context, ref, child) {
                    final progress = ref.watch(playerExpandProgressProvider);
                    return Stack(
                      children: [
                        // Opaque navbar positioning (independent of player panel)
                        if (nav.activeItem != NavItem.settings)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? -150 : 0,
                            child: AnimatedOpacity(
                              opacity: MediaQuery.of(context).viewInsets.bottom > 0 ? 0.0 : (1.0 - progress * 3.0).clamp(0.0, 1.0),
                              duration: const Duration(milliseconds: 150),
                              child: Transform.translate(
                                offset: Offset(0.0, progress * 110.0),
                                child: PremiumNavbar(
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
                                        target = NavItem.library;
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
                              ),
                            ),
                          )
                        else if (song != null)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: AnimatedOpacity(
                              opacity: MediaQuery.of(context).viewInsets.bottom > 0 ? 0.0 : (1.0 - progress * 3.0).clamp(0.0, 1.0),
                              duration: const Duration(milliseconds: 150),
                              child: SizedBox(height: 16 + MediaQuery.of(context).padding.bottom),
                            ),
                          ),

                        // The slide-up/morphing music panel
                        if (song != null && !showSupportUsSheet)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: MediaQuery.of(context).viewInsets.bottom > 0
                                ? -150
                                : (nav.activeItem != NavItem.settings
                                    ? (navbarHeight + 4.0) * (1.0 - progress)
                                    : (16.0 + MediaQuery.of(context).padding.bottom) * (1.0 - progress)),
                            height: 72.0 + (MediaQuery.of(context).size.height - 72.0) * progress,
                            child: const PremiumMusicBar(key: ValueKey('music_bar')),
                          ),
                      ],
                    );
                  },
                ),
              ) else ...[
              // Standard Column layout (original layout)
              Positioned(
                bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? -150 : 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: MediaQuery.of(context).viewInsets.bottom > 0 ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    transform: Matrix4.translationValues(
                      0,
                      MediaQuery.of(context).viewInsets.bottom > 0 ? 150 : 0,
                      0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          child: (song != null && !showSupportUsSheet)
                              ? const PremiumMusicBar(key: ValueKey('music_bar'))
                              : const SizedBox(key: ValueKey('no_music')),
                        ),
                        if (nav.activeItem != NavItem.settings) ...[
                          const SizedBox(height: 4),
                          Transform.translate(
                            offset: const Offset(0.0, 0.0),
                            child: PremiumNavbar(
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
                                    target = NavItem.library;
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
                          ),
                        ] else if (song != null) ...[
                          SizedBox(height: 16 + MediaQuery.of(context).padding.bottom),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Route _createPremiumRoute(Widget page) {
    return PageRouteBuilder(
      opaque: false,
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

class BlurredBackgroundArt extends StatelessWidget {
  final Song song;
  const BlurredBackgroundArt({required this.song, super.key});

  @override
  Widget build(BuildContext context) {
    final path = song.artPath;
    if (path == null) return const SizedBox.shrink();
    return RepaintBoundary(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: 5.0,
          sigmaY: 5.0,
        ),
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          filterQuality: FilterQuality.low,
          cacheWidth: 32,
          cacheHeight: 32,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
