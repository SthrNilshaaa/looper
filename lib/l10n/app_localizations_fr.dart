// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Looper Player';

  @override
  String get songs => 'Chansons';

  @override
  String get albums => 'Albums';

  @override
  String get artists => 'Artistes';

  @override
  String get playlists => 'Playlists';

  @override
  String get search => 'Rechercher';

  @override
  String get settings => 'Paramètres';

  @override
  String get nowPlaying => 'Lecture en cours';

  @override
  String get playQueue => 'File d\'attente';

  @override
  String get lyrics => 'Paroles';

  @override
  String get noLyrics => 'Aucune parole trouvée';

  @override
  String get scanLibrary => 'Analyser la bibliothèque';

  @override
  String get addFolder => 'Ajouter un dossier';

  @override
  String get resetLibrary => 'Réinitialiser & Analyser';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Thème';

  @override
  String get accentColor => 'Couleur d\'accentuation';

  @override
  String get customAccentColor => 'Couleur d\'accent personnalisée';

  @override
  String get selectCustomColor => 'Choisir une couleur personnalisée';

  @override
  String get about => 'À propos';

  @override
  String get unknownArtist => 'Artiste inconnu';

  @override
  String get unknownAlbum => 'Album inconnu';

  @override
  String get customizeColorsTheme =>
      'Personnalisez les couleurs, le thème et les arrière-plans des paroles';

  @override
  String get dynamicTheming => 'Thème dynamique';

  @override
  String get adaptColorsArtwork =>
      'Adapter les couleurs de l\'application à la pochette de l\'album';

  @override
  String get disableBlurEffects => 'Désactiver les effets de flou';

  @override
  String get turnOffBlursOptimize =>
      'Désactiver les flous intenses pour optimiser les performances';

  @override
  String get pureBlackOled => 'Noir pur (OLED)';

  @override
  String get useAbsoluteBlackBg => 'Utiliser un fond noir absolu';

  @override
  String get dynamicLyricsBg => 'Fond de paroles dynamique';

  @override
  String get dynamicBgOnlyLyrics =>
      'Fond dynamique uniquement pour les paroles';

  @override
  String get flatProgressBar => 'Barre de progression plate';

  @override
  String get disableSquigglyProgressBar =>
      'Désactiver l\'animation ondulée de la barre de progression';

  @override
  String get plainTimestamps => 'Horodatages simples';

  @override
  String get useStaticTextTimestamps =>
      'Utiliser du texte statique au lieu d\'une animation pour la progression';

  @override
  String get playbackAudio => 'Lecture & Audio';

  @override
  String get manageLanguageAndFocus =>
      'Gérer les préférences de langue et l\'état de focus des appels';

  @override
  String get manageAudioFocus => 'Gérer le focus audio';

  @override
  String get muteOrPauseCalls =>
      'Couper le son ou mettre en pause pendant les appels et autres activités audio';

  @override
  String get internetMode => 'Mode Internet';

  @override
  String get enableNetworkLyricsArt =>
      'Activer l\'utilisation du réseau pour les paroles en ligne & l\'art de l\'artiste';

  @override
  String get musicLibrary => 'Bibliothèque musicale';

  @override
  String get libraryFoldersSync =>
      'Dossiers, déclencheurs d\'analyse, réinitialisation de la base de données et synchro hors ligne';

  @override
  String get syncLyricsOffline => 'Synchroniser les paroles (Hors ligne)';

  @override
  String get downloadingLyricsOffline =>
      'Téléchargement des paroles pour une utilisation hors ligne...';

  @override
  String get rescanLibrary => 'Analyser à nouveau la bibliothèque';

  @override
  String get scanningLibrary => 'Analyse de la bibliothèque en cours...';

  @override
  String get aboutAndMaintainers => 'À propos & Développeurs';

  @override
  String get appDetailsCreator =>
      'Détails de l\'application, créateur et équipe de conception';

  @override
  String get lyricsProvider => 'Fournisseur de paroles';

  @override
  String get creatorAndMaintainer => 'Créateur et développeur';

  @override
  String get designerAndMaintainer => 'Concepteur et développeur';

  @override
  String get appInfoPrivacy => 'INFOS APP & CONFIDENTIALITÉ';

  @override
  String get corePurpose => 'Objectif principal';

  @override
  String get corePurposeDesc =>
      'Looper Player est un lecteur audio haute fidélité hors ligne par défaut, conçu pour les passionnés de musique qui souhaitent un contrôle absolu sur leur bibliothèque locale, une lecture sans blanc et un défilement fluide des paroles synchronisées.';

  @override
  String get whyPermissionsUsed => 'Pourquoi les autorisations sont utilisées';

  @override
  String get whyPermissionsUsedDesc =>
      '• Accès stockage / médias : Requis pour découvrir, lire et indexer les pistes audio locales stockées sur votre appareil.\n• Notifications : Requis pour afficher les widgets de contrôle de lecture dans la barre d\'état et le tiroir système.';

  @override
  String get whyInternetUsed => 'Pourquoi Internet est utilisé';

  @override
  String get whyInternetUsedDesc =>
      '• Synchronisation des paroles dynamiques : Utilisé uniquement pour récupérer et télécharger en toute sécurité les paroles synchronisées (formats LRC) à partir de bases de données en ligne. Aucune donnée personnelle, paramètre ou fichier multimédia n\'est jamais téléversé ou partagé.';

  @override
  String get privacySafety => 'Confidentialité & Sécurité';

  @override
  String get privacySafetyDesc =>
      '100% privé et hors ligne en priorité. Vos morceaux, votre historique de lecture, vos favoris et votre configuration restent strictement dans une base de données Isar sécurisée sur votre appareil local. Nous ne suivons, ne collectons et ne partageons pas vos données d\'utilisation.';

  @override
  String get searchSongsHint => 'Rechercher des chansons';

  @override
  String get searchLibraryHint => 'Rechercher dans toute votre bibliothèque';

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String get topResult => 'Meilleur résultat';

  @override
  String get matchingLyrics => 'PAROLES CORRESPONDANTES';

  @override
  String get favorites => 'Favoris';

  @override
  String get recentPlayed => 'Écoutés récemment';

  @override
  String get categories => 'Catégories';

  @override
  String get noSongsFound => 'Aucune chanson trouvée';

  @override
  String get allSongs => 'Toutes les chansons';

  @override
  String get library => 'Bibliothèque';

  @override
  String get clearQueue => 'Effacer';

  @override
  String get queueIsEmpty => 'La file d\'attente est vide';

  @override
  String get aboutLooperPlayer => 'À PROPOS DE LOOPER PLAYER';

  @override
  String get systemPermissionChecklist => 'LISTE DE CONTRÔLE DES AUTORISATIONS';

  @override
  String get notificationAccess => 'ACCÈS AUX NOTIFICATIONS';

  @override
  String get musicAudioAccess => 'ACCÈS MUSIQUE & AUDIO';

  @override
  String get allFilesAccess => 'ACCÈS À TOUS LES FICHIERS (RECOMMANDÉ)';

  @override
  String get goStart => 'COMMENCER';

  @override
  String get selectSpecificFolder => 'SÉLECTIONNER UN DOSSIER SPÉCIPIQUE';

  @override
  String get grant => 'AUTORISER';

  @override
  String get granted => 'AUTORISÉ';

  @override
  String get deepStorageScanProgress => 'ANALYSE APPROFONDIE DU STOCKAGE...';

  @override
  String get noMusicDetected => 'AUCUNE MUSIQUE DÉTECTÉE';

  @override
  String get connectDevice => 'CONNECTER L\'APPAREIL';

  @override
  String get transferMusicFiles => 'TRANSFÉRER LES FICHIERS MUSICAUX';

  @override
  String get downloadAudioDirectly => 'TÉLÉCHARGER L\'AUDIO DIRECTEMENT';

  @override
  String get rescanStorage => 'ANALYSER À NOUVEAU LE STOCKAGE';

  @override
  String get backToMainView => 'RETOUR À LA VUE PRINCIPALE';

  @override
  String get storagePermissionRequired =>
      'Les autorisations de stockage sont requises pour analyser la mémoire de l\'appareil.';

  @override
  String get folders => 'Dossiers';

  @override
  String get genres => 'Genres';

  @override
  String get queue => 'File d\'attente';

  @override
  String get history => 'Historique';

  @override
  String get artist => 'Artiste';

  @override
  String get genre => 'Genre';

  @override
  String get noAlbumsFound => 'Aucun album trouvé';

  @override
  String get noArtistsFound => 'Aucun artiste trouvé';

  @override
  String get unknown => 'Inconnu';

  @override
  String get welcomeAboutDesc =>
      'Looper Player est un système Music-OS de nouvelle génération conçu pour une lecture audio hors ligne de qualité supérieure. Il intègre des paroles synchronisées en temps réel, une gestion avancée des sessions audio avec mise en pause automatique lors des appels, des thèmes d\'arrière-plan adaptatifs et la prise en charge de nombreux formats de fichiers. Optimisé pour économiser au maximum la batterie.';

  @override
  String get welcomeNotificationDesc =>
      'Requis pour afficher les commandes de lecture et les widgets de notification active dans votre barre système.';

  @override
  String get welcomeMusicAudioDesc =>
      'Requeri pour découvrir et lire les pistes audio standard stockées dans la mémoire de votre appareil.';

  @override
  String get welcomeAllFilesDesc =>
      'Fortement recommandé pour une analyse professionnelle afin de localiser des chansons dans des dossiers non standard (Téléchargements, Telegram, dossiers personnalisés).';

  @override
  String scanCompleteSongsDetected(int count) {
    return 'ANALYSE TERMINÉE : $count CHANSONS DÉTECTÉES !';
  }

  @override
  String get welcomeScanningFoldersDesc =>
      'Analyse de tous les dossiers et sous-dossiers pour trouver des fichiers audio.';

  @override
  String get welcomeNoSongsDesc =>
      'Nous n\'avons trouvé aucun fichier audio pris en charge (MP3, FLAC, WAV, M4A, OGG) dans la mémoire de votre appareil.';

  @override
  String get welcomeInstructionConnectDesc =>
      'Branchez votre téléphone ou appareil à un ordinateur personnel à l\'aide d\'un câble de données USB standard.';

  @override
  String get welcomeInstructionTransferDesc =>
      'Copiez vos fichiers musicaux (formats pris en charge : .mp3, .flac, .m4a, .wav) directement dans le dossier standard \'Music\' ou \'Download\' de votre appareil.';

  @override
  String get welcomeInstructionDownloadDesc =>
      'Alternativement, téléchargez les fichiers directement à l\'aide d\'un navigateur web ou d\'un autre utilitaire de téléchargement sur l\'appareil lui-même.';

  @override
  String get loadingMusicLibrary => 'CHARGEMENT DE LA BIBLIOTHÈQUE MUSICALE';

  @override
  String get loadingMusicLibraryDesc =>
      'Construction des index premium, configuration des écouteurs matériels et optimisation des caches visuels.';

  @override
  String get addToQueue => 'Ajouter à la file d\'attente';

  @override
  String get removeFromFavorites => 'Retirer des favoris';

  @override
  String get addToFavorites => 'Ajouter aux favoris';

  @override
  String get songDetails => 'Détails de la chanson';

  @override
  String get technicalInfoFrequency => 'Infos techniques & Fréquence';

  @override
  String get share => 'Partager';

  @override
  String get quickPicks => 'Sélections rapides';

  @override
  String get todayMixForYou => 'Mix du jour pour vous';

  @override
  String get play => 'Lire';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get pressBackExit => 'Appuyez à nouveau sur retour pour quitter';

  @override
  String get scanningStorage => 'ANALYSE DU STOCKAGE EN COURS...';

  @override
  String get readyToScan => 'Prêt à analyser';

  @override
  String get scanIndexLocalDesc => 'Analyser & indexer les fichiers locaux';

  @override
  String get scanForMusic => 'RECHERCHER DE LA MUSIQUE';

  @override
  String get selectCustomFolder => 'CHOISIR UN DOSSIER PERSONNALISÉ';

  @override
  String get scanningInBackground => 'Analyse en arrière-plan...';

  @override
  String get loadingPhase1 => 'INTERROGATION DE L\'AUDIO...';

  @override
  String get loadingPhase2 => 'RAFRAÎCHISSEMENT DU MOTEUR...';

  @override
  String get loadingPhase3 => 'EXTRACTION DES DONNÉES ACOUSTIQUES...';

  @override
  String get loadingPhase4 => 'OPTIMISATION DE LA MÉMOIRE...';

  @override
  String get scanningStorageDesc =>
      'Parcours des dossiers pour découvrir des morceaux audio. Veuillez patienter...';

  @override
  String get emptyLibraryDesc =>
      'We couldn\'t find any supported music files in your library. Add folders or run a search scan.';

  @override
  String get home => 'Accueil';

  @override
  String get toggleFavorite => 'Ajouter/Retirer des favoris';

  @override
  String get renameFile => 'Renommer le fichier';

  @override
  String get shareFile => 'Partager le fichier';

  @override
  String get deleteFile => 'Supprimer le fichier';

  @override
  String get songDetailsAndFrequency => 'Détails & Fréquence de la chanson';

  @override
  String get metadataDetails => 'Détails des métadonnées';

  @override
  String get fileInformation => 'Informations sur le fichier';

  @override
  String get showLess => 'Afficher moins';

  @override
  String get showMore => 'Afficher plus';

  @override
  String get acousticSpectralAnalysis => 'ANALYSE ACOUSTIQUE & SPECTRALE';

  @override
  String get cancel => 'Annuler';

  @override
  String get renameSong => 'Renommer la chanson';

  @override
  String get newTitle => 'Nouveau titre';

  @override
  String get rename => 'Renommer';

  @override
  String get deleteSong => 'Supprimer la chanson';

  @override
  String get deleteSongConfirm =>
      'Êtes-vous sûr de vouloir supprimer cette chanson du disque ?';

  @override
  String get delete => 'Supprimer';
}
