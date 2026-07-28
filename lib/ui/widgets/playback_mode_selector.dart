import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/streaming/presentation/streaming_notifier.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PlaybackModeSelector extends ConsumerWidget {
  final bool compact;

  const PlaybackModeSelector({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamingNotifier = ref.watch(streamingProvider.notifier);
    final activeMode = streamingNotifier.currentMode;
    final accentColor = Theme.of(context).colorScheme.primary;

    final items = [
      _ModeItem(
        mode: PlaybackMode.hybrid,
        label: 'Hybrid',
        icon: LucideIcons.shuffle,
      ),
      _ModeItem(
        mode: PlaybackMode.localOnly,
        label: 'Local',
        icon: LucideIcons.hardDrive,
      ),
      _ModeItem(
        mode: PlaybackMode.onlineOnly,
        label: 'Online',
        icon: LucideIcons.globe,
      ),
    ];

    return Container(
      height: compact ? 36 : 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          final isSelected = activeMode == item.mode;

          return GestureDetector(
            onTap: () {
              if (isSelected) return;
              HapticFeedback.lightImpact();
              streamingNotifier.setPlaybackMode(item.mode);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 14,
                vertical: compact ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? accentColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: compact ? 14 : 16,
                    color: isSelected ? Colors.black : Colors.white70,
                  ),
                  if (!compact || isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: AppFonts.jostStyle(
                        fontSize: compact ? 12 : 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.black : Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ModeItem {
  final PlaybackMode mode;
  final String label;
  final IconData icon;

  const _ModeItem({
    required this.mode,
    required this.label,
    required this.icon,
  });
}
