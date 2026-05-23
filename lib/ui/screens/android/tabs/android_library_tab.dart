import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/core/ui_utils.dart';

class AndroidLibraryTab extends ConsumerWidget {
  const AndroidLibraryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      UiUtils.tr(context, 'Library', 'लाइब्रेरी'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    // Action Buttons Matching Home and Songs screen
                    Row(
                      children: [
                        PremiumSection(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          width: 44,
                          height: 44,
                          useExpanded: false,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(appNavigationProvider.notifier).setItem(NavItem.search);
                          },
                          child: const Icon(
                            LucideIcons.search,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 4),
                        PremiumSection(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          width: 44,
                          height: 44,
                          useExpanded: false,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(appNavigationProvider.notifier).setItem(NavItem.settings);
                          },
                          child: const Icon(
                            LucideIcons.settings,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Recent Played Pill
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    PremiumSection(
                      borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(32),
                            bottomLeft: Radius.circular(32),
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      useExpanded: false,
                      child: Text(
                        UiUtils.tr(context, 'Recent Played', 'हाल ही में चलाए गए'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recent Played Horizontal Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: _buildRecentlyAccessed(ref),
              ),
            ),

            // Categories Pill
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                child: Row(
                  children: [
                    PremiumSection(
                      borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(32),
                            bottomLeft: Radius.circular(32),
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      useExpanded: false,
                      child: Text(
                        UiUtils.tr(context, 'Categories', 'श्रेणियां'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Categories Block 1
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: PremiumSection(
                  borderRadius: BorderRadius.circular(20),
                  padding: EdgeInsets.zero,
                  useExpanded: false,
                  child: Column(
                    children: [
                      _buildCategoryRow(
                        context: context,
                        ref: ref,
                        icon: LucideIcons.star,
                        title: 'Favorites',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(appNavigationProvider.notifier).setItem(NavItem.favorites);
                        },
                        isLast: false,
                      ),
                      _buildCategoryRow(
                        context: context,
                        ref: ref,
                        icon: LucideIcons.disc,
                        title: 'Albums',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(appNavigationProvider.notifier).setItem(NavItem.albums);
                        },
                        isLast: false,
                      ),
                      _buildCategoryRow(
                        context: context,
                        ref: ref,
                        icon: LucideIcons.users,
                        title: 'Artists',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(appNavigationProvider.notifier).setItem(NavItem.artists);
                        },
                        isLast: false,
                      ),
                      _buildCategoryRow(
                        context: context,
                        ref: ref,
                        icon: LucideIcons.listMusic,
                        title: 'Playlists',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(appNavigationProvider.notifier).setItem(NavItem.playlists);
                        },
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Categories Block 2
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: PremiumSection(
                  borderRadius: BorderRadius.circular(20),
                  padding: EdgeInsets.zero,
                  useExpanded: false,
                  child: Column(
                    children: [
                      _buildCategoryRow(
                        context: context,
                        ref: ref,
                        icon: LucideIcons.folder,
                        title: 'Folders',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(appNavigationProvider.notifier).setItem(NavItem.folders);
                        },
                        isLast: false,
                      ),
                      _buildCategoryRow(
                        context: context,
                        ref: ref,
                        icon: LucideIcons.music,
                        title: 'Genres',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(appNavigationProvider.notifier).setItem(NavItem.genres);
                        },
                        isLast: false,
                      ),
                      _buildCategoryRow(
                        context: context,
                        ref: ref,
                        icon: LucideIcons.list,
                        title: 'Queue',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(appNavigationProvider.notifier).setItem(NavItem.queue);
                        },
                        isLast: false,
                      ),
                      _buildCategoryRow(
                        context: context,
                        ref: ref,
                        icon: LucideIcons.history,
                        title: 'History',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(appNavigationProvider.notifier).setItem(NavItem.history);
                        },
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom padding to clear Mini Player and let UI breathe
            const SliverToBoxAdapter(child: SizedBox(height: 200)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyAccessed(WidgetRef ref) {
    final recentSongs = ref.watch(recentlyPlayedProvider).value ?? [];
    if (recentSongs.isEmpty) {
      return SizedBox(
        height: 110,
        child: Center(
          child: Text(
            'No recently played tracks',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: recentSongs.length,
        itemBuilder: (context, index) {
          final song = recentSongs[index];
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(playbackProvider.notifier).setPlaylist(recentSongs, initialIndex: index);
            },
            child: Container(
              width: 110,
              height: 110,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: OptimizedImage(
                        imagePath: song.artPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.85),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  Widget _buildCategoryRow({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isLast,
  }) {
    String translatedTitle = title;
    switch (title) {
      case 'Favorites':
        translatedTitle = UiUtils.tr(context, 'Favorites', 'पसंदीदा');
        break;
      case 'Albums':
        translatedTitle = UiUtils.tr(context, 'Albums', 'एल्बम');
        break;
      case 'Artists':
        translatedTitle = UiUtils.tr(context, 'Artists', 'कलाकार');
        break;
      case 'Playlists':
        translatedTitle = UiUtils.tr(context, 'Playlists', 'प्लेलिस्ट');
        break;
      case 'Folders':
        translatedTitle = UiUtils.tr(context, 'Folders', 'फ़ोल्डर');
        break;
      case 'Genres':
        translatedTitle = UiUtils.tr(context, 'Genres', 'शैलियां');
        break;
      case 'Queue':
        translatedTitle = UiUtils.tr(context, 'Queue', 'कतार');
        break;
      case 'History':
        translatedTitle = UiUtils.tr(context, 'History', 'इतिहास');
        break;
    }

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white.withOpacity(0.9),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    translatedTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: Colors.white.withOpacity(0.9),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.8,
            color: Colors.white.withOpacity(0.04),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}
