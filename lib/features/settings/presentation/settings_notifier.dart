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
    await DbService.isar.writeTxn(() async {
      state.libraryFolders = folders;
      await DbService.isar.appSettings.put(state);
    });
    state = _clone(state);
  }

  Future<void> updateLanguage(String lang) async {
    await DbService.isar.writeTxn(() async {
      state.language = lang;
      await DbService.isar.appSettings.put(state);
    });
    state = _clone(state);
  }

  Future<void> updateShuffle(bool shuffle) async {
    state.shuffle = shuffle;
    await _save();
  }

  Future<void> updateRepeatMode(int mode) async {
    state.repeatMode = mode;
    await _save();
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
      ..enableDynamicTheming = s.enableDynamicTheming;
  }

  Future<void> updateDynamicTheming(bool enabled) async {
    await DbService.isar.writeTxn(() async {
      state.enableDynamicTheming = enabled;
      await DbService.isar.appSettings.put(state);
    });
    state = _clone(state);
  }

  Future<void> updateLastPlayedSong(int? songId) async {
    state.lastPlayedSongId = songId;
    await _save();
  }

  Future<void> updateVolume(double volume) async {
    state.volume = volume;
    await _save();
  }

  Future<void> _save() async {
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(state);
    });
  }
}
