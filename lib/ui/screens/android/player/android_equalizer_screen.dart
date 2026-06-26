import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/providers.dart';
import 'package:looper_player/features/playback/presentation/equalizer_notifier.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AndroidEqualizerScreen extends ConsumerWidget {
  const AndroidEqualizerScreen({super.key});

  static const List<String> _bands = [
    '65Hz',
    '92Hz',
    '131Hz',
    '185Hz',
    '262Hz',
    '370Hz',
    '523Hz',
    '740Hz',
    '1kHz',
    '1.4kHz',
    '2kHz',
    '2.9kHz',
    '4.1kHz',
    '5.9kHz',
    '8.3kHz',
    '11.7kHz',
    '16.6kHz',
    '20kHz'
  ];

  static const Map<String, List<double>> _presets = {
    'Flat': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    'Bass Booster': [5, 5, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    'Treble Booster': [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 4, 5, 5, 5, 5],
    'Vocal Booster': [-2, -2, -1, 0, 1, 2, 3, 4, 4, 4, 3, 2, 1, 0, -1, -2, -2, -2],
    'Electronic': [4, 3, 2, 1, 0, -1, 1, 2, 2, 1, 2, 3, 4, 4, 3, 2, 4, 3],
    'Rock': [3, 3, 2, 1, -1, -2, -2, -1, 0, 1, 2, 2, 3, 3, 3, 3, 3, 3],
    'Pop': [-1, -1, -1, 0, 1, 2, 3, 3, 3, 2, 1, 0, -1, -1, -1, -1, -1, -1],
    'Jazz': [3, 3, 2, 1, 1, 2, 2, 1, -1, -1, 0, 1, 1, 2, 2, 3, 3, 3],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eqState = ref.watch(equalizerProvider);
    final eqNotifier = ref.read(equalizerProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final song = ref.watch(playbackProvider.select((s) => s.currentSong));
    
    final accentColor = Color(settings.accentColor);
    final isPureBlack = settings.darkTheme;
    final useBlur = settings.enableDynamicTheming && !settings.disableBlur;

    return Scaffold(
      backgroundColor: isPureBlack ? Colors.black : const Color(0xFF121212),
      body: Container(
        decoration: BoxDecoration(
          gradient: isPureBlack
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accentColor.withValues(alpha: 0.05),
                    const Color(0xFF121212),
                  ],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Title Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    PremiumSection(
                      borderRadius: BorderRadius.circular(32),
                      width: 48,
                      height: 48,
                      useExpanded: false,
                      showShadow: false,
                      forceNoBlur: true,
                      useBlur: useBlur,
                      keepSurfaceOnDisableBlur: true,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      child: const Icon(LucideIcons.chevronLeft, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Equalizer',
                      style: AppFonts.jostStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(LucideIcons.info, color: Colors.white70, size: 20),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _showAudioCapabilitiesSheet(context, ref);
                      },
                    ),
                    const Spacer(),
                    // Master Switch
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          eqState.enabled ? 'On' : 'Off',
                          style: AppFonts.jostStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: eqState.enabled ? accentColor : Colors.white38,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch.adaptive(
                          value: eqState.enabled,
                          activeThumbColor: accentColor,
                          activeTrackColor: accentColor.withValues(alpha: 0.5),
                          onChanged: (val) {
                            HapticFeedback.mediumImpact();
                            eqNotifier.toggleEqualizer(val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Preset Selector Row
                      if (eqState.enabled) ...[
                        Text(
                          'PRESETS',
                          style: AppFonts.jostStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: Colors.white38,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: _presets.keys.map((name) {
                              final presetGains = _presets[name]!;
                              final isCurrent = _isMatchingPreset(eqState.currentSongGains, presetGains);

                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    eqNotifier.setPreset(name, presetGains);
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isCurrent 
                                          ? accentColor.withValues(alpha: 0.15) 
                                          : Colors.white.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isCurrent 
                                            ? accentColor 
                                            : Colors.white.withValues(alpha: 0.08),
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        name,
                                        style: AppFonts.jostStyle(
                                          fontSize: 13,
                                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                          color: isCurrent ? accentColor : Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Currently Playing Custom Config Details
                      if (song != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Row(
                            children: [
                              OptimizedImage(
                                imagePath: song.artPath,
                                width: 44,
                                height: 44,
                                borderRadius: BorderRadius.circular(8),
                                placeholder: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(LucideIcons.music, color: Colors.white30, size: 20),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song.title,
                                      style: AppFonts.jostStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      eqState.currentSongHasCustom
                                          ? 'Song-specific settings active'
                                          : 'Using global settings default',
                                      style: AppFonts.jostStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: eqState.currentSongHasCustom ? accentColor : Colors.white38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (eqState.currentSongHasCustom && eqState.enabled)
                                TextButton.icon(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    eqNotifier.resetCurrentSongToDefault();
                                  },
                                  icon: Icon(LucideIcons.undo2, color: accentColor, size: 14),
                                  label: Text(
                                    'Reset',
                                    style: AppFonts.jostStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // 18-Band Sliders Scrollable Container
                      Text(
                        '18-BAND EQUALIZER (SCROLL HORIZONTALLY)',
                        style: AppFonts.jostStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: Colors.white38,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 290,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Container(
                            width: 18 * 45.0, // Ensures plenty of breathing room for 18 sliders
                            child: Column(
                              children: [
                                // dB Labels Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: List.generate(18, (index) {
                                    final gain = eqState.currentSongGains[index];
                                    return Expanded(
                                      child: Center(
                                        child: Text(
                                          '${gain.round() > 0 ? "+" : ""}${gain.round()}',
                                          style: AppFonts.jostStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: eqState.enabled ? Colors.white60 : Colors.white24,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 12),

                                // Sliders and Curve Stack
                                Expanded(
                                  child: Stack(
                                    children: [
                                      // Bezier EQ Curve Drawing
                                      if (eqState.enabled)
                                        Positioned.fill(
                                          child: IgnorePointer(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(24),
                                              child: CustomPaint(
                                                painter: EqualizerCurvePainter(
                                                  gains: eqState.currentSongGains.sublist(0, 18),
                                                  color: accentColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                      // Sliders Horizontal Layout
                                      Positioned.fill(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: List.generate(18, (index) {
                                            return Expanded(
                                              child: EqualizerSliderTrack(
                                                gain: eqState.currentSongGains[index],
                                                enabled: eqState.enabled,
                                                onChanged: (val) {
                                                  // Snap to zero logic
                                                  double finalizedVal = val;
                                                  if (val.abs() < 0.8) {
                                                    finalizedVal = 0.0;
                                                  }

                                                  final oldInt = eqState.currentSongGains[index].round();
                                                  final newInt = finalizedVal.round();

                                                  if (newInt != oldInt) {
                                                    if (newInt == 0) {
                                                      HapticFeedback.mediumImpact(); // Snapped to zero!
                                                    }
                                                  }
                                                  eqNotifier.setBandGain(index, finalizedVal);
                                                },
                                                onDragEnd: () {
                                                  eqNotifier.applyEqualizerInstant();
                                                },
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Band Frequency Labels Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: List.generate(18, (index) {
                                    return Expanded(
                                      child: Center(
                                        child: Text(
                                          _bands[index],
                                          style: AppFonts.jostStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: eqState.enabled ? Colors.white60 : Colors.white24,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Pre-amp & Volume Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Pre-amp Slider
                            if (eqState.enabled) ...[
                              Row(
                                children: [
                                  Icon(LucideIcons.sliders, color: accentColor.withValues(alpha: 0.8), size: 18),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Pre-amp Gain',
                                    style: AppFonts.jostStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${eqState.preampGain.round() > 0 ? "+" : ""}${eqState.preampGain.round()} dB',
                                    style: AppFonts.jostStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: accentColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: accentColor,
                                  inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
                                  thumbColor: Colors.white,
                                  trackHeight: 3.5,
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                                ),
                                child: Slider(
                                  value: eqState.preampGain,
                                  min: -12.0,
                                  max: 12.0,
                                  divisions: 24,
                                  onChanged: (val) {
                                    double finalized = val;
                                    if (val.abs() < 0.5) finalized = 0.0;
                                    if (eqState.preampGain.round() != finalized.round() && finalized.round() == 0) {
                                      HapticFeedback.mediumImpact();
                                    }
                                    eqNotifier.setBandGain(18, finalized);
                                  },
                                  onChangeEnd: (_) {
                                    eqNotifier.applyEqualizerInstant();
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Volume Slider
                            Row(
                              children: [
                                Icon(
                                  ref.watch(playbackProvider.select((s) => s.volume)) == 0
                                      ? LucideIcons.volumeX
                                      : LucideIcons.volume2,
                                  color: accentColor.withValues(alpha: 0.8),
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Output Volume',
                                  style: AppFonts.jostStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${(ref.watch(playbackProvider.select((s) => s.volume)) * 100).round()}%',
                                  style: AppFonts.jostStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: accentColor,
                                inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
                                thumbColor: Colors.white,
                                trackHeight: 3.5,
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                              ),
                              child: Slider(
                                value: ref.watch(playbackProvider.select((s) => s.volume)),
                                min: 0.0,
                                max: 1.0,
                                onChanged: (val) {
                                  ref.read(playbackProvider.notifier).setVolume(val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Advanced DSP Panels (Only visible when EQ is enabled)
                      if (eqState.enabled) ...[
                        // 1. Dynamic Range Compressor
                        DspCard(
                          title: 'Dynamic Range Compressor',
                          icon: LucideIcons.sliders,
                          trailing: Switch.adaptive(
                            value: eqState.compressorEnabled,
                            activeThumbColor: accentColor,
                            activeTrackColor: accentColor.withValues(alpha: 0.35),
                            onChanged: (val) {
                              HapticFeedback.mediumImpact();
                              eqNotifier.setCompressorEnabled(val);
                            },
                          ),
                           children: [
                            Opacity(
                              opacity: eqState.compressorEnabled ? 1.0 : 0.4,
                              child: IgnorePointer(
                                ignoring: !eqState.compressorEnabled,
                                child: Column(
                                  children: [
                                    _buildSliderRow(
                                      title: 'Threshold',
                                      value: eqState.compressorThreshold,
                                      min: -40.0,
                                      max: 0.0,
                                      unit: 'dB',
                                      onChanged: (v) => eqNotifier.setCompressorThreshold(v),
                                    ),
                                    _buildSliderRow(
                                      title: 'Ratio',
                                      value: eqState.compressorRatio,
                                      min: 1.0,
                                      max: 20.0,
                                      unit: ':1',
                                      onChanged: (v) => eqNotifier.setCompressorRatio(v),
                                    ),
                                    _buildSliderRow(
                                      title: 'Attack',
                                      value: eqState.compressorAttack,
                                      min: 0.01,
                                      max: 100.0, // Clamped display range for attack
                                      unit: 'ms',
                                      onChanged: (v) => eqNotifier.setCompressorAttack(v),
                                    ),
                                    _buildSliderRow(
                                      title: 'Release',
                                      value: eqState.compressorRelease,
                                      min: 10.0,
                                      max: 1000.0, // Clamped display range for release
                                      unit: 'ms',
                                      onChanged: (v) => eqNotifier.setCompressorRelease(v),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // 2. Spatial & Binaural Width
                        DspCard(
                          title: 'Headphone Crossfeed & Width',
                          icon: LucideIcons.headphones,
                          children: [
                            _buildSwitchRow(
                              title: 'Binaural Crossfeed',
                              value: eqState.crossfeedEnabled,
                              onChanged: (val) => eqNotifier.setCrossfeedEnabled(val),
                              accentColor: accentColor,
                            ),
                            if (eqState.crossfeedEnabled)
                              _buildSliderRow(
                                title: 'Crossfeed Strength',
                                value: eqState.crossfeedStrength,
                                min: 0.0,
                                max: 1.0,
                                unit: '',
                                onChanged: (v) => eqNotifier.setCrossfeedStrength(v),
                              ),
                            const SizedBox(height: 12),
                            _buildSwitchRow(
                              title: 'Stereo Widening',
                              value: eqState.stereoWidthEnabled,
                              onChanged: (val) => eqNotifier.setStereoWidthEnabled(val),
                              accentColor: accentColor,
                            ),
                            if (eqState.stereoWidthEnabled)
                              _buildSliderRow(
                                title: 'Widening Factor',
                                value: eqState.stereoWidthFactor,
                                min: -10.0,
                                max: 10.0,
                                unit: 'x',
                                onChanged: (v) => eqNotifier.setStereoWidthFactor(v),
                              ),
                          ],
                        ),

                        // 3. Loudness Normalization
                        DspCard(
                          title: 'Loudness Normalization',
                          icon: LucideIcons.volume2,
                          trailing: Switch.adaptive(
                            value: eqState.loudnormEnabled,
                            activeThumbColor: accentColor,
                            activeTrackColor: accentColor.withValues(alpha: 0.35),
                            onChanged: (val) {
                              HapticFeedback.mediumImpact();
                              eqNotifier.setLoudnormEnabled(val);
                            },
                          ),
                          children: [
                            Opacity(
                              opacity: eqState.loudnormEnabled ? 1.0 : 0.4,
                              child: IgnorePointer(
                                ignoring: !eqState.loudnormEnabled,
                                child: Column(
                                  children: [
                                    _buildSliderRow(
                                      title: 'Target Loudness',
                                      value: eqState.loudnormTarget,
                                      min: -30.0,
                                      max: -5.0,
                                      unit: 'LUFS',
                                      onChanged: (v) => eqNotifier.setLoudnormTarget(v),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // 4. Tone Shelving
                        DspCard(
                          title: 'Tone Shelving (Bass / Treble)',
                          icon: LucideIcons.music4,
                          trailing: Switch.adaptive(
                            value: eqState.shelvingEnabled,
                            activeThumbColor: accentColor,
                            activeTrackColor: accentColor.withValues(alpha: 0.35),
                            onChanged: (val) {
                              HapticFeedback.mediumImpact();
                              eqNotifier.setShelvingEnabled(val);
                            },
                          ),
                          children: [
                            Opacity(
                              opacity: eqState.shelvingEnabled ? 1.0 : 0.4,
                              child: IgnorePointer(
                                ignoring: !eqState.shelvingEnabled,
                                child: Column(
                                  children: [
                                    _buildSliderRow(
                                      title: 'Bass Shelf',
                                      value: eqState.bassGain,
                                      min: -10.0,
                                      max: 15.0,
                                      unit: 'dB',
                                      onChanged: (v) => eqNotifier.setBassGain(v),
                                    ),
                                    _buildSliderRow(
                                      title: 'Treble Shelf',
                                      value: eqState.trebleGain,
                                      min: -10.0,
                                      max: 15.0,
                                      unit: 'dB',
                                      onChanged: (v) => eqNotifier.setTrebleGain(v),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // 5. Speed & Pitch Rubberband
                        DspCard(
                          title: 'Tempo & Pitch Controls',
                          icon: LucideIcons.gauge,
                          trailing: Switch.adaptive(
                            value: eqState.pitchTempoEnabled,
                            activeThumbColor: accentColor,
                            activeTrackColor: accentColor.withValues(alpha: 0.35),
                            onChanged: (val) {
                              HapticFeedback.mediumImpact();
                              eqNotifier.setPitchTempoEnabled(val);
                            },
                          ),
                          children: [
                            Opacity(
                              opacity: eqState.pitchTempoEnabled ? 1.0 : 0.4,
                              child: IgnorePointer(
                                ignoring: !eqState.pitchTempoEnabled,
                                child: Column(
                                  children: [
                                    _buildSliderRow(
                                      title: 'Pitch Shift',
                                      value: eqState.pitch,
                                      min: 0.5,
                                      max: 2.0,
                                      unit: 'x',
                                      onChanged: (v) => eqNotifier.setPitch(v),
                                    ),
                                    _buildSliderRow(
                                      title: 'Tempo Speed',
                                      value: eqState.tempo,
                                      min: 0.5,
                                      max: 3.0,
                                      unit: 'x',
                                      onChanged: (v) => eqNotifier.setTempo(v),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // 6. Silence Trim & Speech Filter
                        DspCard(
                          title: 'Voice & Silence controls',
                          icon: LucideIcons.smile,
                          children: [
                            _buildSwitchRow(
                              title: 'Silence Trimming',
                              value: eqState.silenceTrimEnabled,
                              onChanged: (val) => eqNotifier.setSilenceTrimEnabled(val),
                              accentColor: accentColor,
                            ),
                            if (eqState.silenceTrimEnabled)
                              _buildSliderRow(
                                title: 'Silence Threshold',
                                value: eqState.silenceTrimThreshold,
                                min: -60.0,
                                max: -30.0,
                                unit: 'dB',
                                onChanged: (v) => eqNotifier.setSilenceTrimThreshold(v),
                              ),
                            const SizedBox(height: 12),
                            _buildSwitchRow(
                              title: 'Speech Enhancement Filter',
                              value: eqState.speechFilterEnabled,
                              onChanged: (val) => eqNotifier.setSpeechFilterEnabled(val),
                              accentColor: accentColor,
                            ),
                            if (eqState.speechFilterEnabled) ...[
                              _buildSliderRow(
                                title: 'Highpass Cutoff',
                                value: eqState.speechHighpass,
                                min: 100.0,
                                max: 300.0,
                                unit: 'Hz',
                                onChanged: (v) => eqNotifier.setSpeechHighpass(v),
                              ),
                              _buildSliderRow(
                                title: 'Lowpass Cutoff',
                                value: eqState.speechLowpass,
                                min: 3000.0,
                                max: 6000.0,
                                unit: 'Hz',
                                onChanged: (v) => eqNotifier.setSpeechLowpass(v),
                              ),
                            ],
                          ],
                        ),

                        // 7. Creative Retro & Environment Effects
                        DspCard(
                          title: 'Retro & Room Effects',
                          icon: LucideIcons.sparkles,
                          children: [
                            _buildSwitchRow(
                              title: 'Lofi Effect (8-bit Crusher)',
                              value: eqState.lofiEnabled,
                              onChanged: (val) => eqNotifier.setLofiEnabled(val),
                              accentColor: accentColor,
                            ),
                            const SizedBox(height: 12),
                            _buildSwitchRow(
                              title: 'Studio Room Reverb (Echo)',
                              value: eqState.reverbEnabled,
                              onChanged: (val) => eqNotifier.setReverbEnabled(val),
                              accentColor: accentColor,
                            ),
                            const SizedBox(height: 12),
                            _buildSwitchRow(
                              title: 'Virtual 5.1 Surround Sound',
                              value: eqState.surroundEnabled,
                              onChanged: (val) => eqNotifier.setSurroundEnabled(val),
                              accentColor: accentColor,
                            ),
                          ],
                        ),

                        // 8. Custom FFMpeg AF Console
                        DspCard(
                          title: 'Raw FFMpeg Filter console',
                          icon: LucideIcons.terminal,
                          children: [
                            Text(
                              'Type custom libavfilter audio filter parameters directly (e.g. volume=3dB, aecho=0.8:0.88:60:0.4):',
                              style: AppFonts.jostStyle(fontSize: 12, color: Colors.white54),
                            ),
                            const SizedBox(height: 12),
                            _CustomFilterInput(
                              initialValue: eqState.customFilterString,
                              onSubmitted: (filter) => eqNotifier.setCustomFilterString(filter),
                              accentColor: accentColor,
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Flow & Global Actions Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header Row
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.gitMerge,
                                  color: accentColor.withValues(alpha: 0.8),
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Flow & Global Actions',
                                  style: AppFonts.jostStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Status / Mode Row
                            Row(
                              children: [
                                Text(
                                  'Equalizer Mode:',
                                  style: AppFonts.jostStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (song != null && eqState.currentSongHasCustom)
                                        ? accentColor.withValues(alpha: 0.15)
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: (song != null && eqState.currentSongHasCustom)
                                          ? accentColor
                                          : Colors.white.withValues(alpha: 0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    (song != null && eqState.currentSongHasCustom)
                                        ? 'Song-Specific'
                                        : 'Global Default',
                                    style: AppFonts.jostStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: (song != null && eqState.currentSongHasCustom)
                                          ? accentColor
                                          : Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Action buttons: "Apply to Global" and "Reset Song to Global"
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: eqState.enabled
                                        ? () async {
                                            HapticFeedback.mediumImpact();
                                            await eqNotifier.applyCurrentGainsToGlobal();
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Current gains applied as global default settings.',
                                                    style: AppFonts.jostStyle(color: Colors.white),
                                                  ),
                                                  backgroundColor: accentColor,
                                                ),
                                              );
                                            }
                                          }
                                        : null,
                                    icon: Icon(LucideIcons.globe, size: 14, color: eqState.enabled ? accentColor : Colors.white24),
                                    label: Text(
                                      'Apply to Global',
                                      style: AppFonts.jostStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: eqState.enabled ? Colors.white : Colors.white24,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor: eqState.enabled
                                          ? Colors.white.withValues(alpha: 0.04)
                                          : Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                if (song != null && eqState.currentSongHasCustom && eqState.enabled) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: () async {
                                        HapticFeedback.mediumImpact();
                                        await eqNotifier.resetCurrentSongToDefault();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Song-specific settings reset to global default.',
                                                style: AppFonts.jostStyle(color: Colors.white),
                                              ),
                                              backgroundColor: accentColor,
                                            ),
                                          );
                                        }
                                      },
                                      icon: Icon(LucideIcons.undo2, size: 14, color: accentColor),
                                      label: Text(
                                        'Reset to Global',
                                        style: AppFonts.jostStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.white.withValues(alpha: 0.04),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(color: Colors.white10, height: 1),
                            ),

                            // Reset All Songs Equalizer Data
                            TextButton.icon(
                              onPressed: () async {
                                HapticFeedback.heavyImpact();
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: isPureBlack ? Colors.black : const Color(0xFF1E1E1E),
                                    title: Text(
                                      'Reset All Songs EQ',
                                      style: AppFonts.jostStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    content: Text(
                                      'Are you sure you want to clear custom equalizer settings for all songs in your library?',
                                      style: AppFonts.jostStyle(color: Colors.white70),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text(
                                          'Cancel',
                                          style: AppFonts.jostStyle(color: Colors.white38),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: Text(
                                          'Reset',
                                          style: AppFonts.jostStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await eqNotifier.resetAllSongsEqualizerData();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'All song-specific equalizer data has been reset.',
                                          style: AppFonts.jostStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.redAccent),
                              label: Text(
                                'Reset All Songs EQ Data',
                                style: AppFonts.jostStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.redAccent.withValues(alpha: 0.08),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text(
                        'Edits made when a song is playing apply to that song only. To set the global default, edit when no song is playing, or use the \'Apply to Global\' action.',
                        style: AppFonts.jostStyle(
                          fontSize: 12,
                          color: Colors.white38,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isMatchingPreset(List<double> current, List<double> preset) {
    for (int i = 0; i < 18; i++) {
      final curGain = i < current.length ? current[i] : 0.0;
      final preGain = i < preset.length ? preset[i] : 0.0;
      if ((curGain - preGain).abs() > 0.5) return false;
    }
    return true;
  }

  Widget _buildSwitchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color accentColor,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: AppFonts.jostStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Switch.adaptive(
          value: value,
          activeThumbColor: accentColor,
          activeTrackColor: accentColor.withValues(alpha: 0.35),
          onChanged: (val) {
            HapticFeedback.mediumImpact();
            onChanged(val);
          },
        ),
      ],
    );
  }

  Widget _buildSliderRow({
    required String title,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AppFonts.jostStyle(fontSize: 12, color: Colors.white54),
              ),
              const Spacer(),
              Text(
                '${value.toStringAsFixed(1)} $unit',
                style: AppFonts.jostStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.white24,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.05),
              thumbColor: Colors.white,
              trackHeight: 2.0,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

void _showAudioCapabilitiesSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) {
      final settings = ref.read(settingsProvider);
      final isPureBlack = settings.darkTheme;
      final accentColor = Color(settings.accentColor);
      final useBlur = settings.enableDynamicTheming && !settings.disableBlur;
      final sheetBg = isPureBlack
          ? Colors.black
          : (useBlur ? Colors.black.withValues(alpha: 0.6) : const Color(0xFF1E1E1E));

      return FutureBuilder<Map<String, String>>(
        future: ref.read(audioServiceProvider).getAudioOutputCapabilities(),
        builder: (context, snapshot) {
          final capabilities = snapshot.data ?? {};
          Widget sheetContent = Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: isPureBlack ? Colors.white10 : Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(LucideIcons.activity, color: accentColor, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      'Device Audio Capabilities',
                      style: AppFonts.jostStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white10),
                const SizedBox(height: 12),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (capabilities.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      'No playback active or capabilities information unavailable.',
                      style: AppFonts.jostStyle(color: Colors.white38, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: capabilities.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Text(
                                  entry.key,
                                  style: AppFonts.jostStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                const Spacer(),
                                Text(
                                  entry.value,
                                  style: AppFonts.jostStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          );

          if (useBlur && !isPureBlack) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: sheetContent,
              ),
            );
          }
          return sheetContent;
        },
      );
    },
  );
}

class DspCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final List<Widget> children;
  final bool initialExpanded;

  const DspCard({
    required this.title,
    required this.icon,
    this.trailing,
    required this.children,
    this.initialExpanded = false,
    super.key,
  });

  @override
  State<DspCard> createState() => _DspCardState();
}

class _DspCardState extends State<DspCard> {
  late bool _expanded = widget.initialExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _expanded = !_expanded;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(widget.icon, color: Colors.white70, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    widget.title,
                    style: AppFonts.jostStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  if (widget.trailing != null) widget.trailing!,
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _expanded ? 0.5 : 0,
                    child: const Icon(LucideIcons.chevronDown, color: Colors.white30, size: 18),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.children,
              ),
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _CustomFilterInput extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onSubmitted;
  final Color accentColor;

  const _CustomFilterInput({
    required this.initialValue,
    required this.onSubmitted,
    required this.accentColor,
  });

  @override
  State<_CustomFilterInput> createState() => _CustomFilterInputState();
}

class _CustomFilterInputState extends State<_CustomFilterInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            style: AppFonts.jostStyle(fontSize: 13, color: Colors.white),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Raw filter parameters...',
              hintStyle: AppFonts.jostStyle(fontSize: 13, color: Colors.white30),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: widget.onSubmitted,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            widget.onSubmitted(_controller.text);
          },
          icon: Icon(LucideIcons.check, color: widget.accentColor),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.04),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class EqualizerSliderTrack extends StatelessWidget {
  final double gain;
  final ValueChanged<double> onChanged;
  final VoidCallback? onDragEnd;
  final bool enabled;

  const EqualizerSliderTrack({
    required this.gain,
    required this.onChanged,
    this.onDragEnd,
    required this.enabled,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final percent = ((gain + 20) / 40).clamp(0.0, 1.0);
    final accentColor = Theme.of(context).colorScheme.primary;

    return Opacity(
      opacity: enabled ? 1.0 : 0.35,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackHeight = constraints.maxHeight - 16;
          final centerProgressY = trackHeight * 0.5;
          final thumbY = (1.0 - percent) * trackHeight;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: enabled
                ? (details) {
                    final RenderBox renderBox = context.findRenderObject() as RenderBox;
                    final localPos = renderBox.globalToLocal(details.globalPosition);
                    final dragY = (localPos.dy - 8).clamp(0.0, trackHeight);
                    final newPercent = (1.0 - (dragY / trackHeight)).clamp(0.0, 1.0);
                    onChanged((newPercent * 40.0) - 20.0);
                  }
                : null,
            onVerticalDragEnd: enabled ? (_) => onDragEnd?.call() : null,
            onVerticalDragCancel: enabled ? () => onDragEnd?.call() : null,
            onTapDown: enabled
                ? (details) {
                    final RenderBox renderBox = context.findRenderObject() as RenderBox;
                    final localPos = renderBox.globalToLocal(details.globalPosition);
                    final dragY = (localPos.dy - 8).clamp(0.0, trackHeight);
                    final newPercent = (1.0 - (dragY / trackHeight)).clamp(0.0, 1.0);
                    onChanged((newPercent * 40.0) - 20.0);
                  }
                : null,
            onTapUp: enabled ? (_) => onDragEnd?.call() : null,
            child: Container(
              width: 32,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Full background pill
                  Container(
                    width: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Center zero line
                  Positioned(
                    top: centerProgressY + 8,
                    child: Container(
                      width: 14,
                      height: 1.5,
                      color: Colors.white30,
                    ),
                  ),
                  // Active fill from center
                  Positioned(
                    top: percent >= 0.5 ? thumbY + 8 : centerProgressY + 8,
                    bottom: percent >= 0.5 ? trackHeight - centerProgressY + 8 : trackHeight - thumbY + 8,
                    child: Container(
                      width: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            accentColor,
                            accentColor.withValues(alpha: 0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  // Thumb Handle
                  Positioned(
                    top: thumbY,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (enabled)
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                        ],
                        border: Border.all(
                          color: accentColor,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class EqualizerCurvePainter extends CustomPainter {
  final List<double> gains;
  final Color color;

  EqualizerCurvePainter({required this.gains, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (gains.length < 2) return;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    final path = Path();
    final colWidth = size.width / gains.length;

    final trackTop = 8.0;
    final trackBottom = size.height - 8.0;
    final trackHeight = trackBottom - trackTop;

    double getMappedY(double gain) {
      final percent = ((gain + 20) / 40).clamp(0.0, 1.0);
      final thumbBottom = percent * trackHeight;
      return trackBottom - thumbBottom;
    }

    double getMappedX(int index) {
      return (index + 0.5) * colWidth;
    }

    path.moveTo(getMappedX(0), getMappedY(gains[0]));

    for (int i = 0; i < gains.length - 1; i++) {
      final x1 = getMappedX(i);
      final y1 = getMappedY(gains[i]);
      final x2 = getMappedX(i + 1);
      final y2 = getMappedY(gains[i + 1]);

      final stepX = x2 - x1;
      final cx1 = x1 + stepX / 2;
      final cy1 = y1;
      final cx2 = x2 - stepX / 2;
      final cy2 = y2;

      path.cubicTo(cx1, cy1, cx2, cy2, x2, y2);
    }

    // Shadow glow
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.drawPath(path, paint);

    // Fill under path
    final fillPath = Path.from(path)
      ..lineTo(getMappedX(gains.length - 1), trackBottom)
      ..lineTo(getMappedX(0), trackBottom)
      ..close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withValues(alpha: 0.12),
        color.withValues(alpha: 0.0),
      ],
    );
    fillPaint.shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(EqualizerCurvePainter oldDelegate) {
    return oldDelegate.gains != gains || oldDelegate.color != color;
  }
}
