// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get about => 'について';

  @override
  String get aboutAndMaintainers => '概要とメンテナー';

  @override
  String get aboutApp => 'アプリについて';

  @override
  String get aboutLooperPlayer => 'ルーパープレイヤーについて';

  @override
  String get accentColor => 'アクセントカラー';

  @override
  String get accentColorDesc => 'テーマのアクセントカラーを手動で選択';

  @override
  String get acousticSpectralAnalysis => '音響およびスペクトル分析';

  @override
  String get activeCallCannotPlay => '再生がブロックされました: アクティブな通話中は音楽を再生できません';

  @override
  String get adaptColorsArtwork => 'アプリの色をアルバムのアートワークに適応させる';

  @override
  String addedTo(String name) {
    return '$name に追加しました';
  }

  @override
  String get addedToQueue => 'キューに追加しました';

  @override
  String get addFolder => 'フォルダーの追加';

  @override
  String get addToFavorites => 'お気に入りに追加';

  @override
  String get addToPlaylists => 'プレイリストに追加';

  @override
  String get addToQueue => 'キューに追加';

  @override
  String get album => 'アルバム';

  @override
  String get albums => 'アルバム';

  @override
  String get albumsRowDesc => 'アルバムの水平棚';

  @override
  String get allFilesAccess => 'すべてのファイルへのアクセス (推奨)';

  @override
  String get allSongs => 'すべての曲';

  @override
  String get appDetailsCreator => 'アプリケーションの詳細、作成者、デザインチームの情報';

  @override
  String get appearance => '外観';

  @override
  String get appInfoPrivacy => 'アプリ情報とプライバシー';

  @override
  String get appTitle => 'ルーパープレイヤー';

  @override
  String get artist => 'アーティスト';

  @override
  String get artists => 'アーティスト';

  @override
  String get artistsRowDesc => 'アーティストの横の棚';

  @override
  String get ascending => '昇順';

  @override
  String get audioCrossfade => 'オーディオクロスフェード';

  @override
  String get audioCrossfadeDesc => '曲が変わるときにトラックを滑らかに重ねます';

  @override
  String get audioFocusDenied => '再生一時停止: 音声フォーカスがシステムによって拒否されました';

  @override
  String get audioPlayback => 'オーディオと再生';

  @override
  String get audioPlaybackDesc => 'クロスフェード、無音時間、フェードの設定';

  @override
  String get autoCrossfadeDuration => '自動クロスフェード時間';

  @override
  String get autoCrossfadeDurationDesc => '自動移行時の重なり時間';

  @override
  String get backToMainView => 'メインビューに戻る';

  @override
  String get cancel => 'キャンセル';

  @override
  String get categories => 'カテゴリー';

  @override
  String get center => '中央寄せ';

  @override
  String get clear => 'クリア';

  @override
  String get clearQueue => 'クリア';

  @override
  String get connectDevice => 'デバイスを接続する';

  @override
  String get corePurpose => '主な目的';

  @override
  String get corePurposeDesc =>
      'Looper Player は、ローカル ライブラリの完全な制御、ギャップレス再生、滑らかで同期した歌詞のスクロールを求める音楽愛好家向けに設計された、オフラインファーストの高忠実度オーディオ プレーヤーです。';

  @override
  String get create => '作成';

  @override
  String get createPlaylist => 'プレイリストを作成';

  @override
  String get creatorAndMaintainer => '作成者および保守者';

  @override
  String get customAccentColor => 'カスタムのアクセントカラー';

  @override
  String get customizeColorsTheme => 'アプリの色、テーマ、歌詞の背景をカスタマイズする';

  @override
  String get dateAdded => '追加日';

  @override
  String get deepStorageScanProgress => 'ディープストレージスキャンが進行中...';

  @override
  String get delete => '消去';

  @override
  String get deleteFile => 'ファイルを削除';

  @override
  String get deletePlaylist => 'プレイリストを削除';

  @override
  String deletePlaylistConfirm(String name) {
    return '\"$name\" を削除してもよろしいですか？';
  }

  @override
  String get deleteSong => '曲の削除';

  @override
  String get deleteSongConfirm => 'この曲をディスクから削除してもよろしいですか?';

  @override
  String get descending => '降順';

  @override
  String get designerAndMaintainer => 'デザイナー兼メンテナー';

  @override
  String get disableBlurEffects => 'ぼかし効果を無効にする';

  @override
  String get disableSquigglyProgressBar => '波打つプログレスバーアニメーションを無効にする';

  @override
  String get downloadAudioDirectly => '音声を直接ダウンロードする';

  @override
  String get downloadingLyricsOffline => 'オフラインで使用するために歌詞をダウンロードしています...';

  @override
  String get downloadMissingArtwork => '不足しているアートワークをダウンロードする';

  @override
  String get downloadMissingArtworkDesc =>
      'iTunes から曲の高解像度のカバーアートワークを自動的にダウンロードします';

  @override
  String get duration => '長さ';

  @override
  String get dynamicAccentColor => '動的なアクセントカラー';

  @override
  String get dynamicAccentColorDesc => 'アルバムアートからアクセントカラーのみを動的に更新';

  @override
  String get dynamicBgOnlyLyrics => '歌詞のみのダイナミック背景';

  @override
  String get dynamicColorActiveLyrics => 'ダイナミックカラーアクティブライン';

  @override
  String get dynamicColorActiveLyricsDesc => '現在再生中の歌詞ラインに抽出されたアートワークの色を使用します';

  @override
  String get dynamicLyricsBg => 'ダイナミックリリックBG';

  @override
  String get dynamicLyricsBgDesc => '歌詞画面にアルバムアートのぼかしを適用';

  @override
  String get dynamicTheming => '動的なテーマ';

  @override
  String get emptyLibraryDesc =>
      'ライブラリ内にサポートされている音楽ファイルが見つかりませんでした。フォルダーを追加するか、検索スキャンを実行します。';

  @override
  String get enableNetworkLyricsArt => 'オンラインの歌詞とアーティスト アートのネットワーク使用を有効にする';

  @override
  String get enablePlayerGradient => '音楽画面のグラデーション';

  @override
  String get enablePlayerGradientDesc => '現在再生中の画面で放射状のアクセント グラデーションの背景を有効にする';

  @override
  String get fadeDuration => 'フェード時間';

  @override
  String get fadeDurationDesc => '再生/一時停止/停止フェード効果の長さ';

  @override
  String get fadeOnSeek => 'シーク時のフェード';

  @override
  String get fadeOnSeekDesc => 'シーク（巻き戻し・早送り）時に音量を滑らかにフェードアウト・インします';

  @override
  String get fadePlayPauseStop => '再生/一時停止/停止時のフェード';

  @override
  String get fadePlayPauseStopDesc => '再生、一時停止、停止時に音量を滑らかにフェードイン/アウトします';

  @override
  String get favorites => 'お気に入り';

  @override
  String get fileInformation => 'ファイル情報';

  @override
  String get flatProgressBar => 'フラットプログレスバー';

  @override
  String get folders => 'フォルダー';

  @override
  String get genre => 'ジャンル';

  @override
  String get genres => 'ジャンル';

  @override
  String get genresRowDesc => '音楽ジャンルの水平棚';

  @override
  String get goStart => '始めましょう';

  @override
  String get grant => '付与';

  @override
  String get granted => '付与された';

  @override
  String get history => '歴史';

  @override
  String get home => '家';

  @override
  String get homeDarkness => 'ホーム画面の暗さ';

  @override
  String get homeDarknessDesc => 'ホーム画面の背景オーバーレイの暗さを調整する';

  @override
  String get homeDashboardSettings => 'ホームダッシュボードの設定';

  @override
  String get homeDashboardSettingsDesc => 'ホーム画面の水平行をカスタマイズする';

  @override
  String get internetMode => 'インターネットモード';

  @override
  String get keepBackgroundGradient => '背景のグラデーションを維持する';

  @override
  String get keepBackgroundGradientDesc => 'すべてのアプリケーション画面にわたって背景のグラデーションを維持する';

  @override
  String get language => '言語';

  @override
  String get left => '左寄せ';

  @override
  String get library => '図書館';

  @override
  String get libraryDarkness => 'ライブラリ画面の暗闇';

  @override
  String get libraryDarknessDesc => 'ライブラリ画面の背景オーバーレイの暗さを調整します';

  @override
  String get libraryFoldersSync => 'フォルダー、再スキャントリガー、データベースのリセット、オフライン同期';

  @override
  String get librarySettings => 'ライブラリ設定';

  @override
  String get loadingMusicLibrary => '音楽ライブラリをロード中';

  @override
  String get loadingMusicLibraryDesc =>
      'プレミアム インデックスの構築、ハードウェア リスナーのセットアップ、ビジュアル キャッシュの最適化。';

  @override
  String get loadingPhase1 => 'オーディオ ストレージを問い合わせています...';

  @override
  String get loadingPhase2 => '音楽エンジンをリフレッシュ中...';

  @override
  String get loadingPhase3 => '音響データを抽出しています...';

  @override
  String get loadingPhase4 => '再生メモリを最適化しています...';

  @override
  String get lyrics => '歌詞';

  @override
  String get lyricsAlignment => '歌詞の配置';

  @override
  String get lyricsAlignmentDesc => 'スクロールする歌詞のテキスト位置を揃える';

  @override
  String get lyricsDarkness => '歌詞画面暗闇';

  @override
  String get lyricsDarknessDesc => '歌詞画面の背景オーバーレイの暗さを調整します';

  @override
  String get lyricsProvider => '歌詞プロバイダー';

  @override
  String get lyricsProviderDesc => 'オンライン歌詞は lrclib.net (LRCLIB) から取得されています';

  @override
  String get maintainersAndDesigners => 'メンテナーとデザイナー';

  @override
  String get manageAudioFocus => 'オーディオフォーカスの管理';

  @override
  String get manageAudioFocusDesc => 'システムのオーディオフォーカス変化を要求および応答する';

  @override
  String get manageAudioFocusTitle => 'オーディオフォーカスの管理';

  @override
  String get manageLanguageAndFocus => '言語設定と発信者のフォーカス状態を管理する';

  @override
  String get manualCrossfadeDuration => '手動クロスフェード時間';

  @override
  String get manualCrossfadeDurationDesc => '手動スキップ時の重なり時間';

  @override
  String get matchingLyrics => '一致する歌詞';

  @override
  String get metadataDetails => 'メタデータの詳細';

  @override
  String get mostPlayed => '最も再生された曲';

  @override
  String get musicAudioAccess => '音楽とオーディオへのアクセス';

  @override
  String get musicDarkness => '音楽プレーヤーの暗闇';

  @override
  String get musicDarknessDesc => '音楽プレーヤー画面の背景オーバーレイの暗さを調整します';

  @override
  String get musicLibrary => '音楽ライブラリ';

  @override
  String get muteOrPauseCalls => '通話やその他の音声アクティビティ中にミュートまたは一時停止する';

  @override
  String get newPlaylist => '新規プレイリスト';

  @override
  String get newTitle => '新しいタイトル';

  @override
  String get noAlbumsFound => 'アルバムが見つかりませんでした';

  @override
  String get noArtistsFound => 'アーティストが見つかりませんでした';

  @override
  String get noFavoritesYet => 'お気に入りはまだありません';

  @override
  String get noHistoryYet => '履歴はありません';

  @override
  String get noLyrics => '歌詞が見つかりません';

  @override
  String get noMusicDetected => '音楽が検出されませんでした';

  @override
  String get noPlaylistsCreated => 'プレイリストはまだ作成されていません。';

  @override
  String get noPlaylistsYet => 'プレイリストがありません';

  @override
  String get noResultsFound => '結果が見つかりませんでした';

  @override
  String get noSongsFound => '曲が見つかりませんでした';

  @override
  String get notificationAccess => '通知へのアクセス';

  @override
  String get nowPlaying => 'プレイ中';

  @override
  String get performanceOptimizerDashboard => 'パフォーマンス最適化ダッシュボード';

  @override
  String get performanceOptimizerDashboardDesc => 'リアルタイムのパフォーマンス統計オーバーレイを表示する';

  @override
  String get permanentFocusChangePause => '永続的なフォーカス喪失時に一時停止';

  @override
  String get permanentFocusChangePauseDesc =>
      'オーディオフォーカスを永続的に失ったときに自動的に一時停止します';

  @override
  String get plainTimestamps => 'プレーンなタイムスタンプ';

  @override
  String get play => '遊ぶ';

  @override
  String get playAll => 'すべて再生';

  @override
  String get playbackAudio => '再生と言語';

  @override
  String get playlists => 'プレイリスト';

  @override
  String get playNext => '次に再生';

  @override
  String get playQueue => 'プレイキュー';

  @override
  String get pressBackExit => 'もう一度戻るボタンを押して終了します';

  @override
  String get privacySafety => 'プライバシーと安全性';

  @override
  String get privacySafetyDesc =>
      '100%プライベートかつオフラインファースト。トラック、再生履歴、お気に入り、設定は、ローカル デバイス上の安全な Isar データベース内に厳密に保管されます。当社は、お客様の使用状況データや設定を追跡、収集、共有しません。';

  @override
  String get pureBlackOled => 'ピュアブラック（OLED）';

  @override
  String get pureBlackOledDesc => '背景に絶対的な黒を使用する（OLED）';

  @override
  String get queue => '列';

  @override
  String get queueIsEmpty => 'キューが空です';

  @override
  String get quickPicks => 'クイックピック';

  @override
  String get quickPicksRowDesc => '最も再生された曲のグリッド';

  @override
  String get readyToScan => 'スキャンの準備ができました';

  @override
  String get recentlyAddedSongsRowDesc => '最新のインポートのリスト';

  @override
  String get recentlyPlayed => '最近再生した曲';

  @override
  String get recentPlayed => '最近のプレイ';

  @override
  String get removedFromPlaylist => 'プレイリストから削除しました';

  @override
  String get removeFromFavorites => 'お気に入りから削除';

  @override
  String get removeFromPlaylist => 'プレイリストから削除';

  @override
  String get rename => 'Rename';

  @override
  String get renameFile => 'ファイルを名前変更';

  @override
  String get renamePlaylist => 'プレイリスト名を変更';

  @override
  String get renameSong => '曲の名前を変更する';

  @override
  String get reorderDashboardSections => 'ダッシュボードセクションの並べ替え';

  @override
  String get reorderDashboardSectionsDesc => 'ドラッグ アンド ドロップでダッシュボードの優先順序を設定します';

  @override
  String get rescanLibrary => 'ライブラリを再スキャンする';

  @override
  String get rescanStorage => 'ストレージの再スキャン';

  @override
  String get reset => 'リセット';

  @override
  String get resetLibrary => 'リセットと再スキャン';

  @override
  String get resetLibraryConfirm =>
      'これにより、すべての曲、アルバム、アーティストがクリアされ、フォルダーの完全な再スキャンが実行されます。';

  @override
  String get resetLibraryConfirmNew =>
      'これにより、ライブラリからすべての曲が削除されます。音楽ファイル自体は削除されません。';

  @override
  String get resetLibraryDesc => 'インデックスされたライブラリからすべての曲を削除します';

  @override
  String get resumeAfterCallDesc => '通話終了時に自動的に再生を再開します（通話で一時停止した場合）';

  @override
  String get resumeAfterCallTitle => '通話後に再開';

  @override
  String get resumeOnStartDesc => 'Looper Playerが起動されたときに自動的に再生を再開します';

  @override
  String get resumeOnStartTitle => '起動時に再開';

  @override
  String get persistQueueTitle => '最後のキューを保持';

  @override
  String get persistQueueDesc => 'アプリ再起動時に最後に再生した曲とキューを保存する';

  @override
  String get right => '右寄せ';

  @override
  String scanCompleteSongsDetected(int count) {
    return 'スキャン完了: $count 曲が検出されました!';
  }

  @override
  String get scanForMusic => '音楽をスキャン';

  @override
  String get scanIndexLocalDesc => 'ローカル音楽ファイルをスキャンしてインデックス付けする';

  @override
  String get scanLibrary => 'スキャンライブラリ';

  @override
  String get scanningInBackground => 'バックグラウンドでスキャン中...';

  @override
  String get scanningLibrary => 'ライブラリをスキャンしています...';

  @override
  String get scanningStorage => 'ストレージをスキャン中...';

  @override
  String get scanningStorageDesc =>
      'ディレクトリ ツリーを走査してオーディオ トラックを検出します。お待ちください...';

  @override
  String get search => '検索';

  @override
  String get searchLibraryHint => 'ライブラリ全体を検索する';

  @override
  String get searchSongsHint => '曲を検索する';

  @override
  String get seekFadeDuration => 'シークフェード時間';

  @override
  String get seekFadeDurationDesc => 'シークフェード効果の長さ';

  @override
  String get selectAppLanguage => 'アプリの言語を選択';

  @override
  String get selectCustomColor => 'カスタムカラーの選択';

  @override
  String get selectCustomFolder => 'カスタムフォルダーの選択';

  @override
  String get selectFolderIndex => '音楽ファイルをインデックスするフォルダーを選択';

  @override
  String get selectSpecificFolder => '特定のフォルダーを選択してください';

  @override
  String get settings => '設定';

  @override
  String get share => '共有';

  @override
  String get shareFile => 'ファイルを共有する';

  @override
  String get showAlbumsRow => 'アルバム行を表示';

  @override
  String get showAlbumsRowDesc => 'ホーム画面にアルバムの水平リストを表示します';

  @override
  String get showArtistsRow => 'アーティスト列を表示';

  @override
  String get showArtistsRowDesc => 'ホーム画面にアーティストの水平リストを表示します';

  @override
  String get showGenresRow => 'ジャンル行を表示';

  @override
  String get showGenresRowDesc => 'ホーム画面にジャンルの水平リストを表示します';

  @override
  String get showLess => '表示を減らす';

  @override
  String get showMore => 'もっと見る';

  @override
  String get showQualityBadge => '品質バッジを表示する';

  @override
  String get showQualityBadgeDesc => '再生中の画面に音質情報バッジを表示します';

  @override
  String get silenceBetweenTracksDesc => '曲の間に無音のギャップを追加します（ギャップレスは0ms）';

  @override
  String get silenceBetweenTracksTitle => '曲間の無音時間';

  @override
  String get songDeletedDbOnly => 'ライブラリから削除しました（元のファイルは読み取り専用）';

  @override
  String get songDeletedSuccess => '曲を削除しました';

  @override
  String get songDeleteFailed => '曲の削除に失敗しました';

  @override
  String get songDetails => '曲の詳細';

  @override
  String get songDetailsAndFrequency => 'Song Details & Frequency';

  @override
  String get songRenamedDbOnly => 'アプリ内ライブラリで名前を変更しました（元のファイルは読み取り専用）';

  @override
  String get songRenamedSuccess => '曲の名前を変更しました';

  @override
  String get songRenameFailed => '曲の名前変更に失敗しました';

  @override
  String get songs => '歌';

  @override
  String get songsDarkness => '曲 画面暗さ';

  @override
  String get songsDarknessDesc => 'ソング画面の背景オーバーレイの暗さを調整する';

  @override
  String get sortBy => '並べ替え';

  @override
  String get sortOrder => '並べ替え順序';

  @override
  String get sourceCode => 'ソースコード';

  @override
  String get stopServiceOnAppDismissal => 'アプリ終了時にサービスを停止';

  @override
  String get stopServiceOnAppDismissalDesc =>
      '最近使ったアプリから削除されたときにバックグラウンドサービスを停止しアプリを終了します';

  @override
  String get storagePermissionRequired => 'デバイスのメモリをスキャンするにはストレージのアクセス許可が必要です。';

  @override
  String get syncLyricsOffline => '歌詞を同期（オフライン）';

  @override
  String get systemDefault => 'システムデフォルト';

  @override
  String get systemPermissionChecklist => 'システム許可チェックリスト';

  @override
  String get technicalInfoFrequency => '技術情報と頻度';

  @override
  String get theme => 'テーマ';

  @override
  String get title => 'タイトル';

  @override
  String get todayMixForYou => '今日はあなたにミックスしてください';

  @override
  String get toggleFavorite => 'お気に入りを切り替え';

  @override
  String get topResult => '上位の結果';

  @override
  String get transferMusicFiles => '音楽ファイルを転送する';

  @override
  String get turnOffBlursOptimize => '激しいブラーをオフにしてパフォーマンスを最適化します';

  @override
  String get unknown => '未知';

  @override
  String get unknownAlbum => '未知のアルバム';

  @override
  String get unknownArtist => '不明なアーティスト';

  @override
  String get updateLibraryIndexing => 'ライブラリファイルのインデックスを更新';

  @override
  String get useAbsoluteBlackBg => '背景に絶対的な黒を使用する';

  @override
  String get useStaticTextTimestamps => '進行時間にはローリングアニメーションの代わりに静的テキストを使用します';

  @override
  String get verticalMotionEffectPlayer => 'プレイヤーの垂直ジェスチャー閉じる';

  @override
  String get verticalMotionEffectPlayerDesc => '展開したプレイヤーを下にスワイプして閉じます';

  @override
  String get viewAll => 'すべて見る';

  @override
  String get visitOfficialRepository => 'GitHubの公式リポジトリを表示';

  @override
  String get welcomeAboutDesc =>
      'Looper Player は、プレミアム オフライン オーディオ再生用に構築された次世代 Music-OS です。リアルタイムの動的な歌詞生成、通話ミュート処理を備えた高度なオーディオ セッション管理、適応型バックグラウンド テーマ、およびマルチフォーマット音楽ライブラリのサポートが特徴です。バッテリー効率を最大化するために完全に最適化されています。';

  @override
  String get welcomeAllFilesDesc =>
      '標準以外のディレクトリ (ダウンロード、テレグラム、カスタム フォルダー) にある曲を見つけるためのプロフェッショナルなスキャンに強くお勧めします。';

  @override
  String get welcomeInstructionConnectDesc =>
      '標準の USB データ ケーブルを使用して、携帯電話またはデバイスをパーソナル コンピュータに接続します。';

  @override
  String get welcomeInstructionDownloadDesc =>
      'あるいは、Web ブラウザまたはデバイス自体の他のダウンローダー ユーティリティを使用してファイルを直接ダウンロードします。';

  @override
  String get welcomeInstructionTransferDesc =>
      'オフライン音楽ファイル (.mp3、.flac、.m4a、.wav をサポート) をデバイスの標準の「ミュージック」または「ダウンロード」フォルダーに直接コピーします。';

  @override
  String get welcomeMusicAudioDesc =>
      'デバイスのメモリ上で標準のオフライン オーディオ トラックを検出して再生するために必要です。';

  @override
  String get welcomeNoSongsDesc =>
      'デバイスのストレージ上でサポートされているオーディオ ファイル (MP3、FLAC、WAV、M4A、OGG) が見つかりませんでした。';

  @override
  String get welcomeNotificationDesc =>
      'システム バーに再生コントロールとアクティブな通知ウィジェットを表示するために必要です。';

  @override
  String get welcomeScanningFoldersDesc =>
      'すべてのフォルダーとサブフォルダーをスキャンしてオーディオ ファイルを探します。';

  @override
  String get whyInternetUsed => 'なぜインターネットが使われるのか';

  @override
  String get whyInternetUsedDesc =>
      '• 動的歌詞同期: オンライン データベースから同期された歌詞 (LRC 形式) を安全にフェッチし、ダウンロードするためにのみ使用されます。個人データ、設定、メディア ファイルがアップロードまたは共有されることはありません。';

  @override
  String get whyPermissionsUsed => '権限が使用される理由';

  @override
  String get whyPermissionsUsedDesc =>
      '• ストレージ/メディア アクセス: デバイスに保存されているローカル オーディオ トラックを検出、読み取り、インデックス付けするために必要です。\n• 通知: ステータス バーとシステム ドロワーにアクティブな再生コントロール ウィジェットを表示するために必要です。';

  @override
  String get willPlayNext => '次に再生します';

  @override
  String get year => '年';

  @override
  String get supportUs => '支援する';

  @override
  String get supportUsDesc => 'Looper Player の継続とオープンソース活動を支援';

  @override
  String get supportDevelopment => '開発を支援';

  @override
  String get supportDevelopmentDesc =>
      'Looper Player は 100% 無料でオープンソースです。気に入っていただけましたら、寄付による制作者の支援をご検討ください。すべての支援がプロジェクトの維持に役立ちます！';

  @override
  String get useCustomFont => 'カスタムフォントを使用';

  @override
  String get useCustomFontDesc =>
      'Jost または他のカスタムフォントを使用します。そうでない場合は DM Sans が使用されます。';

  @override
  String get selectFontFamily => 'フォントファミリーの選択';

  @override
  String activeFont(String fontName) {
    return '有効なフォント: $fontName';
  }

  @override
  String get fontWeightAdjustment => 'フォントの太さ調整';

  @override
  String get currentWeight => '現在の太さ';

  @override
  String get useCustomFontLyrics => '歌詞にカスタムフォントを使用';

  @override
  String get useCustomFontLyricsDesc => '同期歌詞ビューでカスタムフォントと太さを使用します';

  @override
  String get lyricsFontFamily => '歌詞フォントファミリー';

  @override
  String activeLyricsFont(String fontName) {
    return '有効な歌詞フォント: $fontName';
  }

  @override
  String get lyricsFontWeightAdjustment => '歌詞フォントの太さ調整';

  @override
  String get giveStarOnGithub => 'GitHub でスターを付ける';

  @override
  String get supportProjectLove => 'プロジェクトをサポートして、愛を示しましょう！';

  @override
  String get sortAlphabeticalAZ => 'アルファベット順 (A-Z)';

  @override
  String get sortAlphabeticalZA => 'アルファベット順 (Z-A)';

  @override
  String get sortRecentlyAdded => '追加日 (新しい順)';

  @override
  String get sortOldestAdded => '追加日 (古い順)';

  @override
  String get sortYearNewest => 'リリース年 (新しい順)';

  @override
  String get sortYearOldest => 'リリース年 (古い順)';

  @override
  String get sortMostSongs => '曲数が最も多い';

  @override
  String get sortLeastSongs => '曲数が最も少ない';

  @override
  String get sortDefault => 'デフォルト';

  @override
  String get sortArtistAsc => 'アーティスト (A-Z)';

  @override
  String get sortAlbumAsc => 'アルバム (A-Z)';

  @override
  String get sortDuration => '曲の長さ';
}
