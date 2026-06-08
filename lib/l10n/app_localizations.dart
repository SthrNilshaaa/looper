import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutAndMaintainers.
  ///
  /// In en, this message translates to:
  /// **'About & Maintainers'**
  String get aboutAndMaintainers;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @aboutLooperPlayer.
  ///
  /// In en, this message translates to:
  /// **'ABOUT LOOPER PLAYER'**
  String get aboutLooperPlayer;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get accentColor;

  /// No description provided for @accentColorDesc.
  ///
  /// In en, this message translates to:
  /// **'Select manual theme accent color'**
  String get accentColorDesc;

  /// No description provided for @acousticSpectralAnalysis.
  ///
  /// In en, this message translates to:
  /// **'ACOUSTIC & SPECTRAL ANALYSIS'**
  String get acousticSpectralAnalysis;

  /// No description provided for @activeCallCannotPlay.
  ///
  /// In en, this message translates to:
  /// **'Playback blocked: Cannot play music during an active call'**
  String get activeCallCannotPlay;

  /// No description provided for @adaptColorsArtwork.
  ///
  /// In en, this message translates to:
  /// **'Adapt app colors to album artwork'**
  String get adaptColorsArtwork;

  /// No description provided for @addedTo.
  ///
  /// In en, this message translates to:
  /// **'Added to {name}'**
  String addedTo(String name);

  /// No description provided for @addedToQueue.
  ///
  /// In en, this message translates to:
  /// **'Added to queue'**
  String get addedToQueue;

  /// No description provided for @addFolder.
  ///
  /// In en, this message translates to:
  /// **'Add Folder'**
  String get addFolder;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// No description provided for @addToPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlists'**
  String get addToPlaylists;

  /// No description provided for @addToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add to Queue'**
  String get addToQueue;

  /// No description provided for @album.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get album;

  /// No description provided for @albums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albums;

  /// No description provided for @albumsRowDesc.
  ///
  /// In en, this message translates to:
  /// **'Horizontal shelf of albums'**
  String get albumsRowDesc;

  /// No description provided for @allFilesAccess.
  ///
  /// In en, this message translates to:
  /// **'ALL FILES ACCESS (RECOMMENDED)'**
  String get allFilesAccess;

  /// No description provided for @allSongs.
  ///
  /// In en, this message translates to:
  /// **'All Songs'**
  String get allSongs;

  /// No description provided for @appDetailsCreator.
  ///
  /// In en, this message translates to:
  /// **'Application details, creator, and design team info'**
  String get appDetailsCreator;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appInfoPrivacy.
  ///
  /// In en, this message translates to:
  /// **'APP INFO & PRIVACY'**
  String get appInfoPrivacy;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Looper Player'**
  String get appTitle;

  /// No description provided for @artist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get artist;

  /// No description provided for @artists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artists;

  /// No description provided for @artistsRowDesc.
  ///
  /// In en, this message translates to:
  /// **'Horizontal shelf of artists'**
  String get artistsRowDesc;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @audioCrossfade.
  ///
  /// In en, this message translates to:
  /// **'Audio Crossfade'**
  String get audioCrossfade;

  /// No description provided for @audioCrossfadeDesc.
  ///
  /// In en, this message translates to:
  /// **'Overlap tracks smoothly when changing songs'**
  String get audioCrossfadeDesc;

  /// No description provided for @audioFocusDenied.
  ///
  /// In en, this message translates to:
  /// **'Playback paused: Audio focus denied by system'**
  String get audioFocusDenied;

  /// No description provided for @audioPlayback.
  ///
  /// In en, this message translates to:
  /// **'Audio & Playback'**
  String get audioPlayback;

  /// No description provided for @audioPlaybackDesc.
  ///
  /// In en, this message translates to:
  /// **'Crossfade, silence gap, and fading settings'**
  String get audioPlaybackDesc;

  /// No description provided for @autoCrossfadeDuration.
  ///
  /// In en, this message translates to:
  /// **'Auto Crossfade Duration'**
  String get autoCrossfadeDuration;

  /// No description provided for @autoCrossfadeDurationDesc.
  ///
  /// In en, this message translates to:
  /// **'Overlap duration when transitioning automatically'**
  String get autoCrossfadeDurationDesc;

  /// No description provided for @backToMainView.
  ///
  /// In en, this message translates to:
  /// **'BACK TO MAIN VIEW'**
  String get backToMainView;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @center.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get center;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearQueue.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearQueue;

  /// No description provided for @connectDevice.
  ///
  /// In en, this message translates to:
  /// **'CONNECT DEVICE'**
  String get connectDevice;

  /// No description provided for @corePurpose.
  ///
  /// In en, this message translates to:
  /// **'Core Purpose'**
  String get corePurpose;

  /// No description provided for @corePurposeDesc.
  ///
  /// In en, this message translates to:
  /// **'Looper Player is an offline-first, high-fidelity audio player designed for music enthusiasts who want absolute control over their local library, gapless playback, and fluid, synchronized lyrics scrolling.'**
  String get corePurposeDesc;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create Playlist'**
  String get createPlaylist;

  /// No description provided for @creatorAndMaintainer.
  ///
  /// In en, this message translates to:
  /// **'Creator and Maintainer'**
  String get creatorAndMaintainer;

  /// No description provided for @customAccentColor.
  ///
  /// In en, this message translates to:
  /// **'Custom Accent Color'**
  String get customAccentColor;

  /// No description provided for @customizeColorsTheme.
  ///
  /// In en, this message translates to:
  /// **'Customize app colors, theme, and lyrics backgrounds'**
  String get customizeColorsTheme;

  /// No description provided for @dateAdded.
  ///
  /// In en, this message translates to:
  /// **'Date Added'**
  String get dateAdded;

  /// No description provided for @deepStorageScanProgress.
  ///
  /// In en, this message translates to:
  /// **'DEEP STORAGE SCAN IN PROGRESS...'**
  String get deepStorageScanProgress;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteFile.
  ///
  /// In en, this message translates to:
  /// **'Delete File'**
  String get deleteFile;

  /// No description provided for @deletePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Delete Playlist'**
  String get deletePlaylist;

  /// No description provided for @deletePlaylistConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deletePlaylistConfirm(String name);

  /// No description provided for @deleteSong.
  ///
  /// In en, this message translates to:
  /// **'Delete Song'**
  String get deleteSong;

  /// No description provided for @deleteSongConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this song from disk?'**
  String get deleteSongConfirm;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @designerAndMaintainer.
  ///
  /// In en, this message translates to:
  /// **'Designer and Maintainer'**
  String get designerAndMaintainer;

  /// No description provided for @disableBlurEffects.
  ///
  /// In en, this message translates to:
  /// **'Disable Blur Effects'**
  String get disableBlurEffects;

  /// No description provided for @disableSquigglyProgressBar.
  ///
  /// In en, this message translates to:
  /// **'Disable squiggly wave progress bar animation'**
  String get disableSquigglyProgressBar;

  /// No description provided for @downloadAudioDirectly.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD AUDIO DIRECTLY'**
  String get downloadAudioDirectly;

  /// No description provided for @downloadingLyricsOffline.
  ///
  /// In en, this message translates to:
  /// **'Downloading lyrics for offline use...'**
  String get downloadingLyricsOffline;

  /// No description provided for @downloadMissingArtwork.
  ///
  /// In en, this message translates to:
  /// **'Download Missing Artwork'**
  String get downloadMissingArtwork;

  /// No description provided for @downloadMissingArtworkDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically download high-resolution cover artwork for songs from iTunes'**
  String get downloadMissingArtworkDesc;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @dynamicAccentColor.
  ///
  /// In en, this message translates to:
  /// **'Dynamic Accent Color'**
  String get dynamicAccentColor;

  /// No description provided for @dynamicAccentColorDesc.
  ///
  /// In en, this message translates to:
  /// **'Update only the accent color dynamically from the artwork'**
  String get dynamicAccentColorDesc;

  /// No description provided for @dynamicBgOnlyLyrics.
  ///
  /// In en, this message translates to:
  /// **'Dynamic background only for lyrics'**
  String get dynamicBgOnlyLyrics;

  /// No description provided for @dynamicColorActiveLyrics.
  ///
  /// In en, this message translates to:
  /// **'Dynamic Color Active Line'**
  String get dynamicColorActiveLyrics;

  /// No description provided for @dynamicColorActiveLyricsDesc.
  ///
  /// In en, this message translates to:
  /// **'Use extracted artwork colors for the currently playing lyrics line'**
  String get dynamicColorActiveLyricsDesc;

  /// No description provided for @dynamicLyricsBg.
  ///
  /// In en, this message translates to:
  /// **'Dynamic Lyrics BG'**
  String get dynamicLyricsBg;

  /// No description provided for @dynamicLyricsBgDesc.
  ///
  /// In en, this message translates to:
  /// **'Apply album-art blur to lyrics screen'**
  String get dynamicLyricsBgDesc;

  /// No description provided for @dynamicTheming.
  ///
  /// In en, this message translates to:
  /// **'Dynamic Theming'**
  String get dynamicTheming;

  /// No description provided for @emptyLibraryDesc.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any supported music files in your library. Add folders or run a search scan.'**
  String get emptyLibraryDesc;

  /// No description provided for @enableNetworkLyricsArt.
  ///
  /// In en, this message translates to:
  /// **'Enable network use for online lyrics & artist art'**
  String get enableNetworkLyricsArt;

  /// No description provided for @enablePlayerGradient.
  ///
  /// In en, this message translates to:
  /// **'Music Screen Gradient'**
  String get enablePlayerGradient;

  /// No description provided for @enablePlayerGradientDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable the radial accent gradient background on the now playing screen'**
  String get enablePlayerGradientDesc;

  /// No description provided for @fadeDuration.
  ///
  /// In en, this message translates to:
  /// **'Fade Duration'**
  String get fadeDuration;

  /// No description provided for @fadeDurationDesc.
  ///
  /// In en, this message translates to:
  /// **'Duration of play/pause/stop fade effect'**
  String get fadeDurationDesc;

  /// No description provided for @fadeOnSeek.
  ///
  /// In en, this message translates to:
  /// **'Fade on Seek'**
  String get fadeOnSeek;

  /// No description provided for @fadeOnSeekDesc.
  ///
  /// In en, this message translates to:
  /// **'Smoothly fade audio volume out and in when seeking'**
  String get fadeOnSeekDesc;

  /// No description provided for @fadePlayPauseStop.
  ///
  /// In en, this message translates to:
  /// **'Fade Play/Pause/Stop'**
  String get fadePlayPauseStop;

  /// No description provided for @fadePlayPauseStopDesc.
  ///
  /// In en, this message translates to:
  /// **'Smoothly fade audio volume when playing, pausing or stopping'**
  String get fadePlayPauseStopDesc;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @fileInformation.
  ///
  /// In en, this message translates to:
  /// **'File Information'**
  String get fileInformation;

  /// No description provided for @flatProgressBar.
  ///
  /// In en, this message translates to:
  /// **'Flat Progress Bar'**
  String get flatProgressBar;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @genre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get genre;

  /// No description provided for @genres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// No description provided for @genresRowDesc.
  ///
  /// In en, this message translates to:
  /// **'Horizontal shelf of music genres'**
  String get genresRowDesc;

  /// No description provided for @goStart.
  ///
  /// In en, this message translates to:
  /// **'GO START'**
  String get goStart;

  /// No description provided for @grant.
  ///
  /// In en, this message translates to:
  /// **'GRANT'**
  String get grant;

  /// No description provided for @granted.
  ///
  /// In en, this message translates to:
  /// **'GRANTED'**
  String get granted;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @homeDarkness.
  ///
  /// In en, this message translates to:
  /// **'Home Screen Darkness'**
  String get homeDarkness;

  /// No description provided for @homeDarknessDesc.
  ///
  /// In en, this message translates to:
  /// **'Adjust background overlay darkness for the Home screen'**
  String get homeDarknessDesc;

  /// No description provided for @homeDashboardSettings.
  ///
  /// In en, this message translates to:
  /// **'Home Dashboard Settings'**
  String get homeDashboardSettings;

  /// No description provided for @homeDashboardSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize horizontal rows on your Home screen'**
  String get homeDashboardSettingsDesc;

  /// No description provided for @internetMode.
  ///
  /// In en, this message translates to:
  /// **'Internet Mode'**
  String get internetMode;

  /// No description provided for @keepBackgroundGradient.
  ///
  /// In en, this message translates to:
  /// **'Keep Background Gradient'**
  String get keepBackgroundGradient;

  /// No description provided for @keepBackgroundGradientDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep the background gradient across all application screens'**
  String get keepBackgroundGradientDesc;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @libraryDarkness.
  ///
  /// In en, this message translates to:
  /// **'Library Screen Darkness'**
  String get libraryDarkness;

  /// No description provided for @libraryDarknessDesc.
  ///
  /// In en, this message translates to:
  /// **'Adjust background overlay darkness for the Library screen'**
  String get libraryDarknessDesc;

  /// No description provided for @libraryFoldersSync.
  ///
  /// In en, this message translates to:
  /// **'Folders, rescan triggers, reset database, and offline sync'**
  String get libraryFoldersSync;

  /// No description provided for @librarySettings.
  ///
  /// In en, this message translates to:
  /// **'Library Settings'**
  String get librarySettings;

  /// No description provided for @loadingMusicLibrary.
  ///
  /// In en, this message translates to:
  /// **'LOADING MUSIC LIBRARY'**
  String get loadingMusicLibrary;

  /// No description provided for @loadingMusicLibraryDesc.
  ///
  /// In en, this message translates to:
  /// **'Building premium indexes, setting up hardware listeners, and optimizing visual caches.'**
  String get loadingMusicLibraryDesc;

  /// No description provided for @loadingPhase1.
  ///
  /// In en, this message translates to:
  /// **'INTERROGATING AUDIO STORAGE...'**
  String get loadingPhase1;

  /// No description provided for @loadingPhase2.
  ///
  /// In en, this message translates to:
  /// **'REFRESHING MUSIC ENGINE...'**
  String get loadingPhase2;

  /// No description provided for @loadingPhase3.
  ///
  /// In en, this message translates to:
  /// **'EXTRACTING ACOUSTIC DATA...'**
  String get loadingPhase3;

  /// No description provided for @loadingPhase4.
  ///
  /// In en, this message translates to:
  /// **'OPTIMIZING PLAYBACK MEMORY...'**
  String get loadingPhase4;

  /// No description provided for @lyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyrics;

  /// No description provided for @lyricsAlignment.
  ///
  /// In en, this message translates to:
  /// **'Lyrics Alignment'**
  String get lyricsAlignment;

  /// No description provided for @lyricsAlignmentDesc.
  ///
  /// In en, this message translates to:
  /// **'Align text positions for scrolling lyrics'**
  String get lyricsAlignmentDesc;

  /// No description provided for @lyricsDarkness.
  ///
  /// In en, this message translates to:
  /// **'Lyrics Screen Darkness'**
  String get lyricsDarkness;

  /// No description provided for @lyricsDarknessDesc.
  ///
  /// In en, this message translates to:
  /// **'Adjust background overlay darkness for the Lyrics screen'**
  String get lyricsDarknessDesc;

  /// No description provided for @lyricsProvider.
  ///
  /// In en, this message translates to:
  /// **'Lyrics Provider'**
  String get lyricsProvider;

  /// No description provided for @lyricsProviderDesc.
  ///
  /// In en, this message translates to:
  /// **'Online lyrics fetched from lrclib.net (LRCLIB)'**
  String get lyricsProviderDesc;

  /// No description provided for @maintainersAndDesigners.
  ///
  /// In en, this message translates to:
  /// **'Maintainers & Designers'**
  String get maintainersAndDesigners;

  /// No description provided for @manageAudioFocus.
  ///
  /// In en, this message translates to:
  /// **'Manage Audio Focus'**
  String get manageAudioFocus;

  /// No description provided for @manageAudioFocusDesc.
  ///
  /// In en, this message translates to:
  /// **'Request and respond to system audio focus changes'**
  String get manageAudioFocusDesc;

  /// No description provided for @manageAudioFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Audio Focus'**
  String get manageAudioFocusTitle;

  /// No description provided for @manageLanguageAndFocus.
  ///
  /// In en, this message translates to:
  /// **'Manage language preferences and caller focus state'**
  String get manageLanguageAndFocus;

  /// No description provided for @manualCrossfadeDuration.
  ///
  /// In en, this message translates to:
  /// **'Manual Crossfade Duration'**
  String get manualCrossfadeDuration;

  /// No description provided for @manualCrossfadeDurationDesc.
  ///
  /// In en, this message translates to:
  /// **'Overlap duration when skipping manually'**
  String get manualCrossfadeDurationDesc;

  /// No description provided for @matchingLyrics.
  ///
  /// In en, this message translates to:
  /// **'MATCHING LYRICS'**
  String get matchingLyrics;

  /// No description provided for @metadataDetails.
  ///
  /// In en, this message translates to:
  /// **'Metadata Details'**
  String get metadataDetails;

  /// No description provided for @mostPlayed.
  ///
  /// In en, this message translates to:
  /// **'Most Played'**
  String get mostPlayed;

  /// No description provided for @musicAudioAccess.
  ///
  /// In en, this message translates to:
  /// **'MUSIC & AUDIO ACCESS'**
  String get musicAudioAccess;

  /// No description provided for @musicDarkness.
  ///
  /// In en, this message translates to:
  /// **'Music Player Darkness'**
  String get musicDarkness;

  /// No description provided for @musicDarknessDesc.
  ///
  /// In en, this message translates to:
  /// **'Adjust background overlay darkness for the Music Player screen'**
  String get musicDarknessDesc;

  /// No description provided for @musicLibrary.
  ///
  /// In en, this message translates to:
  /// **'Music Library'**
  String get musicLibrary;

  /// No description provided for @muteOrPauseCalls.
  ///
  /// In en, this message translates to:
  /// **'Mute or pause during calls and other audio activity'**
  String get muteOrPauseCalls;

  /// No description provided for @newPlaylist.
  ///
  /// In en, this message translates to:
  /// **'New Playlist'**
  String get newPlaylist;

  /// No description provided for @newTitle.
  ///
  /// In en, this message translates to:
  /// **'New Title'**
  String get newTitle;

  /// No description provided for @noAlbumsFound.
  ///
  /// In en, this message translates to:
  /// **'No albums found'**
  String get noAlbumsFound;

  /// No description provided for @noArtistsFound.
  ///
  /// In en, this message translates to:
  /// **'No artists found'**
  String get noArtistsFound;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @noLyrics.
  ///
  /// In en, this message translates to:
  /// **'No Lyrics Found'**
  String get noLyrics;

  /// No description provided for @noMusicDetected.
  ///
  /// In en, this message translates to:
  /// **'NO MUSIC DETECTED'**
  String get noMusicDetected;

  /// No description provided for @noPlaylistsCreated.
  ///
  /// In en, this message translates to:
  /// **'No playlists created yet.'**
  String get noPlaylistsCreated;

  /// No description provided for @noPlaylistsYet.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet'**
  String get noPlaylistsYet;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noSongsFound.
  ///
  /// In en, this message translates to:
  /// **'No songs found'**
  String get noSongsFound;

  /// No description provided for @notificationAccess.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATION ACCESS'**
  String get notificationAccess;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// No description provided for @performanceOptimizerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Performance Optimizer Dashboard'**
  String get performanceOptimizerDashboard;

  /// No description provided for @performanceOptimizerDashboardDesc.
  ///
  /// In en, this message translates to:
  /// **'Show real-time performance optimizer stats overlay'**
  String get performanceOptimizerDashboardDesc;

  /// No description provided for @permanentFocusChangePause.
  ///
  /// In en, this message translates to:
  /// **'Permanent Focus Change Pause'**
  String get permanentFocusChangePause;

  /// No description provided for @permanentFocusChangePauseDesc.
  ///
  /// In en, this message translates to:
  /// **'Pause playing automatically on permanent audio focus loss'**
  String get permanentFocusChangePauseDesc;

  /// No description provided for @plainTimestamps.
  ///
  /// In en, this message translates to:
  /// **'Plain Timestamps'**
  String get plainTimestamps;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @playAll.
  ///
  /// In en, this message translates to:
  /// **'Play All'**
  String get playAll;

  /// No description provided for @playbackAudio.
  ///
  /// In en, this message translates to:
  /// **'Playback & Language'**
  String get playbackAudio;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @playNext.
  ///
  /// In en, this message translates to:
  /// **'Play Next'**
  String get playNext;

  /// No description provided for @playQueue.
  ///
  /// In en, this message translates to:
  /// **'Play Queue'**
  String get playQueue;

  /// No description provided for @pressBackExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get pressBackExit;

  /// No description provided for @privacySafety.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Safety'**
  String get privacySafety;

  /// No description provided for @privacySafetyDesc.
  ///
  /// In en, this message translates to:
  /// **'100% private and offline-first. Your tracks, playback history, favorites, and configuration stay strictly inside a secure Isar database on your local device. We do not track, collect, or share your usage data or preferences.'**
  String get privacySafetyDesc;

  /// No description provided for @pureBlackOled.
  ///
  /// In en, this message translates to:
  /// **'Pure Black (OLED)'**
  String get pureBlackOled;

  /// No description provided for @pureBlackOledDesc.
  ///
  /// In en, this message translates to:
  /// **'Use absolute black backgrounds'**
  String get pureBlackOledDesc;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @queueIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Queue is empty'**
  String get queueIsEmpty;

  /// No description provided for @quickPicks.
  ///
  /// In en, this message translates to:
  /// **'Quick Picks'**
  String get quickPicks;

  /// No description provided for @quickPicksRowDesc.
  ///
  /// In en, this message translates to:
  /// **'Your most played grid of songs'**
  String get quickPicksRowDesc;

  /// No description provided for @readyToScan.
  ///
  /// In en, this message translates to:
  /// **'Ready to Scan'**
  String get readyToScan;

  /// No description provided for @recentlyAddedSongsRowDesc.
  ///
  /// In en, this message translates to:
  /// **'A list of your latest imports'**
  String get recentlyAddedSongsRowDesc;

  /// No description provided for @recentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently Played'**
  String get recentlyPlayed;

  /// No description provided for @recentPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recent Played'**
  String get recentPlayed;

  /// No description provided for @removedFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Removed from Playlist'**
  String get removedFromPlaylist;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavorites;

  /// No description provided for @removeFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Remove from Playlist'**
  String get removeFromPlaylist;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @renameFile.
  ///
  /// In en, this message translates to:
  /// **'Rename File'**
  String get renameFile;

  /// No description provided for @renamePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Rename Playlist'**
  String get renamePlaylist;

  /// No description provided for @renameSong.
  ///
  /// In en, this message translates to:
  /// **'Rename Song'**
  String get renameSong;

  /// No description provided for @reorderDashboardSections.
  ///
  /// In en, this message translates to:
  /// **'Reorder Dashboard Sections'**
  String get reorderDashboardSections;

  /// No description provided for @reorderDashboardSectionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop to set preferred dashboard order'**
  String get reorderDashboardSectionsDesc;

  /// No description provided for @rescanLibrary.
  ///
  /// In en, this message translates to:
  /// **'Rescan Library'**
  String get rescanLibrary;

  /// No description provided for @rescanStorage.
  ///
  /// In en, this message translates to:
  /// **'RESCAN STORAGE'**
  String get rescanStorage;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetLibrary.
  ///
  /// In en, this message translates to:
  /// **'Reset & Rescan'**
  String get resetLibrary;

  /// No description provided for @resetLibraryConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will clear all songs, albums, and artists and perform a full rescan of your folders.'**
  String get resetLibraryConfirm;

  /// No description provided for @resetLibraryConfirmNew.
  ///
  /// In en, this message translates to:
  /// **'This will remove all songs from your library. Your music files will not be deleted.'**
  String get resetLibraryConfirmNew;

  /// No description provided for @resetLibraryDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove all songs from your indexed library'**
  String get resetLibraryDesc;

  /// No description provided for @resumeAfterCallDesc.
  ///
  /// In en, this message translates to:
  /// **'Resume playing automatically on call hang up (if paused by call)'**
  String get resumeAfterCallDesc;

  /// No description provided for @resumeAfterCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Resume after Call'**
  String get resumeAfterCallTitle;

  /// No description provided for @resumeOnStartDesc.
  ///
  /// In en, this message translates to:
  /// **'Resume playing automatically when Looper Player is started'**
  String get resumeOnStartDesc;

  /// No description provided for @resumeOnStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Resume on Start'**
  String get resumeOnStartTitle;

  /// No description provided for @right.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// No description provided for @scanCompleteSongsDetected.
  ///
  /// In en, this message translates to:
  /// **'SCAN COMPLETE: {count} SONGS DETECTED!'**
  String scanCompleteSongsDetected(int count);

  /// No description provided for @scanForMusic.
  ///
  /// In en, this message translates to:
  /// **'SCAN FOR MUSIC'**
  String get scanForMusic;

  /// No description provided for @scanIndexLocalDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan & index local music files'**
  String get scanIndexLocalDesc;

  /// No description provided for @scanLibrary.
  ///
  /// In en, this message translates to:
  /// **'Scan Library'**
  String get scanLibrary;

  /// No description provided for @scanningInBackground.
  ///
  /// In en, this message translates to:
  /// **'Scanning in background...'**
  String get scanningInBackground;

  /// No description provided for @scanningLibrary.
  ///
  /// In en, this message translates to:
  /// **'Scanning library...'**
  String get scanningLibrary;

  /// No description provided for @scanningStorage.
  ///
  /// In en, this message translates to:
  /// **'SCANNING STORAGE...'**
  String get scanningStorage;

  /// No description provided for @scanningStorageDesc.
  ///
  /// In en, this message translates to:
  /// **'Traversing directory trees to discover audio tracks. Please hold on...'**
  String get scanningStorageDesc;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchLibraryHint.
  ///
  /// In en, this message translates to:
  /// **'Search your entire library'**
  String get searchLibraryHint;

  /// No description provided for @searchSongsHint.
  ///
  /// In en, this message translates to:
  /// **'Search songs'**
  String get searchSongsHint;

  /// No description provided for @seekFadeDuration.
  ///
  /// In en, this message translates to:
  /// **'Seek Fade Duration'**
  String get seekFadeDuration;

  /// No description provided for @seekFadeDurationDesc.
  ///
  /// In en, this message translates to:
  /// **'Duration of seeking fade effect'**
  String get seekFadeDurationDesc;

  /// No description provided for @selectAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select application language'**
  String get selectAppLanguage;

  /// No description provided for @selectCustomColor.
  ///
  /// In en, this message translates to:
  /// **'Select Custom Color'**
  String get selectCustomColor;

  /// No description provided for @selectCustomFolder.
  ///
  /// In en, this message translates to:
  /// **'SELECT CUSTOM FOLDER'**
  String get selectCustomFolder;

  /// No description provided for @selectFolderIndex.
  ///
  /// In en, this message translates to:
  /// **'Select folder to index music files'**
  String get selectFolderIndex;

  /// No description provided for @selectSpecificFolder.
  ///
  /// In en, this message translates to:
  /// **'SELECT SPECIFIC FOLDER'**
  String get selectSpecificFolder;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareFile.
  ///
  /// In en, this message translates to:
  /// **'Share File'**
  String get shareFile;

  /// No description provided for @showAlbumsRow.
  ///
  /// In en, this message translates to:
  /// **'Show Albums Row'**
  String get showAlbumsRow;

  /// No description provided for @showAlbumsRowDesc.
  ///
  /// In en, this message translates to:
  /// **'Display a horizontal list of albums on your Home screen'**
  String get showAlbumsRowDesc;

  /// No description provided for @showArtistsRow.
  ///
  /// In en, this message translates to:
  /// **'Show Artists Row'**
  String get showArtistsRow;

  /// No description provided for @showArtistsRowDesc.
  ///
  /// In en, this message translates to:
  /// **'Display a horizontal list of artists on your Home screen'**
  String get showArtistsRowDesc;

  /// No description provided for @showGenresRow.
  ///
  /// In en, this message translates to:
  /// **'Show Genres Row'**
  String get showGenresRow;

  /// No description provided for @showGenresRowDesc.
  ///
  /// In en, this message translates to:
  /// **'Display a horizontal list of genres on your Home screen'**
  String get showGenresRowDesc;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @showQualityBadge.
  ///
  /// In en, this message translates to:
  /// **'Show Quality Badge'**
  String get showQualityBadge;

  /// No description provided for @showQualityBadgeDesc.
  ///
  /// In en, this message translates to:
  /// **'Display audio quality information badge on the now playing screen'**
  String get showQualityBadgeDesc;

  /// No description provided for @silenceBetweenTracksDesc.
  ///
  /// In en, this message translates to:
  /// **'Add a silence gap between tracks (0ms for gapless)'**
  String get silenceBetweenTracksDesc;

  /// No description provided for @silenceBetweenTracksTitle.
  ///
  /// In en, this message translates to:
  /// **'Silence Between Tracks'**
  String get silenceBetweenTracksTitle;

  /// No description provided for @songDeletedDbOnly.
  ///
  /// In en, this message translates to:
  /// **'Song removed from library (physical file read-only)'**
  String get songDeletedDbOnly;

  /// No description provided for @songDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Song deleted successfully'**
  String get songDeletedSuccess;

  /// No description provided for @songDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete song'**
  String get songDeleteFailed;

  /// No description provided for @songDetails.
  ///
  /// In en, this message translates to:
  /// **'Song Details'**
  String get songDetails;

  /// No description provided for @songDetailsAndFrequency.
  ///
  /// In en, this message translates to:
  /// **'Song Details & Frequency'**
  String get songDetailsAndFrequency;

  /// No description provided for @songRenamedDbOnly.
  ///
  /// In en, this message translates to:
  /// **'Song renamed in app library (physical file read-only)'**
  String get songRenamedDbOnly;

  /// No description provided for @songRenamedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Song renamed successfully'**
  String get songRenamedSuccess;

  /// No description provided for @songRenameFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to rename song'**
  String get songRenameFailed;

  /// No description provided for @songs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songs;

  /// No description provided for @songsDarkness.
  ///
  /// In en, this message translates to:
  /// **'Songs Screen Darkness'**
  String get songsDarkness;

  /// No description provided for @songsDarknessDesc.
  ///
  /// In en, this message translates to:
  /// **'Adjust background overlay darkness for the Songs screen'**
  String get songsDarknessDesc;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @sortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort Order'**
  String get sortOrder;

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source Code'**
  String get sourceCode;

  /// No description provided for @stopServiceOnAppDismissal.
  ///
  /// In en, this message translates to:
  /// **'Stop Service on App Dismissal'**
  String get stopServiceOnAppDismissal;

  /// No description provided for @stopServiceOnAppDismissalDesc.
  ///
  /// In en, this message translates to:
  /// **'Stop background service and close app when dismissed'**
  String get stopServiceOnAppDismissalDesc;

  /// No description provided for @storagePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Storage permissions are required to scan device memory.'**
  String get storagePermissionRequired;

  /// No description provided for @syncLyricsOffline.
  ///
  /// In en, this message translates to:
  /// **'Sync Lyrics (Offline)'**
  String get syncLyricsOffline;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @systemPermissionChecklist.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM PERMISSION CHECKLIST'**
  String get systemPermissionChecklist;

  /// No description provided for @technicalInfoFrequency.
  ///
  /// In en, this message translates to:
  /// **'Technical Info & Frequency'**
  String get technicalInfoFrequency;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @todayMixForYou.
  ///
  /// In en, this message translates to:
  /// **'Today Mix for you'**
  String get todayMixForYou;

  /// No description provided for @toggleFavorite.
  ///
  /// In en, this message translates to:
  /// **'Toggle Favorite'**
  String get toggleFavorite;

  /// No description provided for @topResult.
  ///
  /// In en, this message translates to:
  /// **'Top Result'**
  String get topResult;

  /// No description provided for @transferMusicFiles.
  ///
  /// In en, this message translates to:
  /// **'TRANSFER MUSIC FILES'**
  String get transferMusicFiles;

  /// No description provided for @turnOffBlursOptimize.
  ///
  /// In en, this message translates to:
  /// **'Turn off heavy blurs to optimize performance'**
  String get turnOffBlursOptimize;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unknownAlbum.
  ///
  /// In en, this message translates to:
  /// **'Unknown Album'**
  String get unknownAlbum;

  /// No description provided for @unknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown Artist'**
  String get unknownArtist;

  /// No description provided for @updateLibraryIndexing.
  ///
  /// In en, this message translates to:
  /// **'Update library files indexing'**
  String get updateLibraryIndexing;

  /// No description provided for @useAbsoluteBlackBg.
  ///
  /// In en, this message translates to:
  /// **'Use absolute black for backgrounds'**
  String get useAbsoluteBlackBg;

  /// No description provided for @useStaticTextTimestamps.
  ///
  /// In en, this message translates to:
  /// **'Use static text instead of rolling animation for progress duration'**
  String get useStaticTextTimestamps;

  /// No description provided for @verticalMotionEffectPlayer.
  ///
  /// In en, this message translates to:
  /// **'Vertical Motion Effect Player'**
  String get verticalMotionEffectPlayer;

  /// No description provided for @verticalMotionEffectPlayerDesc.
  ///
  /// In en, this message translates to:
  /// **'Swipe down on the expanded player to dismiss it'**
  String get verticalMotionEffectPlayerDesc;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @visitOfficialRepository.
  ///
  /// In en, this message translates to:
  /// **'Visit official repository on GitHub'**
  String get visitOfficialRepository;

  /// No description provided for @welcomeAboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Looper Player is a next-generation Music-OS built for premium offline audio playback. Features real-time dynamic lyrics generation, advanced audio session management with call mute handling, adaptive background theming, and multi-format music library support. Fully optimized for maximum battery efficiency.'**
  String get welcomeAboutDesc;

  /// No description provided for @welcomeAllFilesDesc.
  ///
  /// In en, this message translates to:
  /// **'Highly recommended for professional scanning to locate songs in non-standard directories (Downloads, Telegram, custom folders).'**
  String get welcomeAllFilesDesc;

  /// No description provided for @welcomeInstructionConnectDesc.
  ///
  /// In en, this message translates to:
  /// **'Plug your phone or device into a personal computer using a standard USB data cable.'**
  String get welcomeInstructionConnectDesc;

  /// No description provided for @welcomeInstructionDownloadDesc.
  ///
  /// In en, this message translates to:
  /// **'Alternatively, download files directly using a web browser or other downloader utility on the device itself.'**
  String get welcomeInstructionDownloadDesc;

  /// No description provided for @welcomeInstructionTransferDesc.
  ///
  /// In en, this message translates to:
  /// **'Copy your offline music files (supports .mp3, .flac, .m4a, .wav) directly into the standard \'Music\' or \'Download\' folder of your device.'**
  String get welcomeInstructionTransferDesc;

  /// No description provided for @welcomeMusicAudioDesc.
  ///
  /// In en, this message translates to:
  /// **'Required to discover and play standard offline audio tracks on your device memory.'**
  String get welcomeMusicAudioDesc;

  /// No description provided for @welcomeNoSongsDesc.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any supported audio files (MP3, FLAC, WAV, M4A, OGG) on your device storage.'**
  String get welcomeNoSongsDesc;

  /// No description provided for @welcomeNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Required to show playback controls and active notification widgets in your system bar.'**
  String get welcomeNotificationDesc;

  /// No description provided for @welcomeScanningFoldersDesc.
  ///
  /// In en, this message translates to:
  /// **'Scanning all folders and subfolders for audio files.'**
  String get welcomeScanningFoldersDesc;

  /// No description provided for @whyInternetUsed.
  ///
  /// In en, this message translates to:
  /// **'Why Internet is Used'**
  String get whyInternetUsed;

  /// No description provided for @whyInternetUsedDesc.
  ///
  /// In en, this message translates to:
  /// **'• Dynamic Lyrics Syncing: Used solely to securely fetch and download synchronized lyrics (LRC formats) from online databases. No personal data, settings, or media files are ever uploaded or shared.'**
  String get whyInternetUsedDesc;

  /// No description provided for @whyPermissionsUsed.
  ///
  /// In en, this message translates to:
  /// **'Why Permissions are Used'**
  String get whyPermissionsUsed;

  /// No description provided for @whyPermissionsUsedDesc.
  ///
  /// In en, this message translates to:
  /// **'• Storage / Media Access: Required to discover, read, and index local audio tracks stored on your device.\n• Notifications: Required to display active playback control widgets in your status bar and system drawer.'**
  String get whyPermissionsUsedDesc;

  /// No description provided for @willPlayNext.
  ///
  /// In en, this message translates to:
  /// **'Will play next'**
  String get willPlayNext;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'ko',
    'nl',
    'pt',
    'ru',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
