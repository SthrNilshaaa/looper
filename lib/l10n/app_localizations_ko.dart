// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get about => '소개';

  @override
  String get aboutAndMaintainers => '정보 및 유지관리자';

  @override
  String get aboutApp => '앱 정보';

  @override
  String get aboutLooperPlayer => '루퍼 플레이어 소개';

  @override
  String get accentColor => '악센트 색상';

  @override
  String get accentColorDesc => '테마 테두리 및 액센트 색상 수동 선택';

  @override
  String get acousticSpectralAnalysis => '음향 및 스펙트럼 분석';

  @override
  String get activeCallCannotPlay => '재생 차단됨: 활성 통화 중에는 음악을 재생할 수 없습니다';

  @override
  String get adaptColorsArtwork => '앱 색상을 앨범 아트워크에 맞게 조정';

  @override
  String addedTo(String name) {
    return '$name에 추가됨';
  }

  @override
  String get addedToQueue => '대기열에 추가됨';

  @override
  String get addFolder => '폴더 추가';

  @override
  String get addToFavorites => '즐겨찾기에 추가';

  @override
  String get addToPlaylists => '재생목록에 추가';

  @override
  String get addToQueue => '대기열에 추가';

  @override
  String get album => '앨범';

  @override
  String get albums => '앨범';

  @override
  String get albumsRowDesc => '앨범의 수평 선반';

  @override
  String get allFilesAccess => '모든 파일 액세스(권장)';

  @override
  String get allSongs => '모든 노래';

  @override
  String get appDetailsCreator => '지원서 세부정보, 창작자, 디자인팀 정보';

  @override
  String get appearance => '테마';

  @override
  String get appInfoPrivacy => '앱 정보 및 개인정보 보호';

  @override
  String get appTitle => '루퍼 플레이어';

  @override
  String get artist => '아티스트';

  @override
  String get artists => '아티스트';

  @override
  String get artistsRowDesc => '예술가의 수평 선반';

  @override
  String get ascending => '오름차순';

  @override
  String get audioCrossfade => '오디오 크로스페이드';

  @override
  String get audioCrossfadeDesc => '곡이 바뀔 때 트랙을 부드럽게 겹칩니다';

  @override
  String get audioFocusDenied => '재생 일시중지됨: 시스템에서 오디오 포커스를 거부했습니다.';

  @override
  String get audioPlayback => '오디오 및 재생';

  @override
  String get audioPlaybackDesc => '크로스페이드, 무음 간격 및 페이드 설정';

  @override
  String get autoCrossfadeDuration => '자동 크로스페이드 시간';

  @override
  String get autoCrossfadeDurationDesc => '자동 전환 시 겹치는 시간';

  @override
  String get backToMainView => '기본 보기로 돌아가기';

  @override
  String get cancel => '취소';

  @override
  String get categories => '카테고리';

  @override
  String get center => '가운데';

  @override
  String get clear => '지우기';

  @override
  String get clearQueue => '지우기';

  @override
  String get connectDevice => '장치 연결';

  @override
  String get corePurpose => '핵심 목적';

  @override
  String get corePurposeDesc =>
      'Looper Player는 로컬 라이브러리에 대한 완벽한 제어, 끊김 없는 재생, 유연하고 동기화된 가사 스크롤을 원하는 음악 애호가를 위해 설계된 오프라인 최초의 고성능 오디오 플레이어입니다.';

  @override
  String get create => '만들기';

  @override
  String get createPlaylist => '재생목록 만들기';

  @override
  String get creatorAndMaintainer => '생성자 및 유지관리자';

  @override
  String get customAccentColor => '사용자 정의 강조 색상';

  @override
  String get customizeColorsTheme => '앱 색상, 테마, 가사 배경을 맞춤설정하세요.';

  @override
  String get dateAdded => '추가된 날짜';

  @override
  String get deepStorageScanProgress => '심층 저장소 검사 진행 중...';

  @override
  String get delete => '삭제';

  @override
  String get deleteFile => '파일 삭제';

  @override
  String get deletePlaylist => '재생목록 삭제';

  @override
  String deletePlaylistConfirm(String name) {
    return '\"$name\" 재생목록을 삭제하시겠습니까?';
  }

  @override
  String get deleteSong => '노래 삭제';

  @override
  String get deleteSongConfirm => '정말로 이 노래를 디스크에서 삭제하시겠습니까?';

  @override
  String get descending => '내림차순';

  @override
  String get designerAndMaintainer => '디자이너 및 유지관리자';

  @override
  String get disableBlurEffects => '흐림 효과 비활성화';

  @override
  String get disableSquigglyProgressBar => '구불구불한 물결 진행률 표시줄 애니메이션 비활성화';

  @override
  String get downloadAudioDirectly => '오디오를 직접 다운로드하세요';

  @override
  String get downloadingLyricsOffline => '오프라인 사용을 위해 가사 다운로드 중...';

  @override
  String get downloadMissingArtwork => '누락된 작품 다운로드';

  @override
  String get downloadMissingArtworkDesc =>
      'iTunes에서 노래의 고해상도 표지 아트워크를 자동으로 다운로드합니다.';

  @override
  String get duration => '재생 시간';

  @override
  String get dynamicAccentColor => '동적 액센트 색상';

  @override
  String get dynamicAccentColorDesc => '앨범 아트에서 액센트 색상만 동적으로 업데이트';

  @override
  String get dynamicBgOnlyLyrics => '가사 전용 동적 배경';

  @override
  String get dynamicColorActiveLyrics => '다이나믹 컬러 액티브 라인';

  @override
  String get dynamicColorActiveLyricsDesc => '현재 재생중인 가사라인에 추출된 아트워크 색상을 사용';

  @override
  String get dynamicLyricsBg => '다이나믹 가사 BG';

  @override
  String get dynamicLyricsBgDesc => '가사 화면에 앨범 아트 블러 적용';

  @override
  String get dynamicTheming => '동적 테마';

  @override
  String get emptyLibraryDesc =>
      '라이브러리에서 지원되는 음악 파일을 찾을 수 없습니다. 폴더를 추가하거나 검색 검사를 실행하세요.';

  @override
  String get enableNetworkLyricsArt => '온라인 가사 및 아티스트 아트에 대한 네트워크 사용 활성화';

  @override
  String get enablePlayerGradient => '음악 화면 그라데이션';

  @override
  String get enablePlayerGradientDesc =>
      '지금 재생 중인 화면에서 방사형 액센트 그라데이션 배경을 활성화합니다.';

  @override
  String get fadeDuration => '페이드 시간';

  @override
  String get fadeDurationDesc => '재생/일시정지/정지 페이드 효과 시간';

  @override
  String get fadeOnSeek => '탐색 시 페이드';

  @override
  String get fadeOnSeekDesc => '곡 탐색 시 음량을 부드럽게 페이드아웃/인합니다';

  @override
  String get fadePlayPauseStop => '재생/일시정지/정지 시 페이드';

  @override
  String get fadePlayPauseStopDesc => '재생, 일시정지, 정지 시 음량을 부드럽게 페이드인/아웃합니다';

  @override
  String get favorites => '즐겨찾기';

  @override
  String get fileInformation => '파일 정보';

  @override
  String get flatProgressBar => '플랫 진행률 표시줄';

  @override
  String get folders => '폴더';

  @override
  String get genre => '장르';

  @override
  String get genres => '장르';

  @override
  String get genresRowDesc => '음악 장르의 수평 선반';

  @override
  String get goStart => '시작하세요';

  @override
  String get grant => '그랜트';

  @override
  String get granted => '승인됨';

  @override
  String get history => '역사';

  @override
  String get home => '홈';

  @override
  String get homeDarkness => '홈 화면의 어둠';

  @override
  String get homeDarknessDesc => '홈 화면의 배경 오버레이 명암 조정';

  @override
  String get homeDashboardSettings => '홈 대시보드 설정';

  @override
  String get homeDashboardSettingsDesc => '홈 화면의 가로 행을 맞춤설정하세요.';

  @override
  String get internetMode => '인터넷 모드';

  @override
  String get keepBackgroundGradient => '배경 그라데이션 유지';

  @override
  String get keepBackgroundGradientDesc => '모든 애플리케이션 화면에서 배경 그라데이션 유지';

  @override
  String get language => '언어';

  @override
  String get left => '왼쪽';

  @override
  String get library => '도서관';

  @override
  String get libraryDarkness => '라이브러리 화면 어두움';

  @override
  String get libraryDarknessDesc => '라이브러리 화면의 배경 오버레이 명암 조정';

  @override
  String get libraryFoldersSync => '폴더, 재검색 트리거, 데이터베이스 재설정 및 오프라인 동기화';

  @override
  String get librarySettings => '라이브러리 설정';

  @override
  String get loadingMusicLibrary => '음악 라이브러리 로드 중';

  @override
  String get loadingMusicLibraryDesc =>
      '프리미엄 인덱스 구축, 하드웨어 리스너 설정 및 시각적 캐시 최적화.';

  @override
  String get loadingPhase1 => '오디오 저장 장치를 조사하는 중...';

  @override
  String get loadingPhase2 => '상쾌한 음악 엔진...';

  @override
  String get loadingPhase3 => '음향 데이터 추출 중...';

  @override
  String get loadingPhase4 => '재생 메모리 최적화 중...';

  @override
  String get lyrics => '가사';

  @override
  String get lyricsAlignment => '가사 정렬';

  @override
  String get lyricsAlignmentDesc => '가사 스크롤을 위한 텍스트 위치 정렬';

  @override
  String get lyricsDarkness => '가사 화면 어둠';

  @override
  String get lyricsDarknessDesc => '가사 화면의 배경 오버레이 농도 조정';

  @override
  String get lyricsProvider => '가사 제공자';

  @override
  String get lyricsProviderDesc => 'lrclib.net (LRCLIB)에서 온라인 가사를 가져옵니다';

  @override
  String get maintainersAndDesigners => '유지 관리자 및 디자이너';

  @override
  String get manageAudioFocus => '오디오 포커스 관리';

  @override
  String get manageAudioFocusDesc => '시스템 오디오 포커스 변경을 요청하고 이에 대응합니다';

  @override
  String get manageAudioFocusTitle => '오디오 포커스 관리';

  @override
  String get manageLanguageAndFocus => '언어 기본 설정 및 발신자 초점 상태 관리';

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
  String get manualCrossfadeDuration => '수동 크로스페이드 시간';

  @override
  String get manualCrossfadeDurationDesc => '수동 스킵 시 겹치는 시간';

  @override
  String get matchingLyrics => '일치하는 가사';

  @override
  String get metadataDetails => '메타데이터 세부정보';

  @override
  String get mostPlayed => '가장 많이 재생됨';

  @override
  String get musicAudioAccess => '음악 및 오디오 액세스';

  @override
  String get musicDarkness => '뮤직 플레이어 어둠';

  @override
  String get musicDarknessDesc => '뮤직 플레이어 화면의 배경 오버레이 어둡게 조정';

  @override
  String get musicLibrary => '음악 라이브러리';

  @override
  String get muteOrPauseCalls => '통화 및 기타 오디오 활동 중 음소거 또는 일시 중지';

  @override
  String get newPlaylist => '새 재생목록';

  @override
  String get newTitle => '새 제목';

  @override
  String get noAlbumsFound => '앨범을 찾을 수 없습니다.';

  @override
  String get noArtistsFound => '아티스트를 찾을 수 없습니다.';

  @override
  String get noFavoritesYet => '즐겨찾기 없음';

  @override
  String get noHistoryYet => '기록 없음';

  @override
  String get noLyrics => '가사를 찾을 수 없습니다';

  @override
  String get noMusicDetected => '감지된 음악이 없습니다.';

  @override
  String get noPlaylistsCreated => '생성된 재생목록이 없습니다.';

  @override
  String get noPlaylistsYet => '재생목록 없음';

  @override
  String get noResultsFound => '검색결과가 없습니다';

  @override
  String get noSongsFound => '노래를 찾을 수 없습니다.';

  @override
  String get notificationAccess => '알림 액세스';

  @override
  String get nowPlaying => '지금 재생 중';

  @override
  String get performanceOptimizerDashboard => '성능 최적화 대시보드';

  @override
  String get performanceOptimizerDashboardDesc => '실시간 성능 최적화 통계 오버레이 표시';

  @override
  String get permanentFocusChangePause => '영구 포커스 상실 시 일시정지';

  @override
  String get permanentFocusChangePauseDesc =>
      '오디오 포커스를 영구적으로 잃으면 자동으로 재생을 일시정지합니다';

  @override
  String get plainTimestamps => '일반 타임스탬프';

  @override
  String get play => '플레이';

  @override
  String get playAll => '전체 재생';

  @override
  String get playbackAudio => '재생 및 언어';

  @override
  String get playlists => '재생목록';

  @override
  String get playNext => '다음으로 재생';

  @override
  String get playQueue => '재생 대기열';

  @override
  String get pressBackExit => '종료하려면 뒤로를 다시 누르세요.';

  @override
  String get privacySafety => '개인정보 보호 및 안전';

  @override
  String get privacySafetyDesc =>
      '100% 비공개이며 오프라인 우선입니다. 귀하의 트랙, 재생 기록, 즐겨찾기 및 구성은 로컬 장치의 안전한 Isar 데이터베이스 내에 엄격하게 보관됩니다. 당사는 귀하의 사용 데이터나 기본 설정을 추적, 수집 또는 공유하지 않습니다.';

  @override
  String get pureBlackOled => '퓨어 블랙(OLED)';

  @override
  String get pureBlackOledDesc => '배경에 완전한 검은색 사용 (OLED)';

  @override
  String get queue => '대기열';

  @override
  String get queueIsEmpty => '대기열이 비어 있습니다.';

  @override
  String get quickPicks => '빠른 추천';

  @override
  String get quickPicksRowDesc => '가장 많이 재생된 노래 그리드';

  @override
  String get readyToScan => '스캔 준비 완료';

  @override
  String get recentlyAddedSongsRowDesc => '최신 수입품 목록';

  @override
  String get recentlyPlayed => '최근 재생됨';

  @override
  String get recentPlayed => '최근 플레이';

  @override
  String get removedFromPlaylist => '재생목록에서 제거됨';

  @override
  String get removeFromFavorites => '즐겨찾기에서 제거';

  @override
  String get removeFromPlaylist => '재생목록에서 제거';

  @override
  String get rename => '이름 바꾸기';

  @override
  String get renameFile => '파일 이름 변경';

  @override
  String get renamePlaylist => '재생목록 이름 변경';

  @override
  String get renameSong => '노래 이름 바꾸기';

  @override
  String get reorderDashboardSections => '대시보드 섹션 재정렬';

  @override
  String get reorderDashboardSectionsDesc => '드래그 앤 드롭하여 기본 대시보드 순서 설정';

  @override
  String get rescanLibrary => '라이브러리 다시 스캔';

  @override
  String get rescanStorage => '스토리지 다시 스캔';

  @override
  String get reset => '초기화';

  @override
  String get resetLibrary => '재설정 및 다시 검색';

  @override
  String get resetLibraryConfirm =>
      '이렇게 하면 모든 곡, 앨범, 아티스트가 지워지고 폴더를 완전히 다시 스캔합니다.';

  @override
  String get resetLibraryConfirmNew =>
      '라이브러리에서 모든 곡이 제거됩니다. 실제 음악 파일은 삭제되지 않습니다.';

  @override
  String get resetLibraryDesc => '인덱싱된 라이브러리에서 모든 곡 제거';

  @override
  String get resumeAfterCallDesc => '통화 종료 시 자동으로 재생을 재개합니다 (통화로 일시정지된 경우)';

  @override
  String get resumeAfterCallTitle => '통화 후 재개';

  @override
  String get resumeOnStartDesc => 'Looper Player가 시작될 때 자동으로 재생을 재개합니다';

  @override
  String get resumeOnStartTitle => '시작 시 재개';

  @override
  String get persistQueueTitle => '마지막 대기열 유지';

  @override
  String get persistQueueDesc => '앱 재시작 시 마지막 재생 곡과 대기열 저장';

  @override
  String get right => '오른쪽';

  @override
  String scanCompleteSongsDetected(int count) {
    return '스캔 완료: $count 노래가 감지되었습니다!';
  }

  @override
  String get scanForMusic => '음악 스캔';

  @override
  String get scanIndexLocalDesc => '로컬 음악 파일 스캔 및 색인 생성';

  @override
  String get scanLibrary => '스캔 라이브러리';

  @override
  String get scanningInBackground => '백그라운드에서 스캔 중...';

  @override
  String get scanningLibrary => '라이브러리 스캔 중...';

  @override
  String get scanningStorage => '저장소 스캔 중...';

  @override
  String get scanningStorageDesc =>
      '오디오 트랙을 찾기 위해 디렉터리 트리를 탐색합니다. 잠시만 기다려주세요...';

  @override
  String get search => '검색';

  @override
  String get searchLibraryHint => '전체 라이브러리 검색';

  @override
  String get searchSongsHint => '노래 검색';

  @override
  String get seekFadeDuration => '탐색 페이드 시간';

  @override
  String get seekFadeDurationDesc => '탐색 페이드 효과 시간';

  @override
  String get selectAppLanguage => '앱 언어 선택';

  @override
  String get selectCustomColor => '사용자 정의 색상 선택';

  @override
  String get selectCustomFolder => '맞춤 폴더 선택';

  @override
  String get selectFolderIndex => '음악 파일을 인덱싱할 폴더 선택';

  @override
  String get selectSpecificFolder => '특정 폴더 선택';

  @override
  String get settings => '설정';

  @override
  String get share => '공유';

  @override
  String get shareFile => '파일 공유';

  @override
  String get showAlbumsRow => '앨범 행 표시';

  @override
  String get showAlbumsRowDesc => '홈 화면에 앨범의 가로 목록 표시';

  @override
  String get showArtistsRow => '아티스트 행 표시';

  @override
  String get showArtistsRowDesc => '홈 화면에 아티스트의 가로 목록 표시';

  @override
  String get showGenresRow => '장르 행 표시';

  @override
  String get showGenresRowDesc => '홈 화면에 장르의 가로 목록을 표시합니다.';

  @override
  String get showLess => '간략히 표시';

  @override
  String get showMore => '더보기';

  @override
  String get showQualityBadge => '품질 배지 표시';

  @override
  String get showQualityBadgeDesc => '현재 재생 중인 화면에 오디오 품질 정보 배지 표시';

  @override
  String get silenceBetweenTracksDesc => '트랙 사이에 무음 간격을 추가합니다 (갭리스는 0ms)';

  @override
  String get silenceBetweenTracksTitle => '곡 간 무음 시간';

  @override
  String get songDeletedDbOnly => '라이브러리에서 삭제되었습니다 (실제 파일은 읽기 전용)';

  @override
  String get songDeletedSuccess => '곡 삭제 완료';

  @override
  String get songDeleteFailed => '곡 삭제 실패';

  @override
  String get songDetails => '노래 세부정보';

  @override
  String get songDetailsAndFrequency => '노래 세부정보 및 빈도';

  @override
  String get songRenamedDbOnly => '앱 라이브러리에서 이름이 변경되었습니다 (실제 파일은 읽기 전용)';

  @override
  String get songRenamedSuccess => '곡 이름 변경 완료';

  @override
  String get songRenameFailed => '곡 이름 변경 실패';

  @override
  String get songs => '노래';

  @override
  String get songsDarkness => '노래 화면 어둠';

  @override
  String get songsDarknessDesc => '노래 화면의 배경 오버레이 어두움 조정';

  @override
  String get sortBy => '정렬 기준';

  @override
  String get sortOrder => '정렬 순서';

  @override
  String get sourceCode => '소스 코드';

  @override
  String get stopServiceOnAppDismissal => '앱 종료 시 서비스 중지';

  @override
  String get stopServiceOnAppDismissalDesc =>
      '최근 앱 목록에서 앱을 닫을 때 백그라운드 서비스를 중지하고 앱을 종료합니다';

  @override
  String get storagePermissionRequired => '기기 메모리를 스캔하려면 저장소 권한이 필요합니다.';

  @override
  String get syncLyricsOffline => '가사 동기화(오프라인)';

  @override
  String get systemDefault => '시스템 기본값';

  @override
  String get systemPermissionChecklist => '시스템 권한 체크리스트';

  @override
  String get technicalInfoFrequency => '기술 정보 및 주파수';

  @override
  String get theme => '테마';

  @override
  String get title => '제목';

  @override
  String get todayMixForYou => '오늘은 당신을 위한 믹스';

  @override
  String get toggleFavorite => '즐겨찾기 전환';

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
  String get topResult => '상위 결과';

  @override
  String get transferMusicFiles => '음악 파일 전송';

  @override
  String get turnOffBlursOptimize => '성능을 최적화하려면 심한 흐림을 끄세요.';

  @override
  String get unknown => '알 수 없음';

  @override
  String get unknownAlbum => '알 수 없는 앨범';

  @override
  String get unknownArtist => '알 수 없는 아티스트';

  @override
  String get updateLibraryIndexing => '라이브러리 파일 인덱싱 업데이트';

  @override
  String get useAbsoluteBlackBg => '배경에 절대 검정색 사용';

  @override
  String get useStaticTextTimestamps => '진행 기간 동안 롤링 애니메이션 대신 정적 텍스트를 사용하십시오.';

  @override
  String get verticalMotionEffectPlayer => '플레이어 수직 제스처 닫기';

  @override
  String get verticalMotionEffectPlayerDesc => '확장된 플레이어를 아래로 스와이프하여 닫습니다';

  @override
  String get viewAll => '모두 보기';

  @override
  String get visitOfficialRepository => 'GitHub 공식 리포지토리 방문';

  @override
  String get welcomeAboutDesc =>
      'Looper Player는 프리미엄 오프라인 오디오 재생을 위해 제작된 차세대 Music-OS입니다. 실시간 동적 가사 생성, 통화 음소거 처리를 통한 고급 오디오 세션 관리, 적응형 배경 테마 및 다중 형식 음악 라이브러리 지원 기능을 갖추고 있습니다. 최대 배터리 효율을 위해 완전히 최적화되었습니다.';

  @override
  String get welcomeAllFilesDesc =>
      '비표준 디렉토리(다운로드, 텔레그램, 사용자 정의 폴더)에서 노래를 찾기 위한 전문적인 스캐닝에 적극 권장됩니다.';

  @override
  String get welcomeInstructionConnectDesc =>
      '표준 USB 데이터 케이블을 사용하여 휴대전화나 장치를 개인용 컴퓨터에 연결하세요.';

  @override
  String get welcomeInstructionDownloadDesc =>
      '또는 장치 자체에서 웹 브라우저나 기타 다운로더 유틸리티를 사용하여 직접 파일을 다운로드하십시오.';

  @override
  String get welcomeInstructionTransferDesc =>
      '오프라인 음악 파일(.mp3, .flac, .m4a, .wav 지원)을 장치의 표준 \'음악\' 또는 \'다운로드\' 폴더에 직접 복사하세요.';

  @override
  String get welcomeMusicAudioDesc =>
      '장치 메모리에서 표준 오프라인 오디오 트랙을 검색하고 재생하는 데 필요합니다.';

  @override
  String get welcomeNoSongsDesc =>
      '장치 저장소에서 지원되는 오디오 파일(MP3, FLAC, WAV, M4A, OGG)을 찾을 수 없습니다.';

  @override
  String get welcomeNotificationDesc =>
      '시스템 표시줄에 재생 컨트롤 및 활성 알림 위젯을 표시하는 데 필요합니다.';

  @override
  String get welcomeScanningFoldersDesc => '모든 폴더와 하위 폴더에서 오디오 파일을 검색합니다.';

  @override
  String get whyInternetUsed => '인터넷을 사용하는 이유';

  @override
  String get whyInternetUsedDesc =>
      '• 동적 가사 동기화: 온라인 데이터베이스에서 동기화된 가사(LRC 형식)를 안전하게 가져오고 다운로드하는 데에만 사용됩니다. 개인 데이터, 설정 또는 미디어 파일은 업로드되거나 공유되지 않습니다.';

  @override
  String get whyPermissionsUsed => '권한이 사용되는 이유';

  @override
  String get whyPermissionsUsedDesc =>
      '• 저장소/미디어 액세스: 장치에 저장된 로컬 오디오 트랙을 검색하고 읽고 색인을 생성하는 데 필요합니다.\n• 알림: 상태 표시줄과 시스템 서랍에 활성 재생 제어 위젯을 표시하는 데 필요합니다.';

  @override
  String get willPlayNext => '다음으로 재생됩니다';

  @override
  String get year => '연도';

  @override
  String get supportUs => '후원하기';

  @override
  String get supportUsDesc => 'Looper Player가 유지되고 오픈 소스로 남을 수 있도록 돕기';

  @override
  String get supportDevelopment => '개발 지원';

  @override
  String get supportDevelopmentDesc =>
      'Looper Player는 100% 무료이며 오픈 소스입니다. 마음에 드셨다면 제작자에게 후원을 고려해 주세요. 모든 기부는 프로젝트 활성화에 도움이 됩니다!';

  @override
  String get useCustomFont => '사용자 정의 글꼴 사용';

  @override
  String get useCustomFontDesc =>
      'Jost 또는 기타 사용자 정의 글꼴을 사용합니다. 그렇지 않으면 DM Sans가 사용됩니다.';

  @override
  String get selectFontFamily => '글꼴 패밀리 선택';

  @override
  String activeFont(String fontName) {
    return '활성 글꼴: $fontName';
  }

  @override
  String get fontWeightAdjustment => '글꼴 굵기 조정';

  @override
  String get currentWeight => '현재 굵기';

  @override
  String get useCustomFontLyrics => '가사에 사용자 정의 글꼴 사용';

  @override
  String get useCustomFontLyricsDesc => '동기화 가사 보기에 사용자 정의 글꼴과 굵기 사용';

  @override
  String get lyricsFontFamily => '가사 글꼴 패밀리';

  @override
  String activeLyricsFont(String fontName) {
    return '활성 가사 글꼴: $fontName';
  }

  @override
  String get lyricsFontWeightAdjustment => '가사 글꼴 굵기 조정';

  @override
  String get giveStarOnGithub => 'GitHub에서 스타 주기';

  @override
  String get supportProjectLove => '프로젝트를 지원하고 격려해 주세요!';

  @override
  String get sortAlphabeticalAZ => '가나다순 (A-Z)';

  @override
  String get sortAlphabeticalZA => '역순 (Z-A)';

  @override
  String get sortRecentlyAdded => '최근에 추가됨';

  @override
  String get sortOldestAdded => '가장 오래전에 추가됨';

  @override
  String get sortYearNewest => '연도 (최신순)';

  @override
  String get sortYearOldest => '연도 (오래된순)';

  @override
  String get sortMostSongs => '곡이 가장 많음';

  @override
  String get sortLeastSongs => '곡이 가장 적음';

  @override
  String get sortDefault => '기본';

  @override
  String get sortArtistAsc => '아티스트 (A-Z)';

  @override
  String get sortAlbumAsc => '앨범 (A-Z)';

  @override
  String get sortDuration => '재생 시간';
}
