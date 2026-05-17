import 'dart:io';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/core/app_icons.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/ui/widgets/color_maper.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animations/animations.dart';
import 'package:window_manager/window_manager.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/player_bar.dart';
import '../widgets/expanded_player.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/features/library/presentation/library_grids.dart';
import 'package:looper_player/ui/screens/home_dashboard.dart';
import 'package:looper_player/features/playlists/presentation/playlist_view.dart';
import 'package:looper_player/features/search/presentation/search_view.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/library/presentation/smart_views.dart';
import 'package:looper_player/ui/screens/settings_view.dart';
import 'package:looper_player/ui/screens/welcome_screen.dart';

import 'package:looper_player/ui/widgets/collection_detail_view.dart';
import 'package:looper_player/features/playback/presentation/lyrics_view.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/playback/presentation/lyrics_notifier.dart';
import 'package:looper_player/features/library/presentation/queue_view.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/core/providers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/features/library/presentation/library_grids.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import '../widgets/global_search_bar.dart';
import 'package:looper_player/features/playback/presentation/widgets/overlay_lyrics_widget.dart';

import 'android/android_main_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger library scan for saved folders on startup
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Wait for settings to load from DB
      await ref.read(settingsProvider.notifier).initialization;
      final settings = ref.read(settingsProvider);

      // Handle file passed via CLI arguments
      final initialFile = ref.read(startupFileProvider);
      if (initialFile != null) {
        ref.read(playbackProvider.notifier).playFromFile(initialFile);
        // If playing from file, maybe skip the folder prompt for now
        if (settings.libraryFolders.isNotEmpty) {
          ref.read(libraryProvider.notifier).scanSavedFolders();
        }
        return;
      }

      if (settings.libraryFolders.isEmpty) {
        // First time opening: silently scan default folders (like xdg MUSIC) instead of prompting
        ref.read(libraryProvider.notifier).scanSavedFolders();
      } else {
        ref.read(libraryProvider.notifier).scanSavedFolders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return const AndroidMainScreen();
    }

    final library = ref.watch(libraryProvider);
    final nav = ref.watch(appNavigationProvider);
    final playback = ref.watch(playbackProvider);
    final settings = ref.watch(settingsProvider);
    final isDynamic = settings.enableDynamicTheming;
    final l10n = AppLocalizations.of(context)!;

    // Ensure lyrics pre-fetching is active
    ref.watch(lyricsProvider);

    final bool showWelcome = library.songs.isEmpty && !library.isScanning;
    final bool isNarrow = MediaQuery.of(context).size.width < 800;

    final isOverlayMode = ref.watch(overlayModeProvider);

    if (isOverlayMode) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: OverlayLyricsWidget(),
      );
    }

    return Scaffold(
      backgroundColor: isDynamic
          ? (playback.currentSong != null
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).scaffoldBackgroundColor)
          : Theme.of(context).scaffoldBackgroundColor,
      drawer: isNarrow
          ? Drawer(
              child: Container(
                color: Theme.of(context).colorScheme.background,
                child: Sidebar(l10n: l10n),
              ),
            )
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            // Global Background Art (Conditional)
            if (!showWelcome &&
                settings.enableDynamicTheming &&
                playback.currentSong?.artPath != null) ...[
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1000),
                  child: Image.file(
                    File(playback.currentSong!.artPath!),
                    key: ValueKey(playback.currentSong!.artPath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(color: Colors.black.withOpacity(0.8)),
                ),
              ),
            ],

            Column(
              children: [
                // Custom Title Bar always at the top
                SizedBox(height: 30, child: CustomTitleBar(showMenu: isNarrow)),
                Expanded(
                  child: showWelcome
                      ? const WelcomeScreen()
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final bool isNarrowLayout =
                                constraints.maxWidth < 800;

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Sidebar - hidden on narrow screens
                                if (!isNarrowLayout)
                                  Container(
                                    width: 240.s,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant
                                          .withOpacity(0.01),
                                      border: Border(
                                        right: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant
                                              .withOpacity(0.2),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    child: Sidebar(l10n: l10n),
                                  ),

                                // Main Content Area
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (nav.activeItem != NavItem.lyrics)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                            ),
                                            child: Row(
                                              children: [
                                                AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  curve: Curves.easeInOutCubic,
                                                  width: nav.history.isEmpty
                                                      ? 0
                                                      : 120,
                                                  child: ClipRect(
                                                    child: AnimatedScale(
                                                      scale: nav.history.isEmpty
                                                          ? 0.0
                                                          : 1.0,
                                                      duration: const Duration(
                                                        milliseconds: 300,
                                                      ),
                                                      curve: Curves.easeOutBack,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              right: 16,
                                                            ),
                                                        child: _HeaderButton(
                                                          onTap: () => ref
                                                              .read(
                                                                appNavigationProvider
                                                                    .notifier,
                                                              )
                                                              .goBack(),
                                                          icon: LucideIcons
                                                              .arrowLeft,
                                                          label: 'Back',
                                                          isDynamic: isDynamic,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Expanded(
                                                  child: GlobalSearchBar(),
                                                ),
                                                // const SizedBox(width: 48),
                                                Spacer(),
                                                _HeaderButton(
                                                  onTap: () async {
                                                    final String? path =
                                                        await FilePicker
                                                            .platform
                                                            .getDirectoryPath();
                                                    if (path != null) {
                                                      ref
                                                          .read(
                                                            libraryProvider
                                                                .notifier,
                                                          )
                                                          .scanLibrary(path);
                                                    }
                                                  },
                                                  icon: LucideIcons.plus,
                                                  label: 'Add Folder',
                                                  isDynamic: isDynamic,
                                                ),
                                              ],
                                            ),
                                          ),
                                        Expanded(
                                          child: _buildMainContent(
                                            nav,
                                            library,
                                            context,
                                            l10n,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
                // Global Player Bar always at the bottom
                if (!nav.isPlayerExpanded)
                  GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (Platform.isAndroid || Platform.isIOS) {
                        if (details.delta.dy < -10) {
                          ref
                              .read(appNavigationProvider.notifier)
                              .setPlayerExpansion(true);
                        }
                      }
                    },
                    child: const PlayerBar(),
                  ),
              ],
            ),
            // Expanded Player View
            if (nav.isPlayerExpanded)
              Positioned.fill(
                child: WillPopScope(
                  onWillPop: () async {
                    ref
                        .read(appNavigationProvider.notifier)
                        .setPlayerExpansion(false);
                    return false;
                  },
                  child: const ExpandedPlayer(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
    NavigationState nav,
    LibraryState library,
    BuildContext context,
    AppLocalizations l10n,
  ) {
    if (library.isScanning) {
      return const Center(child: CircularProgressIndicator());
    }

    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return FadeThroughTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          fillColor: Colors.transparent,
          child: child,
        );
      },
      child: _getWidgetForNavItem(nav, library, context, l10n),
    );
  }

  Widget _getWidgetForNavItem(
    NavigationState nav,
    LibraryState library,
    BuildContext context,
    AppLocalizations l10n,
  ) {
    switch (nav.activeItem) {
      case NavItem.search:
        return const SearchView(key: ValueKey('search'));
      case NavItem.albums:
        return const AlbumsGrid(key: ValueKey('albums'));
      case NavItem.artists:
        return const ArtistsGrid(key: ValueKey('artists'));
      case NavItem.playlists:
        return const PlaylistView(key: ValueKey('playlists'));
      case NavItem.favorites:
        return const FavoritesView(key: ValueKey('favorites'));
      case NavItem.recentlyPlayed:
        return const RecentlyPlayedView(key: ValueKey('recentlyPlayed'));
      case NavItem.lyrics:
        return const LyricsView(key: ValueKey('lyrics'));
      case NavItem.settings:
        return const SettingsView(key: ValueKey('settings'));
      case NavItem.collectionDetail:
        return CollectionDetailView(
          key: ValueKey('collection_${nav.collectionTitle}'),
          title: nav.collectionTitle ?? 'Unknown',
          subtitle: nav.collectionSubtitle,
          artPath: nav.collectionArt,
          imageUrl: nav.collectionImageUrl,
          songs: nav.collectionSongs,
        );
      case NavItem.queue:
        return const QueueView(key: ValueKey('queue'));
      case NavItem.songs:
        return library.songs.isEmpty
            ? _buildEmptyState(context, l10n)
            : SongsList(songs: library.songs, key: const ValueKey('songs'));
      case NavItem.home:
      default:
        return library.songs.isEmpty
            ? _buildEmptyState(context, l10n)
            : const HomeDashboard(key: ValueKey('home'));
    }
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return const WelcomeScreen();
  }
}

class CustomTitleBar extends StatelessWidget {
  final bool showMenu;
  const CustomTitleBar({super.key, this.showMenu = false});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      return const SizedBox.shrink();
    }
    return WindowCaption(
      brightness: Brightness.dark,
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          if (showMenu)
            IconButton(
              icon: const Icon(LucideIcons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
        ],
      ),
    );
  }
}

class Sidebar extends ConsumerWidget {
  final AppLocalizations l10n;
  const Sidebar({super.key, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(appNavigationProvider);
    final activeItem = nav.activeItem;

    void navigateTo(NavItem item) {
      ref.read(appNavigationProvider.notifier).setItem(item);
      if (Scaffold.of(context).isDrawerOpen) {
        Navigator.of(context).pop();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - 32).clamp(0.0, double.infinity),
              ), // -32 for padding
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 5),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 42,
                            child: SvgPicture.asset(
                              'assets/main_logo.svg',
                              fit: BoxFit.contain,
                              colorMapper: AccentColorMapper(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    _SidebarItem(
                      customIcon: AppIcons.home,
                      label: 'Home',
                      isSelected: activeItem == NavItem.home,
                      onTap: () => navigateTo(NavItem.home),
                    ),
                    _SidebarItem(
                      customIcon: AppIcons.songs,
                      label: l10n.songs,
                      isSelected: activeItem == NavItem.songs,
                      onTap: () => navigateTo(NavItem.songs),
                    ),
                    if ((ref.watch(albumsProvider).value?.length ?? 0) >= 6)
                      _SidebarItem(
                        icon: LucideIcons.disc,
                        label: l10n.albums,
                        isSelected: activeItem == NavItem.albums,
                        onTap: () => navigateTo(NavItem.albums),
                      ),
                    _SidebarItem(
                      icon: LucideIcons.mic2,
                      label: l10n.artists,
                      isSelected: activeItem == NavItem.artists,
                      onTap: () => navigateTo(NavItem.artists),
                    ),
                    _SidebarItem(
                      customIcon: AppIcons.library,
                      label: l10n.playlists,
                      isSelected: activeItem == NavItem.playlists,
                      onTap: () => navigateTo(NavItem.playlists),
                    ),
                    _SidebarItem(
                      icon: LucideIcons.clock,
                      label: 'Recently Played',
                      isSelected: activeItem == NavItem.recentlyPlayed,
                      onTap: () => navigateTo(NavItem.recentlyPlayed),
                    ),
                    _SidebarItem(
                      customIcon: AppIcons.heart,
                      label: 'Favorites',
                      isSelected: activeItem == NavItem.favorites,
                      onTap: () => navigateTo(NavItem.favorites),
                    ),
                    _SidebarItem(
                      icon: LucideIcons.listOrdered,
                      label: l10n.playQueue,
                      isSelected: activeItem == NavItem.queue,
                      onTap: () => navigateTo(NavItem.queue),
                    ),
                    _SidebarItem(
                      customIcon: AppIcons.settings,
                      label: l10n.settings,
                      isSelected: activeItem == NavItem.settings,
                      onTap: () => navigateTo(NavItem.settings),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: Colors.white10,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final bool isDynamic;

  const _HeaderButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.isDynamic,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 55.s,
        padding: EdgeInsets.symmetric(horizontal: 20.s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color.fromARGB(
            255,
            53,
            53,
            53,
          ).withOpacity(isDynamic ? 0.3 : 0.1),
          border: Border.all(color: Colors.white10.withOpacity(0.1), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == LucideIcons.arrowLeft)
              SvgPicture.asset(
                AppIcons.backVector,
                width: AppIcons.headerIcon.s,
                height: AppIcons.headerIcon.s,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              )
            else
              Icon(icon, size: AppIcons.headerIcon.s, color: Colors.white),
            SizedBox(width: 10.s),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.ts,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData? icon;
  final String? customIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    this.icon,
    this.customIcon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color selectedColor = colorScheme.primary;
    final Color unselectedColor = Colors.white.withOpacity(0.4);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: ListTile(
        leading: customIcon != null
            ? SvgPicture.asset(
                customIcon!,
                width: AppIcons.sidebarIcon.s,
                height: AppIcons.sidebarIcon.s,
                colorFilter: ColorFilter.mode(
                  isSelected ? selectedColor : unselectedColor,
                  BlendMode.srcIn,
                ),
              )
            : Icon(
                icon,
                size: AppIcons.sidebarIcon.s,
                color: isSelected ? selectedColor : unselectedColor,
              ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14.ts,
            color: isSelected ? selectedColor : unselectedColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        dense: true,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: onTap,
      ),
    );
  }
}
