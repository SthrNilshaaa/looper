import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/streaming/data/recommendations_service.dart';
import 'package:looper_player/features/streaming/domain/models/online_track.dart';
import 'package:looper_player/features/streaming/presentation/streaming_notifier.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final recommendationsServiceProvider = Provider((ref) => RecommendationsService());

final relatedTracksProvider = FutureProvider.autoDispose<List<OnlineTrack>>((ref) async {
  final currentSong = ref.watch(playbackProvider).currentSong;
  if (currentSong == null) return [];
  
  final service = ref.read(recommendationsServiceProvider);
  return await service.getRelatedTracks(currentSong);
});

class RecommendationsSection extends ConsumerWidget {
  const RecommendationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relatedAsync = ref.watch(relatedTracksProvider);

    return relatedAsync.when(
      data: (tracks) {
        if (tracks.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(LucideIcons.sparkles, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'You Might Also Like',
                    style: AppFonts.jostStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final track = tracks[index];

                  return Container(
                    width: 120,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: PremiumSection(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(8),
                      useExpanded: false,
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final song = await ref
                            .read(streamingProvider.notifier)
                            .resolveAndCreateSong(track);
                        if (song != null) {
                          ref.read(playbackProvider.notifier).play(song);
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 104,
                              height: 90,
                              child: OptimizedImage(
                                imageUrl: track.thumbnailUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.jostStyle(
                              fontSize: 12,
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
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
