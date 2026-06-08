// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get about => 'Acerca de';

  @override
  String get aboutAndMaintainers => 'Acerca de y desarrolladores';

  @override
  String get aboutApp => 'Acerca de la aplicación';

  @override
  String get aboutLooperPlayer => 'ACERCA DE LOOPER PLAYER';

  @override
  String get accentColor => 'Color de acento';

  @override
  String get accentColorDesc =>
      'Seleccionar manualmente el color de acento del tema';

  @override
  String get acousticSpectralAnalysis => 'ANÁLISIS ACÚSTICO Y ESPECTRAL';

  @override
  String get activeCallCannotPlay =>
      'Reproducción bloqueada: No se puede reproducir música durante una llamada activa';

  @override
  String get adaptColorsArtwork =>
      'Adaptar colores de la aplicación al arte del álbum';

  @override
  String addedTo(String name) {
    return 'Añadido a $name';
  }

  @override
  String get addedToQueue => 'Añadido a la cola';

  @override
  String get addFolder => 'Añadir carpeta';

  @override
  String get addToFavorites => 'Añadir a favoritos';

  @override
  String get addToPlaylists => 'Añadir a listas de reproducción';

  @override
  String get addToQueue => 'Añadir a la cola';

  @override
  String get album => 'Álbum';

  @override
  String get albums => 'Álbumes';

  @override
  String get albumsRowDesc => 'Estante horizontal de álbumes';

  @override
  String get allFilesAccess => 'ACCESO A TODOS LOS ARCHIVOS (RECOMENDADO)';

  @override
  String get allSongs => 'Todas las canciones';

  @override
  String get appDetailsCreator =>
      'Detalles del creador, la aplicación y el equipo de diseño';

  @override
  String get appearance => 'Apariencia';

  @override
  String get appInfoPrivacy => 'INFORMACIÓN Y PRIVACIDAD';

  @override
  String get appTitle => 'Looper Player';

  @override
  String get artist => 'Artista';

  @override
  String get artists => 'Artistas';

  @override
  String get artistsRowDesc => 'Estante horizontal de artistas';

  @override
  String get ascending => 'Ascendente';

  @override
  String get audioCrossfade => 'Fundido cruzado de audio';

  @override
  String get audioCrossfadeDesc =>
      'Superpone las pistas suavemente al cambiar de canción';

  @override
  String get audioFocusDenied =>
      'Playback paused: Audio focus denied by system';

  @override
  String get audioPlayback => 'Audio y reproducción';

  @override
  String get audioPlaybackDesc =>
      'Ajustes de fundido cruzado, intervalo de silencio y atenuación';

  @override
  String get autoCrossfadeDuration => 'Duración del fundido cruzado automático';

  @override
  String get autoCrossfadeDurationDesc =>
      'Duración de la superposición al cambiar automáticamente';

  @override
  String get backToMainView => 'VOLVER A LA VISTA PRINCIPAL';

  @override
  String get cancel => 'Cancelar';

  @override
  String get categories => 'Categorías';

  @override
  String get center => 'Centro';

  @override
  String get clear => 'Limpiar';

  @override
  String get clearQueue => 'Limpiar';

  @override
  String get connectDevice => 'CONECTAR DISPOSITIVO';

  @override
  String get corePurpose => 'Propósito principal';

  @override
  String get corePurposeDesc =>
      'Looper Player es un reproductor de audio de alta fidelidad, primero sin conexión, diseñado para entusiastas de la música que desean un control absoluto sobre su biblioteca local, reproducción sin silencios y desplazamiento fluido de letras sincronizadas.';

  @override
  String get create => 'Crear';

  @override
  String get createPlaylist => 'Crear lista de reproducción';

  @override
  String get creatorAndMaintainer => 'Creador y desarrollador';

  @override
  String get customAccentColor => 'Color de acento personalizado';

  @override
  String get customizeColorsTheme =>
      'Personalizar colores de la aplicación, el tema y fondos de letras';

  @override
  String get dateAdded => 'Fecha de adición';

  @override
  String get deepStorageScanProgress => 'ESCANEO PROFUNDO EN PROGRESO...';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteFile => 'Eliminar archivo';

  @override
  String get deletePlaylist => 'Eliminar lista de reproducción';

  @override
  String deletePlaylistConfirm(String name) {
    return '¿Estás seguro de que quieres eliminar \"$name\"?';
  }

  @override
  String get deleteSong => 'Eliminar canción';

  @override
  String get deleteSongConfirm =>
      '¿Estás seguro de que quieres eliminar esta canción del disco?';

  @override
  String get descending => 'Descendente';

  @override
  String get designerAndMaintainer => 'Diseñador y desarrollador';

  @override
  String get disableBlurEffects => 'Desactivar efectos de desenfoque';

  @override
  String get disableSquigglyProgressBar =>
      'Desactivar animación de barra de progreso ondulada';

  @override
  String get downloadAudioDirectly => 'DESCARGAR AUDIO DIRECTAMENTE';

  @override
  String get downloadingLyricsOffline =>
      'Descargando letras para uso sin conexión...';

  @override
  String get downloadMissingArtwork => 'Descargar arte faltante';

  @override
  String get downloadMissingArtworkDesc =>
      'Descarga automáticamente arte de portada de alta resolución de iTunes';

  @override
  String get duration => 'Duración';

  @override
  String get dynamicAccentColor => 'Color de acento dinámico';

  @override
  String get dynamicAccentColorDesc =>
      'Actualiza dinámicamente solo el color de acento según la carátula';

  @override
  String get dynamicBgOnlyLyrics => 'Fondo dinámico solo para letras';

  @override
  String get dynamicColorActiveLyrics => 'Dynamic Color Active Line';

  @override
  String get dynamicColorActiveLyricsDesc =>
      'Use extracted artwork colors for the currently playing lyrics line';

  @override
  String get dynamicLyricsBg => 'Fondo dinámico de letras';

  @override
  String get dynamicLyricsBgDesc =>
      'Aplicar desenfoque de portada al fondo de la pantalla de letras';

  @override
  String get dynamicTheming => 'Temas dinámicos';

  @override
  String get emptyLibraryDesc =>
      'No pudimos encontrar archivos de música compatibles en su biblioteca. Añada carpetas o realice un escaneo.';

  @override
  String get enableNetworkLyricsArt =>
      'Permitir uso de red para letras en línea y arte de artista';

  @override
  String get enablePlayerGradient => 'Music Screen Gradient';

  @override
  String get enablePlayerGradientDesc =>
      'Enable the radial accent gradient background on the now playing screen';

  @override
  String get fadeDuration => 'Duración del desvanecimiento';

  @override
  String get fadeDurationDesc =>
      'Duración del efecto de desvanecimiento al reproducir/pausar/detener';

  @override
  String get fadeOnSeek => 'Desvanecimiento al buscar';

  @override
  String get fadeOnSeekDesc =>
      'Desvanece suavemente el volumen al buscar en la pista';

  @override
  String get fadePlayPauseStop =>
      'Desvanecimiento al reproducir/pausar/detener';

  @override
  String get fadePlayPauseStopDesc =>
      'Desvanece suavemente el volumen al reproducir, pausar o detener';

  @override
  String get favorites => 'Favoritos';

  @override
  String get fileInformation => 'Información del archivo';

  @override
  String get flatProgressBar => 'Barra de progreso plana';

  @override
  String get folders => 'Carpetas';

  @override
  String get genre => 'Género';

  @override
  String get genres => 'Géneros';

  @override
  String get genresRowDesc => 'Estante horizontal de géneros musicales';

  @override
  String get goStart => 'COMENZAR';

  @override
  String get grant => 'CONCEDER';

  @override
  String get granted => 'CONCEDIDO';

  @override
  String get history => 'Historial';

  @override
  String get home => 'Inicio';

  @override
  String get homeDarkness => 'Home Screen Darkness';

  @override
  String get homeDarknessDesc =>
      'Adjust background overlay darkness for the Home screen';

  @override
  String get homeDashboardSettings => 'Ajustes del panel de inicio';

  @override
  String get homeDashboardSettingsDesc =>
      'Personaliza las filas horizontales en tu pantalla de inicio';

  @override
  String get internetMode => 'Modo Internet';

  @override
  String get keepBackgroundGradient => 'Mantener gradiente de fondo';

  @override
  String get keepBackgroundGradientDesc =>
      'Mantener el gradiente de fondo en todas las pantallas de la aplicación';

  @override
  String get language => 'Idioma';

  @override
  String get left => 'Izquierda';

  @override
  String get library => 'Biblioteca';

  @override
  String get libraryDarkness => 'Library Screen Darkness';

  @override
  String get libraryDarknessDesc =>
      'Adjust background overlay darkness for the Library screen';

  @override
  String get libraryFoldersSync =>
      'Carpetas, reescaneos, restablecimiento de base de datos y sincronización sin conexión';

  @override
  String get librarySettings => 'Configuración de la biblioteca';

  @override
  String get loadingMusicLibrary => 'CARGANDO BIBLIOTECA DE MÚSICA';

  @override
  String get loadingMusicLibraryDesc =>
      'Construyendo índices premium, configurando controladores de hardware y optimizando cachés visuales.';

  @override
  String get loadingPhase1 => 'INTERROGANDO ALMACENAMIENTO...';

  @override
  String get loadingPhase2 => 'REGENERANDO MOTOR DE MÚSICA...';

  @override
  String get loadingPhase3 => 'EXTRAYENDO INFORMACIÓN ACÚSTICA...';

  @override
  String get loadingPhase4 => 'OPTIMIZANDO MEMORIA DE REPRODUCCIÓN...';

  @override
  String get lyrics => 'Letras';

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
  String get lyricsProvider => 'Proveedor de letras';

  @override
  String get lyricsProviderDesc =>
      'Letras en línea obtenidas de lrclib.net (LRCLIB)';

  @override
  String get maintainersAndDesigners => 'Desarrolladores y diseñadores';

  @override
  String get manageAudioFocus => 'Gestionar el enfoque de audio';

  @override
  String get manageAudioFocusDesc =>
      'Solicita y responde a los cambios de enfoque de audio del sistema';

  @override
  String get manageAudioFocusTitle => 'Gestionar el enfoque de audio';

  @override
  String get manageLanguageAndFocus =>
      'Gestionar preferencias de idioma y enfoque de llamadas';

  @override
  String get manualCrossfadeDuration => 'Duración del fundido cruzado manual';

  @override
  String get manualCrossfadeDurationDesc =>
      'Duración de la superposición al cambiar manualmente';

  @override
  String get matchingLyrics => 'LETRAS COINCIDENTES';

  @override
  String get metadataDetails => 'Detalles de metadatos';

  @override
  String get mostPlayed => 'Más reproducido';

  @override
  String get musicAudioAccess => 'ACCESO A MÚSICA Y AUDIO';

  @override
  String get musicDarkness => 'Music Player Darkness';

  @override
  String get musicDarknessDesc =>
      'Adjust background overlay darkness for the Music Player screen';

  @override
  String get musicLibrary => 'Biblioteca de música';

  @override
  String get muteOrPauseCalls =>
      'Silenciar o pausar durante llamadas y otra actividad de audio';

  @override
  String get newPlaylist => 'Nueva lista de reproducción';

  @override
  String get newTitle => 'Nuevo título';

  @override
  String get noAlbumsFound => 'No se encontraron álbumes';

  @override
  String get noArtistsFound => 'No se encontraron artistas';

  @override
  String get noFavoritesYet => 'Aún no hay favoritos';

  @override
  String get noHistoryYet => 'Sin historial';

  @override
  String get noLyrics => 'No se encontraron letras';

  @override
  String get noMusicDetected => 'NO SE DETECTÓ MÚSICA';

  @override
  String get noPlaylistsCreated =>
      'Aún no se han creado listas de reproducción.';

  @override
  String get noPlaylistsYet => 'No hay listas de reproducción';

  @override
  String get noResultsFound => 'No se encontraron resultados';

  @override
  String get noSongsFound => 'No se encontraron canciones';

  @override
  String get notificationAccess => 'ACCESO A NOTIFICACIONES';

  @override
  String get nowPlaying => 'Reproduciendo ahora';

  @override
  String get performanceOptimizerDashboard =>
      'Panel del optimizador de rendimiento';

  @override
  String get performanceOptimizerDashboardDesc =>
      'Muestra una superposición con estadísticas del optimizador en tiempo real';

  @override
  String get permanentFocusChangePause =>
      'Pausa por pérdida permanente de enfoque';

  @override
  String get permanentFocusChangePauseDesc =>
      'Pausa automáticamente la reproducción al perder el enfoque de audio permanentemente';

  @override
  String get plainTimestamps => 'Marcas de tiempo simples';

  @override
  String get play => 'Reproducir';

  @override
  String get playAll => 'Reproducir todo';

  @override
  String get playbackAudio => 'Reproducción e idioma';

  @override
  String get playlists => 'Listas de reproducción';

  @override
  String get playNext => 'Reproducir a continuación';

  @override
  String get playQueue => 'Cola de reproducción';

  @override
  String get pressBackExit => 'Presione atrás de nuevo para salir';

  @override
  String get privacySafety => 'Privacidad y seguridad';

  @override
  String get privacySafetyDesc =>
      '100% privado y sin conexión por defecto. Sus canciones, historial de reproducción, favoritos y configuración permanecen estrictamente dentro de una base de datos segura Isar en su dispositivo local. No recopilamos, rastreamos ni compartimos sus datos de uso.';

  @override
  String get pureBlackOled => 'Negro puro (OLED)';

  @override
  String get pureBlackOledDesc => 'Usar negro absoluto para los fondos';

  @override
  String get queue => 'Cola';

  @override
  String get queueIsEmpty => 'La cola está vacía';

  @override
  String get quickPicks => 'Selecciones rápidas';

  @override
  String get quickPicksRowDesc => 'Tu cuadrícula de canciones más reproducidas';

  @override
  String get readyToScan => 'Listo para escanear';

  @override
  String get recentlyAddedSongsRowDesc =>
      'Una lista de tus últimas importaciones';

  @override
  String get recentlyPlayed => 'Reproducido recientemente';

  @override
  String get recentPlayed => 'Reproducidas recientemente';

  @override
  String get removedFromPlaylist => 'Eliminado de la lista de reproducción';

  @override
  String get removeFromFavorites => 'Eliminar de favoritos';

  @override
  String get removeFromPlaylist => 'Eliminar de la lista de reproducción';

  @override
  String get rename => 'Renombrar';

  @override
  String get renameFile => 'Renombrar archivo';

  @override
  String get renamePlaylist => 'Renombrar lista de reproducción';

  @override
  String get renameSong => 'Renombrar canción';

  @override
  String get reorderDashboardSections => 'Reordenar secciones del panel';

  @override
  String get reorderDashboardSectionsDesc =>
      'Arrastra y suelta para establecer el orden preferido';

  @override
  String get rescanLibrary => 'Reescanear biblioteca';

  @override
  String get rescanStorage => 'REESCANEAR ALMACENAMIENTO';

  @override
  String get reset => 'Restablecer';

  @override
  String get resetLibrary => 'Restablecer y reescanear';

  @override
  String get resetLibraryConfirm =>
      'Esto borrará todas las canciones, álbumes y artistas y realizará un escaneo completo de tus carpetas.';

  @override
  String get resetLibraryConfirmNew =>
      'Esto eliminará todas las canciones de tu biblioteca. Tus archivos de música no se borrarán.';

  @override
  String get resetLibraryDesc =>
      'Elimina todas las canciones de tu biblioteca indexada';

  @override
  String get resumeAfterCallDesc =>
      'Reanuda la reproducción automáticamente al colgar (si se pausó por la llamada)';

  @override
  String get resumeAfterCallTitle => 'Reanudar después de una llamada';

  @override
  String get resumeOnStartDesc =>
      'Reanuda la reproducción automáticamente cuando se inicia Looper Player';

  @override
  String get resumeOnStartTitle => 'Reanudar al iniciar';

  @override
  String get right => 'Derecha';

  @override
  String scanCompleteSongsDetected(int count) {
    return '¡ESCANEO COMPLETADO: $count CANCIONES DETECTADAS!';
  }

  @override
  String get scanForMusic => 'ESCANEAR MÚSICA';

  @override
  String get scanIndexLocalDesc => 'Escanear e indexar archivos locales';

  @override
  String get scanLibrary => 'Escanear biblioteca';

  @override
  String get scanningInBackground => 'Escaneando en segundo plano...';

  @override
  String get scanningLibrary => 'Escaneando biblioteca...';

  @override
  String get scanningStorage => 'ESCANEANDO ALMACENAMIENTO...';

  @override
  String get scanningStorageDesc =>
      'Explorando directorios para descubrir pistas de audio. Por favor, espere...';

  @override
  String get search => 'Buscar';

  @override
  String get searchLibraryHint => 'Buscar en toda la biblioteca';

  @override
  String get searchSongsHint => 'Buscar canciones';

  @override
  String get seekFadeDuration => 'Duración del desvanecimiento al buscar';

  @override
  String get seekFadeDurationDesc =>
      'Duración del efecto de desvanecimiento al buscar';

  @override
  String get selectAppLanguage => 'Seleccionar idioma de la aplicación';

  @override
  String get selectCustomColor => 'Seleccionar color personalizado';

  @override
  String get selectCustomFolder => 'SELECCIONAR CARPETA PERSONALIZADA';

  @override
  String get selectFolderIndex =>
      'Seleccionar carpeta para indexar archivos de música';

  @override
  String get selectSpecificFolder => 'SELECCIONAR CARPETA ESPECÍFICA';

  @override
  String get settings => 'Ajustes';

  @override
  String get share => 'Compartir';

  @override
  String get shareFile => 'Compartir archivo';

  @override
  String get showAlbumsRow => 'Mostrar fila de álbumes';

  @override
  String get showAlbumsRowDesc =>
      'Muestra una lista horizontal de álbumes en tu pantalla de inicio';

  @override
  String get showArtistsRow => 'Mostrar fila de artistas';

  @override
  String get showArtistsRowDesc =>
      'Muestra una lista horizontal de artistas en tu pantalla de inicio';

  @override
  String get showGenresRow => 'Mostrar fila de géneros';

  @override
  String get showGenresRowDesc =>
      'Muestra una lista horizontal de géneros en tu pantalla de inicio';

  @override
  String get showLess => 'Mostrar menos';

  @override
  String get showMore => 'Mostrar más';

  @override
  String get showQualityBadge => 'Show Quality Badge';

  @override
  String get showQualityBadgeDesc =>
      'Display audio quality information badge on the now playing screen';

  @override
  String get silenceBetweenTracksDesc =>
      'Añade un intervalo de silencio entre pistas (0 ms para reproducción sin pausas)';

  @override
  String get silenceBetweenTracksTitle => 'Silencio entre pistas';

  @override
  String get songDeletedDbOnly =>
      'Canción eliminada de la biblioteca (archivo físico de solo lectura)';

  @override
  String get songDeletedSuccess => 'Canción eliminada con éxito';

  @override
  String get songDeleteFailed => 'Error al eliminar la canción';

  @override
  String get songDetails => 'Detalles de la canción';

  @override
  String get songDetailsAndFrequency => 'Detalles y frecuencia de la canción';

  @override
  String get songRenamedDbOnly =>
      'Canción renombrada en la biblioteca de la aplicación (archivo físico de solo lectura)';

  @override
  String get songRenamedSuccess => 'Canción renombrada con éxito';

  @override
  String get songRenameFailed => 'Error al renombrar la canción';

  @override
  String get songs => 'Canciones';

  @override
  String get songsDarkness => 'Songs Screen Darkness';

  @override
  String get songsDarknessDesc =>
      'Adjust background overlay darkness for the Songs screen';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortOrder => 'Orden de clasificación';

  @override
  String get sourceCode => 'Código fuente';

  @override
  String get stopServiceOnAppDismissal =>
      'Detener servicio al cerrar la aplicación';

  @override
  String get stopServiceOnAppDismissalDesc =>
      'Detiene el servicio en segundo plano y cierra la aplicación al descartarla';

  @override
  String get storagePermissionRequired =>
      'Se requieren permisos de almacenamiento para escanear el dispositivo.';

  @override
  String get syncLyricsOffline => 'Sincronizar letras (sin conexión)';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get systemPermissionChecklist => 'LISTA DE PERMISOS DEL SISTEMA';

  @override
  String get technicalInfoFrequency => 'Info técnica y frecuencia';

  @override
  String get theme => 'Tema';

  @override
  String get title => 'Título';

  @override
  String get todayMixForYou => 'Mezcla de hoy para ti';

  @override
  String get toggleFavorite => 'Alternar favorito';

  @override
  String get topResult => 'Resultado principal';

  @override
  String get transferMusicFiles => 'TRANSFERIR ARCHIVOS DE MÚSICA';

  @override
  String get turnOffBlursOptimize =>
      'Desactivar desenfoques pesados para optimizar el rendimiento';

  @override
  String get unknown => 'Desconocido';

  @override
  String get unknownAlbum => 'Álbum desconocido';

  @override
  String get unknownArtist => 'Artista desconocido';

  @override
  String get updateLibraryIndexing =>
      'Actualizar la indexación de archivos de la biblioteca';

  @override
  String get useAbsoluteBlackBg => 'Usar negro absoluto para los fondos';

  @override
  String get useStaticTextTimestamps =>
      'Usar texto estático en lugar de animación para la duración del progreso';

  @override
  String get verticalMotionEffectPlayer =>
      'Efecto de movimiento vertical del reproductor';

  @override
  String get verticalMotionEffectPlayerDesc =>
      'Desliza hacia abajo en el reproductor expandido para cerrarlo';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get visitOfficialRepository =>
      'Visita el repositorio oficial en GitHub';

  @override
  String get welcomeAboutDesc =>
      'Looper Player es un sistema Music-OS de última generación diseñado para reproducción de música de alta fidelidad sin conexión. Cuenta con letras dinámicas en tiempo real, administración avanzada de sesiones de audio con silenciamiento automático de llamadas, fondos adaptables y soporte para múltiples formatos. Optimizado para el máximo ahorro de batería.';

  @override
  String get welcomeAllFilesDesc =>
      'Muy recomendado para escaneo profesional y localización de canciones en directorios no estándar (Descargas, Telegram, carpetas personalizadas).';

  @override
  String get welcomeInstructionConnectDesc =>
      'Conecte su teléfono o dispositivo a una computadora usando un cable de datos USB estándar.';

  @override
  String get welcomeInstructionDownloadDesc =>
      'Alternativamente, descargue archivos directamente usando un navegador web u otra utilidad en el propio dispositivo.';

  @override
  String get welcomeInstructionTransferDesc =>
      'Copie sus archivos de música sin conexión (compatible con .mp3, .flac, .m4a, .wav) directamente en la carpeta estándar \'Music\' o \'Download\' de su dispositivo.';

  @override
  String get welcomeMusicAudioDesc =>
      'Requerido para descubrir y reproducir pistas de audio estándar en la memoria de su dispositivo.';

  @override
  String get welcomeNoSongsDesc =>
      'No pudimos encontrar ningún archivo de audio compatible (MP3, FLAC, WAV, M4A, OGG) en el almacenamiento de su dispositivo.';

  @override
  String get welcomeNotificationDesc =>
      'Requerido para mostrar controles de reproducción y widgets de notificación en la barra del sistema.';

  @override
  String get welcomeScanningFoldersDesc =>
      'Escaneando todas las carpetas y subcarpetas en busca de archivos de audio.';

  @override
  String get whyInternetUsed => 'Por qué se usa Internet';

  @override
  String get whyInternetUsedDesc =>
      '• Sincronización dinámica de letras: Se usa únicamente para buscar y descargar de forma segura letras sincronizadas (formatos LRC) de bases de datos en línea. Ningún dato personal, ajuste o archivo multimedia se sube o comparte jamás.';

  @override
  String get whyPermissionsUsed => 'Por qué se usan los permisos';

  @override
  String get whyPermissionsUsedDesc =>
      '• Acceso a almacenamiento / multimedia: Requerido para descubrir, leer e indexar pistas de audio locales en su dispositivo.\n• Notificaciones: Requerido para mostrar widgets de control de reproducción en la barra de estado y panel del sistema.';

  @override
  String get willPlayNext => 'Se reproducirá a continuación';

  @override
  String get year => 'Año';
}
