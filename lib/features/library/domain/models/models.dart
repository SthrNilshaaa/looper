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

  // Metadata for search
  @Index(type: IndexType.value, caseSensitive: false)
  List<String> get searchTerms => [title, artist ?? '', album ?? '', lyrics ?? ''];
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
  double volume = 1.0;
  bool shuffle = false;
  int repeatMode = 0; // 0: off, 1: one, 2: all
  String language = 'en';
  bool enableDynamicTheming = false;
  bool darkTheme = false;
  bool saveDynamicColor = true;
  bool dynamicLyrics = true;
  int accentColor = 0xFF41C25E; // Default Green
  bool audioFocus = true;
  bool disableSquiggle = false;
  bool disableAnimatedDuration = false;
  bool disableBlur = true;
  bool enableInternet = true;
  bool downloadArtwork = false;
  bool keepBackgroundGradient = false;
  bool showQualityBadge = true;
  bool enablePlayerGradient = true;
  bool settingsV2 = false;
  bool showPerformanceOptimizer = false;
  String? customBackgroundImagePath;
  double bgBrightness = 0.5;
  double bgOpacity = 0.3;
  bool showHomeArtists = true;
  bool showHomeAlbums = false;
  bool showHomeGenres = true;
  List<String> homeSectionOrder = ['quick_picks', 'songs', 'albums', 'artists', 'genres'];
  bool enableSlideGesture = false;
  bool stopOnTaskRemoved = false;

  bool enableCrossfade = false;
  int crossfadeLength = 150; // ms (100ms-15000ms)
  int shortManualCrossfadeLength = 200; // ms (10ms-1000ms)
  bool fadePlayPauseStop = true;
  int playPauseStopFadeLength = 150; // ms (10ms-1000ms)
  bool fadeOnSeek = false;
  int seekFadeLength = 50; // ms (10ms-500ms)
  int silenceBetweenTracks = 0; // ms (0ms-5000ms)
  bool resumeAfterCall = true;
  bool resumeOnStart = false;
  bool permanentAudioFocusChange = true;
  bool dynamicColorActiveLyrics = true;
  String lyricsAlignment = 'left'; // 'left', 'center', 'right'
  bool dynamicAccentColor = false;
  int sortStrategyIndex = 0;
  bool sortAscending = false;

  double homeDarkness = 0.62;
  double songsDarkness = 0.62;
  double libraryDarkness = 0.62;
  double musicDarkness = 0.62;
  double lyricsDarkness = 0.55;
}
