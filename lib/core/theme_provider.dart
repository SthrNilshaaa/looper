import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
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
  final Ref _ref;
  AppSettings _settings;
  bool _isUpdating = false;

  ThemeNotifier(this._ref, this._settings)
    : super(
        ThemeState(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(_settings.accentColor),
            primary: Color(_settings.accentColor),
            surface: const Color(0xFF070707),
            brightness: Brightness.dark,
          ),
        ),
      );

  // Update internal settings reference when they change
  void updateSettings(AppSettings newSettings) {
    if (_isUpdating) return; // Prevent loop during dynamic update

    final oldSettings = _settings;
    _settings = newSettings;

    debugPrint(
      '⚙️ Settings updated in ThemeNotifier. Dynamic: ${newSettings.enableDynamicTheming}, Color: ${Color(newSettings.accentColor)}',
    );

    // Handle theme reset logic
    if (!newSettings.enableDynamicTheming) {
      if (oldSettings.enableDynamicTheming ||
          oldSettings.accentColor != newSettings.accentColor) {
        _resetTheme();
      }
    } else {
      if (!oldSettings.enableDynamicTheming) {
        final playback = _ref.read(playbackProvider);
        updateFromImage(playback.currentSong?.artPath);
      } else if (oldSettings.accentColor != newSettings.accentColor) {
        final playback = _ref.read(playbackProvider);
        if (playback.currentSong == null) {
          _resetTheme();
        }
      }
    }
  }

  Future<void> updateFromImage(String? imagePath) async {
    if (imagePath == null) {
      return;
    }

    try {
      _isUpdating = true;
      ImageProvider provider;
      if (imagePath.startsWith('http')) {
        provider = NetworkImage(imagePath);
      } else {
        final file = File(imagePath);
        if (!await file.exists()) {
          _isUpdating = false;
          return;
        }
        provider = FileImage(file);
      }

      final palette = await PaletteGenerator.fromImageProvider(
        ResizeImage(provider, width: 100, height: 100),
        maximumColorCount: 8,
      );

      final Color? color =
          palette.vibrantColor?.color ??
          palette.lightVibrantColor?.color ??
          palette.darkVibrantColor?.color ??
          palette.dominantColor?.color;

      if (color != null) {
        final hsv = HSVColor.fromColor(color);
        final vibrantColor = hsv
            .withSaturation((hsv.saturation * 1.2).clamp(0.6, 1.0))
            .withValue((hsv.value * 1.1).clamp(0.8, 1.0))
            .toColor();

        debugPrint('🎨 Extracted vibrant color: $vibrantColor');

        // Update the state
        state = state.copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: vibrantColor,
            primary: vibrantColor,
            onPrimary: Colors.white,
            brightness: Brightness.dark,
          ),
        );

        // PERSIST the color to database if enabled
        if (_settings.saveDynamicColor) {
          debugPrint('💾 Requesting database save for color: $vibrantColor');
          await _ref
              .read(settingsProvider.notifier)
              .updateAccentColor(vibrantColor.value);
        }
      }
    } catch (e) {
      debugPrint('Error updating theme from image: $e');
    } finally {
      _isUpdating = false;
    }
  }

  void _resetTheme() {
    debugPrint(
      '🔄 Resetting theme to accent color: ${Color(_settings.accentColor)}',
    );
    state = state.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(_settings.accentColor),
        primary: Color(_settings.accentColor),
        surface: const Color(0xFF070707),
        brightness: Brightness.dark,
      ),
    );
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  // Use read here to avoid the re-creation loop
  final initialSettings = ref.read(settingsProvider);
  final notifier = ThemeNotifier(ref, initialSettings);

  // Watch current song and update theme only if dynamic theming is enabled
  ref.listen(playbackProvider, (previous, next) {
    final currentSettings = ref.read(settingsProvider);
    if (currentSettings.enableDynamicTheming &&
        next.currentSong?.artPath != previous?.currentSong?.artPath) {
      notifier.updateFromImage(next.currentSong?.artPath);
    }
  });

  // Handle settings changes without re-creating the notifier
  ref.listen(settingsProvider, (previous, next) {
    notifier.updateSettings(next);
  });

  return notifier;
});
