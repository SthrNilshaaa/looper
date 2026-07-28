import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/streaming/domain/models/online_track.dart';
import 'package:looper_player/features/streaming/presentation/streaming_notifier.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/ui/widgets/playback_mode_selector.dart';
import 'package:looper_player/ui/widgets/grid_list_toggle_button.dart';
import 'package:looper_player/ui/widgets/recommendations_section.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OnlineExploreTab extends ConsumerStatefulWidget {
  const OnlineExploreTab({super.key});

  @override
  ConsumerState<OnlineExploreTab> createState() => _OnlineExploreTabState();
}

class _OnlineExploreTabState extends ConsumerState<OnlineExploreTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamingState = ref.watch(streamingProvider);
    final streamingNotifier = ref.read(streamingProvider.notifier);
    final isGrid = ref.watch(isGridViewProvider);

    return RepaintBoundary(
      child: SafeArea(
        child: Column(
          children: [
            // Top Header Bar with Title and Mode Switcher
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Explore Online',
                    style: AppFonts.jostStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const GridListToggleButton(),
                  const SizedBox(width: 8),
                  const PlaybackModeSelector(compact: true),
                ],
              ),
            ),

            // Search Bar Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: PremiumSection(
                borderRadius: BorderRadius.circular(24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                useExpanded: false,
                child: TextField(
                  controller: _searchController,
                  style: AppFonts.jostStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search YouTube Music songs, artists...',
                    hintStyle: AppFonts.jostStyle(color: Colors.white38, fontSize: 14),
                    border: InputBorder.none,
                    icon: const Icon(LucideIcons.search, color: Colors.white70, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, color: Colors.white70, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              streamingNotifier.search('');
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (query) {
                    streamingNotifier.search(query);
                  },
                ),
              ),
            ),

            // Category & Mood Filter Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  '🔥 Trending',
                  '🎵 Pop',
                  '🎸 Rock',
                  '🎧 Hip-Hop',
                  '☕ Chill',
                  '💪 Workout',
                  '📚 Focus',
                  '🌙 Lo-Fi',
                ].map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(category, style: AppFonts.jostStyle(fontSize: 12, color: Colors.white)),
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      selectedColor: Theme.of(context).colorScheme.primary,
                      onSelected: (_) {
                        HapticFeedback.lightImpact();
                        final query = category.replaceAll(RegExp(r'[^\w\s]'), '').trim();
                        _searchController.text = query;
                        streamingNotifier.search(query);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // Search Results or Trending Stream List
            Expanded(
              child: streamingState.isLoadingSearch || streamingState.isLoadingTrending
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        const SliverToBoxAdapter(child: RecommendationsSection()),
                        if (streamingState.searchResults.isNotEmpty) ...[
                          _buildSectionHeader('Search Results'),
                          if (isGrid)
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              sliver: SliverGrid(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.1,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildTrackCard(context, ref, streamingState.searchResults[index]),
                                  childCount: streamingState.searchResults.length,
                                ),
                              ),
                            )
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildTrackTile(context, ref, streamingState.searchResults[index]),
                                childCount: streamingState.searchResults.length,
                              ),
                            ),
                        ] else ...[
                          _buildSectionHeader('🔥 Trending Music Streams'),
                          if (isGrid)
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              sliver: SliverGrid(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.1,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildTrackCard(context, ref, streamingState.trendingTracks[index]),
                                  childCount: streamingState.trendingTracks.length,
                                ),
                              ),
                            )
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildTrackTile(context, ref, streamingState.trendingTracks[index]),
                                childCount: streamingState.trendingTracks.length,
                              ),
                            ),
                        ],
                        const SliverToBoxAdapter(child: SizedBox(height: 180)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          title,
          style: AppFonts.jostStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildTrackTile(BuildContext context, WidgetRef ref, OnlineTrack track) {
    final streamingState = ref.watch(streamingProvider);
    final isResolving = streamingState.activeResolvingId == track.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: PremiumSection(
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(8),
        useExpanded: false,
        onTap: isResolving
            ? null
            : () async {
                HapticFeedback.lightImpact();
                final song = await ref.read(streamingProvider.notifier).resolveAndCreateSong(track);
                if (song != null) {
                  ref.read(playbackProvider.notifier).play(song);
                }
              },
        child: Row(
          children: [
            // Thumbnail Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 52,
                height: 52,
                child: OptimizedImage(
                  imageUrl: track.thumbnailUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Track info & Badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.jostStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          'ONLINE',
                          style: AppFonts.jostStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.jostStyle(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action / Resolving indicator
            if (isResolving)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            else
              const Icon(LucideIcons.playCircle, color: Colors.white70, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackCard(BuildContext context, WidgetRef ref, OnlineTrack track) {
    final streamingState = ref.watch(streamingProvider);
    final isResolving = streamingState.activeResolvingId == track.id;

    return PremiumSection(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(8),
      useExpanded: false,
      onTap: isResolving
          ? null
          : () async {
              HapticFeedback.lightImpact();
              final song = await ref.read(streamingProvider.notifier).resolveAndCreateSong(track);
              if (song != null) {
                ref.read(playbackProvider.notifier).play(song);
              }
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                child: OptimizedImage(
                  imageUrl: track.thumbnailUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            track.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.jostStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            track.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.jostStyle(
              fontSize: 11,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}
