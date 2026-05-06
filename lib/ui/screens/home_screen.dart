import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animations/animations.dart';
import 'package:window_manager/window_manager.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/player_bar.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/features/library/presentation/library_grids.dart';
import 'package:looper_player/ui/screens/home_dashboard.dart';
import 'package:looper_player/features/playlists/presentation/playlist_view.dart';
import 'package:looper_player/features/search/presentation/search_view.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/library/presentation/smart_views.dart';
import 'package:looper_player/ui/screens/settings_view.dart';

import 'package:looper_player/ui/widgets/collection_detail_view.dart';
import 'package:looper_player/features/playback/presentation/lyrics_view.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/library/presentation/queue_view.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/core/providers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import '../widgets/global_search_bar.dart';

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
    final library = ref.watch(libraryProvider);
    final nav = ref.watch(appNavigationProvider);
    final playback = ref.watch(playbackProvider);
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    final bool showWelcome = library.songs.isEmpty && !library.isScanning;
    final bool isNarrow = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: isNarrow ? Drawer(
        child: Container(
          color: Theme.of(context).colorScheme.background,
          child: Sidebar(l10n: l10n),
        ),
      ) : null,
      body: SafeArea(
        child: Stack(
          children: [
            // Global Background Art (Conditional)
            if (!showWelcome && settings.enableDynamicTheming && playback.currentSong?.artPath != null) ...[
              Positioned.fill(
                child: Image.file(
                  File(playback.currentSong!.artPath!),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ),
            ],

            
            Column(
              children: [
                // Custom Title Bar always at the top
                SizedBox(
                  height: 40,
                  child: CustomTitleBar(showMenu: isNarrow),
                ),
                Expanded(
                  child: showWelcome
                    ? _buildWelcomeView(context, l10n)
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final bool isNarrowLayout = constraints.maxWidth < 800;
                          
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Sidebar - hidden on narrow screens
                              if (!isNarrowLayout)
                                Container(
                                  width: 260,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.01),
                                    border: Border(
                                      right: BorderSide(
                                        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  child: Sidebar(l10n: l10n),
                                ),
                              
                              // Main Content Area
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const GlobalSearchBar(),
                                    Expanded(child: _buildMainContent(nav, library, context, l10n)),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                ),
                // Global Player Bar always at the bottom
                PlayerBar(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeView(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            height: 120,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/main_logo_app.svg',
              height: 100,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => const Text(
                'Looper Player',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome to ${l10n.appTitle}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.scanLibrary,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () async {
              final String? path = await FilePicker.platform.getDirectoryPath();
              if (path != null) {
                ref.read(libraryProvider.notifier).scanLibrary(path);
              }
            },
            icon: const Icon(LucideIcons.folderSearch),
            label: Text(l10n.addFolder),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
          const Text(
            'High-Fidelity Audio • Modern Experience',
            style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 1.5),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMainContent(NavigationState nav, LibraryState library, BuildContext context, AppLocalizations l10n) {
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

  Widget _getWidgetForNavItem(NavigationState nav, LibraryState library, BuildContext context, AppLocalizations l10n) {
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
    return _buildWelcomeView(context, l10n);
  }
}

class CustomTitleBar extends StatelessWidget {
  final bool showMenu;
  const CustomTitleBar({super.key, this.showMenu = false});

  @override
  Widget build(BuildContext context) {
    return  WindowCaption(
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
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 32), // -32 for padding
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                  padding: const EdgeInsets.only(left: 15,right: 5),
                  child: 
                  Row(
                    children: [
                      SizedBox(
                        height: 50,
                        child: SvgPicture.asset(
                          'assets/main_logo_app.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                
                 
                ),
                SizedBox(height: 10),
                    _SidebarItem(
                      customIcon: 'assets/side_bar/home_active.svg',
                      label: 'Home',
                      isSelected: activeItem == NavItem.home,
                      onTap: () => navigateTo(NavItem.home),
                    ),

                    _SidebarItem(
                      customIcon: 'assets/side_bar/my_music.svg',
                      label: l10n.songs,
                      isSelected: activeItem == NavItem.songs,
                      onTap: () => navigateTo(NavItem.songs),
                    ),
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
                    const SizedBox(height: 24),
                    Text(l10n.playlists.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    _SidebarItem(
                      customIcon: 'assets/side_bar/library.svg',
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
                      customIcon: 'assets/side_bar/favourites.svg',
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
                    const Spacer(),
                    const SizedBox(height: 16),
                    _SidebarItem(
                      icon: LucideIcons.settings,
                      label: l10n.settings,
                      isSelected: activeItem == NavItem.settings,
                      onTap: () => navigateTo(NavItem.settings),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: customIcon != null 
            ? SvgPicture.asset(
                customIcon!, 
                width: 18, 
                height: 18, 
                colorFilter: ColorFilter.mode(
                  isSelected ? Theme.of(context).colorScheme.primary : Colors.grey, 
                  BlendMode.srcIn
                ),
              )
            : Icon(icon, size: 18, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
        ),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}
