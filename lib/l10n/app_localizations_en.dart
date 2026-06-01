// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Looper Player';

  @override
  String get songs => 'Songs';

  @override
  String get albums => 'Albums';

  @override
  String get artists => 'Artists';

  @override
  String get playlists => 'Playlists';

  @override
  String get search => 'Search';

  @override
  String get settings => 'Settings';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get playQueue => 'Play Queue';

  @override
  String get lyrics => 'Lyrics';

  @override
  String get noLyrics => 'No Lyrics Found';

  @override
  String get scanLibrary => 'Scan Library';

  @override
  String get addFolder => 'Add Folder';

  @override
  String get resetLibrary => 'Reset & Rescan';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get accentColor => 'Accent Color';

  @override
  String get customAccentColor => 'Custom Accent Color';

  @override
  String get selectCustomColor => 'Select Custom Color';

  @override
  String get about => 'About';

  @override
  String get unknownArtist => 'Unknown Artist';

  @override
  String get unknownAlbum => 'Unknown Album';

  @override
  String get customizeColorsTheme =>
      'Customize app colors, theme, and lyrics backgrounds';

  @override
  String get dynamicTheming => 'Dynamic Theming';

  @override
  String get adaptColorsArtwork => 'Adapt app colors to album artwork';

  @override
  String get disableBlurEffects => 'Disable Blur Effects';

  @override
  String get turnOffBlursOptimize =>
      'Turn off heavy blurs to optimize performance';

  @override
  String get pureBlackOled => 'Pure Black (OLED)';

  @override
  String get useAbsoluteBlackBg => 'Use absolute black for backgrounds';

  @override
  String get dynamicLyricsBg => 'Dynamic Lyrics BG';

  @override
  String get dynamicBgOnlyLyrics => 'Dynamic background only for lyrics';

  @override
  String get flatProgressBar => 'Flat Progress Bar';

  @override
  String get disableSquigglyProgressBar =>
      'Disable squiggly wave progress bar animation';

  @override
  String get plainTimestamps => 'Plain Timestamps';

  @override
  String get useStaticTextTimestamps =>
      'Use static text instead of rolling animation for progress duration';

  @override
  String get playbackAudio => 'Playback & Audio';

  @override
  String get manageLanguageAndFocus =>
      'Manage language preferences and caller focus state';

  @override
  String get manageAudioFocus => 'Manage Audio Focus';

  @override
  String get muteOrPauseCalls =>
      'Mute or pause during calls and other audio activity';

  @override
  String get internetMode => 'Internet Mode';

  @override
  String get enableNetworkLyricsArt =>
      'Enable network use for online lyrics & artist art';

  @override
  String get musicLibrary => 'Music Library';

  @override
  String get libraryFoldersSync =>
      'Folders, rescan triggers, reset database, and offline sync';

  @override
  String get syncLyricsOffline => 'Sync Lyrics (Offline)';

  @override
  String get downloadingLyricsOffline =>
      'Downloading lyrics for offline use...';

  @override
  String get rescanLibrary => 'Rescan Library';

  @override
  String get scanningLibrary => 'Scanning library...';

  @override
  String get aboutAndMaintainers => 'About & Maintainers';

  @override
  String get appDetailsCreator =>
      'Application details, creator, and design team info';

  @override
  String get lyricsProvider => 'Lyrics Provider';

  @override
  String get creatorAndMaintainer => 'Creator and Maintainer';

  @override
  String get designerAndMaintainer => 'Designer and Maintainer';

  @override
  String get appInfoPrivacy => 'APP INFO & PRIVACY';

  @override
  String get corePurpose => 'Core Purpose';

  @override
  String get corePurposeDesc =>
      'Looper Player is an offline-first, high-fidelity audio player designed for music enthusiasts who want absolute control over their local library, gapless playback, and fluid, synchronized lyrics scrolling.';

  @override
  String get whyPermissionsUsed => 'Why Permissions are Used';

  @override
  String get whyPermissionsUsedDesc =>
      '• Storage / Media Access: Required to discover, read, and index local audio tracks stored on your device.\n• Notifications: Required to display active playback control widgets in your status bar and system drawer.';

  @override
  String get whyInternetUsed => 'Why Internet is Used';

  @override
  String get whyInternetUsedDesc =>
      '• Dynamic Lyrics Syncing: Used solely to securely fetch and download synchronized lyrics (LRC formats) from online databases. No personal data, settings, or media files are ever uploaded or shared.';

  @override
  String get privacySafety => 'Privacy & Safety';

  @override
  String get privacySafetyDesc =>
      '100% private and offline-first. Your tracks, playback history, favorites, and configuration stay strictly inside a secure Isar database on your local device. We do not track, collect, or share your usage data or preferences.';

  @override
  String get searchSongsHint => 'Search songs';

  @override
  String get searchLibraryHint => 'Search your entire library';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get topResult => 'Top Result';

  @override
  String get matchingLyrics => 'MATCHING LYRICS';

  @override
  String get favorites => 'Favorites';

  @override
  String get recentPlayed => 'Recent Played';

  @override
  String get categories => 'Categories';

  @override
  String get noSongsFound => 'No songs found';

  @override
  String get allSongs => 'All Songs';

  @override
  String get library => 'Library';

  @override
  String get clearQueue => 'Clear';

  @override
  String get queueIsEmpty => 'Queue is empty';

  @override
  String get aboutLooperPlayer => 'ABOUT LOOPER PLAYER';

  @override
  String get systemPermissionChecklist => 'SYSTEM PERMISSION CHECKLIST';

  @override
  String get notificationAccess => 'NOTIFICATION ACCESS';

  @override
  String get musicAudioAccess => 'MUSIC & AUDIO ACCESS';

  @override
  String get allFilesAccess => 'ALL FILES ACCESS (RECOMMENDED)';

  @override
  String get goStart => 'GO START';

  @override
  String get selectSpecificFolder => 'SELECT SPECIFIC FOLDER';

  @override
  String get grant => 'GRANT';

  @override
  String get granted => 'GRANTED';

  @override
  String get deepStorageScanProgress => 'DEEP STORAGE SCAN IN PROGRESS...';

  @override
  String get noMusicDetected => 'NO MUSIC DETECTED';

  @override
  String get connectDevice => 'CONNECT DEVICE';

  @override
  String get transferMusicFiles => 'TRANSFER MUSIC FILES';

  @override
  String get downloadAudioDirectly => 'DOWNLOAD AUDIO DIRECTLY';

  @override
  String get rescanStorage => 'RESCAN STORAGE';

  @override
  String get backToMainView => 'BACK TO MAIN VIEW';

  @override
  String get storagePermissionRequired =>
      'Storage permissions are required to scan device memory.';

  @override
  String get folders => 'Folders';

  @override
  String get genres => 'Genres';

  @override
  String get queue => 'Queue';

  @override
  String get history => 'History';

  @override
  String get artist => 'Artist';

  @override
  String get genre => 'Genre';

  @override
  String get noAlbumsFound => 'No albums found';

  @override
  String get noArtistsFound => 'No artists found';

  @override
  String get unknown => 'Unknown';

  @override
  String get welcomeAboutDesc =>
      'Looper Player is a next-generation Music-OS built for premium offline audio playback. Features real-time dynamic lyrics generation, advanced audio session management with call mute handling, adaptive background theming, and multi-format music library support. Fully optimized for maximum battery efficiency.';

  @override
  String get welcomeNotificationDesc =>
      'Required to show playback controls and active notification widgets in your system bar.';

  @override
  String get welcomeMusicAudioDesc =>
      'Required to discover and play standard offline audio tracks on your device memory.';

  @override
  String get welcomeAllFilesDesc =>
      'Highly recommended for professional scanning to locate songs in non-standard directories (Downloads, Telegram, custom folders).';

  @override
  String scanCompleteSongsDetected(int count) {
    return 'SCAN COMPLETE: $count SONGS DETECTED!';
  }

  @override
  String get welcomeScanningFoldersDesc =>
      'Scanning all folders and subfolders for audio files.';

  @override
  String get welcomeNoSongsDesc =>
      'We couldn\'t find any supported audio files (MP3, FLAC, WAV, M4A, OGG) on your device storage.';

  @override
  String get welcomeInstructionConnectDesc =>
      'Plug your phone or device into a personal computer using a standard USB data cable.';

  @override
  String get welcomeInstructionTransferDesc =>
      'Copy your offline music files (supports .mp3, .flac, .m4a, .wav) directly into the standard \'Music\' or \'Download\' folder of your device.';

  @override
  String get welcomeInstructionDownloadDesc =>
      'Alternatively, download files directly using a web browser or other downloader utility on the device itself.';

  @override
  String get loadingMusicLibrary => 'LOADING MUSIC LIBRARY';

  @override
  String get loadingMusicLibraryDesc =>
      'Building premium indexes, setting up hardware listeners, and optimizing visual caches.';

  @override
  String get addToQueue => 'Add to Queue';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get songDetails => 'Song Details';

  @override
  String get technicalInfoFrequency => 'Technical Info & Frequency';

  @override
  String get share => 'Share';

  @override
  String get quickPicks => 'Quick Picks';

  @override
  String get todayMixForYou => 'Today Mix for you';

  @override
  String get play => 'Play';

  @override
  String get viewAll => 'View All';

  @override
  String get pressBackExit => 'Press back again to exit';

  @override
  String get scanningStorage => 'SCANNING STORAGE...';

  @override
  String get readyToScan => 'Ready to Scan';

  @override
  String get scanIndexLocalDesc => 'Scan & index local music files';

  @override
  String get scanForMusic => 'SCAN FOR MUSIC';

  @override
  String get selectCustomFolder => 'SELECT CUSTOM FOLDER';

  @override
  String get scanningInBackground => 'Scanning in background...';

  @override
  String get loadingPhase1 => 'INTERROGATING AUDIO STORAGE...';

  @override
  String get loadingPhase2 => 'REFRESHING MUSIC ENGINE...';

  @override
  String get loadingPhase3 => 'EXTRACTING ACOUSTIC DATA...';

  @override
  String get loadingPhase4 => 'OPTIMIZING PLAYBACK MEMORY...';

  @override
  String get scanningStorageDesc =>
      'Traversing directory trees to discover audio tracks. Please hold on...';

  @override
  String get emptyLibraryDesc =>
      'We couldn\'t find any supported music files in your library. Add folders or run a search scan.';

  @override
  String get home => 'Home';

  @override
  String get toggleFavorite => 'Toggle Favorite';

  @override
  String get renameFile => 'Rename File';

  @override
  String get shareFile => 'Share File';

  @override
  String get deleteFile => 'Delete File';

  @override
  String get songDetailsAndFrequency => 'Song Details & Frequency';

  @override
  String get metadataDetails => 'Metadata Details';

  @override
  String get fileInformation => 'File Information';

  @override
  String get showLess => 'Show Less';

  @override
  String get showMore => 'Show More';

  @override
  String get acousticSpectralAnalysis => 'ACOUSTIC & SPECTRAL ANALYSIS';

  @override
  String get cancel => 'Cancel';

  @override
  String get renameSong => 'Rename Song';

  @override
  String get newTitle => 'New Title';

  @override
  String get rename => 'Rename';

  @override
  String get deleteSong => 'Delete Song';

  @override
  String get deleteSongConfirm =>
      'Are you sure you want to delete this song from disk?';

  @override
  String get delete => 'Delete';

  @override
  String get downloadMissingArtwork => 'Download Missing Artwork';

  @override
  String get downloadMissingArtworkDesc =>
      'Automatically download high-resolution cover artwork for songs from iTunes';

  @override
  String get keepBackgroundGradient => 'Keep Background Gradient';

  @override
  String get keepBackgroundGradientDesc =>
      'Keep the background gradient across all application screens';

  @override
  String get homeDashboardSettings => 'Home Dashboard Settings';

  @override
  String get homeDashboardSettingsDesc =>
      'Customize horizontal rows on your Home screen';

  @override
  String get showArtistsRow => 'Show Artists Row';

  @override
  String get showArtistsRowDesc =>
      'Display a horizontal list of artists on your Home screen';

  @override
  String get showAlbumsRow => 'Show Albums Row';

  @override
  String get showAlbumsRowDesc =>
      'Display a horizontal list of albums on your Home screen';

  @override
  String get showGenresRow => 'Show Genres Row';

  @override
  String get showGenresRowDesc =>
      'Display a horizontal list of genres on your Home screen';

  @override
  String get reorderDashboardSections => 'Reorder Dashboard Sections';

  @override
  String get reorderDashboardSectionsDesc =>
      'Drag and drop to set preferred dashboard order';

  @override
  String get quickPicksRowDesc => 'Your most played grid of songs';

  @override
  String get recentlyAddedSongsRowDesc => 'A list of your latest imports';

  @override
  String get albumsRowDesc => 'Horizontal shelf of albums';

  @override
  String get artistsRowDesc => 'Horizontal shelf of artists';

  @override
  String get genresRowDesc => 'Horizontal shelf of music genres';
}
