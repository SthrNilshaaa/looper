// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get about => 'Über';

  @override
  String get aboutAndMaintainers => 'Über & Betreuer';

  @override
  String get aboutApp => 'Über die App';

  @override
  String get aboutLooperPlayer => 'ÜBER LOOPER PLAYER';

  @override
  String get accentColor => 'Akzentfarbe';

  @override
  String get accentColorDesc => 'Manuelle Akzentfarbe für das Design wählen';

  @override
  String get acousticSpectralAnalysis => 'AKUSTISCHE UND SPEKTRALANALYSE';

  @override
  String get activeCallCannotPlay =>
      'Wiedergabe blockiert: Während eines aktiven Anrufs kann keine Musik abgespielt werden';

  @override
  String get adaptColorsArtwork =>
      'Passen Sie die Farben der App an das Albumcover an';

  @override
  String addedTo(String name) {
    return 'Zu $name hinzugefügt';
  }

  @override
  String get addedToQueue => 'Zur Warteschlange hinzugefügt';

  @override
  String get addFolder => 'Ordner hinzufügen';

  @override
  String get addToFavorites => 'Zu Favoriten hinzufügen';

  @override
  String get addToPlaylists => 'Zu Playlists hinzufügen';

  @override
  String get addToQueue => 'Zur Warteschlange hinzufügen';

  @override
  String get album => 'Album';

  @override
  String get albums => 'Alben';

  @override
  String get albumsRowDesc => 'Horizontales Regal mit Alben';

  @override
  String get allFilesAccess => 'Zugriff auf alle Dateien (empfohlen)';

  @override
  String get allSongs => 'Alle Lieder';

  @override
  String get appDetailsCreator =>
      'Anwendungsdetails, Ersteller und Informationen zum Designteam';

  @override
  String get appearance => 'Darstellung';

  @override
  String get appInfoPrivacy => 'APP-INFO & DATENSCHUTZ';

  @override
  String get appTitle => 'Looper-Spieler';

  @override
  String get artist => 'Künstler';

  @override
  String get artists => 'Künstler';

  @override
  String get artistsRowDesc => 'Horizontales Künstlerregal';

  @override
  String get ascending => 'Aufsteigend';

  @override
  String get audioCrossfade => 'Überblenden (Crossfade)';

  @override
  String get audioCrossfadeDesc =>
      'Titel beim Songwechsel sanft ineinander übergehen lassen';

  @override
  String get audioFocusDenied =>
      'Wiedergabe angehalten: Audio-Fokus vom System verweigert';

  @override
  String get audioPlayback => 'Audio & Wiedergabe';

  @override
  String get audioPlaybackDesc =>
      'Einstellungen für Überblenden, Stille und Ein-/Ausblenden';

  @override
  String get autoCrossfadeDuration => 'Dauer bei automatischer Überblendung';

  @override
  String get autoCrossfadeDurationDesc =>
      'Dauer der Überlappung bei automatischem Songwechsel';

  @override
  String get backToMainView => 'ZURÜCK ZUR HAUPTANSICHT';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get categories => 'Kategorien';

  @override
  String get center => 'Zentriert';

  @override
  String get clear => 'Leeren';

  @override
  String get clearQueue => 'Klar';

  @override
  String get connectDevice => 'GERÄT VERBINDEN';

  @override
  String get corePurpose => 'Kernzweck';

  @override
  String get corePurposeDesc =>
      'Looper Player ist ein Offline-High-Fidelity-Audioplayer, der für Musikliebhaber entwickelt wurde, die absolute Kontrolle über ihre lokale Bibliothek, lückenlose Wiedergabe und flüssiges, synchronisiertes Scrollen der Liedtexte wünschen.';

  @override
  String get create => 'Erstellen';

  @override
  String get createPlaylist => 'Playlist erstellen';

  @override
  String get creatorAndMaintainer => 'Schöpfer und Bewahrer';

  @override
  String get customAccentColor => 'Benutzerdefinierte Akzentfarbe';

  @override
  String get customizeColorsTheme =>
      'Passen Sie App-Farben, Themen und Liedtexthintergründe an';

  @override
  String get dateAdded => 'Hinzugefügt am';

  @override
  String get deepStorageScanProgress => 'TIEFSPEICHER-SCAN IN ARBEIT...';

  @override
  String get delete => 'Löschen';

  @override
  String get deleteFile => 'Datei löschen';

  @override
  String get deletePlaylist => 'Playlist löschen';

  @override
  String deletePlaylistConfirm(String name) {
    return 'Sind Sie sicher, dass Sie \"$name\" löschen möchten?';
  }

  @override
  String get deleteSong => 'Lied löschen';

  @override
  String get deleteSongConfirm =>
      'Möchten Sie diesen Song wirklich von der Festplatte löschen?';

  @override
  String get descending => 'Absteigend';

  @override
  String get designerAndMaintainer => 'Designer und Betreuer';

  @override
  String get disableBlurEffects => 'Deaktivieren Sie Unschärfeeffekte';

  @override
  String get disableSquigglyProgressBar =>
      'Deaktivieren Sie die Animation der Wellen-Fortschrittsleiste';

  @override
  String get downloadAudioDirectly => 'AUDIO DIREKT HERUNTERLADEN';

  @override
  String get downloadingLyricsOffline =>
      'Songtexte zur Offline-Nutzung werden heruntergeladen...';

  @override
  String get downloadMissingArtwork => 'Laden Sie „Missing Artwork“ herunter';

  @override
  String get downloadMissingArtworkDesc =>
      'Laden Sie automatisch hochauflösende Cover-Artworks für Songs von iTunes herunter';

  @override
  String get duration => 'Dauer';

  @override
  String get dynamicAccentColor => 'Dynamische Akzentfarbe';

  @override
  String get dynamicAccentColorDesc =>
      'Nur die Akzentfarbe dynamisch aus dem Albumcover generieren';

  @override
  String get dynamicBgOnlyLyrics => 'Dynamischer Hintergrund nur für Liedtexte';

  @override
  String get dynamicColorActiveLyrics => 'Dynamic Color Active Line';

  @override
  String get dynamicColorActiveLyricsDesc =>
      'Verwenden Sie extrahierte Bildfarben für die aktuell wiedergegebene Textzeile';

  @override
  String get dynamicLyricsBg => 'Dynamischer Liedtext BG';

  @override
  String get dynamicLyricsBgDesc =>
      'Albumcover-Unschärfe auf Songtext-Bildschirm anwenden';

  @override
  String get dynamicTheming => 'Dynamisches Theming';

  @override
  String get emptyLibraryDesc =>
      'Wir konnten in Ihrer Bibliothek keine unterstützten Musikdateien finden. Fügen Sie Ordner hinzu oder führen Sie einen Suchscan durch.';

  @override
  String get enableNetworkLyricsArt =>
      'Aktivieren Sie die Netzwerknutzung für Online-Liedtexte und Künstlerkunst';

  @override
  String get enablePlayerGradient => 'Musik-Bildschirmverlauf';

  @override
  String get enablePlayerGradientDesc =>
      'Aktivieren Sie den Hintergrund mit radialem Akzentverlauf auf dem aktuellen Bildschirm';

  @override
  String get fadeDuration => 'Dauer des Ein-/Ausblendens';

  @override
  String get fadeDurationDesc => 'Dauer des Ein- und Ausblende-Effekts';

  @override
  String get fadeOnSeek => 'Ausblenden beim Spulen';

  @override
  String get fadeOnSeekDesc =>
      'Lautstärke beim Spulen kurz aus- und wieder einblenden';

  @override
  String get fadePlayPauseStop => 'Ein-/Ausblenden bei Wiedergabe/Pause/Stopp';

  @override
  String get fadePlayPauseStopDesc =>
      'Lautstärke beim Starten, Pausieren oder Stoppen sanft ein- oder ausblenden';

  @override
  String get favorites => 'Favoriten';

  @override
  String get fileInformation => 'Dateiinformationen';

  @override
  String get flatProgressBar => 'Flacher Fortschrittsbalken';

  @override
  String get folders => 'Ordner';

  @override
  String get genre => 'Genre';

  @override
  String get genres => 'Genres';

  @override
  String get genresRowDesc => 'Horizontales Regal mit Musikgenres';

  @override
  String get goStart => 'LOS STARTEN';

  @override
  String get grant => 'GEWÄHREN';

  @override
  String get granted => 'ZUGEWÄHRT';

  @override
  String get history => 'Geschichte';

  @override
  String get home => 'Zuhause';

  @override
  String get homeDarkness => 'Dunkelheit des Startbildschirms';

  @override
  String get homeDarknessDesc =>
      'Passen Sie die Dunkelheit der Hintergrundüberlagerung für den Startbildschirm an';

  @override
  String get homeDashboardSettings => 'Home-Dashboard-Einstellungen';

  @override
  String get homeDashboardSettingsDesc =>
      'Passen Sie horizontale Reihen auf Ihrem Startbildschirm an';

  @override
  String get internetMode => 'Internetmodus';

  @override
  String get keepBackgroundGradient =>
      'Behalten Sie den Hintergrundverlauf bei';

  @override
  String get keepBackgroundGradientDesc =>
      'Behalten Sie den Hintergrundverlauf auf allen Anwendungsbildschirmen bei';

  @override
  String get language => 'Sprache';

  @override
  String get left => 'Links';

  @override
  String get library => 'Bibliothek';

  @override
  String get libraryDarkness => 'Dunkelheit des Bibliotheksbildschirms';

  @override
  String get libraryDarknessDesc =>
      'Passen Sie die Dunkelheit der Hintergrundüberlagerung für den Bibliotheksbildschirm an';

  @override
  String get libraryFoldersSync =>
      'Ordner, Auslöser für erneutes Scannen, Zurücksetzen der Datenbank und Offline-Synchronisierung';

  @override
  String get librarySettings => 'Bibliothek-Einstellungen';

  @override
  String get loadingMusicLibrary => 'MUSIKBIBLIOTHEK WIRD GELADEN';

  @override
  String get loadingMusicLibraryDesc =>
      'Erstellen Sie Premium-Indizes, richten Sie Hardware-Listener ein und optimieren Sie visuelle Caches.';

  @override
  String get loadingPhase1 => 'AUDIOSPEICHER ABFRAGEN...';

  @override
  String get loadingPhase2 => 'ERFRISCHENDE MUSIK-ENGINE...';

  @override
  String get loadingPhase3 => 'AKUSTISCHE DATEN EXTRAHIEREN...';

  @override
  String get loadingPhase4 => 'WIEDERGABESPEICHER OPTIMIEREN...';

  @override
  String get lyrics => 'Songtexte';

  @override
  String get lyricsAlignment => 'Songtext-Ausrichtung';

  @override
  String get lyricsAlignmentDesc =>
      'Richten Sie Textpositionen für das Scrollen von Liedtexten aus';

  @override
  String get lyricsDarkness => 'Songtext von Screen Darkness';

  @override
  String get lyricsDarknessDesc =>
      'Passen Sie die Dunkelheit der Hintergrundüberlagerung für den Songtext-Bildschirm an';

  @override
  String get lyricsProvider => 'Liedtextanbieter';

  @override
  String get lyricsProviderDesc => 'Online-Songtexte von lrclib.net (LRCLIB)';

  @override
  String get maintainersAndDesigners => 'Entwickler & Designer';

  @override
  String get manageAudioFocus => 'Audiofokus verwalten';

  @override
  String get manageAudioFocusDesc =>
      'Audio-Fokus beim System anfordern und auf Fokusänderungen reagieren';

  @override
  String get manageAudioFocusTitle => 'Audio-Fokus verwalten';

  @override
  String get manageLanguageAndFocus =>
      'Verwalten Sie Spracheinstellungen und Anruferfokusstatus';

  @override
  String get manualCrossfadeDuration => 'Dauer bei manueller Überblendung';

  @override
  String get manualCrossfadeDurationDesc =>
      'Dauer der Überlappung beim manuellen Überspringen';

  @override
  String get matchingLyrics => 'PASSENDE TEXTE';

  @override
  String get metadataDetails => 'Metadatendetails';

  @override
  String get mostPlayed => 'Meistgespielt';

  @override
  String get musicAudioAccess => 'MUSIK- UND AUDIO-ZUGANG';

  @override
  String get musicDarkness => 'Musik-Player-Dunkelheit';

  @override
  String get musicDarknessDesc =>
      'Passen Sie die Dunkelheit der Hintergrundüberlagerung für den Musik-Player-Bildschirm an';

  @override
  String get musicLibrary => 'Musikbibliothek';

  @override
  String get muteOrPauseCalls =>
      'Stummschalten oder Pausieren während Anrufen und anderen Audioaktivitäten';

  @override
  String get newPlaylist => 'Neue Playlist';

  @override
  String get newTitle => 'Neuer Titel';

  @override
  String get noAlbumsFound => 'Keine Alben gefunden';

  @override
  String get noArtistsFound => 'Keine Künstler gefunden';

  @override
  String get noFavoritesYet => 'Noch keine Favoriten';

  @override
  String get noHistoryYet => 'Kein Verlauf';

  @override
  String get noLyrics => 'Kein Songtext gefunden';

  @override
  String get noMusicDetected => 'KEINE MUSIK ERKANNT';

  @override
  String get noPlaylistsCreated => 'Noch keine Playlists erstellt.';

  @override
  String get noPlaylistsYet => 'Noch keine Playlists';

  @override
  String get noResultsFound => 'Keine Ergebnisse gefunden';

  @override
  String get noSongsFound => 'Keine Lieder gefunden';

  @override
  String get notificationAccess => 'ZUGRIFF AUF BENACHRICHTIGUNGEN';

  @override
  String get nowPlaying => 'Jetzt gespielt';

  @override
  String get performanceOptimizerDashboard =>
      'Performance-Optimierungs-Dashboard';

  @override
  String get performanceOptimizerDashboardDesc =>
      'Echtzeit-Statistiken zur Performance-Optimierung einblenden';

  @override
  String get permanentFocusChangePause => 'Pause bei dauerhaftem Fokusverlust';

  @override
  String get permanentFocusChangePauseDesc =>
      'Wiedergabe bei dauerhaftem Audio-Fokusverlust automatisch pausieren';

  @override
  String get plainTimestamps => 'Einfache Zeitstempel';

  @override
  String get play => 'Spielen';

  @override
  String get playAll => 'Alle abspielen';

  @override
  String get playbackAudio => 'Wiedergabe & Sprache';

  @override
  String get playlists => 'Wiedergabelisten';

  @override
  String get playNext => 'Nächstes abspielen';

  @override
  String get playQueue => 'Spielwarteschlange';

  @override
  String get pressBackExit =>
      'Drücken Sie erneut die Zurück-Taste, um den Vorgang zu beenden';

  @override
  String get privacySafety => 'Datenschutz und Sicherheit';

  @override
  String get privacySafetyDesc =>
      '100 % privat und offline-zuerst. Ihre Titel, Ihr Wiedergabeverlauf, Ihre Favoriten und Ihre Konfiguration bleiben ausschließlich in einer sicheren Isar-Datenbank auf Ihrem lokalen Gerät. Wir verfolgen, sammeln oder teilen Ihre Nutzungsdaten oder Präferenzen nicht.';

  @override
  String get pureBlackOled => 'Reines Schwarz (OLED)';

  @override
  String get pureBlackOledDesc =>
      'Absolutes Schwarz für Hintergründe verwenden';

  @override
  String get queue => 'Warteschlange';

  @override
  String get queueIsEmpty => 'Die Warteschlange ist leer';

  @override
  String get quickPicks => 'Schnelle Tipps';

  @override
  String get quickPicksRowDesc => 'Ihr meistgespieltes Liederraster';

  @override
  String get readyToScan => 'Bereit zum Scannen';

  @override
  String get recentlyAddedSongsRowDesc => 'Eine Liste Ihrer letzten Importe';

  @override
  String get recentlyPlayed => 'Zuletzt gespielt';

  @override
  String get recentPlayed => 'Zuletzt gespielt';

  @override
  String get removedFromPlaylist => 'Aus Playlist entfernt';

  @override
  String get removeFromFavorites => 'Aus Favoriten entfernen';

  @override
  String get removeFromPlaylist => 'Aus Playlist entfernen';

  @override
  String get rename => 'Umbenennen';

  @override
  String get renameFile => 'Datei umbenennen';

  @override
  String get renamePlaylist => 'Playlist umbenennen';

  @override
  String get renameSong => 'Song umbenennen';

  @override
  String get reorderDashboardSections => 'Dashboard-Abschnitte neu anordnen';

  @override
  String get reorderDashboardSectionsDesc =>
      'Legen Sie per Drag-and-Drop die bevorzugte Dashboard-Reihenfolge fest';

  @override
  String get rescanLibrary => 'Bibliothek erneut scannen';

  @override
  String get rescanStorage => 'SPEICHER NEU SCANNEN';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get resetLibrary => 'Zurücksetzen und erneut scannen';

  @override
  String get resetLibraryConfirm =>
      'Dadurch werden alle Songs, Alben und Künstler gelöscht und Ihre Ordner vollständig neu gescannt.';

  @override
  String get resetLibraryConfirmNew =>
      'Dadurch werden alle Songs aus Ihrer Bibliothek entfernt. Ihre Musikdateien werden nicht gelöscht.';

  @override
  String get resetLibraryDesc =>
      'Alle Songs aus Ihrer indizierten Bibliothek entfernen';

  @override
  String get resumeAfterCallDesc =>
      'Wiedergabe nach dem Auflegen fortsetzen (falls durch Anruf pausiert)';

  @override
  String get resumeAfterCallTitle => 'Wiedergabe nach Anruf fortsetzen';

  @override
  String get resumeOnStartDesc =>
      'Wiedergabe beim Starten von Looper Player automatisch fortsetzen';

  @override
  String get resumeOnStartTitle => 'Wiedergabe beim Start fortsetzen';

  @override
  String get persistQueueTitle => 'Letzte Warteschlange beibehalten';

  @override
  String get persistQueueDesc =>
      'Letzten Titel und Warteschlange bei App-Neustarts speichern';

  @override
  String get right => 'Rechts';

  @override
  String scanCompleteSongsDetected(int count) {
    return 'SCAN ABGESCHLOSSEN: $count SONGS ERKANNT!';
  }

  @override
  String get scanForMusic => 'NACH MUSIK SUCHEN';

  @override
  String get scanIndexLocalDesc => 'Lokale Musikdateien scannen und indizieren';

  @override
  String get scanLibrary => 'Bibliothek scannen';

  @override
  String get scanningInBackground => 'Scannen im Hintergrund...';

  @override
  String get scanningLibrary => 'Bibliothek wird gescannt...';

  @override
  String get scanningStorage => 'SPEICHER SCANNEN...';

  @override
  String get scanningStorageDesc =>
      'Durchsuchen Sie Verzeichnisbäume, um Audiospuren zu entdecken. Bitte warten Sie...';

  @override
  String get search => 'Suchen';

  @override
  String get searchLibraryHint => 'Durchsuchen Sie Ihre gesamte Bibliothek';

  @override
  String get searchSongsHint => 'Lieder suchen';

  @override
  String get seekFadeDuration => 'Dauer beim Spulen';

  @override
  String get seekFadeDurationDesc => 'Dauer des Ausblende-Effekts beim Spulen';

  @override
  String get selectAppLanguage => 'App-Sprache auswählen';

  @override
  String get selectCustomColor => 'Wählen Sie „Benutzerdefinierte Farbe“.';

  @override
  String get selectCustomFolder => 'BENUTZERDEFINIERTEN ORDNER WÄHLEN';

  @override
  String get selectFolderIndex =>
      'Ordner zum Scannen von Musikdateien auswählen';

  @override
  String get selectSpecificFolder => 'BESTIMMTEN ORDNER WÄHLEN';

  @override
  String get settings => 'Einstellungen';

  @override
  String get share => 'Teilen';

  @override
  String get shareFile => 'Datei teilen';

  @override
  String get showAlbumsRow => 'Albumzeile anzeigen';

  @override
  String get showAlbumsRowDesc =>
      'Zeigen Sie eine horizontale Liste der Alben auf Ihrem Startbildschirm an';

  @override
  String get showArtistsRow => 'Künstlerreihe anzeigen';

  @override
  String get showArtistsRowDesc =>
      'Zeigen Sie eine horizontale Liste der Künstler auf Ihrem Startbildschirm an';

  @override
  String get showGenresRow => 'Genrezeile anzeigen';

  @override
  String get showGenresRowDesc =>
      'Zeigen Sie eine horizontale Liste der Genres auf Ihrem Startbildschirm an';

  @override
  String get showLess => 'Weniger anzeigen';

  @override
  String get showMore => 'Mehr anzeigen';

  @override
  String get showQualityBadge => 'Qualitätsabzeichen vorzeigen';

  @override
  String get showQualityBadgeDesc =>
      'Zeigen Sie das Informationssymbol zur Audioqualität auf dem Bildschirm der aktuellen Wiedergabe an';

  @override
  String get silenceBetweenTracksDesc =>
      'Stille Pause zwischen Titeln einfügen (0ms für lückenlose Wiedergabe)';

  @override
  String get silenceBetweenTracksTitle => 'Stille zwischen Titeln';

  @override
  String get songDeletedDbOnly =>
      'Song aus Bibliothek entfernt (physische Datei schreibgeschützt)';

  @override
  String get songDeletedSuccess => 'Song erfolgreich gelöscht';

  @override
  String get songDeleteFailed => 'Fehler beim Löschen des Songs';

  @override
  String get songDetails => 'Songdetails';

  @override
  String get songDetailsAndFrequency => 'Songdetails und Häufigkeit';

  @override
  String get songRenamedDbOnly =>
      'Song in App-Bibliothek umbenannt (physische Datei schreibgeschützt)';

  @override
  String get songRenamedSuccess => 'Song erfolgreich umbenannt';

  @override
  String get songRenameFailed => 'Fehler beim Umbenennen des Songs';

  @override
  String get songs => 'Lieder';

  @override
  String get songsDarkness => 'Songs Screen Darkness';

  @override
  String get songsDarknessDesc =>
      'Passen Sie die Dunkelheit der Hintergrundüberlagerung für den Bildschirm „Songs“ an';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get sortOrder => 'Sortierreihenfolge';

  @override
  String get sourceCode => 'Quellcode';

  @override
  String get stopServiceOnAppDismissal =>
      'Dienst beim Schließen der App beenden';

  @override
  String get stopServiceOnAppDismissalDesc =>
      'Hintergrunddienst stoppen und App schließen, wenn sie aus der Übersicht entfernt wird';

  @override
  String get storagePermissionRequired =>
      'Zum Scannen des Gerätespeichers sind Speicherberechtigungen erforderlich.';

  @override
  String get syncLyricsOffline => 'Songtexte synchronisieren (Offline)';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String get systemPermissionChecklist => 'CHECKLISTE FÜR SYSTEMBERECHTIGUNGEN';

  @override
  String get technicalInfoFrequency =>
      'Technische Informationen und Häufigkeit';

  @override
  String get theme => 'Thema';

  @override
  String get title => 'Titel';

  @override
  String get todayMixForYou => 'Heute Mix für Dich';

  @override
  String get toggleFavorite => 'Favoriten umschalten';

  @override
  String get topResult => 'Top-Ergebnis';

  @override
  String get transferMusicFiles => 'MUSIKDATEIEN ÜBERTRAGEN';

  @override
  String get turnOffBlursOptimize =>
      'Deaktivieren Sie starke Unschärfen, um die Leistung zu optimieren';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get unknownAlbum => 'Unbekanntes Album';

  @override
  String get unknownArtist => 'Unbekannter Künstler';

  @override
  String get updateLibraryIndexing =>
      'Indizierung der Musikdateien aktualisieren';

  @override
  String get useAbsoluteBlackBg =>
      'Verwenden Sie für Hintergründe absolutes Schwarz';

  @override
  String get useStaticTextTimestamps =>
      'Verwenden Sie für die Dauer des Fortschritts statischen Text anstelle einer rollenden Animation';

  @override
  String get verticalMotionEffectPlayer => 'Vertikaler Bewegungseffekt Player';

  @override
  String get verticalMotionEffectPlayerDesc =>
      'Nach unten wischen, um den geöffneten Player zu schließen';

  @override
  String get viewAll => 'Alle anzeigen';

  @override
  String get visitOfficialRepository =>
      'Offizielles GitHub-Repository besuchen';

  @override
  String get welcomeAboutDesc =>
      'Looper Player ist ein Musik-Betriebssystem der nächsten Generation, das für erstklassige Offline-Audiowiedergabe entwickelt wurde. Bietet dynamische Textgenerierung in Echtzeit, erweiterte Audiositzungsverwaltung mit Anrufstummschaltung, adaptive Hintergrundthemen und Unterstützung für Musikbibliotheken in mehreren Formaten. Vollständig optimiert für maximale Batterieeffizienz.';

  @override
  String get welcomeAllFilesDesc =>
      'Sehr empfehlenswert für professionelles Scannen, um Songs in nicht standardmäßigen Verzeichnissen (Downloads, Telegram, benutzerdefinierte Ordner) zu finden.';

  @override
  String get welcomeInstructionConnectDesc =>
      'Schließen Sie Ihr Telefon oder Gerät über ein Standard-USB-Datenkabel an einen PC an.';

  @override
  String get welcomeInstructionDownloadDesc =>
      'Alternativ können Sie Dateien direkt über einen Webbrowser oder ein anderes Download-Dienstprogramm auf dem Gerät selbst herunterladen.';

  @override
  String get welcomeInstructionTransferDesc =>
      'Kopieren Sie Ihre Offline-Musikdateien (unterstützt .mp3, .flac, .m4a, .wav) direkt in den Standardordner „Musik“ oder „Download“ Ihres Geräts.';

  @override
  String get welcomeMusicAudioDesc =>
      'Erforderlich, um Standard-Offline-Audiotitel im Speicher Ihres Geräts zu erkennen und abzuspielen.';

  @override
  String get welcomeNoSongsDesc =>
      'Wir konnten keine unterstützten Audiodateien (MP3, FLAC, WAV, M4A, OGG) auf Ihrem Gerätespeicher finden.';

  @override
  String get welcomeNotificationDesc =>
      'Erforderlich, um Wiedergabesteuerungen und aktive Benachrichtigungs-Widgets in Ihrer Systemleiste anzuzeigen.';

  @override
  String get welcomeScanningFoldersDesc =>
      'Durchsucht alle Ordner und Unterordner nach Audiodateien.';

  @override
  String get whyInternetUsed => 'Warum das Internet genutzt wird';

  @override
  String get whyInternetUsedDesc =>
      '• Dynamische Synchronisierung von Liedtexten: Wird ausschließlich zum sicheren Abrufen und Herunterladen synchronisierter Liedtexte (LRC-Formate) aus Online-Datenbanken verwendet. Es werden niemals persönliche Daten, Einstellungen oder Mediendateien hochgeladen oder geteilt.';

  @override
  String get whyPermissionsUsed => 'Warum Berechtigungen verwendet werden';

  @override
  String get whyPermissionsUsedDesc =>
      '• Speicher-/Medienzugriff: Erforderlich, um auf Ihrem Gerät gespeicherte lokale Audiotitel zu erkennen, zu lesen und zu indizieren.\n• Benachrichtigungen: Erforderlich, um aktive Wiedergabesteuerungs-Widgets in Ihrer Statusleiste und Systemschublade anzuzeigen.';

  @override
  String get willPlayNext => 'Wird als nächstes abgespielt';

  @override
  String get year => 'Jahr';

  @override
  String get supportUs => 'Unterstützen Sie uns';

  @override
  String get supportUsDesc =>
      'Helfen Sie mit, Looper Player am Leben und quelloffen zu halten';

  @override
  String get supportDevelopment => 'Entwicklung unterstützen';

  @override
  String get supportDevelopmentDesc =>
      'Looper Player ist zu 100% kostenlos und quelloffen. Wenn Sie ihn gerne nutzen, unterstützen Sie den Entwickler bitte mit einer Spende. Jeder Beitrag hilft, das Projekt aktiv zu halten!';

  @override
  String get useCustomFont => 'Benutzerdefinierte Schriftart verwenden';

  @override
  String get useCustomFontDesc =>
      'Jost oder andere benutzerdefinierte Schriftarten verwenden. Andernfalls wird DM Sans verwendet.';

  @override
  String get selectFontFamily => 'Schriftfamilie auswählen';

  @override
  String activeFont(String fontName) {
    return 'Aktive Schriftart: $fontName';
  }

  @override
  String get fontWeightAdjustment => 'Schriftgewichtsanpassung';

  @override
  String get currentWeight => 'Aktuelles Gewicht';

  @override
  String get useCustomFontLyrics => 'Benutzerdefinierte Liedtext-Schriftart';

  @override
  String get useCustomFontLyricsDesc =>
      'Benutzerdefinierte Schriftart und -gewicht für die synchronisierte Liedtextansicht verwenden';

  @override
  String get lyricsFontFamily => 'Liedtext-Schriftfamilie';

  @override
  String activeLyricsFont(String fontName) {
    return 'Aktive Liedtext-Schriftart: $fontName';
  }

  @override
  String get lyricsFontWeightAdjustment => 'Liedtext-Schriftgewichtsanpassung';

  @override
  String get giveStarOnGithub => 'Stern auf GitHub geben';

  @override
  String get supportProjectLove =>
      'Unterstützen Sie das Projekt und zeigen Sie Ihre Begeisterung!';

  @override
  String get sortAlphabeticalAZ => 'Alphabetisch (A-Z)';

  @override
  String get sortAlphabeticalZA => 'Alphabetisch (Z-A)';

  @override
  String get sortRecentlyAdded => 'Kürzlich hinzugefügt';

  @override
  String get sortOldestAdded => 'Ältest hinzugefügt';

  @override
  String get sortYearNewest => 'Jahr (Neueste)';

  @override
  String get sortYearOldest => 'Jahr (Älteste)';

  @override
  String get sortMostSongs => 'Mehrste Titel';

  @override
  String get sortLeastSongs => 'Wenigste Titel';

  @override
  String get sortDefault => 'Standard';

  @override
  String get sortArtistAsc => 'Künstler (A-Z)';

  @override
  String get sortAlbumAsc => 'Album (A-Z)';

  @override
  String get sortDuration => 'Dauer';
}
