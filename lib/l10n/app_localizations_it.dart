// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get about => 'Informazioni';

  @override
  String get aboutAndMaintainers => 'Informazioni e Sviluppatori';

  @override
  String get aboutApp => 'Informazioni sull\'app';

  @override
  String get aboutLooperPlayer => 'INFORMAZIONI SU LOOPER PLAYER';

  @override
  String get accentColor => 'Colore d\'accento';

  @override
  String get accentColorDesc =>
      'Seleziona manualmente il colore principale del tema';

  @override
  String get acousticSpectralAnalysis => 'ACOUSTIC & SPECTRAL ANALYSIS';

  @override
  String get activeCallCannotPlay =>
      'Riproduzione bloccata: Impossibile riprodurre musica durante una chiamata attiva';

  @override
  String get adaptColorsArtwork => 'Adatta i colori all\'immagine di copertina';

  @override
  String addedTo(String name) {
    return 'Aggiunto a $name';
  }

  @override
  String get addedToQueue => 'Aggiunto alla coda';

  @override
  String get addFolder => 'Aggiungi cartella';

  @override
  String get addToFavorites => 'Aggiungi ai preferiti';

  @override
  String get addToPlaylists => 'Aggiungi alle playlist';

  @override
  String get addToQueue => 'Aggiungi alla coda';

  @override
  String get album => 'Album';

  @override
  String get albums => 'Album';

  @override
  String get albumsRowDesc => 'Elenco orizzontale di album';

  @override
  String get allFilesAccess => 'ACCESSO A TUTTI I FILE (CONSIGLIATO)';

  @override
  String get allSongs => 'Tutti i brani';

  @override
  String get appDetailsCreator =>
      'Dettagli dell\'applicazione, autore e team di design';

  @override
  String get appearance => 'Aspetto';

  @override
  String get appInfoPrivacy => 'INFORMAZIONI E PRIVACY';

  @override
  String get appTitle => 'Looper Player';

  @override
  String get artist => 'Artista';

  @override
  String get artists => 'Artisti';

  @override
  String get artistsRowDesc => 'Elenco orizzontale di artisti';

  @override
  String get ascending => 'Crescente';

  @override
  String get audioCrossfade => 'Dissolvenza incrociata audio';

  @override
  String get audioCrossfadeDesc =>
      'Sovrappone i brani gradualmente durante il cambio traccia';

  @override
  String get audioFocusDenied =>
      'Riproduzione in pausa: focus audio negato dal sistema';

  @override
  String get audioPlayback => 'Audio e riproduzione';

  @override
  String get audioPlaybackDesc =>
      'Impostazioni di dissolvenza incrociata, silenzio e sfumatura';

  @override
  String get autoCrossfadeDuration =>
      'Durata dissolvenza incrociata automatica';

  @override
  String get autoCrossfadeDurationDesc =>
      'Durata sovrapposizione durante la transizione automatica';

  @override
  String get backToMainView => 'TORNA ALLA SCHERMATA PRINCIPALE';

  @override
  String get cancel => 'Annulla';

  @override
  String get categories => 'Categorie';

  @override
  String get center => 'Centro';

  @override
  String get clear => 'Cancella';

  @override
  String get clearQueue => 'Svuota coda';

  @override
  String get connectDevice => 'CONNETTI DISPOSITIVO';

  @override
  String get corePurpose => 'Scopo principale';

  @override
  String get corePurposeDesc =>
      'Looper Player è un riproduttore audio offline ad alta fedeltà pensato per gli appassionati che vogliono il controllo totale sulla propria libreria locale, riproduzione continua senza pause e scorrimento fluido dei testi sincronizzati.';

  @override
  String get create => 'Crea';

  @override
  String get createPlaylist => 'Crea Playlist';

  @override
  String get creatorAndMaintainer => 'Autore e manutentore';

  @override
  String get customAccentColor => 'Colore d\'accento personalizzato';

  @override
  String get customizeColorsTheme =>
      'Personalizza i colori dell\'applicazione, il tema e gli sfondi dei testi';

  @override
  String get dateAdded => 'Data di aggiunta';

  @override
  String get deepStorageScanProgress => 'SCANSIONE PROFONDA IN CORSO...';

  @override
  String get delete => 'Elimina';

  @override
  String get deleteFile => 'Elimina File';

  @override
  String get deletePlaylist => 'Elimina Playlist';

  @override
  String deletePlaylistConfirm(String name) {
    return 'Sei sicuro di voler eliminare \"$name\"?';
  }

  @override
  String get deleteSong => 'Elimina brano';

  @override
  String get deleteSongConfirm =>
      'Sei sicuro di voler eliminare questo brano dal disco?';

  @override
  String get descending => 'Decrescente';

  @override
  String get designerAndMaintainer => 'Designer e manutentore';

  @override
  String get disableBlurEffects => 'Disattiva effetti di sfocatura';

  @override
  String get disableSquigglyProgressBar =>
      'Disattiva l\'animazione ondulata della barra di progresso';

  @override
  String get downloadAudioDirectly => 'SCARICA AUDIO DIRETAMENTE';

  @override
  String get downloadingLyricsOffline =>
      'Download dei testi per l\'uso offline...';

  @override
  String get downloadMissingArtwork => 'Scarica copertine mancanti';

  @override
  String get downloadMissingArtworkDesc =>
      'Scarica automaticamente da iTunes le copertine ad alta risoluzione per i brani mancanti';

  @override
  String get duration => 'Durata';

  @override
  String get dynamicAccentColor => 'Colore d\'accento dinamico';

  @override
  String get dynamicAccentColorDesc =>
      'Aggiorna solo il colore principale in base alla copertina';

  @override
  String get dynamicBgOnlyLyrics => 'Sfondo dinamico solo per i testi';

  @override
  String get dynamicColorActiveLyrics => 'Colore dinamico per la riga attiva';

  @override
  String get dynamicColorActiveLyricsDesc =>
      'Usa i colori estratti dalla copertina per la riga dei testi attualmente attiva';

  @override
  String get dynamicLyricsBg => 'Dynamic Lyrics BG';

  @override
  String get dynamicLyricsBgDesc =>
      'Applica la sfocatura della copertina sullo schermo dei testi';

  @override
  String get dynamicTheming => 'Tema dinamico';

  @override
  String get emptyLibraryDesc =>
      'Non abbiamo trovato file musicali supportati nella tua libreria. Aggiungi delle cartelle o avvia una scansione.';

  @override
  String get enableNetworkLyricsArt =>
      'Consenti l\'uso della rete per testi online e immagini degli artisti';

  @override
  String get enablePlayerGradient => 'Gradiente schermata riproduzione';

  @override
  String get enablePlayerGradientDesc =>
      'Attiva lo sfondo radiale con gradiente d\'accento nella schermata di riproduzione';

  @override
  String get fadeDuration => 'Durata dissolvenza';

  @override
  String get fadeDurationDesc => 'Durata dell\'effetto di dissolvenza volume';

  @override
  String get fadeOnSeek => 'Dissolvenza sul seek';

  @override
  String get fadeOnSeekDesc =>
      'Sfuma gradualmente il volume durante il posizionamento sulla traccia';

  @override
  String get fadePlayPauseStop => 'Dissolvenza Riproduzione/Pausa/Stop';

  @override
  String get fadePlayPauseStopDesc =>
      'Sfuma gradualmente il volume all\'avvio, in pausa o all\'arresto';

  @override
  String get favorites => 'Preferiti';

  @override
  String get fileInformation => 'Informazioni file';

  @override
  String get flatProgressBar => 'Barra di progresso piatta';

  @override
  String get folders => 'Cartelle';

  @override
  String get genre => 'Genere';

  @override
  String get genres => 'Generi';

  @override
  String get genresRowDesc => 'Elenco orizzontale di generi musicali';

  @override
  String get goStart => 'INIZIA';

  @override
  String get grant => 'CONCEDI';

  @override
  String get granted => 'CONCESSO';

  @override
  String get history => 'Cronologia';

  @override
  String get home => 'Home';

  @override
  String get homeDarkness => 'Luminosità sfondo Home';

  @override
  String get homeDarknessDesc =>
      'Regola l\'oscurità del livello di sfondo per la schermata Home';

  @override
  String get homeDashboardSettings => 'Impostazioni pannello principale';

  @override
  String get homeDashboardSettingsDesc =>
      'Personalizza le righe orizzontali nella schermata Home';

  @override
  String get internetMode => 'Modalità Internet';

  @override
  String get keepBackgroundGradient => 'Mantieni gradiente di sfondo';

  @override
  String get keepBackgroundGradientDesc =>
      'Mantieni il gradiente di sfondo su tutte le schermate dell\'applicazione';

  @override
  String get language => 'Lingua';

  @override
  String get left => 'Sinistra';

  @override
  String get library => 'Libreria';

  @override
  String get libraryDarkness => 'Luminosità sfondo Libreria';

  @override
  String get libraryDarknessDesc =>
      'Regola l\'oscurità del livello di sfondo per la schermata Libreria';

  @override
  String get libraryFoldersSync =>
      'Cartelle, attivatori di nuova scansione, ripristino database e sincronizzazione offline';

  @override
  String get librarySettings => 'Impostazioni Libreria';

  @override
  String get loadingMusicLibrary => 'CARICAMENTO LIBRERIA MUSICALE';

  @override
  String get loadingMusicLibraryDesc =>
      'Generazione degli indici, configurazione dei listener hardware e ottimizzazione della cache visiva.';

  @override
  String get loadingPhase1 => 'INTERROGAZIONE ARCHIVIO DI MEMORIA...';

  @override
  String get loadingPhase2 => 'AGGIORNAMENTO MOTORE DI RIPRODUZIONE...';

  @override
  String get loadingPhase3 => 'EXTRACTING ACOUSTIC DATA...';

  @override
  String get loadingPhase4 => 'OPTIMIZING PLAYBACK MEMORY...';

  @override
  String get lyrics => 'Testo';

  @override
  String get lyricsAlignment => 'Allineamento testo';

  @override
  String get lyricsAlignmentDesc =>
      'Allinea la posizione del testo per lo scorrimento dei testi';

  @override
  String get lyricsDarkness => 'Luminosità sfondo testi';

  @override
  String get lyricsDarknessDesc =>
      'Regola l\'oscurità del livello di sfondo per la schermata dei testi';

  @override
  String get lyricsProvider => 'Lyrics Provider';

  @override
  String get lyricsProviderDesc =>
      'Testi online ottenuti da lrclib.net (LRCLIB)';

  @override
  String get maintainersAndDesigners => 'Sviluppatori e designer';

  @override
  String get manageAudioFocus => 'Manage Audio Focus';

  @override
  String get manageAudioFocusDesc =>
      'Richiede e risponde alle variazioni del focus audio di sistema';

  @override
  String get manageAudioFocusTitle => 'Gestisci focus audio';

  @override
  String get manageLanguageAndFocus =>
      'Gestisci le preferenze della lingua e lo stato di pausa sulle chiamate';

  @override
  String get audioFocusGetFocus => 'Get Focus';

  @override
  String get audioFocusGetFocusDesc =>
      'Request audio focus when playback begins.';

  @override
  String get audioFocusReleaseFocus => 'Release Focus';

  @override
  String get audioFocusReleaseFocusDesc =>
      'Release audio focus when playback pauses or stops.';

  @override
  String get audioFocusStopOnOtherSession =>
      'Stop Music on Other Music Session';

  @override
  String get audioFocusStopOnOtherSessionDesc =>
      'Pause playback when another app starts playing audio.';

  @override
  String get audioFocusRestartOnGain => 'Restart Music on Focus Gain';

  @override
  String get audioFocusRestartOnGainDesc =>
      'Resume playback automatically when audio focus returns, only if playback was interrupted by focus loss.';

  @override
  String get pauseOnDuckTitle => 'Pause on Duck';

  @override
  String get pauseOnDuckDesc =>
      'Pause playback instead of lowering volume when another app plays a transient sound (e.g. notifications, navigation directions).';

  @override
  String get resumeOnBluetoothConnectTitle => 'Resume on Bluetooth Connect';

  @override
  String get resumeOnBluetoothConnectDesc =>
      'Resume playback automatically when a Bluetooth audio device (headphones, car kit) reconnects.';

  @override
  String get manualCrossfadeDuration => 'Durata dissolvenza incrociata manuale';

  @override
  String get manualCrossfadeDurationDesc =>
      'Durata sovrapposizione durante il cambio traccia manuale';

  @override
  String get matchingLyrics => 'MATCHING LYRICS';

  @override
  String get metadataDetails => 'Dettagli metadati';

  @override
  String get mostPlayed => 'Più riprodotti';

  @override
  String get musicAudioAccess => 'ACCESSO A MUSICA E AUDIO';

  @override
  String get musicDarkness => 'Luminosità sfondo Player';

  @override
  String get musicDarknessDesc =>
      'Regola l\'oscurità del livello di sfondo per la schermata del Player';

  @override
  String get musicLibrary => 'Libreria musicale';

  @override
  String get muteOrPauseCalls =>
      'Silenzia o metti in pausa durante le telefonate e altre attività audio';

  @override
  String get newPlaylist => 'Nuova Playlist';

  @override
  String get newTitle => 'Nuovo titolo';

  @override
  String get noAlbumsFound => 'Nessun album trovato';

  @override
  String get noArtistsFound => 'Nessun artista trovato';

  @override
  String get noFavoritesYet => 'Nessun preferito';

  @override
  String get noHistoryYet => 'Nessuna cronologia';

  @override
  String get noLyrics => 'Nessun testo trovato';

  @override
  String get noMusicDetected => 'NESSUN BRANO RILEVATO';

  @override
  String get noPlaylistsCreated => 'Nessuna playlist creata.';

  @override
  String get noPlaylistsYet => 'Nessuna playlist';

  @override
  String get noResultsFound => 'Nessun risultato trovato';

  @override
  String get noSongsFound => 'Nessun brano trovato';

  @override
  String get notificationAccess => 'ACCESSO ALLE NOTIFICHE';

  @override
  String get nowPlaying => 'In riproduzione';

  @override
  String get performanceOptimizerDashboard =>
      'Dashboard Ottimizzazione Prestazioni';

  @override
  String get performanceOptimizerDashboardDesc =>
      'Mostra le statistiche dell\'ottimizzatore in tempo reale';

  @override
  String get permanentFocusChangePause => 'Pausa su perdita focus permanente';

  @override
  String get permanentFocusChangePauseDesc =>
      'Sospende la riproduzione in caso di perdita definitiva del focus audio';

  @override
  String get plainTimestamps => 'Marcatori temporali semplici';

  @override
  String get play => 'Riproduci';

  @override
  String get playAll => 'Riproduci tutto';

  @override
  String get playbackAudio => 'Playback & Language';

  @override
  String get playlists => 'Playlists';

  @override
  String get playNext => 'Riproduci dopo';

  @override
  String get playQueue => 'Coda di riproduzione';

  @override
  String get pressBackExit => 'Premi di nuovo indietro per uscire';

  @override
  String get privacySafety => 'Privacy e sicurezza';

  @override
  String get privacySafetyDesc =>
      '100% privato e offline. I tuoi brani, la cronologia di riproduzione, i preferiti e la configurazione rimangono esclusivamente all\'interno di un database Isar sicuro sul tuo dispositivo. Non tracciamo, raccogliamo o condividiamo le tue preferenze o i dati di utilizzo.';

  @override
  String get pureBlackOled => 'Pure Black (OLED)';

  @override
  String get pureBlackOledDesc => 'Usa nero assoluto per gli sfondi';

  @override
  String get queue => 'Coda';

  @override
  String get queueIsEmpty => 'Queue is empty';

  @override
  String get quickPicks => 'Selezione rapida';

  @override
  String get quickPicksRowDesc => 'La griglia dei tuoi brani più riprodotti';

  @override
  String get readyToScan => 'Pronto per la scansione';

  @override
  String get recentlyAddedSongsRowDesc =>
      'Un elenco dei tuoi ultimi file importati';

  @override
  String get recentlyPlayed => 'Riprodotti di recente';

  @override
  String get recentPlayed => 'Brani riprodotti di recente';

  @override
  String get removedFromPlaylist => 'Rimosso dalla Playlist';

  @override
  String get removeFromFavorites => 'Rimuovi dai preferiti';

  @override
  String get removeFromPlaylist => 'Rimuovi dalla Playlist';

  @override
  String get rename => 'Rinomina';

  @override
  String get renameFile => 'Rinomina File';

  @override
  String get renamePlaylist => 'Rinomina Playlist';

  @override
  String get renameSong => 'Rinomina brano';

  @override
  String get reorderDashboardSections => 'Riordina sezioni pannello principale';

  @override
  String get reorderDashboardSectionsDesc =>
      'Trascina e rilascia per impostare l\'ordine preferito del pannello principale';

  @override
  String get rescanLibrary => 'Nuova scansione libreria';

  @override
  String get rescanStorage => 'RAGGIUNGI E SCANSIONA ARCHIVIO';

  @override
  String get reset => 'Ripristina';

  @override
  String get resetLibrary => 'Reset & Rescan';

  @override
  String get resetLibraryConfirm =>
      'Questo cancellerà tutti i brani, gli album e gli artisti ed eseguirà una nuova scansione completa delle tue cartelle.';

  @override
  String get resetLibraryConfirmNew =>
      'Questo rimuoverà tutti i brani dalla libreria. I file musicali fisici non verranno eliminati.';

  @override
  String get resetLibraryDesc =>
      'Rimuovi tutti i brani dalla libreria indicizzata';

  @override
  String get resumeAfterCallDesc =>
      'Riprende la riproduzione automaticamente al termine della chiamata (se sospesa da chiamata)';

  @override
  String get resumeAfterCallTitle => 'Riprendi dopo chiamata';

  @override
  String get resumeOnStartDesc =>
      'Riprende la riproduzione automaticamente all\'avvio di Looper Player';

  @override
  String get resumeOnStartTitle => 'Riprendi all\'avvio';

  @override
  String get persistQueueTitle => 'Mantieni ultima coda';

  @override
  String get persistQueueDesc =>
      'Salva l\'ultimo brano e la coda al riavvio dell\'applicazione';

  @override
  String get right => 'Destra';

  @override
  String scanCompleteSongsDetected(int count) {
    return 'SCAN COMPLETE: $count SONGS DETECTED!';
  }

  @override
  String get scanForMusic => 'SCANSIONA MUSICA';

  @override
  String get scanIndexLocalDesc =>
      'Scansiona e indicizza i file musicali locali';

  @override
  String get scanLibrary => 'Scansiona libreria';

  @override
  String get scanningInBackground => 'Scansione in background...';

  @override
  String get scanningLibrary => 'Scansione della libreria...';

  @override
  String get scanningStorage => 'SCANSIONE ARCHIVIO IN CORSO...';

  @override
  String get scanningStorageDesc =>
      'Ricerca dei brani audio nelle cartelle. Attendi...';

  @override
  String get search => 'Cerca';

  @override
  String get searchLibraryHint => 'Cerca nell\'intera libreria';

  @override
  String get searchSongsHint => 'Cerca brani';

  @override
  String get seekFadeDuration => 'Durata dissolvenza sul seek';

  @override
  String get seekFadeDurationDesc =>
      'Durata dell\'effetto di dissolvenza durante il posizionamento';

  @override
  String get selectAppLanguage => 'Seleziona la lingua dell\'applicazione';

  @override
  String get selectCustomColor => 'Seleziona colore personalizzato';

  @override
  String get selectCustomFolder => 'SELEZIONA CARTELLA PERSONALIZZATA';

  @override
  String get selectFolderIndex =>
      'Seleziona una cartella per indicizzare i file musicali';

  @override
  String get selectSpecificFolder => 'SELEZIONA CARTELLA SPECIFICA';

  @override
  String get settings => 'Impostazioni';

  @override
  String get share => 'Condividi';

  @override
  String get shareFile => 'Condividi file';

  @override
  String get showAlbumsRow => 'Mostra riga Album';

  @override
  String get showAlbumsRowDesc =>
      'Mostra un elenco orizzontale di album nella schermata Home';

  @override
  String get showArtistsRow => 'Mostra riga Artisti';

  @override
  String get showArtistsRowDesc =>
      'Mostra un elenco orizzontale di artisti nella schermata Home';

  @override
  String get showGenresRow => 'Mostra riga Generi';

  @override
  String get showGenresRowDesc =>
      'Mostra un elenco orizzontale di generi nella schermata Home';

  @override
  String get showLess => 'Mostra meno';

  @override
  String get showMore => 'Mostra altro';

  @override
  String get showQualityBadge => 'Mostra badge qualità';

  @override
  String get showQualityBadgeDesc =>
      'Mostra le informazioni sulla qualità audio nella schermata di riproduzione';

  @override
  String get silenceBetweenTracksDesc =>
      'Aggiunge un intervallo di silenzio tra i brani (0ms per riproduzione continua)';

  @override
  String get silenceBetweenTracksTitle => 'Silenzio tra le tracce';

  @override
  String get songDeletedDbOnly =>
      'Brano rimosso dalla libreria (file fisico in sola lettura)';

  @override
  String get songDeletedSuccess => 'Brano eliminato con successo';

  @override
  String get songDeleteFailed => 'Impossibile eliminare il brano';

  @override
  String get songDetails => 'Dettagli brano';

  @override
  String get songDetailsAndFrequency => 'Dettagli brano e frequenza';

  @override
  String get songRenamedDbOnly =>
      'Brano rinominato nella libreria (file fisico in sola lettura)';

  @override
  String get songRenamedSuccess => 'Brano rinominato con successo';

  @override
  String get songRenameFailed => 'Impossibile rinominare il brano';

  @override
  String get songs => 'Brani';

  @override
  String get songsDarkness => 'Luminosità sfondo Brani';

  @override
  String get songsDarknessDesc =>
      'Regola l\'oscurità del livello di sfondo per la schermata dei Brani';

  @override
  String get sortBy => 'Ordina per';

  @override
  String get sortOrder => 'Ordinamento';

  @override
  String get sourceCode => 'Codice sorgente';

  @override
  String get stopServiceOnAppDismissal =>
      'Interrompi servizio alla chiusura dell\'app';

  @override
  String get stopServiceOnAppDismissalDesc =>
      'Arresta il servizio in background e chiude l\'app quando viene rimossa dalle recenti';

  @override
  String get storagePermissionRequired =>
      'I permessi di archiviazione sono richiesti per scansionare la memoria del dispositivo.';

  @override
  String get syncLyricsOffline => 'Sincronizza testi (Offline)';

  @override
  String get systemDefault => 'Predefinito di sistema';

  @override
  String get systemPermissionChecklist => 'PERMESSI DI SISTEMA RICHIESTI';

  @override
  String get technicalInfoFrequency => 'Technical Info & Frequency';

  @override
  String get theme => 'Tema';

  @override
  String get title => 'Titolo';

  @override
  String get todayMixForYou => 'Mix di oggi per te';

  @override
  String get toggleFavorite => 'Aggiungi/Rimuovi preferito';

  @override
  String get shuffleTitle => 'Shuffle';

  @override
  String get shuffleDisabledDesc =>
      'Play songs in their original queue order. Turning shuffle off keeps the current song playing and restores the remaining queue to its original sequence without affecting playback or playback history.';

  @override
  String get shuffleEnabledDesc =>
      'Randomize the remaining songs while keeping the current song unchanged. The generated shuffle order remains consistent until the queue changes or a new shuffle is requested, preventing repeated or skipped tracks.';

  @override
  String get shuffleSwitchingDesc =>
      'Toggling shuffle never restarts the current song. It only changes the order of upcoming tracks—randomized when enabled and restored to the original queue order when disabled.';

  @override
  String get topResult => 'Risultato principale';

  @override
  String get transferMusicFiles => 'TRASFERISCI FILE MUSICALI';

  @override
  String get turnOffBlursOptimize =>
      'Disattiva sfocature complesse per ottimizzare le prestazioni';

  @override
  String get unknown => 'Sconosciuto';

  @override
  String get unknownAlbum => 'Album sconosciuto';

  @override
  String get unknownArtist => 'Artista sconosciuto';

  @override
  String get updateLibraryIndexing =>
      'Aggiorna l\'indicizzazione dei file della libreria';

  @override
  String get useAbsoluteBlackBg => 'Usa nero assoluto per gli sfondi';

  @override
  String get useStaticTextTimestamps =>
      'Usa testo statico invece dell\'animazione per il tempo di riproduzione';

  @override
  String get verticalMotionEffectPlayer =>
      'Effetto di scorrimento verticale player';

  @override
  String get verticalMotionEffectPlayerDesc =>
      'Trascina verso il basso sul player espanso per chiuderlo';

  @override
  String get viewAll => 'Vedi tutti';

  @override
  String get visitOfficialRepository =>
      'Visita il repository ufficiale su GitHub';

  @override
  String get welcomeAboutDesc =>
      'Looper Player è un sistema Music-OS di nuova generazione per la riproduzione audio offline ad alta fedeltà. Include testi sincronizzati in tempo reale, gestione avanzata delle sessioni audio, temi dinamici adattivi e supporto per librerie musicali multi-formato. Completamente ottimizzato per la massima efficienza della batteria.';

  @override
  String get welcomeAllFilesDesc =>
      'Consigliato per la scansione avanzata in directory non standard (Download, Telegram, cartelle personalizzate).';

  @override
  String get welcomeInstructionConnectDesc =>
      'Collega il tuo telefono o dispositivo al computer usando un cavo dati USB standard.';

  @override
  String get welcomeInstructionDownloadDesc =>
      'In alternativa, scarica i file direttamente sul dispositivo usando un browser web o altre utilità di download.';

  @override
  String get welcomeInstructionTransferDesc =>
      'Copia i tuoi file musicali offline (supportati .mp3, .flac, .m4a, .wav) direttamente nella cartella \'Music\' o \'Download\' del tuo dispositivo.';

  @override
  String get welcomeMusicAudioDesc =>
      'Richiesto per trovare e riprodurre brani audio offline presenti nella memoria del tuo dispositivo.';

  @override
  String get welcomeNoSongsDesc =>
      'Non siamo riusciti a trovare nessun file audio supportato (MP3, FLAC, WAV, M4A, OGG) nella memoria del tuo dispositivo.';

  @override
  String get welcomeNotificationDesc =>
      'Richiesto per mostrare i controlli di riproduzione e le notifiche attive nella barra di sistema.';

  @override
  String get welcomeScanningFoldersDesc =>
      'Scansione di tutte le cartelle e sottocartelle per trovare file audio.';

  @override
  String get whyInternetUsed => 'Perché usiamo Internet';

  @override
  String get whyInternetUsedDesc =>
      '• Sincronizzazione dei testi: Utilizzato esclusivamente per cercare e scaricare testi sincronizzati (in formato LRC) da database online. Nessun dato personale, impostazione o file multimediale viene caricato o condiviso.';

  @override
  String get whyPermissionsUsed => 'Perché usiamo i permessi';

  @override
  String get whyPermissionsUsedDesc =>
      '• Accesso all\'archivio / File multimediali: Richiesto per scansionare, leggere e indicizzare i brani musicali locali.\n• Notifiche: Richiesto per mostrare i widget dei controlli di riproduzione nella barra delle notifiche.';

  @override
  String get willPlayNext => 'Verrà riprodotto dopo';

  @override
  String get year => 'Anno';

  @override
  String get supportUs => 'Supportaci';

  @override
  String get supportUsDesc =>
      'Aiuta a mantener Looper Player attivo e open source';

  @override
  String get supportDevelopment => 'Supporta lo sviluppo';

  @override
  String get supportDevelopmentDesc =>
      'Looper Player è gratuito al 100% e open source. Se ti piace usarlo, considera di supportare il creatore con una donazione. Ogni contributo aiuta a mantenere il progetto attivo!';

  @override
  String get useCustomFont => 'Usa carattere personalizzato';

  @override
  String get useCustomFontDesc =>
      'Usa carattere e spessore personalizzati per la vista dei testi sincronizzati';

  @override
  String get selectFontFamily => 'Seleziona famiglia caratteri';

  @override
  String activeFont(String fontName) {
    return 'Carattere attivo: $fontName';
  }

  @override
  String get fontWeightAdjustment => 'Regolazione spessore carattere';

  @override
  String get currentWeight => 'Spessore attuale';

  @override
  String get useCustomFontLyrics => 'Carattere personalizzato per il testo';

  @override
  String get useCustomFontLyricsDesc =>
      'Usa carattere e spessore personalizzati per la vista dei testi sincronizzati';

  @override
  String get lyricsFontFamily => 'Famiglia caratteri testo';

  @override
  String activeLyricsFont(String fontName) {
    return 'Carattere testo attivo: $fontName';
  }

  @override
  String get lyricsFontWeightAdjustment => 'Regolazione spessore testo';

  @override
  String get giveStarOnGithub => 'Lascia una stella su GitHub';

  @override
  String get supportProjectLove =>
      'Supporta il progetto e mostra il tuo apprezzamento!';

  @override
  String get sortAlphabeticalAZ => 'Alfabetico (A-Z)';

  @override
  String get sortAlphabeticalZA => 'Alfabetico (Z-A)';

  @override
  String get sortRecentlyAdded => 'Aggiunto di recente';

  @override
  String get sortOldestAdded => 'Meno recente';

  @override
  String get sortYearNewest => 'Anno (Più recente)';

  @override
  String get sortYearOldest => 'Anno (Meno recente)';

  @override
  String get sortMostSongs => 'Più canzoni';

  @override
  String get sortLeastSongs => 'Meno canzoni';

  @override
  String get sortDefault => 'Predefinito';

  @override
  String get sortArtistAsc => 'Artista (A-Z)';

  @override
  String get sortAlbumAsc => 'Album (A-Z)';

  @override
  String get sortDuration => 'Durata';
}
