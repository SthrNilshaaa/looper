// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get about => 'À propos';

  @override
  String get aboutAndMaintainers => 'À propos & Développeurs';

  @override
  String get aboutApp => 'À propos de l\'application';

  @override
  String get aboutLooperPlayer => 'À PROPOS DE LOOPER PLAYER';

  @override
  String get accentColor => 'Couleur d\'accentuation';

  @override
  String get accentColorDesc =>
      'Sélectionner manuellement la couleur d\'accentuation';

  @override
  String get acousticSpectralAnalysis => 'ANALYSE ACOUSTIQUE & SPECTRALE';

  @override
  String get activeCallCannotPlay =>
      'Lecture bloquée : Impossible de lire de la musique pendant un appel actif';

  @override
  String get adaptColorsArtwork =>
      'Adapter les couleurs de l\'application à la pochette de l\'album';

  @override
  String addedTo(String name) {
    return 'Ajouté à $name';
  }

  @override
  String get addedToQueue => 'Ajouté à la file d\'attente';

  @override
  String get addFolder => 'Ajouter un dossier';

  @override
  String get addToFavorites => 'Ajouter aux favoris';

  @override
  String get addToPlaylists => 'Ajouter aux playlists';

  @override
  String get addToQueue => 'Ajouter à la file d\'attente';

  @override
  String get album => 'Album';

  @override
  String get albums => 'Albums';

  @override
  String get albumsRowDesc => 'Étagère horizontale d\'albums';

  @override
  String get allFilesAccess => 'ACCÈS À TOUS LES FICHIERS (RECOMMANDÉ)';

  @override
  String get allSongs => 'Toutes les chansons';

  @override
  String get appDetailsCreator =>
      'Détails de l\'application, créateur et équipe de conception';

  @override
  String get appearance => 'Apparence';

  @override
  String get appInfoPrivacy => 'INFOS APP & CONFIDENTIALITÉ';

  @override
  String get appTitle => 'Looper Player';

  @override
  String get artist => 'Artiste';

  @override
  String get artists => 'Artistes';

  @override
  String get artistsRowDesc => 'Étagère horizontale d\'artistes';

  @override
  String get ascending => 'Ascendant';

  @override
  String get audioCrossfade => 'Fondu enchaîné audio';

  @override
  String get audioCrossfadeDesc =>
      'Superposer les pistes en douceur lors du changement de chanson';

  @override
  String get audioFocusDenied =>
      'Playback paused: Audio focus denied by system';

  @override
  String get audioPlayback => 'Audio & lecture';

  @override
  String get audioPlaybackDesc =>
      'Paramètres de fondu enchaîné, de silence et d\'atténuation';

  @override
  String get autoCrossfadeDuration => 'Durée du fondu enchaîné automatique';

  @override
  String get autoCrossfadeDurationDesc =>
      'Durée de superposition lors des transitions automatiques';

  @override
  String get backToMainView => 'RETOUR À LA VUE PRINCIPALE';

  @override
  String get cancel => 'Annuler';

  @override
  String get categories => 'Catégories';

  @override
  String get center => 'Centre';

  @override
  String get clear => 'Effacer';

  @override
  String get clearQueue => 'Effacer';

  @override
  String get connectDevice => 'CONNECTER L\'APPAREIL';

  @override
  String get corePurpose => 'Objectif principal';

  @override
  String get corePurposeDesc =>
      'Looper Player est un lecteur audio haute fidélité hors ligne par défaut, conçu pour les passionnés de musique qui souhaitent un contrôle absolu sur leur bibliothèque locale, une lecture sans blanc et un défilement fluide des paroles synchronisées.';

  @override
  String get create => 'Créer';

  @override
  String get createPlaylist => 'Créer une playlist';

  @override
  String get creatorAndMaintainer => 'Créateur et développeur';

  @override
  String get customAccentColor => 'Couleur d\'accent personnalisée';

  @override
  String get customizeColorsTheme =>
      'Personnalisez les couleurs, le thème et les arrière-plans des paroles';

  @override
  String get dateAdded => 'Date d\'ajout';

  @override
  String get deepStorageScanProgress => 'ANALYSE APPROFONDIE DU STOCKAGE...';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteFile => 'Supprimer le fichier';

  @override
  String get deletePlaylist => 'Supprimer la playlist';

  @override
  String deletePlaylistConfirm(String name) {
    return 'Êtes-vous sûr de vouloir supprimer \"$name\" ?';
  }

  @override
  String get deleteSong => 'Supprimer la chanson';

  @override
  String get deleteSongConfirm =>
      'Êtes-vous sûr de vouloir supprimer cette chanson du disque ?';

  @override
  String get descending => 'Descendant';

  @override
  String get designerAndMaintainer => 'Concepteur et développeur';

  @override
  String get disableBlurEffects => 'Désactiver les effets de flou';

  @override
  String get disableSquigglyProgressBar =>
      'Désactiver l\'animation ondulée de la barre de progression';

  @override
  String get downloadAudioDirectly => 'TÉLÉCHARGER L\'AUDIO DIRECTEMENT';

  @override
  String get downloadingLyricsOffline =>
      'Téléchargement des paroles pour une utilisation hors ligne...';

  @override
  String get downloadMissingArtwork => 'Télécharger l\'art manquant';

  @override
  String get downloadMissingArtworkDesc =>
      'Télécharger automatiquement les pochettes haute résolution depuis iTunes';

  @override
  String get duration => 'Durée';

  @override
  String get dynamicAccentColor => 'Couleur d\'accentuation dynamique';

  @override
  String get dynamicAccentColorDesc =>
      'Mettre à jour dynamiquement la couleur d\'accentuation selon la pochette';

  @override
  String get dynamicBgOnlyLyrics =>
      'Fond dynamique uniquement pour les paroles';

  @override
  String get dynamicColorActiveLyrics => 'Dynamic Color Active Line';

  @override
  String get dynamicColorActiveLyricsDesc =>
      'Use extracted artwork colors for the currently playing lyrics line';

  @override
  String get dynamicLyricsBg => 'Fond de paroles dynamique';

  @override
  String get dynamicLyricsBgDesc =>
      'Appliquer le flou de la pochette à l\'écran des paroles';

  @override
  String get dynamicTheming => 'Thème dynamique';

  @override
  String get emptyLibraryDesc =>
      'We couldn\'t find any supported music files in your library. Add folders or run a search scan.';

  @override
  String get enableNetworkLyricsArt =>
      'Activer l\'utilisation du réseau pour les paroles en ligne & l\'art de l\'artiste';

  @override
  String get enablePlayerGradient => 'Music Screen Gradient';

  @override
  String get enablePlayerGradientDesc =>
      'Enable the radial accent gradient background on the now playing screen';

  @override
  String get fadeDuration => 'Durée du fondu';

  @override
  String get fadeDurationDesc =>
      'Durée de l\'effet de fondu lecture/pause/arrêt';

  @override
  String get fadeOnSeek => 'Fondu lors de la recherche';

  @override
  String get fadeOnSeekDesc =>
      'Atténuer doucement le volume lors de la recherche dans un morceau';

  @override
  String get fadePlayPauseStop => 'Fondu Lecture/Pause/Arrêt';

  @override
  String get fadePlayPauseStopDesc =>
      'Atténuer doucement le volume lors de la lecture, pause ou arrêt';

  @override
  String get favorites => 'Favoris';

  @override
  String get fileInformation => 'Informations sur le fichier';

  @override
  String get flatProgressBar => 'Barre de progression plate';

  @override
  String get folders => 'Dossiers';

  @override
  String get genre => 'Genre';

  @override
  String get genres => 'Genres';

  @override
  String get genresRowDesc => 'Étagère horizontale de genres musicaux';

  @override
  String get goStart => 'COMMENCER';

  @override
  String get grant => 'AUTORISER';

  @override
  String get granted => 'AUTORISÉ';

  @override
  String get history => 'Historique';

  @override
  String get home => 'Accueil';

  @override
  String get homeDarkness => 'Home Screen Darkness';

  @override
  String get homeDarknessDesc =>
      'Adjust background overlay darkness for the Home screen';

  @override
  String get homeDashboardSettings => 'Paramètres du tableau de bord';

  @override
  String get homeDashboardSettingsDesc =>
      'Personnaliser les lignes horizontales de votre écran d\'accueil';

  @override
  String get internetMode => 'Mode Internet';

  @override
  String get keepBackgroundGradient => 'Garder le dégradé de fond';

  @override
  String get keepBackgroundGradientDesc =>
      'Garder le dégradé de fond sur tous les écrans de l\'application';

  @override
  String get language => 'Langue';

  @override
  String get left => 'Gauche';

  @override
  String get library => 'Bibliothèque';

  @override
  String get libraryDarkness => 'Library Screen Darkness';

  @override
  String get libraryDarknessDesc =>
      'Adjust background overlay darkness for the Library screen';

  @override
  String get libraryFoldersSync =>
      'Dossiers, déclencheurs d\'analyse, réinitialisation de la base de données et synchro hors ligne';

  @override
  String get librarySettings => 'Paramètres de la bibliothèque';

  @override
  String get loadingMusicLibrary => 'CHARGEMENT DE LA BIBLIOTHÈQUE MUSICALE';

  @override
  String get loadingMusicLibraryDesc =>
      'Construction des index premium, configuration des écouteurs matériels et optimisation des caches visuels.';

  @override
  String get loadingPhase1 => 'INTERROGATION DE L\'AUDIO...';

  @override
  String get loadingPhase2 => 'RAFRAÎCHISSEMENT DU MOTEUR...';

  @override
  String get loadingPhase3 => 'EXTRACTION DES DONNÉES ACOUSTIQUES...';

  @override
  String get loadingPhase4 => 'OPTIMISATION DE LA MÉMOIRE...';

  @override
  String get lyrics => 'Paroles';

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
  String get lyricsProvider => 'Fournisseur de paroles';

  @override
  String get lyricsProviderDesc =>
      'Paroles en ligne récupérées depuis lrclib.net (LRCLIB)';

  @override
  String get maintainersAndDesigners => 'Développeurs & designers';

  @override
  String get manageAudioFocus => 'Gérer le focus audio';

  @override
  String get manageAudioFocusDesc =>
      'Demander et répondre aux changements de focus audio du système';

  @override
  String get manageAudioFocusTitle => 'Gérer le focus audio';

  @override
  String get manageLanguageAndFocus =>
      'Gérer les préférences de langue et l\'état de focus des appels';

  @override
  String get manualCrossfadeDuration => 'Durée du fondu enchaîné manuel';

  @override
  String get manualCrossfadeDurationDesc =>
      'Durée de superposition lors des transitions manuelles';

  @override
  String get matchingLyrics => 'PAROLES CORRESPONDANTES';

  @override
  String get metadataDetails => 'Détails des métadonnées';

  @override
  String get mostPlayed => 'Plus écoutés';

  @override
  String get musicAudioAccess => 'ACCÈS MUSIQUE & AUDIO';

  @override
  String get musicDarkness => 'Music Player Darkness';

  @override
  String get musicDarknessDesc =>
      'Adjust background overlay darkness for the Music Player screen';

  @override
  String get musicLibrary => 'Bibliothèque musicale';

  @override
  String get muteOrPauseCalls =>
      'Couper le son ou mettre en pause pendant les appels et autres activités audio';

  @override
  String get newPlaylist => 'Nouvelle playlist';

  @override
  String get newTitle => 'Nouveau titre';

  @override
  String get noAlbumsFound => 'Aucun album trouvé';

  @override
  String get noArtistsFound => 'Aucun artiste trouvé';

  @override
  String get noFavoritesYet => 'Aucun favori pour le moment';

  @override
  String get noHistoryYet => 'Aucun historique';

  @override
  String get noLyrics => 'Aucune parole trouvée';

  @override
  String get noMusicDetected => 'AUCUNE MUSIQUE DÉTECTÉE';

  @override
  String get noPlaylistsCreated => 'Aucune playlist créée pour le moment.';

  @override
  String get noPlaylistsYet => 'Aucune playlist pour le moment';

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String get noSongsFound => 'Aucune chanson trouvée';

  @override
  String get notificationAccess => 'ACCÈS AUX NOTIFICATIONS';

  @override
  String get nowPlaying => 'Lecture en cours';

  @override
  String get performanceOptimizerDashboard =>
      'Tableau de bord de l\'optimiseur de performances';

  @override
  String get performanceOptimizerDashboardDesc =>
      'Afficher les statistiques de l\'optimiseur en temps réel';

  @override
  String get permanentFocusChangePause => 'Pause sur perte de focus permanente';

  @override
  String get permanentFocusChangePauseDesc =>
      'Mettre en pause automatiquement lors de la perte définitive du focus audio';

  @override
  String get plainTimestamps => 'Horodatages simples';

  @override
  String get play => 'Lire';

  @override
  String get playAll => 'Tout lire';

  @override
  String get playbackAudio => 'Lecture & Langue';

  @override
  String get playlists => 'Playlists';

  @override
  String get playNext => 'Lire ensuite';

  @override
  String get playQueue => 'File d\'attente';

  @override
  String get pressBackExit => 'Appuyez à nouveau sur retour pour quitter';

  @override
  String get privacySafety => 'Confidentialité & Sécurité';

  @override
  String get privacySafetyDesc =>
      '100% privé et hors ligne en priorité. Vos morceaux, votre historique de lecture, vos favoris et votre configuration restent strictement dans une base de données Isar sécurisée sur votre appareil local. Nous ne suivons, ne collectons et ne partageons pas vos données d\'utilisation.';

  @override
  String get pureBlackOled => 'Noir pur (OLED)';

  @override
  String get pureBlackOledDesc =>
      'Utiliser le noir absolu pour les arrière-plans';

  @override
  String get queue => 'File d\'attente';

  @override
  String get queueIsEmpty => 'La file d\'attente est vide';

  @override
  String get quickPicks => 'Sélections rapides';

  @override
  String get quickPicksRowDesc => 'Votre grille de chansons les plus écoutées';

  @override
  String get readyToScan => 'Prêt à analyser';

  @override
  String get recentlyAddedSongsRowDesc =>
      'Une liste de vos dernières importations';

  @override
  String get recentlyPlayed => 'Récemment écoutés';

  @override
  String get recentPlayed => 'Écoutés récemment';

  @override
  String get removedFromPlaylist => 'Retiré de la playlist';

  @override
  String get removeFromFavorites => 'Retirer des favoris';

  @override
  String get removeFromPlaylist => 'Retirer de la playlist';

  @override
  String get rename => 'Renommer';

  @override
  String get renameFile => 'Renommer le fichier';

  @override
  String get renamePlaylist => 'Renommer la playlist';

  @override
  String get renameSong => 'Renommer la chanson';

  @override
  String get reorderDashboardSections =>
      'Réorganiser les sections du tableau de bord';

  @override
  String get reorderDashboardSectionsDesc =>
      'Glisser-déposer pour définir l\'ordre préféré';

  @override
  String get rescanLibrary => 'Analyser à nouveau la bibliothèque';

  @override
  String get rescanStorage => 'ANALYSER À NOUVEAU LE STOCKAGE';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get resetLibrary => 'Réinitialiser & Analyser';

  @override
  String get resetLibraryConfirm =>
      'Cela effacera toutes les chansons, albums et artistes et effectuera une analyse complète de vos dossiers.';

  @override
  String get resetLibraryConfirmNew =>
      'Cela retirera toutes les chansons de votre bibliothèque. Vos fichiers musicaux ne seront pas supprimés.';

  @override
  String get resetLibraryDesc =>
      'Retirer toutes les chansons de votre bibliothèque indexée';

  @override
  String get resumeAfterCallDesc =>
      'Reprendre la lecture automatiquement à la fin de l\'appel (si mis en pause par l\'appel)';

  @override
  String get resumeAfterCallTitle => 'Reprendre après un appel';

  @override
  String get resumeOnStartDesc =>
      'Reprendre la lecture automatiquement au démarrage de Looper Player';

  @override
  String get resumeOnStartTitle => 'Reprendre au démarrage';

  @override
  String get right => 'Droite';

  @override
  String scanCompleteSongsDetected(int count) {
    return 'ANALYSE TERMINÉE : $count CHANSONS DÉTECTÉES !';
  }

  @override
  String get scanForMusic => 'RECHERCHER DE LA MUSIQUE';

  @override
  String get scanIndexLocalDesc => 'Analyser & indexer les fichiers locaux';

  @override
  String get scanLibrary => 'Analyser la bibliothèque';

  @override
  String get scanningInBackground => 'Analyse en arrière-plan...';

  @override
  String get scanningLibrary => 'Analyse de la bibliothèque en cours...';

  @override
  String get scanningStorage => 'ANALYSE DU STOCKAGE EN COURS...';

  @override
  String get scanningStorageDesc =>
      'Parcours des dossiers pour découvrir des morceaux audio. Veuillez patienter...';

  @override
  String get search => 'Rechercher';

  @override
  String get searchLibraryHint => 'Rechercher dans toute votre bibliothèque';

  @override
  String get searchSongsHint => 'Rechercher des chansons';

  @override
  String get seekFadeDuration => 'Durée du fondu de recherche';

  @override
  String get seekFadeDurationDesc =>
      'Durée de l\'effet de fondu lors de la recherche';

  @override
  String get selectAppLanguage => 'Sélectionner la langue de l\'application';

  @override
  String get selectCustomColor => 'Choisir une couleur personnalisée';

  @override
  String get selectCustomFolder => 'CHOISIR UN DOSSIER PERSONNALISÉ';

  @override
  String get selectFolderIndex =>
      'Sélectionner un dossier pour indexer les fichiers musicaux';

  @override
  String get selectSpecificFolder => 'SÉLECTIONNER UN DOSSIER SPÉCIPIQUE';

  @override
  String get settings => 'Paramètres';

  @override
  String get share => 'Partager';

  @override
  String get shareFile => 'Partager le fichier';

  @override
  String get showAlbumsRow => 'Afficher la ligne Albums';

  @override
  String get showAlbumsRowDesc =>
      'Afficher une liste horizontale d\'albums sur votre écran d\'accueil';

  @override
  String get showArtistsRow => 'Afficher la ligne Artistes';

  @override
  String get showArtistsRowDesc =>
      'Afficher une liste horizontale d\'artistes sur votre écran d\'accueil';

  @override
  String get showGenresRow => 'Afficher la ligne Genres';

  @override
  String get showGenresRowDesc =>
      'Afficher une liste horizontale de genres sur votre écran d\'accueil';

  @override
  String get showLess => 'Afficher moins';

  @override
  String get showMore => 'Afficher plus';

  @override
  String get showQualityBadge => 'Show Quality Badge';

  @override
  String get showQualityBadgeDesc =>
      'Display audio quality information badge on the now playing screen';

  @override
  String get silenceBetweenTracksDesc =>
      'Ajouter un silence entre les pistes (0ms pour le sans blanc)';

  @override
  String get silenceBetweenTracksTitle => 'Silence entre les pistes';

  @override
  String get songDeletedDbOnly =>
      'Chanson retirée de la bibliothèque (fichier physique en lecture seule)';

  @override
  String get songDeletedSuccess => 'Chanson supprimée avec succès';

  @override
  String get songDeleteFailed => 'Échec de la suppression de la chanson';

  @override
  String get songDetails => 'Détails de la chanson';

  @override
  String get songDetailsAndFrequency => 'Détails & Fréquence de la chanson';

  @override
  String get songRenamedDbOnly =>
      'Chanson renommée dans la bibliothèque (fichier physique en lecture seule)';

  @override
  String get songRenamedSuccess => 'Chanson renommée avec succès';

  @override
  String get songRenameFailed => 'Échec du renommage de la chanson';

  @override
  String get songs => 'Chansons';

  @override
  String get songsDarkness => 'Songs Screen Darkness';

  @override
  String get songsDarknessDesc =>
      'Adjust background overlay darkness for the Songs screen';

  @override
  String get sortBy => 'Trier par';

  @override
  String get sortOrder => 'Ordre de tri';

  @override
  String get sourceCode => 'Code source';

  @override
  String get stopServiceOnAppDismissal =>
      'Arrêter le service à la fermeture de l\'application';

  @override
  String get stopServiceOnAppDismissalDesc =>
      'Arrête le service en arrière-plan et ferme l\'application lorsqu\'elle est balayée';

  @override
  String get storagePermissionRequired =>
      'Les autorisations de stockage sont requises pour analyser la mémoire de l\'appareil.';

  @override
  String get syncLyricsOffline => 'Synchroniser les paroles (Hors ligne)';

  @override
  String get systemDefault => 'Système par défaut';

  @override
  String get systemPermissionChecklist => 'LISTE DE CONTRÔLE DES AUTORISATIONS';

  @override
  String get technicalInfoFrequency => 'Infos techniques & Fréquence';

  @override
  String get theme => 'Thème';

  @override
  String get title => 'Titre';

  @override
  String get todayMixForYou => 'Mix du jour pour vous';

  @override
  String get toggleFavorite => 'Ajouter/Retirer des favoris';

  @override
  String get topResult => 'Meilleur résultat';

  @override
  String get transferMusicFiles => 'TRANSFÉRER LES FICHIERS MUSICAUX';

  @override
  String get turnOffBlursOptimize =>
      'Désactiver les flous intenses pour optimiser les performances';

  @override
  String get unknown => 'Inconnu';

  @override
  String get unknownAlbum => 'Album inconnu';

  @override
  String get unknownArtist => 'Artiste inconnu';

  @override
  String get updateLibraryIndexing =>
      'Mettre à jour l\'indexation des fichiers de la bibliothèque';

  @override
  String get useAbsoluteBlackBg => 'Utiliser un fond noir absolu';

  @override
  String get useStaticTextTimestamps =>
      'Utiliser du texte statique au lieu d\'une animation pour la progression';

  @override
  String get verticalMotionEffectPlayer =>
      'Effet de mouvement vertical du lecteur';

  @override
  String get verticalMotionEffectPlayerDesc =>
      'Glisser vers le bas sur le lecteur étendu pour le fermer';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get visitOfficialRepository => 'Visiter le dépôt officiel sur GitHub';

  @override
  String get welcomeAboutDesc =>
      'Looper Player est un système Music-OS de nouvelle génération conçu pour une lecture audio hors ligne de qualité supérieure. Il intègre des paroles synchronisées en temps réel, une gestion avancée des sessions audio avec mise en pause automatique lors des appels, des thèmes d\'arrière-plan adaptatifs et la prise en charge de nombreux formats de fichiers. Optimisé pour économiser au maximum la batterie.';

  @override
  String get welcomeAllFilesDesc =>
      'Fortement recommandé pour une analyse professionnelle afin de localiser des chansons dans des dossiers non standard (Téléchargements, Telegram, dossiers personnalisés).';

  @override
  String get welcomeInstructionConnectDesc =>
      'Branchez votre téléphone ou appareil à un ordinateur personnel à l\'aide d\'un câble de données USB standard.';

  @override
  String get welcomeInstructionDownloadDesc =>
      'Alternativement, téléchargez les fichiers directement à l\'aide d\'un navigateur web ou d\'un autre utilitaire de téléchargement sur l\'appareil lui-même.';

  @override
  String get welcomeInstructionTransferDesc =>
      'Copiez vos fichiers musicaux (formats pris en charge : .mp3, .flac, .m4a, .wav) directement dans le dossier standard \'Music\' ou \'Download\' de votre appareil.';

  @override
  String get welcomeMusicAudioDesc =>
      'Requeri pour découvrir et lire les pistes audio standard stockées dans la mémoire de votre appareil.';

  @override
  String get welcomeNoSongsDesc =>
      'Nous n\'avons trouvé aucun fichier audio pris en charge (MP3, FLAC, WAV, M4A, OGG) dans la mémoire de votre appareil.';

  @override
  String get welcomeNotificationDesc =>
      'Requis pour afficher les commandes de lecture et les widgets de notification active dans votre barre système.';

  @override
  String get welcomeScanningFoldersDesc =>
      'Analyse de tous les dossiers et sous-dossiers pour trouver des fichiers audio.';

  @override
  String get whyInternetUsed => 'Pourquoi Internet est utilisé';

  @override
  String get whyInternetUsedDesc =>
      '• Synchronisation des paroles dynamiques : Utilisé uniquement pour récupérer et télécharger en toute sécurité les paroles synchronisées (formats LRC) à partir de bases de données en ligne. Aucune donnée personnelle, paramètre ou fichier multimédia n\'est jamais téléversé ou partagé.';

  @override
  String get whyPermissionsUsed => 'Pourquoi les autorisations sont utilisées';

  @override
  String get whyPermissionsUsedDesc =>
      '• Accès stockage / médias : Requis pour découvrir, lire et indexer les pistes audio locales stockées sur votre appareil.\n• Notifications : Requis pour afficher les widgets de contrôle de lecture dans la barre d\'état et le tiroir système.';

  @override
  String get willPlayNext => 'Sera lu ensuite';

  @override
  String get year => 'Année';
}
