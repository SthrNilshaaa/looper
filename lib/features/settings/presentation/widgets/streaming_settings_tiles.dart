import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/playback_mode_selector.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StreamingModeTile extends ConsumerWidget {
  const StreamingModeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.globe, color: Colors.white70, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SpatialFlow Operational Mode',
                      style: AppFonts.jostStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Switch between Hybrid, Local-only, or Online Streaming mode',
                      style: AppFonts.jostStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Center(
            child: PlaybackModeSelector(compact: false),
          ),
        ],
      ),
    );
  }
}

class StreamingQualityTile extends ConsumerWidget {
  const StreamingQualityTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isHigh = settings.streamingQuality == 1;

    return ListTile(
      leading: const Icon(LucideIcons.sparkles, color: Colors.white70),
      title: Text(
        'Audio Stream Quality',
        style: AppFonts.jostStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      subtitle: Text(
        isHigh ? 'High Quality (256 kbps AAC/Opus)' : 'Low Bandwidth (128 kbps)',
        style: AppFonts.jostStyle(fontSize: 12, color: Colors.white60),
      ),
      trailing: Switch(
        value: isHigh,
        activeColor: Theme.of(context).colorScheme.primary,
        onChanged: (val) {
          HapticFeedback.lightImpact();
          ref.read(settingsProvider.notifier).updateStreamingQuality(val ? 1 : 0);
        },
      ),
    );
  }
}
