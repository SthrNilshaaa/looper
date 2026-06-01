import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db_service.dart';
import '../../library/domain/models/models.dart';

import '../../library/data/artwork_downloader_service.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  late Future<void> initialization;

  SettingsNotifier() : super(AppSettings()) {
    initialization = _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await DbService.isar.appSettings.get(0);
    if (settings != null) {
      if (settings.language.isEmpty) {
        settings.language = 'en';
      }
      // Migrate old settings record safely
      bool needsSave = false;
      if (settings.bgBrightness == 0.0) {
        settings.bgBrightness = 0.5;
        needsSave = true;
      }
      if (settings.bgOpacity == 0.0) {
        settings.bgOpacity = 0.3;
        needsSave = true;
      }
      // Since uninitialized booleans in old DB records default to false:
      // if keepBackgroundGradient is false, that is fine.
      // showHomeArtists defaults to true, but showHomeAlbums and showHomeGenres should default to false (off)!
      if (!settings.showHomeArtists && !settings.showHomeAlbums && !settings.showHomeGenres) {
        settings.showHomeArtists = true;
        settings.showHomeAlbums = false;
        settings.showHomeGenres = false;
        needsSave = true;
      }
      if (settings.homeSectionOrder.isEmpty) {
        settings.homeSectionOrder = ['quick_picks', 'songs', 'albums', 'artists', 'genres'];
        needsSave = true;
      }
      if (needsSave) {
        await DbService.isar.writeTxn(() async {
          await DbService.isar.appSettings.put(settings);
        });
      }
      state = settings;
    } else {
      // Initialize default settings
      // Default to off on Android, but enabled on Linux
      final defaultSettings = AppSettings()
        ..enableDynamicTheming = !Platform.isAndroid
        ..bgBrightness = 0.5
        ..bgOpacity = 0.3
        ..showHomeArtists = true
        ..showHomeAlbums = false
        ..showHomeGenres = false
        ..homeSectionOrder = ['quick_picks', 'songs', 'albums', 'artists', 'genres'];
      await DbService.isar.writeTxn(() async {
        await DbService.isar.appSettings.put(defaultSettings);
      });
      state = defaultSettings;
    }

    if (state.downloadArtwork && state.enableInternet) {
      ArtworkDownloaderService().downloadAllMissingArtworks();
    }
  }

  Future<void> updateLibraryFolders(List<String> folders) async {
    final newState = _clone(state)..libraryFolders = folders;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateLanguage(String lang) async {
    final newState = _clone(state)..language = lang;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateShuffle(bool shuffle) async {
    final newState = _clone(state)..shuffle = shuffle;
    await _save(newState);
    state = newState;
  }

  Future<void> updateRepeatMode(int mode) async {
    final newState = _clone(state)..repeatMode = mode;
    await _save(newState);
    state = newState;
  }

  Future<void> updateHomeSectionOrder(List<String> newOrder) async {
    final newState = _clone(state)..homeSectionOrder = newOrder;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  AppSettings _clone(AppSettings s) {
    return AppSettings()
      ..id = s.id
      ..libraryFolders = List.from(s.libraryFolders)
      ..lastPlayedSongId = s.lastPlayedSongId
      ..volume = s.volume
      ..shuffle = s.shuffle
      ..repeatMode = s.repeatMode
      ..language = s.language
      ..enableDynamicTheming = s.enableDynamicTheming
      ..darkTheme = s.darkTheme
      ..saveDynamicColor = s.saveDynamicColor
      ..dynamicLyrics = s.dynamicLyrics
      ..accentColor = s.accentColor
      ..audioFocus = s.audioFocus
      ..disableSquiggle = s.disableSquiggle
      ..disableAnimatedDuration = s.disableAnimatedDuration
      ..disableBlur = s.disableBlur
      ..enableInternet = s.enableInternet
      ..downloadArtwork = s.downloadArtwork
      ..keepBackgroundGradient = s.keepBackgroundGradient
      ..customBackgroundImagePath = s.customBackgroundImagePath
      ..bgBrightness = s.bgBrightness
      ..bgOpacity = s.bgOpacity
      ..showHomeArtists = s.showHomeArtists
      ..showHomeAlbums = s.showHomeAlbums
      ..showHomeGenres = s.showHomeGenres
      ..homeSectionOrder = List.from(s.homeSectionOrder.isEmpty ? ['quick_picks', 'songs', 'albums', 'artists', 'genres'] : s.homeSectionOrder);
  }

  Future<void> updateDownloadArtwork(bool enabled) async {
    final newState = _clone(state)..downloadArtwork = enabled;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;

    if (enabled && newState.enableInternet) {
      // Trigger full async scan to download all missing artworks
      ArtworkDownloaderService().downloadAllMissingArtworks();
    }
  }

  Future<void> updateKeepBackgroundGradient(bool value) async {
    final newState = _clone(state)..keepBackgroundGradient = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateCustomBackgroundImagePath(String? path) async {
    final newState = _clone(state)..customBackgroundImagePath = path;
    await _save(newState);
    state = newState;
  }

  Future<void> updateBgBrightness(double value) async {
    final newState = _clone(state)..bgBrightness = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateBgOpacity(double value) async {
    final newState = _clone(state)..bgOpacity = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateShowHomeArtists(bool value) async {
    final newState = _clone(state)..showHomeArtists = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateShowHomeAlbums(bool value) async {
    final newState = _clone(state)..showHomeAlbums = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateShowHomeGenres(bool value) async {
    final newState = _clone(state)..showHomeGenres = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateDisableSquiggle(bool disabled) async {
    final newState = _clone(state)..disableSquiggle = disabled;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateDisableAnimatedDuration(bool disabled) async {
    final newState = _clone(state)..disableAnimatedDuration = disabled;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateDisableBlur(bool disabled) async {
    final newState = _clone(state)..disableBlur = disabled;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateEnableInternet(bool enabled) async {
    final newState = _clone(state)..enableInternet = enabled;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateAudioFocus(bool enabled) async {
    final newState = _clone(state)..audioFocus = enabled;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateDynamicTheming(bool enabled) async {
    final newState = _clone(state)..enableDynamicTheming = enabled;
    if (!enabled) {
      // If dynamic theming is disabled, ensure accent color resets to default Green (0xFF41C25E)
      // if the current color is not one of the manual selection options.
      const allowedColors = [0xFF41C25E, 0xFFF7EAA6, 0xFF448AFF]; // Green, Yellow, Blue Accent
      if (!allowedColors.contains(newState.accentColor)) {
        newState.accentColor = 0xFF41C25E;
      }
    }
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateDarkTheme(bool enabled) async {
    final newState = _clone(state)..darkTheme = enabled;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateDynamicLyrics(bool enabled) async {
    final newState = _clone(state)..dynamicLyrics = enabled;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateAccentColor(int color) async {
    final newState = _clone(state)..accentColor = color;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateSaveDynamicColor(bool enabled) async {
    final newState = _clone(state)..saveDynamicColor = enabled;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateLastPlayedSong(int? songId) async {
    final newState = _clone(state)..lastPlayedSongId = songId;
    await _save(newState);
    state = newState;
  }

  Future<void> updateVolume(double volume) async {
    final newState = _clone(state)..volume = volume;
    await _save(newState);
    state = newState;
  }

  Future<void> _save(AppSettings settings) async {
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(settings);
    });
  }
}
