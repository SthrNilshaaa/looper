import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db_service.dart';
import '../../library/domain/models/models.dart';

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
      state = settings;
    } else {
      // Initialize default settings
      final defaultSettings = AppSettings();
      await DbService.isar.writeTxn(() async {
        await DbService.isar.appSettings.put(defaultSettings);
      });
      state = defaultSettings;
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
      ..saveDynamicColor = s.saveDynamicColor
      ..accentColor = s.accentColor;
  }

  Future<void> updateDynamicTheming(bool enabled) async {
    final newState = _clone(state)..enableDynamicTheming = enabled;
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
