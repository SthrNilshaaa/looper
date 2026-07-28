import 'package:isar/isar.dart';

part 'models.g.dart';

@collection
class Song {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String path;

  late String title;

  @Index()
  String? artist;

  @Index()
  String? album;

  String? genre;
  int? duration; // In milliseconds
  int? trackNumber;
  int? year;
  String? artPath;

  @Index()
  late DateTime dateAdded;

  int playCount = 0;
  @Index()
  DateTime? lastPlayed;
  bool isFavorite = false;
  String? lyrics;
  bool hasCustomEqualizer = false;
  List<double>? equalizerGains;

  // SpatialFlow Online Streaming fields
  bool isOnlineStream = false;
  String? streamUrl;
  String? youtubeId;
  String? onlineArtUrl;
  int? streamQuality; // 0: low, 1: high

  // Metadata for search
  @Index(type: IndexType.value, caseSensitive: false)
  List<String> get searchTerms => [
    title,
    artist ?? '',
    album ?? '',
    lyrics ?? '',
  ];
}

@collection
class Album {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  String? artist;
  String? artPath;
  int? year;

  @Index()
  late DateTime dateAdded;
}

@collection
class Artist {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  String? artPath;
  String? artistImageUrl;
}

@collection
class Playlist {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  late List<String> songPaths;
  late DateTime dateCreated;
  late DateTime dateModified;
}

@collection
class AppSettings {
  Id id = 0; // Always use ID 0 for single settings object

  List<String> libraryFolders = [];
  int? lastPlayedSongId;
  List<int> lastQueueSongIds = [];
  int lastQueueIndex = -1;
  double volume = 1.0;
  int lastPositionMs = 0;
  bool shuffle = false;
  int repeatMode = 0; // 0: off, 1: one, 2: all
  String language = 'en';
  bool enableDynamicTheming = false;
  bool darkTheme = true;
  bool saveDynamicColor = true;
  bool dynamicLyrics = false;
  bool blurredArtworkForLyrics = true;
  int accentColor = 0xFF41C25E; // Default Green
  bool audioFocus = true;
  bool audioFocusRequestOnPlay = true;
  bool audioFocusReleaseOnPause = true;
  bool audioFocusStopOnOtherSession = true;
  bool audioFocusRestartOnGain = true;
  bool disableSquiggle = false;
  bool disableAnimatedDuration = false;
  bool disableBlur = true;
  bool enableInternet = true;
  bool downloadArtwork = false;
  bool keepBackgroundGradient = false;
  bool showQualityBadge = true;
  bool enablePlayerGradient = true;
  bool settingsV2 = false;
  bool settingsV3 = false;
  bool showPerformanceOptimizer = false;
  String? customBackgroundImagePath;
  double bgBrightness = 0.5;
  double bgOpacity = 0.3;
  bool showHomeArtists = true;
  bool showHomeAlbums = false;
  bool showHomeGenres = true;
  List<String> homeSectionOrder = [
    'quick_picks',
    'songs',
    'albums',
    'artists',
    'genres',
  ];
  bool enableSlideGesture = false;
  bool stopOnTaskRemoved = true;
  bool persistQueue = true;

  bool fadePlayPauseStop = true;
  int playPauseStopFadeLength = 150; // ms (10ms-1000ms)
  bool resumeAfterCall = true;
  bool pauseOnDuck = false;
  bool resumeOnBluetoothConnect = false;
  bool resumeOnStart = false;
  bool permanentAudioFocusChange = false;
  bool dynamicColorActiveLyrics = true;
  String lyricsAlignment = 'left'; // 'left', 'center', 'right'
  bool dynamicAccentColor = true;
  int sortStrategyIndex = 0;
  bool sortAscending = true;
  int albumSortOptionIndex = 0;
  int artistSortOptionIndex = 0;
  int genreSortOptionIndex = 0;
  int collectionSortOptionIndex = 0;

  double homeDarkness = 0.62;
  double songsDarkness = 0.62;
  double libraryDarkness = 0.62;
  double musicDarkness = 0.62;
  double lyricsDarkness = 0.55;

  bool useNewFont = false;
  String customFontFamily = 'Jost';
  int customFontWeight = 400;
  int customFontWeightDelta = 0;
  bool useNewFontLyrics = false;
  String customFontFamilyLyrics = 'Sora';
  String customFontWeightLyrics = 'Normal';
  int customFontWeightLyricsDelta = 0;
  int activeLyricsFontWeightDelta = 0;
  bool equalizerEnabled = false;
  List<double> globalEqualizerGains = [];
  bool equalizerGlobalMode = true;
  bool firstTimeEqualizer = true;
  bool enableAudioCache = true;
  int audioCacheSizeMB = 200;
  int audioCacheSecs = 120;
  int audioBackCacheSizeMB = 100;
  bool exclusiveHardwareMode = false;
  String lyricsProvider = 'LRCLIB';

  // SpatialFlow Operational Mode & Network Streaming
  int playbackModeIndex = 0; // 0: hybrid, 1: localOnly, 2: onlineOnly
  int streamingQuality = 1; // 0: Low (128k), 1: High (256k)
  bool cacheOnlineStreams = true;
}

enum PlaybackMode {
  hybrid,
  localOnly,
  onlineOnly,
}
