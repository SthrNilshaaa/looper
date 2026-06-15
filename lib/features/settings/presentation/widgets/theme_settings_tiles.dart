import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.adaptColorsArtwork,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.turnOffBlursOptimize,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
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
      title: const Text(
        'Dynamic Accent Color',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: const Text(
        'Update only the accent color dynamically from the artwork',
        style: TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.useAbsoluteBlackBg,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.selectCustomColor,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.dynamicBgOnlyLyrics,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
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
      title: const Text(
        'Blurred Artwork for Lyrics',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: const Text(
        'Show blurred album art as background instead of dynamic/static gradient',
        style: TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.dynamicColorActiveLyricsDesc,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.lyricsAlignmentDesc,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.disableSquigglyProgressBar,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.useStaticTextTimestamps,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.showQualityBadgeDesc,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.enablePlayerGradientDesc,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.keepBackgroundGradientDesc,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
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
      title: const Text(
        'Performance Optimizer Dashboard',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: const Text(
        'Show real-time performance optimizer stats overlay',
        style: TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
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
      value: ((settings.homeDarkness.isNaN || settings.homeDarkness == 0.0)
              ? 0.72
              : settings.homeDarkness) *
          100,
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
      value: ((settings.songsDarkness.isNaN || settings.songsDarkness == 0.0)
              ? 0.72
              : settings.songsDarkness) *
          100,
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
      value: ((settings.libraryDarkness.isNaN || settings.libraryDarkness == 0.0)
              ? 0.72
              : settings.libraryDarkness) *
          100,
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
      value: ((settings.musicDarkness.isNaN || settings.musicDarkness == 0.0)
              ? 0.62
              : settings.musicDarkness) *
          100,
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
      value: ((settings.lyricsDarkness.isNaN || settings.lyricsDarkness == 0.0)
              ? 0.55
              : settings.lyricsDarkness) *
          100,
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
    return SwitchListTile(
      secondary: const Icon(LucideIcons.type, color: Colors.white70),
      title: const Text(
        'Use Custom Font',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: const Text(
        'Use Jost or other custom fonts. Otherwise, DM Sans is used.',
        style: TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
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
      title: const Text(
        'Select Font Family',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Active font: ${settings.customFontFamily}',
        style: const TextStyle(color: Colors.white54, fontSize: 12),
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
              style: const TextStyle(color: Colors.white),
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
