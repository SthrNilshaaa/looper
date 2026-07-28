import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'settings_widgets.dart';
import 'settings_dialogs.dart';

class DynamicThemingTile extends ConsumerWidget {
  const DynamicThemingTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.palette, color: Colors.white70),
      title: Text(
        l10n.dynamicTheming,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.adaptColorsArtwork,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.enableDynamicTheming,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateDynamicTheming(value);
      },
    );
  }
}

class DisableBlurTile extends ConsumerWidget {
  const DisableBlurTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.eyeOff, color: Colors.white70),
      title: Text(
        l10n.disableBlurEffects,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.turnOffBlursOptimize,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.disableBlur,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateDisableBlur(value);
      },
    );
  }
}

class DynamicAccentColorTile extends ConsumerWidget {
  const DynamicAccentColorTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return SwitchListTile(
      secondary: const Icon(LucideIcons.paintBucket, color: Colors.white70),
      title: Text(
        'Dynamic Accent Color',
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        'Update only the accent color dynamically from the artwork',
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.dynamicAccentColor,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateDynamicAccentColor(value);
      },
    );
  }
}

class PureBlackOledTile extends ConsumerWidget {
  const PureBlackOledTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.moon, color: Colors.white70),
      title: Text(
        l10n.pureBlackOled,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.useAbsoluteBlackBg,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.darkTheme,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateDarkTheme(value);
      },
    );
  }
}

class AccentColorTile extends ConsumerWidget {
  const AccentColorTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(LucideIcons.droplet, color: Colors.white70),
      title: Text(
        l10n.accentColor,
        style: _tileTitleStyle(),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorCircle(
            color: const Color(0xFF41C25E),
            isSelected: settings.accentColor == 0xFF41C25E,
            onTap: () => ref
                .read(settingsProvider.notifier)
                .updateAccentColor(0xFF41C25E),
          ),
          const SizedBox(width: 8),
          ColorCircle(
            color: const Color(0xFFF7EAA6),
            isSelected: settings.accentColor == 0xFFF7EAA6,
            onTap: () => ref
                .read(settingsProvider.notifier)
                .updateAccentColor(0xFFF7EAA6),
          ),
          const SizedBox(width: 8),
          ColorCircle(
            color: Colors.blueAccent,
            isSelected: settings.accentColor == Colors.blueAccent.value,
            onTap: () => ref
                .read(settingsProvider.notifier)
                .updateAccentColor(Colors.blueAccent.value),
          ),
        ],
      ),
    );
  }
}

class CustomAccentColorTile extends ConsumerWidget {
  const CustomAccentColorTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(LucideIcons.palette, color: Colors.white70),
      title: Text(
        l10n.customAccentColor,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.selectCustomColor,
        style: _tileSubtitleStyle(),
      ),
      trailing: ColorCircle(
        color: Color(settings.accentColor),
        isSelected:
            settings.accentColor != 0xFF41C25E &&
            settings.accentColor != 0xFFF7EAA6 &&
            settings.accentColor != Colors.blueAccent.value,
        onTap: () => showCustomColorPicker(
          context,
          ref,
          Color(settings.accentColor),
        ),
      ),
      onTap: () => showCustomColorPicker(
        context,
        ref,
        Color(settings.accentColor),
      ),
    );
  }
}

class DynamicLyricsBgTile extends ConsumerWidget {
  const DynamicLyricsBgTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.music, color: Colors.white70),
      title: Text(
        l10n.dynamicLyricsBg,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.dynamicBgOnlyLyrics,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.dynamicLyrics,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateDynamicLyrics(value);
      },
    );
  }
}

class BlurredArtworkLyricsTile extends ConsumerWidget {
  const BlurredArtworkLyricsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return SwitchListTile(
      secondary: const Icon(LucideIcons.image, color: Colors.white70),
      title: Text(
        'Blurred Artwork for Lyrics',
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        'Show blurred album art as background instead of dynamic/static gradient',
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.blurredArtworkForLyrics,
      onChanged: (value) {
        ref
            .read(settingsProvider.notifier)
            .updateBlurredArtworkForLyrics(value);
      },
    );
  }
}

class DynamicColorActiveLyricsTile extends ConsumerWidget {
  const DynamicColorActiveLyricsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.palette, color: Colors.white70),
      title: Text(
        l10n.dynamicColorActiveLyrics,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.dynamicColorActiveLyricsDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.dynamicColorActiveLyrics,
      onChanged: (value) {
        ref
            .read(settingsProvider.notifier)
            .updateDynamicColorActiveLyrics(value);
      },
    );
  }
}

class LyricsAlignmentTile extends ConsumerWidget {
  const LyricsAlignmentTile({super.key});

  Widget _buildAlignmentButton({
    required BuildContext context,
    required WidgetRef ref,
    required String alignment,
    required IconData icon,
    required String currentAlignment,
    required Color accentColor,
  }) {
    final isSelected = currentAlignment == alignment;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(settingsProvider.notifier).updateLyricsAlignment(alignment);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.black : Colors.white70,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(LucideIcons.alignCenter, color: Colors.white70),
      title: Text(
        l10n.lyricsAlignment,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.lyricsAlignmentDesc,
        style: _tileSubtitleStyle(),
      ),
      trailing: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10, width: 0.5),
        ),
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAlignmentButton(
              context: context,
              ref: ref,
              alignment: 'left',
              icon: LucideIcons.alignLeft,
              currentAlignment: settings.lyricsAlignment,
              accentColor: Color(settings.accentColor),
            ),
            _buildAlignmentButton(
              context: context,
              ref: ref,
              alignment: 'center',
              icon: LucideIcons.alignCenter,
              currentAlignment: settings.lyricsAlignment,
              accentColor: Color(settings.accentColor),
            ),
            _buildAlignmentButton(
              context: context,
              ref: ref,
              alignment: 'right',
              icon: LucideIcons.alignRight,
              currentAlignment: settings.lyricsAlignment,
              accentColor: Color(settings.accentColor),
            ),
          ],
        ),
      ),
    );
  }
}

class FlatProgressBarTile extends ConsumerWidget {
  const FlatProgressBarTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.sliders, color: Colors.white70),
      title: Text(
        l10n.flatProgressBar,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.disableSquigglyProgressBar,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.disableSquiggle,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateDisableSquiggle(value);
      },
    );
  }
}

class PlainTimestampsTile extends ConsumerWidget {
  const PlainTimestampsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.clock, color: Colors.white70),
      title: Text(
        l10n.plainTimestamps,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.useStaticTextTimestamps,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.disableAnimatedDuration,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateDisableAnimatedDuration(value);
      },
    );
  }
}

class ShowQualityBadgeTile extends ConsumerWidget {
  const ShowQualityBadgeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.info, color: Colors.white70),
      title: Text(
        l10n.showQualityBadge,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.showQualityBadgeDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.showQualityBadge,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateShowQualityBadge(value);
      },
    );
  }
}

class EnablePlayerGradientTile extends ConsumerWidget {
  const EnablePlayerGradientTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.sparkles, color: Colors.white70),
      title: Text(
        l10n.enablePlayerGradient,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.enablePlayerGradientDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.enablePlayerGradient,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateEnablePlayerGradient(value);
      },
    );
  }
}

class KeepBackgroundGradientTile extends ConsumerWidget {
  const KeepBackgroundGradientTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.layers, color: Colors.white70),
      title: Text(
        l10n.keepBackgroundGradient,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.keepBackgroundGradientDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.keepBackgroundGradient,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateKeepBackgroundGradient(value);
      },
    );
  }
}

class PerformanceOptimizerTile extends ConsumerWidget {
  const PerformanceOptimizerTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return SwitchListTile(
      secondary: const Icon(LucideIcons.activity, color: Colors.white70),
      title: Text(
        'Performance Optimizer Dashboard',
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        'Show real-time performance optimizer stats overlay',
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.showPerformanceOptimizer,
      onChanged: (value) {
        ref
            .read(settingsProvider.notifier)
            .updateShowPerformanceOptimizer(value);
      },
    );
  }
}

class HomeDarknessSlider extends ConsumerWidget {
  const HomeDarknessSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SettingsSliderTile(
      icon: LucideIcons.home,
      title: l10n.homeDarkness,
      subtitle: l10n.homeDarknessDesc,
      value: (settings.homeDarkness.isNaN ? 0.72 : settings.homeDarkness) * 100,
      min: 0.0,
      max: 100.0,
      divisions: 100,
      suffix: '%',
      onChanged: (val) {
        ref.read(settingsProvider.notifier).updateHomeDarkness(val / 100.0);
      },
    );
  }
}

class SongsDarknessSlider extends ConsumerWidget {
  const SongsDarknessSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SettingsSliderTile(
      icon: LucideIcons.music,
      title: l10n.songsDarkness,
      subtitle: l10n.songsDarknessDesc,
      value: (settings.songsDarkness.isNaN ? 0.72 : settings.songsDarkness) * 100,
      min: 0.0,
      max: 100.0,
      divisions: 100,
      suffix: '%',
      onChanged: (val) {
        ref.read(settingsProvider.notifier).updateSongsDarkness(val / 100.0);
      },
    );
  }
}

class LibraryDarknessSlider extends ConsumerWidget {
  const LibraryDarknessSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SettingsSliderTile(
      icon: LucideIcons.library,
      title: l10n.libraryDarkness,
      subtitle: l10n.libraryDarknessDesc,
      value: (settings.libraryDarkness.isNaN ? 0.72 : settings.libraryDarkness) * 100,
      min: 0.0,
      max: 100.0,
      divisions: 100,
      suffix: '%',
      onChanged: (val) {
        ref.read(settingsProvider.notifier).updateLibraryDarkness(val / 100.0);
      },
    );
  }
}

class MusicDarknessSlider extends ConsumerWidget {
  const MusicDarknessSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SettingsSliderTile(
      icon: LucideIcons.playCircle,
      title: l10n.musicDarkness,
      subtitle: l10n.musicDarknessDesc,
      value: (settings.musicDarkness.isNaN ? 0.62 : settings.musicDarkness) * 100,
      min: 0.0,
      max: 100.0,
      divisions: 100,
      suffix: '%',
      onChanged: (val) {
        ref.read(settingsProvider.notifier).updateMusicDarkness(val / 100.0);
      },
    );
  }
}

class LyricsDarknessSlider extends ConsumerWidget {
  const LyricsDarknessSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SettingsSliderTile(
      icon: LucideIcons.alignLeft,
      title: l10n.lyricsDarkness,
      subtitle: l10n.lyricsDarknessDesc,
      value: (settings.lyricsDarkness.isNaN ? 0.55 : settings.lyricsDarkness) * 100,
      min: 0.0,
      max: 100.0,
      divisions: 100,
      suffix: '%',
      onChanged: (val) {
        ref.read(settingsProvider.notifier).updateLyricsDarkness(val / 100.0);
      },
    );
  }
}

class UseNewFontTile extends ConsumerWidget {
  const UseNewFontTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.type, color: Colors.white70),
      title: Text(
        l10n.useCustomFont,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.useCustomFontDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.useNewFont,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateUseNewFont(value);
      },
    );
  }
}

class FontFamilySelectionTile extends ConsumerWidget {
  const FontFamilySelectionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    final availableFonts = [
      'Jost',
      'DM Sans',
      'Poppins',
      'Space Grotesk',
      'Plus Jakarta Sans',
      'Sora',
      'Google Sans',
    ];

    return ListTile(
      leading: const Icon(LucideIcons.type, color: Colors.white70),
      title: Text(
        l10n.selectFontFamily,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.activeFont(settings.customFontFamily ?? 'Jost'),
        style: _tileSubtitleStyle(),
      ),
      trailing: DropdownButton<String>(
        value: availableFonts.contains(settings.customFontFamily)
            ? settings.customFontFamily
            : 'Jost',
        dropdownColor: const Color(0xFF1A1A1A),
        underline: const SizedBox(),
        items: availableFonts.map((font) {
          return DropdownMenuItem<String>(
            value: font,
            child: Text(
              font,
              style: AppFonts.jostStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            ref.read(settingsProvider.notifier).updateCustomFontFamily(value);
          }
        },
      ),
    );
  }
}

class FontWeightSelectionTile extends ConsumerWidget {
  const FontWeightSelectionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    final delta = settings.customFontWeightDelta;
    final selectedWeight = 400 + (delta * 100);

    final weights = [100, 200, 300, 400, 500, 600, 700, 800, 900];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(LucideIcons.bold, color: Colors.white70),
          title: Text(
            l10n.fontWeightAdjustment,
            style: _tileTitleStyle(),
          ),
          subtitle: Text(
            '${l10n.currentWeight}: $selectedWeight',
            style: _tileSubtitleStyle(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: weights.length,
              itemBuilder: (context, index) {
                final w = weights[index];
                final isSelected = w == selectedWeight;
                final accentColor = Color(settings.accentColor);
                return GestureDetector(
                   onTap: () {
                    HapticFeedback.lightImpact();
                    final newDelta = (w - 400) ~/ 100;
                    ref.read(settingsProvider.notifier).updateCustomFontWeightDelta(newDelta);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$w',
                      style: AppFonts.jostStyle(
                        color: isSelected
                            ? (ThemeData.estimateBrightnessForColor(accentColor) == Brightness.dark
                                ? Colors.white
                                : Colors.black)
                            : Colors.white70,
                        fontWeight: FontWeight.values[index],
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class UseNewFontLyricsTile extends ConsumerWidget {
  const UseNewFontLyricsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.type, color: Colors.white70),
      title: Text(
        l10n.useCustomFontLyrics,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.useCustomFontLyricsDesc,
        style: _tileSubtitleStyle(),
      ),
      activeThumbColor: Color(settings.accentColor),
      value: settings.useNewFontLyrics,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateUseNewFontLyrics(value);
      },
    );
  }
}

class LyricsFontFamilySelectionTile extends ConsumerWidget {
  const LyricsFontFamilySelectionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    final availableFonts = [
      'Sora',
      'Jost',
      'Space Grotesk',
      'Plus Jakarta Sans',
      'Google Sans',
    ];

    return ListTile(
      leading: const Icon(LucideIcons.type, color: Colors.white70),
      title: Text(
        l10n.lyricsFontFamily,
        style: _tileTitleStyle(),
      ),
      subtitle: Text(
        l10n.activeLyricsFont(settings.customFontFamilyLyrics ?? 'Sora'),
        style: _tileSubtitleStyle(),
      ),
      trailing: DropdownButton<String>(
        value: availableFonts.contains(settings.customFontFamilyLyrics)
            ? settings.customFontFamilyLyrics
            : 'Sora',
        dropdownColor: const Color(0xFF1A1A1A),
        underline: const SizedBox(),
        items: availableFonts.map((font) {
          return DropdownMenuItem<String>(
            value: font,
            child: Text(
              font,
              style: AppFonts.jostStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            ref.read(settingsProvider.notifier).updateCustomFontFamilyLyrics(value);
          }
        },
      ),
    );
  }
}

class LyricsFontWeightSelectionTile extends ConsumerWidget {
  const LyricsFontWeightSelectionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final delta = settings.activeLyricsFontWeightDelta;
    final selectedWeight = 700 + (delta * 100);

    final weights = [400, 500, 600, 700, 800, 900];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(LucideIcons.bold, color: Colors.white70),
          title: Text(
            'Lyrics Font Weight',
            style: _tileTitleStyle(),
          ),
          subtitle: Text(
            'Current weight: $selectedWeight',
            style: _tileSubtitleStyle(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: weights.length,
              itemBuilder: (context, index) {
                final w = weights[index];
                final isSelected = w == selectedWeight;
                final accentColor = Color(settings.accentColor);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    final newDelta = (w - 700) ~/ 100;
                    ref.read(settingsProvider.notifier).updateActiveLyricsFontWeightDelta(newDelta);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$w',
                      style: AppFonts.jostStyle(
                        color: isSelected
                            ? (ThemeData.estimateBrightnessForColor(accentColor) == Brightness.dark
                                ? Colors.white
                                : Colors.black)
                            : Colors.white70,
                        fontWeight: FontWeight.values[index + 3], // 400 is w400 (index 3)
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

TextStyle _tileTitleStyle() => AppFonts.jostStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
    );

TextStyle _tileSubtitleStyle() => AppFonts.jostStyle(
      color: Colors.white54,
      fontSize: 12,
    );

