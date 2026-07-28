import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/playback/presentation/equalizer_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SpatialFlowAudioEffectsSheet extends ConsumerWidget {
  const SpatialFlowAudioEffectsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eqState = ref.watch(equalizerProvider);
    final eqNotifier = ref.read(equalizerProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF14141E).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sliders, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'SpatialFlow DSP Audio Suite',
                style: AppFonts.jostStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Spacer(),
              Switch(
                value: eqState.enabled,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  ref.read(settingsProvider.notifier).updateEqualizerEnabled(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildEffectSlider(
                    title: 'Bass Boost',
                    icon: LucideIcons.disc,
                    value: eqState.bassGain,
                    min: -10,
                    max: 10,
                    onChanged: (val) => eqNotifier.setBassGain(val),
                  ),
                  _buildEffectSlider(
                    title: 'Treble Enhancer',
                    icon: LucideIcons.sparkles,
                    value: eqState.trebleGain,
                    min: -10,
                    max: 10,
                    onChanged: (val) => eqNotifier.setTrebleGain(val),
                  ),
                  _buildEffectSlider(
                    title: 'Playback Pitch',
                    icon: LucideIcons.music,
                    value: eqState.pitch,
                    min: 0.5,
                    max: 1.5,
                    onChanged: (val) => eqNotifier.setPitch(val),
                  ),
                  _buildEffectSlider(
                    title: 'Playback Tempo',
                    icon: LucideIcons.zap,
                    value: eqState.tempo,
                    min: 0.5,
                    max: 1.5,
                    onChanged: (val) => eqNotifier.setTempo(val),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectSlider({
    required String title,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: PremiumSection(
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(12),
        useExpanded: false,
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.jostStyle(fontSize: 14, color: Colors.white),
                  ),
                  Slider(
                    value: value.clamp(min, max),
                    min: min,
                    max: max,
                    onChanged: onChanged,
                  ),
                ],
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: AppFonts.jostStyle(fontSize: 12, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}
