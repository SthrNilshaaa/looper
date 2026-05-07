import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';

class ThemeState {
  final ColorScheme colorScheme;
  final bool isDynamic;

  ThemeState({required this.colorScheme, this.isDynamic = true});

  ThemeState copyWith({ColorScheme? colorScheme, bool? isDynamic}) {
    return ThemeState(
      colorScheme: colorScheme ?? this.colorScheme,
      isDynamic: isDynamic ?? this.isDynamic,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF41C25E),
      primary: const Color(0xFF41C25E),
      surface: const Color(0xFF070707),
      brightness: Brightness.dark,
    ),
  ));

  Future<void> updateFromImage(String? imagePath) async {
    if (imagePath == null) {
      _resetTheme();
      return;
    }

    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        _resetTheme();
        return;
      }

      final palette = await PaletteGenerator.fromImageProvider(
        ResizeImage(FileImage(file), width: 100, height: 100),
        maximumColorCount: 8,
      );

      final Color? color = palette.vibrantColor?.color ?? 
                           palette.lightVibrantColor?.color ??
                           palette.darkVibrantColor?.color ??
                           palette.dominantColor?.color;

      if (color != null) {
        // Boost saturation and value to make it "pop" or "vibrate" as requested
        final hsv = HSVColor.fromColor(color);
        final vibrantColor = hsv
            .withSaturation((hsv.saturation * 1.2).clamp(0.6, 1.0))
            .withValue((hsv.value * 1.1).clamp(0.8, 1.0))
            .toColor();

        debugPrint('🎨 Updating theme color to: $vibrantColor (Original: $color)');
        state = state.copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: vibrantColor,
            primary: vibrantColor,
            onPrimary: Colors.white,
            brightness: Brightness.dark,
          ),
        );
      } else {
        _resetTheme();
      }
    } catch (e) {
      debugPrint('Error updating theme from image: $e');
      _resetTheme();
    }
  }

  void _resetTheme() {
    state = state.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF41C25E),
        primary: const Color(0xFF41C25E),
        surface: const Color(0xFF070707),
        brightness: Brightness.dark,
      ),
    );
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final notifier = ThemeNotifier();
  final settings = ref.watch(settingsProvider);
  
  // Watch current song and update theme only if dynamic theming is enabled
  ref.listen(playbackProvider, (previous, next) {
    if (settings.enableDynamicTheming && 
        next.currentSong?.artPath != previous?.currentSong?.artPath) {
      notifier.updateFromImage(next.currentSong?.artPath);
    }
  });

  // Watch the flag itself to reset if disabled
  ref.listen(settingsProvider, (previous, next) {
    if (previous?.enableDynamicTheming == true && next.enableDynamicTheming == false) {
      notifier._resetTheme();
    } else if (previous?.enableDynamicTheming == false && next.enableDynamicTheming == true) {
      final playback = ref.read(playbackProvider);
      notifier.updateFromImage(playback.currentSong?.artPath);
    }
  });

  return notifier;
});
