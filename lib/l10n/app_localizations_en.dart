// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about => 'About';

  @override
  String get aboutAndMaintainers => 'About & Maintainers';

  @override
  String get aboutApp => 'About App';

  @override
  String get aboutLooperPlayer => 'ABOUT LOOPER PLAYER';

  @override
  String get accentColor => 'Accent Color';

  @override
  String get accentColorDesc => 'Select manual theme accent color';

  @override
  String get acousticSpectralAnalysis => 'ACOUSTIC & SPECTRAL ANALYSIS';

  @override
  String get activeCallCannotPlay =>
      'Playback blocked: Cannot play music during an active call';

  @override
  String get adaptColorsArtwork => 'Adapt app colors to album artwork';

  @override
  String addedTo(String name) {
    return 'Added to $name';
  }

  @override
  String get addedToQueue => 'Added to queue';

  @override
  String get addFolder => 'Add Folder';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get addToPlaylists => 'Add to Playlists';

  @override
  String get addToQueue => 'Add to Queue';

  @override
  String get album => 'Album';

  @override
  String get albums => 'Albums';

  @override
  String get albumsRowDesc => 'Horizontal shelf of albums';

  @override
  String get allFilesAccess => 'ALL FILES ACCESS (RECOMMENDED)';

  @override
  String get allSongs => 'All Songs';

  @override
  String get appDetailsCreator =>
      'Application details, creator, and design team info';

  @override
  String get appearance => 'Appearance';

  @override
  String get appInfoPrivacy => 'APP INFO & PRIVACY';

  @override
  String get appTitle => 'Looper Player';

  @override
  String get artist => 'Artist';

  @override
  String get artists => 'Artists';

  @override
  String get artistsRowDesc => 'Horizontal shelf of artists';

  @override
  String get ascending => 'Ascending';

  @override
  String get audioCrossfade => 'Audio Crossfade';

  @override
  String get audioCrossfadeDesc =>
      'Overlap tracks smoothly when changing songs';

  @override
  String get audioFocusDenied =>
      'Playback paused: Audio focus denied by system';

  @override
  String get audioPlayback => 'Audio & Playback';

  @override
  String get audioPlaybackDesc => 'Crossfade, silence gap, and fading settings';

  @override
  String get autoCrossfadeDuration => 'Auto Crossfade Duration';

  @override
  String get autoCrossfadeDurationDesc =>
      'Overlap duration when transitioning automatically';

  @override
  String get backToMainView => 'BACK TO MAIN VIEW';

  @override
  String get cancel => 'Cancel';

  @override
  String get categories => 'Categories';

  @override
  String get center => 'Center';

  @override
  String get clear => 'Clear';

  @override
  String get clearQueue => 'Clear';

  @override
  String get connectDevice => 'CONNECT DEVICE';

  @override
  String get corePurpose => 'Core Purpose';

  @override
  String get corePurposeDesc =>
      'Looper Player is an offline-first, high-fidelity audio player designed for music enthusiasts who want absolute control over their local library, gapless playback, and fluid, synchronized lyrics scrolling.';

  @override
  String get create => 'Create';

  @override
  String get createPlaylist => 'Create Playlist';

  @override
  String get creatorAndMaintainer => 'Creator and Maintainer';

  @override
  String get customAccentColor => 'Custom Accent Color';

  @override
  String get customizeColorsTheme =>
      'Customize app colors, theme, and lyrics backgrounds';

  @override
  String get dateAdded => 'Date Added';

  @override
  String get deepStorageScanProgress => 'DEEP STORAGE SCAN IN PROGRESS...';

  @override
  String get delete => 'Delete';

  @override
  String get deleteFile => 'Delete File';

  @override
  String get deletePlaylist => 'Delete Playlist';

  @override
  String deletePlaylistConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get deleteSong => 'Delete Song';

  @override
  String get deleteSongConfirm =>
      'Are you sure you want to delete this song from disk?';

  @override
  String get descending => 'Descending';

  @override
  String get designerAndMaintainer => 'Designer and Maintainer';

  @override
  String get disableBlurEffects => 'Disable Blur Effects';

  @override
  String get disableSquigglyProgressBar =>
      'Disable squiggly wave progress bar animation';

  @override
  String get downloadAudioDirectly => 'DOWNLOAD AUDIO DIRECTLY';

  @override
  String get downloadingLyricsOffline =>
      'Downloading lyrics for offline use...';

  @override
  String get downloadMissingArtwork => 'Download Missing Artwork';

  @override
  String get downloadMissingArtworkDesc =>
      'Automatically download high-resolution cover artwork for songs from iTunes';

  @override
  String get duration => 'Duration';

  @override
  String get dynamicAccentColor => 'Dynamic Accent Color';

  @override
  String get dynamicAccentColorDesc =>
      'Update only the accent color dynamically from the artwork';

  @override
  String get dynamicBgOnlyLyrics => 'Dynamic background only for lyrics';

  @override
  String get dynamicColorActiveLyrics => 'Dynamic Color Active Line';

  @override
  String get dynamicColorActiveLyricsDesc =>
      'Use extracted artwork colors for the currently playing lyrics line';

  @override
  String get dynamicLyricsBg => 'Dynamic Lyrics BG';

  @override
  String get dynamicLyricsBgDesc => 'Apply album-art blur to lyrics screen';

  @override
  String get dynamicTheming => 'Dynamic Theming';

  @override
  String get emptyLibraryDesc =>
      'We couldn\'t find any supported music files in your library. Add folders or run a search scan.';

  @override
  String get enableNetworkLyricsArt =>
      'Enable network use for online lyrics & artist art';

  @override
  String get enablePlayerGradient => 'Music Screen Gradient';

  @override
  String get enablePlayerGradientDesc =>
      'Enable the radial accent gradient background on the now playing screen';

  @override
  String get fadeDuration => 'Fade Duration';

  @override
  String get fadeDurationDesc => 'Duration of play/pause/stop fade effect';

  @override
  String get fadeOnSeek => 'Fade on Seek';

  @override
  String get fadeOnSeekDesc =>
      'Smoothly fade audio volume out and in when seeking';

  @override
  String get fadePlayPauseStop => 'Fade Play/Pause/Stop';

  @override
  String get fadePlayPauseStopDesc =>
      'Smoothly fade audio volume when playing, pausing or stopping';

  @override
  String get favorites => 'Favorites';

  @override
  String get fileInformation => 'File Information';

  @override
  String get flatProgressBar => 'Flat Progress Bar';

  @override
  String get folders => 'Folders';

  @override
  String get genre => 'Genre';

  @override
  String get genres => 'Genres';

  @override
  String get genresRowDesc => 'Horizontal shelf of music genres';

  @override
  String get goStart => 'GO START';

  @override
  String get grant => 'GRANT';

  @override
  String get granted => 'GRANTED';

  @override
  String get history => 'History';

  @override
  String get home => 'Home';

  @override
  String get homeDarkness => 'Home Screen Darkness';

  @override
  String get homeDarknessDesc =>
      'Adjust background overlay darkness for the Home screen';

  @override
  String get homeDashboardSettings => 'Home Dashboard Settings';

  @override
  String get homeDashboardSettingsDesc =>
      'Customize horizontal rows on your Home screen';

  @override
  String get internetMode => 'Internet Mode';

  @override
  String get keepBackgroundGradient => 'Keep Background Gradient';

  @override
  String get keepBackgroundGradientDesc =>
      'Keep the background gradient across all application screens';

  @override
  String get language => 'Language';

  @override
  String get left => 'Left';

  @override
  String get library => 'Library';

  @override
  String get libraryDarkness => 'Library Screen Darkness';

  @override
  String get libraryDarknessDesc =>
      'Adjust background overlay darkness for the Library screen';

  @override
  String get libraryFoldersSync =>
      'Folders, rescan triggers, reset database, and offline sync';

  @override
  String get librarySettings => 'Library Settings';

  @override
  String get loadingMusicLibrary => 'LOADING MUSIC LIBRARY';

  @override
  String get loadingMusicLibraryDesc =>
      'Building premium indexes, setting up hardware listeners, and optimizing visual caches.';

  @override
  String get loadingPhase1 => 'INTERROGATING AUDIO STORAGE...';

  @override
  String get loadingPhase2 => 'REFRESHING MUSIC ENGINE...';

  @override
  String get loadingPhase3 => 'EXTRACTING ACOUSTIC DATA...';

  @override
  String get loadingPhase4 => 'OPTIMIZING PLAYBACK MEMORY...';

  @override
  String get lyrics => 'Lyrics';

  @override
  String get lyricsAlignment => 'Lyrics Alignment';

  @override
  String get lyricsAlignmentDesc => 'Align text positions for scrolling lyrics';

  @override
  String get lyricsDarkness => 'Lyrics Screen Darkness';

  @override
  String get lyricsDarknessDesc =>
      'Adjust background overlay darkness for the Lyrics screen';

  @override
  String get lyricsProvider => 'Lyrics Provider';

  @override
  String get lyricsProviderDesc =>
      'Online lyrics fetched from lrclib.net (LRCLIB)';

  @override
  String get maintainersAndDesigners => 'Maintainers & Designers';

  @override
  String get manageAudioFocus => 'Manage Audio Focus';

  @override
  String get manageAudioFocusDesc =>
      'Request and respond to system audio focus changes';

  @override
  String get manageAudioFocusTitle => 'Manage Audio Focus';

  @override
  String get manageLanguageAndFocus =>
      'Manage language preferences and caller focus state';

  @override
  String get manualCrossfadeDuration => 'Manual Crossfade Duration';

  @override
  String get manualCrossfadeDurationDesc =>
      'Overlap duration when skipping manually';

  @override
  String get matchingLyrics => 'MATCHING LYRICS';

  @override
  String get metadataDetails => 'Metadata Details';

  @override
  String get mostPlayed => 'Most Played';

  @override
  String get musicAudioAccess => 'MUSIC & AUDIO ACCESS';

  @override
  String get musicDarkness => 'Music Player Darkness';

  @override
  String get musicDarknessDesc =>
      'Adjust background overlay darkness for the Music Player screen';

  @override
  String get musicLibrary => 'Music Library';

  @override
  String get muteOrPauseCalls =>
      'Mute or pause during calls and other audio activity';

  @override
  String get newPlaylist => 'New Playlist';

  @override
  String get newTitle => 'New Title';

  @override
  String get noAlbumsFound => 'No albums found';

  @override
  String get noArtistsFound => 'No artists found';

  @override
  String get noFavoritesYet => 'No favorites yet';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get noLyrics => 'No Lyrics Found';

  @override
  String get noMusicDetected => 'NO MUSIC DETECTED';

  @override
  String get noPlaylistsCreated => 'No playlists created yet.';

  @override
  String get noPlaylistsYet => 'No playlists yet';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get noSongsFound => 'No songs found';

  @override
  String get notificationAccess => 'NOTIFICATION ACCESS';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get performanceOptimizerDashboard => 'Performance Optimizer Dashboard';

  @override
  String get performanceOptimizerDashboardDesc =>
      'Show real-time performance optimizer stats overlay';

  @override
  String get permanentFocusChangePause => 'Permanent Focus Change Pause';

  @override
  String get permanentFocusChangePauseDesc =>
      'Pause playing automatically on permanent audio focus loss';

  @override
  String get plainTimestamps => 'Plain Timestamps';

  @override
  String get play => 'Play';

  @override
  String get playAll => 'Play All';

  @override
  String get playbackAudio => 'Playback & Language';

  @override
  String get playlists => 'Playlists';

  @override
  String get playNext => 'Play Next';

  @override
  String get playQueue => 'Play Queue';

  @override
  String get pressBackExit => 'Press back again to exit';

  @override
  String get privacySafety => 'Privacy & Safety';

  @override
  String get privacySafetyDesc =>
      '100% private and offline-first. Your tracks, playback history, favorites, and configuration stay strictly inside a secure Isar database on your local device. We do not track, collect, or share your usage data or preferences.';

  @override
  String get pureBlackOled => 'Pure Black (OLED)';

  @override
  String get pureBlackOledDesc => 'Use absolute black backgrounds';

  @override
  String get queue => 'Queue';

  @override
  String get queueIsEmpty => 'Queue is empty';

  @override
  String get quickPicks => 'Quick Picks';

  @override
  String get quickPicksRowDesc => 'Your most played grid of songs';

  @override
  String get readyToScan => 'Ready to Scan';

  @override
  String get recentlyAddedSongsRowDesc => 'A list of your latest imports';

  @override
  String get recentlyPlayed => 'Recently Played';

  @override
  String get recentPlayed => 'Recent Played';

  @override
  String get removedFromPlaylist => 'Removed from Playlist';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get removeFromPlaylist => 'Remove from Playlist';

  @override
  String get rename => 'Rename';

  @override
  String get renameFile => 'Rename File';

  @override
  String get renamePlaylist => 'Rename Playlist';

  @override
  String get renameSong => 'Rename Song';

  @override
  String get reorderDashboardSections => 'Reorder Dashboard Sections';

  @override
  String get reorderDashboardSectionsDesc =>
      'Drag and drop to set preferred dashboard order';

  @override
  String get rescanLibrary => 'Rescan Library';

  @override
  String get rescanStorage => 'RESCAN STORAGE';

  @override
  String get reset => 'Reset';

  @override
  String get resetLibrary => 'Reset & Rescan';

  @override
  String get resetLibraryConfirm =>
      'This will clear all songs, albums, and artists and perform a full rescan of your folders.';

  @override
  String get resetLibraryConfirmNew =>
      'This will remove all songs from your library. Your music files will not be deleted.';

  @override
  String get resetLibraryDesc => 'Remove all songs from your indexed library';

  @override
  String get resumeAfterCallDesc =>
      'Resume playing automatically on call hang up (if paused by call)';

  @override
  String get resumeAfterCallTitle => 'Resume after Call';

  @override
  String get resumeOnStartDesc =>
      'Resume playing automatically when Looper Player is started';

  @override
  String get resumeOnStartTitle => 'Resume on Start';

  @override
  String get right => 'Right';

  @override
  String scanCompleteSongsDetected(int count) {
    return 'SCAN COMPLETE: $count SONGS DETECTED!';
  }

  @override
  String get scanForMusic => 'SCAN FOR MUSIC';

  @override
  String get scanIndexLocalDesc => 'Scan & index local music files';

  @override
  String get scanLibrary => 'Scan Library';

  @override
  String get scanningInBackground => 'Scanning in background...';

  @override
  String get scanningLibrary => 'Scanning library...';

  @override
  String get scanningStorage => 'SCANNING STORAGE...';

  @override
  String get scanningStorageDesc =>
      'Traversing directory trees to discover audio tracks. Please hold on...';

  @override
  String get search => 'Search';

  @override
  String get searchLibraryHint => 'Search your entire library';

  @override
  String get searchSongsHint => 'Search songs';

  @override
  String get seekFadeDuration => 'Seek Fade Duration';

  @override
  String get seekFadeDurationDesc => 'Duration of seeking fade effect';

  @override
  String get selectAppLanguage => 'Select application language';

  @override
  String get selectCustomColor => 'Select Custom Color';

  @override
  String get selectCustomFolder => 'SELECT CUSTOM FOLDER';

  @override
  String get selectFolderIndex => 'Select folder to index music files';

  @override
  String get selectSpecificFolder => 'SELECT SPECIFIC FOLDER';

  @override
  String get settings => 'Settings';

  @override
  String get share => 'Share';

  @override
  String get shareFile => 'Share File';

  @override
  String get showAlbumsRow => 'Show Albums Row';

  @override
  String get showAlbumsRowDesc =>
      'Display a horizontal list of albums on your Home screen';

  @override
  String get showArtistsRow => 'Show Artists Row';

  @override
  String get showArtistsRowDesc =>
      'Display a horizontal list of artists on your Home screen';

  @override
  String get showGenresRow => 'Show Genres Row';

  @override
  String get showGenresRowDesc =>
      'Display a horizontal list of genres on your Home screen';

  @override
  String get showLess => 'Show Less';

  @override
  String get showMore => 'Show More';

  @override
  String get showQualityBadge => 'Show Quality Badge';

  @override
  String get showQualityBadgeDesc =>
      'Display audio quality information badge on the now playing screen';

  @override
  String get silenceBetweenTracksDesc =>
      'Add a silence gap between tracks (0ms for gapless)';

  @override
  String get silenceBetweenTracksTitle => 'Silence Between Tracks';

  @override
  String get songDeletedDbOnly =>
      'Song removed from library (physical file read-only)';

  @override
  String get songDeletedSuccess => 'Song deleted successfully';

  @override
  String get songDeleteFailed => 'Failed to delete song';

  @override
  String get songDetails => 'Song Details';

  @override
  String get songDetailsAndFrequency => 'Song Details & Frequency';

  @override
  String get songRenamedDbOnly =>
      'Song renamed in app library (physical file read-only)';

  @override
  String get songRenamedSuccess => 'Song renamed successfully';

  @override
  String get songRenameFailed => 'Failed to rename song';

  @override
  String get songs => 'Songs';

  @override
  String get songsDarkness => 'Songs Screen Darkness';

  @override
  String get songsDarknessDesc =>
      'Adjust background overlay darkness for the Songs screen';

  @override
  String get sortBy => 'Sort By';

  @override
  String get sortOrder => 'Sort Order';

  @override
  String get sourceCode => 'Source Code';

  @override
  String get stopServiceOnAppDismissal => 'Stop Service on App Dismissal';

  @override
  String get stopServiceOnAppDismissalDesc =>
      'Stop background service and close app when dismissed';

  @override
  String get storagePermissionRequired =>
      'Storage permissions are required to scan device memory.';

  @override
  String get syncLyricsOffline => 'Sync Lyrics (Offline)';

  @override
  String get systemDefault => 'System Default';

  @override
  String get systemPermissionChecklist => 'SYSTEM PERMISSION CHECKLIST';

  @override
  String get technicalInfoFrequency => 'Technical Info & Frequency';

  @override
  String get theme => 'Theme';

  @override
  String get title => 'Title';

  @override
  String get todayMixForYou => 'Today Mix for you';

  @override
  String get toggleFavorite => 'Toggle Favorite';

  @override
  String get topResult => 'Top Result';

  @override
  String get transferMusicFiles => 'TRANSFER MUSIC FILES';

  @override
  String get turnOffBlursOptimize =>
      'Turn off heavy blurs to optimize performance';

  @override
  String get unknown => 'Unknown';

  @override
  String get unknownAlbum => 'Unknown Album';

  @override
  String get unknownArtist => 'Unknown Artist';

  @override
  String get updateLibraryIndexing => 'Update library files indexing';

  @override
  String get useAbsoluteBlackBg => 'Use absolute black for backgrounds';

  @override
  String get useStaticTextTimestamps =>
      'Use static text instead of rolling animation for progress duration';

  @override
  String get verticalMotionEffectPlayer => 'Vertical Motion Effect Player';

  @override
  String get verticalMotionEffectPlayerDesc =>
      'Swipe down on the expanded player to dismiss it';

  @override
  String get viewAll => 'View All';

  @override
  String get visitOfficialRepository => 'Visit official repository on GitHub';

  @override
  String get welcomeAboutDesc =>
      'Looper Player is a next-generation Music-OS built for premium offline audio playback. Features real-time dynamic lyrics generation, advanced audio session management with call mute handling, adaptive background theming, and multi-format music library support. Fully optimized for maximum battery efficiency.';

  @override
  String get welcomeAllFilesDesc =>
      'Highly recommended for professional scanning to locate songs in non-standard directories (Downloads, Telegram, custom folders).';

  @override
  String get welcomeInstructionConnectDesc =>
      'Plug your phone or device into a personal computer using a standard USB data cable.';

  @override
  String get welcomeInstructionDownloadDesc =>
      'Alternatively, download files directly using a web browser or other downloader utility on the device itself.';

  @override
  String get welcomeInstructionTransferDesc =>
      'Copy your offline music files (supports .mp3, .flac, .m4a, .wav) directly into the standard \'Music\' or \'Download\' folder of your device.';

  @override
  String get welcomeMusicAudioDesc =>
      'Required to discover and play standard offline audio tracks on your device memory.';

  @override
  String get welcomeNoSongsDesc =>
      'We couldn\'t find any supported audio files (MP3, FLAC, WAV, M4A, OGG) on your device storage.';

  @override
  String get welcomeNotificationDesc =>
      'Required to show playback controls and active notification widgets in your system bar.';

  @override
  String get welcomeScanningFoldersDesc =>
      'Scanning all folders and subfolders for audio files.';

  @override
  String get whyInternetUsed => 'Why Internet is Used';

  @override
  String get whyInternetUsedDesc =>
      '• Dynamic Lyrics Syncing: Used solely to securely fetch and download synchronized lyrics (LRC formats) from online databases. No personal data, settings, or media files are ever uploaded or shared.';

  @override
  String get whyPermissionsUsed => 'Why Permissions are Used';

  @override
  String get whyPermissionsUsedDesc =>
      '• Storage / Media Access: Required to discover, read, and index local audio tracks stored on your device.\n• Notifications: Required to display active playback control widgets in your status bar and system drawer.';

  @override
  String get willPlayNext => 'Will play next';

  @override
  String get year => 'Year';
}
