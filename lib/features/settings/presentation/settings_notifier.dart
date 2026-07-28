import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db_service.dart';
import '../../library/domain/models/models.dart';

import '../../library/data/artwork_downloader_service.dart';
import '../../../core/app_fonts.dart';

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

  List<double> _createDefaultGains() {
    final list = List<double>.filled(48, 0.0);
    list[20] = -50.0; // Silence remove threshold dB
    list[22] = 0.2; // Crossfeed strength
    list[24] = -20.0; // Compressor threshold dB
    list[25] = 2.0; // Compressor ratio
    list[26] = 20.0; // Compressor attack ms
    list[27] = 250.0; // Compressor release ms
    list[29] = -24.0; // Loudnorm target
    list[31] = 2.5; // Stereo width factor
    list[34] = 1.0; // Pitch shift
    list[35] = 1.0; // Tempo shift
    list[36] = 0.0; // ReplayGain mode
    list[37] = 0.0; // ReplayGain preamp
    list[39] = 150.0; // Speech highpass
    list[40] = 4000.0; // Speech lowpass
    list[44] = 1.0; // Tone shelving enabled
    list[45] = 1.0; // Pitch/tempo enabled
    return list;
  }

  Future<void> _loadSettings() async {
    final settings = await DbService.isar.appSettings.get(0);
    if (settings != null) {
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
      if (!settings.showHomeArtists &&
          !settings.showHomeAlbums &&
          !settings.showHomeGenres) {
        settings.showHomeArtists = true;
        settings.showHomeAlbums = false;
        settings.showHomeGenres = false;
        needsSave = true;
      }
      if (settings.homeSectionOrder.isEmpty) {
        settings.homeSectionOrder = [
          'quick_picks',
          'songs',
          'albums',
          'artists',
          'genres',
        ];
        needsSave = true;
      }
      if (settings.homeDarkness.isNaN || (settings.homeDarkness == 0.0 && !settings.settingsV3)) {
        settings.homeDarkness = 0.72;
        needsSave = true;
      }
      if (settings.songsDarkness.isNaN || (settings.songsDarkness == 0.0 && !settings.settingsV3)) {
        settings.songsDarkness = 0.72;
        needsSave = true;
      }
      if (settings.libraryDarkness.isNaN || (settings.libraryDarkness == 0.0 && !settings.settingsV3)) {
        settings.libraryDarkness = 0.72;
        needsSave = true;
      }
      if (settings.musicDarkness.isNaN || (settings.musicDarkness == 0.0 && !settings.settingsV3)) {
        settings.musicDarkness = 0.62;
        needsSave = true;
      }
      if (settings.lyricsDarkness.isNaN || (settings.lyricsDarkness == 0.0 && !settings.settingsV3)) {
        settings.lyricsDarkness = 0.55;
        needsSave = true;
      }
      if (!settings.settingsV2) {
        settings.showQualityBadge = true;
        settings.enablePlayerGradient = true;
        settings.settingsV2 = true;
        needsSave = true;
      }
      if (!settings.settingsV3) {
        settings.dynamicLyrics = false;
        settings.blurredArtworkForLyrics = true;
        settings.settingsV3 = true;
        needsSave = true;
      }
      if (settings.globalEqualizerGains.length < 48) {
        settings.globalEqualizerGains = _createDefaultGains();
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
        ..homeSectionOrder = [
          'quick_picks',
          'songs',
          'albums',
          'artists',
          'genres',
        ]
        ..homeDarkness = 0.72
        ..songsDarkness = 0.72
        ..libraryDarkness = 0.72
        ..musicDarkness = 0.62
        ..lyricsDarkness = 0.55
        ..showQualityBadge = true
        ..enablePlayerGradient = true
        ..settingsV2 = true
        ..settingsV3 = true
        ..dynamicLyrics = false
        ..blurredArtworkForLyrics = true
        ..showPerformanceOptimizer = false
        ..equalizerEnabled = false
        ..enableAudioCache = true
        ..audioCacheSizeMB = 200
        ..audioCacheSecs = 120
        ..audioBackCacheSizeMB = 100
        ..persistQueue = true
        ..globalEqualizerGains = _createDefaultGains();
      await DbService.isar.writeTxn(() async {
        await DbService.isar.appSettings.put(defaultSettings);
      });
      state = defaultSettings;
    }

    _updateActiveFont();

    if (state.downloadArtwork && state.enableInternet) {
      ArtworkDownloaderService().downloadAllMissingArtworks();
    }
  }

  void _updateActiveFont([AppSettings? customState]) {
    final activeState = customState ?? state;
    AppFonts.activeFontFamily = activeState.useNewFont
        ? (activeState.customFontFamily ?? 'Jost')
        : 'DM Sans';
    AppFonts.appFontWeightDelta = activeState.useNewFont
        ? activeState.customFontWeightDelta
        : 0;
    AppFonts.lyricsFontWeightDelta = activeState.useNewFontLyrics
        ? activeState.customFontWeightLyricsDelta
        : 0;
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
      ..lastQueueSongIds = List.from(s.lastQueueSongIds)
      ..lastQueueIndex = s.lastQueueIndex
      ..volume = s.volume
      ..lastPositionMs = s.lastPositionMs
      ..shuffle = s.shuffle
      ..repeatMode = s.repeatMode
      ..language = s.language
      ..enableDynamicTheming = s.enableDynamicTheming
      ..darkTheme = s.darkTheme
      ..saveDynamicColor = s.saveDynamicColor
      ..dynamicLyrics = s.dynamicLyrics
      ..accentColor = s.accentColor
      ..audioFocus = s.audioFocus
      ..audioFocusRequestOnPlay = s.audioFocusRequestOnPlay
      ..audioFocusReleaseOnPause = s.audioFocusReleaseOnPause
      ..audioFocusStopOnOtherSession = s.audioFocusStopOnOtherSession
      ..audioFocusRestartOnGain = s.audioFocusRestartOnGain
      ..disableSquiggle = s.disableSquiggle
      ..disableAnimatedDuration = s.disableAnimatedDuration
      ..disableBlur = s.disableBlur
      ..enableInternet = s.enableInternet
      ..downloadArtwork = s.downloadArtwork
      ..keepBackgroundGradient = s.keepBackgroundGradient
      ..showQualityBadge = s.showQualityBadge
      ..enablePlayerGradient = s.enablePlayerGradient
      ..settingsV2 = s.settingsV2
      ..settingsV3 = s.settingsV3
      ..blurredArtworkForLyrics = s.blurredArtworkForLyrics
      ..customBackgroundImagePath = s.customBackgroundImagePath
      ..bgBrightness = s.bgBrightness
      ..bgOpacity = s.bgOpacity
      ..showHomeArtists = s.showHomeArtists
      ..showHomeAlbums = s.showHomeAlbums
      ..showHomeGenres = s.showHomeGenres
      ..homeSectionOrder = List.from(
        s.homeSectionOrder.isEmpty
            ? ['quick_picks', 'songs', 'albums', 'artists', 'genres']
            : s.homeSectionOrder,
      )
      ..enableSlideGesture = s.enableSlideGesture
      ..stopOnTaskRemoved = s.stopOnTaskRemoved
      ..persistQueue = s.persistQueue
      ..fadePlayPauseStop = s.fadePlayPauseStop
      ..playPauseStopFadeLength = s.playPauseStopFadeLength
      ..resumeAfterCall = s.resumeAfterCall
      ..pauseOnDuck = s.pauseOnDuck
      ..resumeOnBluetoothConnect = s.resumeOnBluetoothConnect
      ..resumeOnStart = s.resumeOnStart
      ..permanentAudioFocusChange = s.permanentAudioFocusChange
      ..dynamicColorActiveLyrics = s.dynamicColorActiveLyrics
      ..lyricsAlignment = s.lyricsAlignment
      ..dynamicAccentColor = s.dynamicAccentColor
      ..sortStrategyIndex = s.sortStrategyIndex
      ..sortAscending = s.sortAscending
      ..albumSortOptionIndex = s.albumSortOptionIndex
      ..artistSortOptionIndex = s.artistSortOptionIndex
      ..genreSortOptionIndex = s.genreSortOptionIndex
      ..collectionSortOptionIndex = s.collectionSortOptionIndex
      ..homeDarkness = s.homeDarkness
      ..songsDarkness = s.songsDarkness
      ..libraryDarkness = s.libraryDarkness
      ..musicDarkness = s.musicDarkness
      ..lyricsDarkness = s.lyricsDarkness
      ..showPerformanceOptimizer = s.showPerformanceOptimizer
      ..useNewFont = s.useNewFont
      ..customFontFamily = s.customFontFamily
      ..customFontWeight = s.customFontWeight
      ..customFontWeightDelta = s.customFontWeightDelta
      ..useNewFontLyrics = s.useNewFontLyrics
      ..customFontFamilyLyrics = s.customFontFamilyLyrics
      ..customFontWeightLyrics = s.customFontWeightLyrics
      ..customFontWeightLyricsDelta = s.customFontWeightLyricsDelta
      ..activeLyricsFontWeightDelta = s.activeLyricsFontWeightDelta
      ..equalizerEnabled = s.equalizerEnabled
      ..globalEqualizerGains = List.from(
        s.globalEqualizerGains.isEmpty
            ? _createDefaultGains()
            : s.globalEqualizerGains,
      )
      ..enableAudioCache = s.enableAudioCache
      ..audioCacheSizeMB = s.audioCacheSizeMB
      ..audioCacheSecs = s.audioCacheSecs
      ..audioBackCacheSizeMB = s.audioBackCacheSizeMB
      ..exclusiveHardwareMode = s.exclusiveHardwareMode
      ..lyricsProvider = s.lyricsProvider
      ..equalizerGlobalMode = s.equalizerGlobalMode
      ..firstTimeEqualizer = s.firstTimeEqualizer;
  }

  Future<void> updateLyricsProvider(String value) async {
    final newState = _clone(state)..lyricsProvider = value;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateBlurredArtworkForLyrics(bool value) async {
    final newState = _clone(state)..blurredArtworkForLyrics = value;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateShowQualityBadge(bool value) async {
    final newState = _clone(state)..showQualityBadge = value;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateShowPerformanceOptimizer(bool value) async {
    final newState = _clone(state)..showPerformanceOptimizer = value;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateEnablePlayerGradient(bool value) async {
    final newState = _clone(state);
    newState.enablePlayerGradient = value;
    if (!value) {
      newState.keepBackgroundGradient = false;
    }
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateEnableSlideGesture(bool value) async {
    final newState = _clone(state)..enableSlideGesture = value;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateStopOnTaskRemoved(bool value) async {
    final newState = _clone(state)..stopOnTaskRemoved = value;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }
  Future<void> updateFadePlayPauseStop(bool value) async {
    final newState = _clone(state)..fadePlayPauseStop = value;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updatePlayPauseStopFadeLength(int value) async {
    final newState = _clone(state)..playPauseStopFadeLength = value;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }
  Future<void> updateResumeAfterCall(bool value) async {
    final newState = _clone(state)..resumeAfterCall = value;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updatePauseOnDuck(bool value) async {
    final newState = _clone(state)..pauseOnDuck = value;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateResumeOnBluetoothConnect(bool value) async {
    final newState = _clone(state)..resumeOnBluetoothConnect = value;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateResumeOnStart(bool value) async {
    final newState = _clone(state)..resumeOnStart = value;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updatePersistQueue(bool value) async {
    final newState = _clone(state)..persistQueue = value;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updatePermanentAudioFocusChange(bool value) async {
    final newState = _clone(state)..permanentAudioFocusChange = value;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
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

  Future<void> updateAudioFocusRequestOnPlay(bool enabled) async {
    final newState = _clone(state)..audioFocusRequestOnPlay = enabled;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateAudioFocusReleaseOnPause(bool enabled) async {
    final newState = _clone(state)..audioFocusReleaseOnPause = enabled;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateAudioFocusStopOnOtherSession(bool enabled) async {
    final newState = _clone(state)..audioFocusStopOnOtherSession = enabled;
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(newState);
    });
    state = newState;
  }

  Future<void> updateAudioFocusRestartOnGain(bool enabled) async {
    final newState = _clone(state)..audioFocusRestartOnGain = enabled;
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
      const allowedColors = [
        0xFF41C25E,
        0xFFF7EAA6,
        0xFF448AFF,
      ]; // Green, Yellow, Blue Accent
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

  Future<void> updateLastQueueState(
    List<int> queueIds,
    int index,
    int? lastSongId, {
    int? positionMs,
  }) async {
    final newState = _clone(state)
      ..lastQueueSongIds = queueIds
      ..lastQueueIndex = index
      ..lastPlayedSongId = lastSongId
      ..lastPositionMs = positionMs ?? 0;
    await _save(newState);
    state = newState;
  }

  Future<void> updateLastPosition(int positionMs) async {
    final newState = _clone(state)..lastPositionMs = positionMs;
    await _save(newState);
    state = newState;
  }

  Future<void> updateVolume(double volume) async {
    final newState = _clone(state)..volume = volume;
    await _save(newState);
    state = newState;
  }

  Future<void> updateDynamicColorActiveLyrics(bool enabled) async {
    final newState = _clone(state)..dynamicColorActiveLyrics = enabled;
    await _save(newState);
    state = newState;
  }

  Future<void> updateLyricsAlignment(String alignment) async {
    final newState = _clone(state)..lyricsAlignment = alignment;
    await _save(newState);
    state = newState;
  }

  Future<void> updateDynamicAccentColor(bool enabled) async {
    final newState = _clone(state)..dynamicAccentColor = enabled;
    await _save(newState);
    state = newState;
  }

  Future<void> updateSortStrategy(int strategyIndex) async {
    final newState = _clone(state)..sortStrategyIndex = strategyIndex;
    await _save(newState);
    state = newState;
  }

  Future<void> updateSortAscending(bool ascending) async {
    final newState = _clone(state)..sortAscending = ascending;
    await _save(newState);
    state = newState;
  }

  Future<void> updateAlbumSortOptionIndex(int index) async {
    final newState = _clone(state)..albumSortOptionIndex = index;
    await _save(newState);
    state = newState;
  }

  Future<void> updateArtistSortOptionIndex(int index) async {
    final newState = _clone(state)..artistSortOptionIndex = index;
    await _save(newState);
    state = newState;
  }

  Future<void> updateGenreSortOptionIndex(int index) async {
    final newState = _clone(state)..genreSortOptionIndex = index;
    await _save(newState);
    state = newState;
  }

  Future<void> updateCollectionSortOptionIndex(int index) async {
    final newState = _clone(state)..collectionSortOptionIndex = index;
    await _save(newState);
    state = newState;
  }

  Future<void> updateHomeDarkness(double value) async {
    final newState = _clone(state)..homeDarkness = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateSongsDarkness(double value) async {
    final newState = _clone(state)..songsDarkness = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateLibraryDarkness(double value) async {
    final newState = _clone(state)..libraryDarkness = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateMusicDarkness(double value) async {
    final newState = _clone(state)..musicDarkness = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateLyricsDarkness(double value) async {
    final newState = _clone(state)..lyricsDarkness = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateUseNewFont(bool value) async {
    final newState = _clone(state)..useNewFont = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateCustomFontFamily(String value) async {
    final newState = _clone(state)..customFontFamily = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateCustomFontWeight(int value) async {
    final newState = _clone(state)..customFontWeight = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateCustomFontWeightDelta(int value) async {
    final newState = _clone(state)..customFontWeightDelta = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateUseNewFontLyrics(bool value) async {
    final newState = _clone(state)..useNewFontLyrics = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateCustomFontFamilyLyrics(String value) async {
    final newState = _clone(state)..customFontFamilyLyrics = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateCustomFontWeightLyrics(String value) async {
    final newState = _clone(state)..customFontWeightLyrics = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateCustomFontWeightLyricsDelta(int value) async {
    final newState = _clone(state)..customFontWeightLyricsDelta = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateActiveLyricsFontWeightDelta(int value) async {
    final newState = _clone(state)..activeLyricsFontWeightDelta = value;
    await _save(newState);
    _updateActiveFont(newState);
    state = newState;
  }

  Future<void> updateEqualizerEnabled(bool value) async {
    final newState = _clone(state)..equalizerEnabled = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateGlobalEqualizerGains(List<double> value) async {
    final newState = _clone(state)..globalEqualizerGains = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateEnableAudioCache(bool value) async {
    final newState = _clone(state)..enableAudioCache = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateAudioCacheSizeMB(int value) async {
    final newState = _clone(state)..audioCacheSizeMB = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateAudioCacheSecs(int value) async {
    final newState = _clone(state)..audioCacheSecs = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateAudioBackCacheSizeMB(int value) async {
    final newState = _clone(state)..audioBackCacheSizeMB = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateExclusiveHardwareMode(bool value) async {
    final newState = _clone(state)..exclusiveHardwareMode = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateEqualizerGlobalMode(bool value) async {
    final newState = _clone(state)..equalizerGlobalMode = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updateFirstTimeEqualizer(bool value) async {
    final newState = _clone(state)..firstTimeEqualizer = value;
    await _save(newState);
    state = newState;
  }

  Future<void> updatePlaybackMode(int mode) async {
    final newState = _clone(state)..playbackModeIndex = mode;
    await _save(newState);
    state = newState;
  }

  Future<void> updateStreamingQuality(int quality) async {
    final newState = _clone(state)..streamingQuality = quality;
    await _save(newState);
    state = newState;
  }

  Future<void> _save(AppSettings settings) async {
    await DbService.isar.writeTxn(() async {
      await DbService.isar.appSettings.put(settings);
    });
  }
}
