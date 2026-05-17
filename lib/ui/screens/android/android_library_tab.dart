import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';

class AndroidLibraryTab extends ConsumerWidget {
  const AndroidLibraryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final library = ref.watch(libraryProvider);
    final l10n = AppLocalizations.of(context)!;
    final accentColor = Color(settings.accentColor);

    return Scaffold(
    backgroundColor: 
    //settings.enableDynamicTheming ? 
    Colors.transparent ,//: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Library',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                        IconButton(
                          onPressed: () => ref.read(appNavigationProvider.notifier).setItem(NavItem.settings),
                          icon: const Icon(LucideIcons.settings, color: Colors.white70),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.05),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Organize your entire music universe',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Search & Filter Area
                    _buildSearchBar(context, ref, accentColor),
                    const SizedBox(height: 32),

                    // Recently Accessed (Horizontal)
                    _buildSectionHeader('Recently Accessed'),
                    const SizedBox(height: 16),
                    _buildRecentlyAccessed(ref),
                    const SizedBox(height: 32),

                    _buildSectionHeader('Main Categories'),
                  ],
                ),
              ),
            ),

            // Main Library Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildListDelegate([
                  _LibraryCard(
                    title: 'Favorites',
                    subtitle: '${library.songs.where((s) => s.isFavorite).length} songs',
                    icon: LucideIcons.heart,
                    color: Colors.redAccent,
                    onTap: () => ref.read(appNavigationProvider.notifier).setItem(NavItem.favorites),
                  ),
                  _LibraryCard(
                    title: 'Albums',
                    subtitle: '${library.albums.length} collections',
                    icon: LucideIcons.disc,
                    color: Colors.blueAccent,
                    onTap: () => ref.read(appNavigationProvider.notifier).setItem(NavItem.albums),
                  ),
                  _LibraryCard(
                    title: 'Artists',
                    subtitle: '${library.artists.length} artists',
                    icon: LucideIcons.users,
                    color: Colors.orangeAccent,
                    onTap: () => ref.read(appNavigationProvider.notifier).setItem(NavItem.artists),
                  ),
                  _LibraryCard(
                    title: 'Playlists',
                    subtitle: '${library.playlists.length} playlists',
                    icon: LucideIcons.listMusic,
                    color: Colors.purpleAccent,
                    onTap: () => ref.read(appNavigationProvider.notifier).setItem(NavItem.playlists),
                  ),
                ]),
              ),
            ),

            // More Categories (Compact Grid)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: _buildSectionHeader('Advanced Tools'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 180),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.2,
                ),
                delegate: SliverChildListDelegate([
                  _buildToolCard(
                    title: 'Genres',
                    icon: LucideIcons.music,
                    color: Colors.indigoAccent,
                    onTap: () => ref.read(appNavigationProvider.notifier).setItem(NavItem.genres),
                  ),
                  _buildToolCard(
                    title: 'Folders',
                    icon: LucideIcons.folder,
                    color: Colors.amberAccent,
                    onTap: () => ref.read(appNavigationProvider.notifier).setItem(NavItem.folders),
                  ),
                  _buildToolCard(
                    title: 'History',
                    icon: LucideIcons.history,
                    color: Colors.tealAccent,
                    onTap: () => ref.read(appNavigationProvider.notifier).setItem(NavItem.history),
                  ),
                  _buildToolCard(
                    title: 'Queue',
                    icon: LucideIcons.playCircle,
                    color: accentColor,
                    onTap: () => ref.read(appNavigationProvider.notifier).setItem(NavItem.queue),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withOpacity(0.4),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildRecentlyAccessed(WidgetRef ref) {
    final recentSongs = ref.watch(recentlyPlayedProvider).value ?? [];
    if (recentSongs.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentSongs.length,
        itemBuilder: (context, index) {
          final song = recentSongs[index];
          return InkWell(
            onTap: () => ref.read(playbackProvider.notifier).setPlaylist(recentSongs, initialIndex: index),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: OptimizedImage(
                        imagePath: song.artPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    song.title,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return PremiumSection(
      onTap: onTap,
      useExpanded: false,
      borderRadius: BorderRadius.circular(20),
      backgroundColor: Colors.white.withOpacity(0.03),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref, Color accentColor) {
    return PremiumSection(
      borderRadius: BorderRadius.circular(24),
      useExpanded: false,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: () => ref.read(appNavigationProvider.notifier).setItem(NavItem.search),
      child: Row(
        children: [
          Icon(LucideIcons.search, size: 20, color: Colors.white.withOpacity(0.5)),
          const SizedBox(width: 12),
          Text(
            'Search in library...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 15,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.sliders, size: 16, color: accentColor),
          ),
        ],
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLarge;

  const _LibraryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumSection(
      onTap: onTap,
      useExpanded: false,
      backgroundColor: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(32),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
