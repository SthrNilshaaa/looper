import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:one_player/features/playback/presentation/playback_notifier.dart';

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
      seedColor: const Color(0xFF00FF00),
      primary: const Color(0xFF00FF00),
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
        FileImage(file),
        maximumColorCount: 20,
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
        seedColor: const Color(0xFF00FF00),
        primary: const Color(0xFF00FF00),
        brightness: Brightness.dark,
      ),
    );
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final notifier = ThemeNotifier();
  
  // Watch current song and update theme
  ref.listen(playbackProvider, (previous, next) {
    if (next.currentSong?.artPath != previous?.currentSong?.artPath) {
      notifier.updateFromImage(next.currentSong?.artPath);
    }
  });

  return notifier;
});
