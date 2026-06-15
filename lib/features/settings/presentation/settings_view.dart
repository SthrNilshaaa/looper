import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animations/animations.dart';

import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/settings_widgets.dart';
import 'widgets/settings_dialogs.dart';
import 'widgets/theme_settings_tiles.dart';
import 'widgets/dashboard_settings_tiles.dart';
import 'widgets/playback_settings_tiles.dart';
import 'widgets/audio_playback_settings_tiles.dart';
import 'widgets/library_settings_tiles.dart';
import 'widgets/about_settings_tiles.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final useBlur = settings.enableDynamicTheming && !settings.disableBlur;

    return Material(
      color: Colors.transparent,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header title / Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _isSearching
                      ? Row(
                          key: const ValueKey('searching_header'),
                          children: [
                            PremiumSection(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(32),
                                bottomLeft: Radius.circular(32),
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              width: 48,
                              height: 48,
                              useBlur: useBlur,
                              useExpanded: false,
                              forceNoBlur: true,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _isSearching = false;
                                  _searchController.clear();
                                });
                              },
                              child: const Icon(
                                LucideIcons.arrowLeft,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    topRight: Radius.circular(32),
                                    bottomRight: Radius.circular(32),
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                                child: Center(
                                  child: TextField(
                                    controller: _searchController,
                                    autofocus: true,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search settings...',
                                      hintStyle: const TextStyle(
                                        color: Colors.white38,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      suffixIcon:
                                          _searchController.text.isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(
                                                    LucideIcons.x,
                                                    color: Colors.white70,
                                                    size: 18,
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    setState(() {});
                                                  },
                                                )
                                              : null,
                                    ),
                                    onChanged: (val) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          key: const ValueKey('standard_header'),
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PremiumSection(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(32),
                                bottomLeft: Radius.circular(32),
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              width: 48,
                              height: 48,
                              useBlur: useBlur,
                              forceNoBlur: true,
                              useExpanded: false,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(appNavigationProvider.notifier)
                                    .goBack();
                              },
                              child: const Icon(
                                LucideIcons.arrowLeft,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            Text(
                              l10n.settings,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PremiumSection(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                topRight: Radius.circular(32),
                                bottomRight: Radius.circular(32),
                              ),
                              width: 48,
                              height: 48,
                              useExpanded: false,
                              forceNoBlur: true,
                              useBlur: useBlur,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _isSearching = true;
                                });
                              },
                              child: const Icon(
                                LucideIcons.search,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Settings Body
              Expanded(
                child: _isSearching
                    ? _buildSearchResults(context, ref, settings, l10n)
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // 1. Theme & Appearance
                          _buildCategoryGroup(
                            context: context,
                            id: 'theme',
                            title: l10n.theme,
                            subtitle: l10n.customizeColorsTheme,
                            icon: LucideIcons.palette,
                            colorScheme: Theme.of(context).colorScheme,
                            useBlur: useBlur,
                            settings: settings,
                          ),

                          // 2. Home Screen Customization
                          _buildCategoryGroup(
                            context: context,
                            id: 'dashboard',
                            title: l10n.homeDashboardSettings,
                            subtitle: l10n.homeDashboardSettingsDesc,
                            icon: LucideIcons.layout,
                            colorScheme: Theme.of(context).colorScheme,
                            useBlur: useBlur,
                            settings: settings,
                          ),

                          // 3. Playback & Language
                          _buildCategoryGroup(
                            context: context,
                            id: 'playback',
                            title: l10n.playbackAudio,
                            subtitle: l10n.manageLanguageAndFocus,
                            icon: LucideIcons.playCircle,
                            colorScheme: Theme.of(context).colorScheme,
                            useBlur: useBlur,
                            settings: settings,
                          ),

                          // 4. Audio & Playback
                          _buildCategoryGroup(
                            context: context,
                            id: 'audio_playback',
                            title: l10n.audioPlayback,
                            subtitle: l10n.audioPlaybackDesc,
                            icon: LucideIcons.music,
                            colorScheme: Theme.of(context).colorScheme,
                            useBlur: useBlur,
                            settings: settings,
                          ),

                          // 5. Music Library
                          _buildCategoryGroup(
                            context: context,
                            id: 'library',
                            title: l10n.musicLibrary,
                            subtitle: l10n.libraryFoldersSync,
                            icon: LucideIcons.database,
                            colorScheme: Theme.of(context).colorScheme,
                            useBlur: useBlur,
                            settings: settings,
                          ),

                          // 6. About & Creators
                          _buildCategoryGroup(
                            context: context,
                            id: 'about',
                            title: l10n.aboutAndMaintainers,
                            subtitle: l10n.appDetailsCreator,
                            icon: LucideIcons.info,
                            colorScheme: Theme.of(context).colorScheme,
                            useBlur: useBlur,
                            settings: settings,
                          ),

                          const SizedBox(
                            height: 140,
                          ), // Bottom breathing room for expanded player bar
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGroup({
    required BuildContext context,
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required ColorScheme colorScheme,
    required bool useBlur,
    required AppSettings settings,
  }) {
    return Column(
      children: [
        PremiumSection(
          useBlur: useBlur,
          forceNoBlur: true,
          borderRadius: BorderRadius.circular(20),
          useExpanded: false,
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                PageRouteBuilder(
                  settings: const RouteSettings(name: 'settings_subpage'),
                  opaque: false,
                  transitionDuration: const Duration(milliseconds: 350),
                  reverseTransitionDuration: const Duration(milliseconds: 250),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return SettingsCategoryScreen(categoryId: id, title: title);
                  },
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SharedAxisTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      child: child,
                    );
                  },
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(settings.accentColor).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Color(settings.accentColor),
                      size: 20.s,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 18.s,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    AppLocalizations l10n,
  ) {
    final query = _searchController.text.toLowerCase();
    final allSearchItems = _getSearchItems(context, ref, settings, l10n);
    final filteredItems = allSearchItems.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);
    }).toList();

    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.search, size: 48, color: Colors.white24),
            SizedBox(height: 16),
            Text(
              'Type to search settings...',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              'No settings found for "$query"',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const BouncingScrollPhysics(),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        final useBlur = settings.enableDynamicTheming && !settings.disableBlur;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: PremiumSection(
            useBlur: useBlur,
            forceNoBlur: true,
            borderRadius: BorderRadius.circular(16),
            useExpanded: false,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    top: 8.0,
                    bottom: 4.0,
                  ),
                  child: Text(
                    item.category.toUpperCase(),
                    style: TextStyle(
                      color: Color(settings.accentColor).withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                item.widget,
              ],
            ),
          ),
        );
      },
    );
  }

  List<SettingsSearchItem> _getSearchItems(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    AppLocalizations l10n,
  ) {
    return [
      // Theme
      SettingsSearchItem(
        title: l10n.dynamicTheming,
        subtitle: l10n.adaptColorsArtwork,
        category: l10n.theme,
        widget: const DynamicThemingTile(),
      ),
      if (settings.enableDynamicTheming)
        SettingsSearchItem(
          title: l10n.disableBlurEffects,
          subtitle: l10n.turnOffBlursOptimize,
          category: l10n.theme,
          widget: const DisableBlurTile(),
        ),
      if (!settings.enableDynamicTheming) ...[
        SettingsSearchItem(
          title: 'Dynamic Accent Color',
          subtitle: 'Update only the accent color dynamically from the artwork',
          category: l10n.theme,
          widget: const DynamicAccentColorTile(),
        ),
        SettingsSearchItem(
          title: l10n.pureBlackOled,
          subtitle: l10n.useAbsoluteBlackBg,
          category: l10n.theme,
          widget: const PureBlackOledTile(),
        ),
        if (!settings.dynamicAccentColor) ...[
          SettingsSearchItem(
            title: l10n.accentColor,
            subtitle: 'Choose quick accent colors',
            category: l10n.theme,
            widget: const AccentColorTile(),
          ),
          SettingsSearchItem(
            title: l10n.customAccentColor,
            subtitle: l10n.selectCustomColor,
            category: l10n.theme,
            widget: const CustomAccentColorTile(),
          ),
        ],
      ],
      if (!settings.enableDynamicTheming)
        SettingsSearchItem(
          title: l10n.dynamicLyricsBg,
          subtitle: l10n.dynamicBgOnlyLyrics,
          category: l10n.theme,
          widget: const DynamicLyricsBgTile(),
        ),
      if (!settings.enableDynamicTheming && !settings.dynamicLyrics)
        SettingsSearchItem(
          title: 'Blurred Artwork for Lyrics',
          subtitle:
              'Show blurred album art as background instead of dynamic/static gradient',
          category: l10n.theme,
          widget: const BlurredArtworkLyricsTile(),
        ),
      if (settings.enableDynamicTheming || settings.dynamicLyrics)
        SettingsSearchItem(
          title: l10n.dynamicColorActiveLyrics,
          subtitle: l10n.dynamicColorActiveLyricsDesc,
          category: l10n.theme,
          widget: const DynamicColorActiveLyricsTile(),
        ),
      SettingsSearchItem(
        title: l10n.lyricsAlignment,
        subtitle: l10n.lyricsAlignmentDesc,
        category: l10n.theme,
        widget: const LyricsAlignmentTile(),
      ),
      SettingsSearchItem(
        title: l10n.flatProgressBar,
        subtitle: l10n.disableSquigglyProgressBar,
        category: l10n.theme,
        widget: const FlatProgressBarTile(),
      ),
      SettingsSearchItem(
        title: l10n.plainTimestamps,
        subtitle: l10n.useStaticTextTimestamps,
        category: l10n.theme,
        widget: const PlainTimestampsTile(),
      ),
      SettingsSearchItem(
        title: l10n.showQualityBadge,
        subtitle: l10n.showQualityBadgeDesc,
        category: l10n.theme,
        widget: const ShowQualityBadgeTile(),
      ),
      SettingsSearchItem(
        title: l10n.enablePlayerGradient,
        subtitle: l10n.enablePlayerGradientDesc,
        category: l10n.theme,
        widget: const EnablePlayerGradientTile(),
      ),
      if (settings.enablePlayerGradient)
        SettingsSearchItem(
          title: l10n.keepBackgroundGradient,
          subtitle: l10n.keepBackgroundGradientDesc,
          category: l10n.theme,
          widget: const KeepBackgroundGradientTile(),
        ),
      SettingsSearchItem(
        title: 'Use Custom Font',
        subtitle: 'Use Jost or other custom fonts. Otherwise, DM Sans is used.',
        category: l10n.theme,
        widget: const UseNewFontTile(),
      ),
      if (settings.useNewFont)
        SettingsSearchItem(
          title: 'Select Font Family',
          subtitle: 'Active font: ${settings.customFontFamily}',
          category: l10n.theme,
          widget: const FontFamilySelectionTile(),
        ),

      // Dashboard
      SettingsSearchItem(
        title: l10n.showArtistsRow,
        subtitle: l10n.showArtistsRowDesc,
        category: l10n.homeDashboardSettings,
        widget: const ShowArtistsRowTile(),
      ),
      SettingsSearchItem(
        title: l10n.showAlbumsRow,
        subtitle: l10n.showAlbumsRowDesc,
        category: l10n.homeDashboardSettings,
        widget: const ShowAlbumsRowTile(),
      ),
      SettingsSearchItem(
        title: l10n.showGenresRow,
        subtitle: l10n.showGenresRowDesc,
        category: l10n.homeDashboardSettings,
        widget: const ShowGenresRowTile(),
      ),
      SettingsSearchItem(
        title: l10n.reorderDashboardSections,
        subtitle: l10n.reorderDashboardSectionsDesc,
        category: l10n.homeDashboardSettings,
        widget: const ReorderDashboardSectionsTile(),
      ),

      // Playback
      SettingsSearchItem(
        title: l10n.language,
        subtitle: 'Select application language',
        category: l10n.playbackAudio,
        widget: const LanguageTile(),
      ),
      SettingsSearchItem(
        title: 'Vertical Motion Effect Player',
        subtitle: 'Swipe down on the expanded player to dismiss it',
        category: l10n.playbackAudio,
        widget: const VerticalMotionEffectTile(),
      ),
      SettingsSearchItem(
        title: 'Stop Service on App Dismissal',
        subtitle:
            'Stop playback and close the app when swiped away from recent panel',
        category: l10n.playbackAudio,
        widget: const StopServiceTile(),
      ),
      SettingsSearchItem(
        title: l10n.internetMode,
        subtitle: l10n.enableNetworkLyricsArt,
        category: l10n.playbackAudio,
        widget: const InternetModeTile(),
      ),
      SettingsSearchItem(
        title: l10n.downloadMissingArtwork,
        subtitle: l10n.downloadMissingArtworkDesc,
        category: l10n.playbackAudio,
        widget: const DownloadMissingArtworkTile(),
      ),

      // Audio Playback
      SettingsSearchItem(
        title: l10n.fadePlayPauseStop,
        subtitle: l10n.fadePlayPauseStopDesc,
        category: l10n.audioPlayback,
        widget: const FadePlayPauseStopTile(),
      ),
      if (settings.fadePlayPauseStop)
        SettingsSearchItem(
          title: l10n.fadeDuration,
          subtitle: l10n.fadeDurationDesc,
          category: l10n.audioPlayback,
          widget: const FadeDurationSlider(),
        ),
      SettingsSearchItem(
        title: l10n.fadeOnSeek,
        subtitle: l10n.fadeOnSeekDesc,
        category: l10n.audioPlayback,
        widget: const FadeOnSeekTile(),
      ),
      if (settings.fadeOnSeek)
        SettingsSearchItem(
          title: l10n.seekFadeDuration,
          subtitle: l10n.seekFadeDurationDesc,
          category: l10n.audioPlayback,
          widget: const SeekFadeDurationSlider(),
        ),
      SettingsSearchItem(
        title: l10n.audioCrossfade,
        subtitle: l10n.audioCrossfadeDesc,
        category: l10n.audioPlayback,
        widget: const AudioCrossfadeTile(),
      ),
      if (settings.enableCrossfade) ...[
        SettingsSearchItem(
          title: l10n.autoCrossfadeDuration,
          subtitle: l10n.autoCrossfadeDurationDesc,
          category: l10n.audioPlayback,
          widget: const AutoCrossfadeDurationSlider(),
        ),
        SettingsSearchItem(
          title: l10n.manualCrossfadeDuration,
          subtitle: l10n.manualCrossfadeDurationDesc,
          category: l10n.audioPlayback,
          widget: const ManualCrossfadeDurationSlider(),
        ),
      ],
      SettingsSearchItem(
        title: l10n.silenceBetweenTracksTitle,
        subtitle: l10n.silenceBetweenTracksDesc,
        category: l10n.audioPlayback,
        widget: const SilenceBetweenTracksSlider(),
      ),
      SettingsSearchItem(
        title: l10n.manageAudioFocusTitle,
        subtitle: l10n.manageAudioFocusDesc,
        category: l10n.audioPlayback,
        widget: const ManageAudioFocusTile(),
      ),
      if (settings.audioFocus) ...[
        SettingsSearchItem(
          title: l10n.resumeAfterCallTitle,
          subtitle: l10n.resumeAfterCallDesc,
          category: l10n.audioPlayback,
          widget: const ResumeAfterCallTile(),
        ),
        SettingsSearchItem(
          title: l10n.resumeOnStartTitle,
          subtitle: l10n.resumeOnStartDesc,
          category: l10n.audioPlayback,
          widget: const ResumeOnStartTile(),
        ),
        SettingsSearchItem(
          title: l10n.permanentFocusChangePause,
          subtitle: l10n.permanentFocusChangePauseDesc,
          category: l10n.audioPlayback,
          widget: const PermanentAudioFocusChangeTile(),
        ),
      ],

      // Library
      SettingsSearchItem(
        title: l10n.addFolder,
        subtitle: 'Scan a new folder for audio files',
        category: l10n.musicLibrary,
        widget: const AddFolderTile(),
      ),
      SettingsSearchItem(
        title: l10n.syncLyricsOffline,
        subtitle: l10n.downloadingLyricsOffline,
        category: l10n.musicLibrary,
        widget: const SyncLyricsOfflineTile(),
      ),
      SettingsSearchItem(
        title: l10n.rescanLibrary,
        subtitle: l10n.scanningLibrary,
        category: l10n.musicLibrary,
        widget: const RescanLibraryTile(),
      ),
      SettingsSearchItem(
        title: l10n.resetLibrary,
        subtitle: 'Clear library data',
        category: l10n.musicLibrary,
        widget: const ResetLibraryTile(),
      ),

      // About
      SettingsSearchItem(
        title: 'Looper Player Version',
        subtitle: 'Version 2.1.0',
        category: l10n.aboutAndMaintainers,
        widget: const LooperVersionTile(),
      ),
      SettingsSearchItem(
        title: l10n.lyricsProvider,
        subtitle: 'lrclib.net',
        category: l10n.aboutAndMaintainers,
        widget: const LyricsProviderTile(),
      ),
    ];
  }
}

class SettingsCategoryScreen extends ConsumerWidget {
  final String categoryId;
  final String title;

  const SettingsCategoryScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    final useBlur = settings.enableDynamicTheming && !settings.disableBlur;

    List<Widget> children = [];
    if (categoryId == 'theme') {
      children = [
        const DynamicThemingTile(),
        if (settings.enableDynamicTheming) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const DisableBlurTile(),
        ],
        if (!settings.enableDynamicTheming) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const DynamicAccentColorTile(),
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const PureBlackOledTile(),
          if (!settings.dynamicAccentColor) ...[
            const Divider(height: 1, indent: 72, color: Colors.white10),
            const AccentColorTile(),
            const Divider(height: 1, indent: 72, color: Colors.white10),
            const CustomAccentColorTile(),
          ],
        ],
        if (!settings.enableDynamicTheming) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const DynamicLyricsBgTile(),
        ],
        if (!settings.enableDynamicTheming && !settings.dynamicLyrics) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const BlurredArtworkLyricsTile(),
        ],
        if (settings.enableDynamicTheming || settings.dynamicLyrics) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const DynamicColorActiveLyricsTile(),
        ],
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const LyricsAlignmentTile(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const FlatProgressBarTile(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const PlainTimestampsTile(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const ShowQualityBadgeTile(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const EnablePlayerGradientTile(),
        if (settings.enablePlayerGradient) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const KeepBackgroundGradientTile(),
        ],
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const UseNewFontTile(),
        if (settings.useNewFont) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const FontFamilySelectionTile(),
        ],
        // Darkness sliders
        if (settings.enableDynamicTheming) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const HomeDarknessSlider(),
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const SongsDarknessSlider(),
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const LibraryDarknessSlider(),
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const MusicDarknessSlider(),
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const LyricsDarknessSlider(),
        ] else if (settings.dynamicLyrics ||
            settings.keepBackgroundGradient ||
            settings.blurredArtworkForLyrics) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const LyricsDarknessSlider(),
        ],
      ];
    } else if (categoryId == 'dashboard') {
      children = [
        const ShowArtistsRowTile(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const ShowAlbumsRowTile(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const ShowGenresRowTile(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const ReorderDashboardSectionsTile(),
      ];
    } else if (categoryId == 'playback') {
      children = [
        const LanguageTile(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const VerticalMotionEffectTile(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const StopServiceTile(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const InternetModeTile(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const DownloadMissingArtworkTile(),
      ];
    } else if (categoryId == 'audio_playback') {
      children = [
        const FadePlayPauseStopTile(),
        if (settings.fadePlayPauseStop) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const FadeDurationSlider(),
        ],
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const FadeOnSeekTile(),
        if (settings.fadeOnSeek) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const SeekFadeDurationSlider(),
        ],
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const AudioCrossfadeTile(),
        if (settings.enableCrossfade) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const AutoCrossfadeDurationSlider(),
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const ManualCrossfadeDurationSlider(),
        ],
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const SilenceBetweenTracksSlider(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const ManageAudioFocusTile(),
        if (settings.audioFocus) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const ResumeAfterCallTile(),
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const ResumeOnStartTile(),
          const Divider(height: 1, indent: 72, color: Colors.white10),
          const PermanentAudioFocusChangeTile(),
        ],
      ];
    } else if (categoryId == 'library') {
      children = [
        const LibraryFoldersList(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const AddFolderTile(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const SyncLyricsOfflineTile(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const RescanLibraryTile(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const ResetLibraryTile(),
      ];
    } else if (categoryId == 'about') {
      children = [
        const LooperVersionTile(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        const LyricsProviderTile(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        AboutMaintainerRow(
          name: 'Nilesh Suthar',
          role: l10n.creatorAndMaintainer,
          avatar: 'assets/about/maintainer_avatar.png',
          github: 'https://github.com/SthrNilshaaa',
          telegram: 'https://t.me/neelshy',
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        AboutMaintainerRow(
          name: 'Karan Suthar',
          role: l10n.designerAndMaintainer,
          avatar: 'assets/about/designer_avatar.png',
          github: 'https://github.com/sthrkaran',
          telegram: 'https://t.me/karanwhy',
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        AboutMaintainerRow(
          name: 'Madan Suthar',
          role: 'Active Contributor',
          avatar: 'assets/about/designer_avatar.png',
          github: 'https://github.com/',
          telegram: 'https://t.me/madansthr',
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.appInfoPrivacy.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(settings.accentColor).withValues(alpha: 0.8),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              InfoSubTile(
                icon: LucideIcons.music,
                title: l10n.corePurpose,
                description: l10n.corePurposeDesc,
              ),
              const SizedBox(height: 16),
              InfoSubTile(
                icon: LucideIcons.shieldCheck,
                title: l10n.whyPermissionsUsed,
                description: l10n.whyPermissionsUsedDesc,
              ),
              const SizedBox(height: 16),
              InfoSubTile(
                icon: LucideIcons.globe,
                title: l10n.whyInternetUsed,
                description: l10n.whyInternetUsedDesc,
              ),
              const SizedBox(height: 16),
              InfoSubTile(
                icon: LucideIcons.lock,
                title: l10n.privacySafety,
                description: l10n.privacySafetyDesc,
              ),
            ],
          ),
        ),
      ];
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PremiumSection(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      bottomLeft: Radius.circular(32),
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    width: 48,
                    height: 48,
                    useBlur: useBlur,
                    forceNoBlur: true,
                    useExpanded: false,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48, height: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                physics: const BouncingScrollPhysics(),
                children: categoryId == 'about'
                    ? [
                        // Top Section Card
                        PremiumSection(
                          useBlur: useBlur,
                          forceNoBlur: true,
                          borderRadius: BorderRadius.circular(14),
                          useExpanded: false,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/main_logo.svg',
                                height: 36,
                                fit: BoxFit.contain,
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(32),
                                    bottomLeft: Radius.circular(32),
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'Version 2.1',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  final Uri uri = Uri.parse(
                                      'https://github.com/SthrNilshaaa/looper');
                                  try {
                                    await launchUrl(uri,
                                        mode: LaunchMode.externalApplication);
                                  } catch (e) {
                                    debugPrint('Error launching URL: $e');
                                  }
                                },
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/about/github_icon.svg',
                                      width: 32,
                                      height: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Give Star on Github Card
                        const GitHubStarTile(),
                        const SizedBox(height: 32),
                        // Maintainers Header
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Maintainers',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Person behind LooperPlayer',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Maintainers Card
                        PremiumSection(
                          useBlur: useBlur,
                          forceNoBlur: true,
                          borderRadius: BorderRadius.circular(14),
                          useExpanded: false,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: children.sublist(2, 5),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // App Info & Privacy Card
                        PremiumSection(
                          useBlur: useBlur,
                          forceNoBlur: true,
                          borderRadius: BorderRadius.circular(14),
                          useExpanded: false,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: children.last,
                        ),
                        const SizedBox(height: 120),
                      ]
                    : [
                        PremiumSection(
                          useBlur: useBlur,
                          forceNoBlur: true,
                          borderRadius: BorderRadius.circular(24),
                          useExpanded: false,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: children,
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
