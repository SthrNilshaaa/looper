import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/app_icons.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/core/ui_calculations.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/ui/screens/android/player/widgets/sleep_timer_clock.dart';
import 'package:looper_player/core/player_expand_provider.dart';
import 'package:looper_player/core/ui_utils.dart';

class ExpandedPlayerHeader extends ConsumerWidget {
  final bool enableSlide;
  final dynamic settings;
  final String qualityText;
  final double contentOpacity;
  final VoidCallback onMorePressed;

  const ExpandedPlayerHeader({
    super.key,
    required this.enableSlide,
    required this.settings,
    required this.qualityText,
    required this.contentOpacity,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useBlur = settings.enableDynamicTheming;

    return Opacity(
      opacity: contentOpacity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PremiumSection(
              borderRadius: BorderRadius.circular(32),
              width: 48,
              showShadow: false,
              height: 48,
              forceNoBlur: true,
              useExpanded: false,
              useBlur: true,
              onTap: () {
                HapticFeedback.lightImpact();
                if (enableSlide) {
                  ref.read(playerCollapseTriggerProvider.notifier).update((state) => state + 1);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: SvgPicture.asset(
                AppIcons.close,
                width: 8,
                height: 8,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Now Playing',
                  style: AppFonts.jostStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (settings.showQualityBadge)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      qualityText,
                      style: AppFonts.jostStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            PremiumSection(
              height: 48,
              width: 48,
              useBlur: true,
              useExpanded: false,
              showShadow: false,
              forceNoBlur: true,
              onTap: onMorePressed,
              borderRadius: BorderRadius.circular(32),
              child: _buildSleepTimerOrMore(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepTimerOrMore(BuildContext context, WidgetRef ref) {
    final isSleepActive = ref.watch(playbackProvider.select((s) => s.isSleepTimerActive));
    final durationRemaining = ref.watch(playbackProvider.select((s) => s.sleepTimerDurationRemaining));
    final durationInitial = ref.watch(playbackProvider.select((s) => s.sleepTimerDurationInitial));
    final songsRemaining = ref.watch(playbackProvider.select((s) => s.sleepTimerSongsRemaining));
    final songsInitial = ref.watch(playbackProvider.select((s) => s.sleepTimerSongsInitial));

    if (isSleepActive) {
      final (progress, label) = UiCalculations.getSleepTimerProgress(
        isActive: isSleepActive,
        durationRemaining: durationRemaining,
        durationInitial: durationInitial,
        songsRemaining: songsRemaining,
        songsInitial: songsInitial,
      );

      return SleepTimerClock(
        progress: progress,
        label: label,
        color: Theme.of(context).colorScheme.primary,
      );
    } else {
      return SvgPicture.asset(
        AppIcons.more,
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
        width: AppIcons.morebuttonsize.s,
        height: AppIcons.morebuttonsize.s,
      );
    }
  }
}
