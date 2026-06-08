import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:animations/animations.dart';

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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
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
      // 1. Theme & Appearance
      SettingsSearchItem(
        title: l10n.dynamicTheming,
        subtitle: l10n.adaptColorsArtwork,
        category: l10n.theme,
        widget: SwitchListTile(
          secondary: const Icon(LucideIcons.palette, color: Colors.white70),
          title: Text(
            l10n.dynamicTheming,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.adaptColorsArtwork,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.enableDynamicTheming,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateDynamicTheming(value);
          },
        ),
      ),
      if (settings.enableDynamicTheming)
        SettingsSearchItem(
          title: l10n.disableBlurEffects,
          subtitle: l10n.turnOffBlursOptimize,
          category: l10n.theme,
          widget: SwitchListTile(
            secondary: const Icon(LucideIcons.eyeOff, color: Colors.white70),
            title: Text(
              l10n.disableBlurEffects,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.turnOffBlursOptimize,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.disableBlur,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateDisableBlur(value);
            },
          ),
        ),
      if (!settings.enableDynamicTheming) ...[
        SettingsSearchItem(
          title: 'Dynamic Accent Color',
          subtitle: 'Update only the accent color dynamically from the artwork',
          category: l10n.theme,
          widget: SwitchListTile(
            secondary: const Icon(
              LucideIcons.paintBucket,
              color: Colors.white70,
            ),
            title: const Text(
              'Dynamic Accent Color',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'Update only the accent color dynamically from the artwork',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.dynamicAccentColor,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateDynamicAccentColor(value);
            },
          ),
        ),
        SettingsSearchItem(
          title: l10n.pureBlackOled,
          subtitle: l10n.useAbsoluteBlackBg,
          category: l10n.theme,
          widget: SwitchListTile(
            secondary: const Icon(LucideIcons.moon, color: Colors.white70),
            title: Text(
              l10n.pureBlackOled,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.useAbsoluteBlackBg,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.darkTheme,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateDarkTheme(value);
            },
          ),
        ),
        if (!settings.dynamicAccentColor) ...[
          SettingsSearchItem(
            title: l10n.accentColor,
            subtitle: 'Choose quick accent colors',
            category: l10n.theme,
            widget: ListTile(
              leading: const Icon(LucideIcons.droplet, color: Colors.white70),
              title: Text(
                l10n.accentColor,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ColorCircle(
                    color: const Color(0xFF41C25E),
                    isSelected: settings.accentColor == 0xFF41C25E,
                    onTap: () => ref
                        .read(settingsProvider.notifier)
                        .updateAccentColor(0xFF41C25E),
                  ),
                  const SizedBox(width: 8),
                  _ColorCircle(
                    color: const Color(0xFFF7EAA6),
                    isSelected: settings.accentColor == 0xFFF7EAA6,
                    onTap: () => ref
                        .read(settingsProvider.notifier)
                        .updateAccentColor(0xFFF7EAA6),
                  ),
                  const SizedBox(width: 8),
                  _ColorCircle(
                    color: Colors.blueAccent,
                    isSelected: settings.accentColor == Colors.blueAccent.value,
                    onTap: () => ref
                        .read(settingsProvider.notifier)
                        .updateAccentColor(Colors.blueAccent.value),
                  ),
                ],
              ),
            ),
          ),
          SettingsSearchItem(
            title: l10n.customAccentColor,
            subtitle: l10n.selectCustomColor,
            category: l10n.theme,
            widget: ListTile(
              leading: const Icon(LucideIcons.palette, color: Colors.white70),
              title: Text(
                l10n.customAccentColor,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                l10n.selectCustomColor,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              trailing: _ColorCircle(
                color: Color(settings.accentColor),
                isSelected:
                    settings.accentColor != 0xFF41C25E &&
                    settings.accentColor != 0xFFF7EAA6 &&
                    settings.accentColor != Colors.blueAccent.value,
                onTap: () => _showCustomColorPicker(
                  context,
                  ref,
                  Color(settings.accentColor),
                ),
              ),
              onTap: () => _showCustomColorPicker(
                context,
                ref,
                Color(settings.accentColor),
              ),
            ),
          ),
        ],
      ],
      if (!settings.enableDynamicTheming)
        SettingsSearchItem(
          title: l10n.dynamicLyricsBg,
          subtitle: l10n.dynamicBgOnlyLyrics,
          category: l10n.theme,
          widget: SwitchListTile(
            secondary: const Icon(LucideIcons.music, color: Colors.white70),
            title: Text(
              l10n.dynamicLyricsBg,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.dynamicBgOnlyLyrics,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.dynamicLyrics,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateDynamicLyrics(value);
            },
          ),
        ),
      if (settings.enableDynamicTheming || settings.dynamicLyrics)
        SettingsSearchItem(
          title: l10n.dynamicColorActiveLyrics,
          subtitle: l10n.dynamicColorActiveLyricsDesc,
          category: l10n.theme,
          widget: SwitchListTile(
            secondary: const Icon(LucideIcons.palette, color: Colors.white70),
            title: Text(
              l10n.dynamicColorActiveLyrics,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.dynamicColorActiveLyricsDesc,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.dynamicColorActiveLyrics,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateDynamicColorActiveLyrics(value);
            },
          ),
        ),
      SettingsSearchItem(
        title: l10n.lyricsAlignment,
        subtitle: l10n.lyricsAlignmentDesc,
        category: l10n.theme,
        widget: ListTile(
          leading: const Icon(LucideIcons.alignCenter, color: Colors.white70),
          title: Text(
            l10n.lyricsAlignment,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.lyricsAlignmentDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          trailing: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10, width: 0.5),
            ),
            padding: const EdgeInsets.all(2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAlignmentButton(
                  context: context,
                  ref: ref,
                  alignment: 'left',
                  icon: LucideIcons.alignLeft,
                  currentAlignment: settings.lyricsAlignment,
                  accentColor: Color(settings.accentColor),
                ),
                _buildAlignmentButton(
                  context: context,
                  ref: ref,
                  alignment: 'center',
                  icon: LucideIcons.alignCenter,
                  currentAlignment: settings.lyricsAlignment,
                  accentColor: Color(settings.accentColor),
                ),
                _buildAlignmentButton(
                  context: context,
                  ref: ref,
                  alignment: 'right',
                  icon: LucideIcons.alignRight,
                  currentAlignment: settings.lyricsAlignment,
                  accentColor: Color(settings.accentColor),
                ),
              ],
            ),
          ),
        ),
      ),
      SettingsSearchItem(
        title: l10n.flatProgressBar,
        subtitle: l10n.disableSquigglyProgressBar,
        category: l10n.theme,
        widget: SwitchListTile(
          secondary: const Icon(LucideIcons.sliders, color: Colors.white70),
          title: Text(
            l10n.flatProgressBar,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.disableSquigglyProgressBar,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.disableSquiggle,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateDisableSquiggle(value);
          },
        ),
      ),
      SettingsSearchItem(
        title: l10n.plainTimestamps,
        subtitle: l10n.useStaticTextTimestamps,
        category: l10n.theme,
        widget: SwitchListTile(
          secondary: const Icon(LucideIcons.clock, color: Colors.white70),
          title: Text(
            l10n.plainTimestamps,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.useStaticTextTimestamps,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.disableAnimatedDuration,
          onChanged: (value) {
            ref
                .read(settingsProvider.notifier)
                .updateDisableAnimatedDuration(value);
          },
        ),
      ),
      SettingsSearchItem(
        title: l10n.showQualityBadge,
        subtitle: l10n.showQualityBadgeDesc,
        category: l10n.theme,
        widget: SwitchListTile(
          secondary: const Icon(LucideIcons.info, color: Colors.white70),
          title: Text(
            l10n.showQualityBadge,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.showQualityBadgeDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.showQualityBadge,
          onChanged: (value) {
            ref
                .read(settingsProvider.notifier)
                .updateShowQualityBadge(value);
          },
        ),
      ),
      SettingsSearchItem(
        title: l10n.enablePlayerGradient,
        subtitle: l10n.enablePlayerGradientDesc,
        category: l10n.theme,
        widget: SwitchListTile(
          secondary: const Icon(LucideIcons.sparkles, color: Colors.white70),
          title: Text(
            l10n.enablePlayerGradient,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.enablePlayerGradientDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.enablePlayerGradient,
          onChanged: (value) {
            ref
                .read(settingsProvider.notifier)
                .updateEnablePlayerGradient(value);
          },
        ),
      ),
      if (settings.enablePlayerGradient)
        SettingsSearchItem(
          title: l10n.keepBackgroundGradient,
          subtitle: l10n.keepBackgroundGradientDesc,
          category: l10n.theme,
          widget: SwitchListTile(
            secondary: const Icon(LucideIcons.layers, color: Colors.white70),
            title: Text(
              l10n.keepBackgroundGradient,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.keepBackgroundGradientDesc,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.keepBackgroundGradient,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateKeepBackgroundGradient(value);
            },
          ),
        ),
      SettingsSearchItem(
        title: 'Performance Optimizer Dashboard',
        subtitle: 'Show real-time performance optimizer stats overlay',
        category: l10n.theme,
        widget: SwitchListTile(
          secondary: const Icon(LucideIcons.activity, color: Colors.white70),
          title: const Text(
            'Performance Optimizer Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: const Text(
            'Show real-time performance optimizer stats overlay',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.showPerformanceOptimizer,
          onChanged: (value) {
            ref
                .read(settingsProvider.notifier)
                .updateShowPerformanceOptimizer(value);
          },
        ),
      ),

      // 2. Home Screen Customization
      SettingsSearchItem(
        title: l10n.showArtistsRow,
        subtitle: l10n.showArtistsRowDesc,
        category: l10n.homeDashboardSettings,
        widget: SwitchListTile(
          secondary: const Icon(LucideIcons.user, color: Colors.white70),
          title: Text(
            l10n.showArtistsRow,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.showArtistsRowDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.showHomeArtists,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateShowHomeArtists(value);
          },
        ),
      ),
      SettingsSearchItem(
        title: l10n.showAlbumsRow,
        subtitle: l10n.showAlbumsRowDesc,
        category: l10n.homeDashboardSettings,
        widget: SwitchListTile(
          secondary: const Icon(LucideIcons.disc, color: Colors.white70),
          title: Text(
            l10n.showAlbumsRow,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.showAlbumsRowDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.showHomeAlbums,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateShowHomeAlbums(value);
          },
        ),
      ),
      SettingsSearchItem(
        title: l10n.showGenresRow,
        subtitle: l10n.showGenresRowDesc,
        category: l10n.homeDashboardSettings,
        widget: SwitchListTile(
          secondary: const Icon(LucideIcons.music, color: Colors.white70),
          title: Text(
            l10n.showGenresRow,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.showGenresRowDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.showHomeGenres,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateShowHomeGenres(value);
          },
        ),
      ),
      SettingsSearchItem(
        title: l10n.reorderDashboardSections,
        subtitle: l10n.reorderDashboardSectionsDesc,
        category: l10n.homeDashboardSettings,
        widget: ListTile(
          leading: const Icon(LucideIcons.listOrdered, color: Colors.white70),
          title: Text(
            l10n.reorderDashboardSections,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.reorderDashboardSectionsDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          trailing: const Icon(LucideIcons.chevronRight, color: Colors.white30),
          onTap: () {
            _showReorderBottomSheet(context, ref, settings);
          },
        ),
      ),

      // 3. Playback & Language
      SettingsSearchItem(
        title: l10n.language,
        subtitle: 'Select application language',
        category: l10n.playbackAudio,
        widget: ListTile(
          leading: const Icon(LucideIcons.languages, color: Colors.white70),
          title: Text(
            l10n.language,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: DropdownButton<String>(
            value: settings.language,
            dropdownColor: const Color(0xFF1A1A1A),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(
                value: '',
                child: Text(
                  'System Default',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              DropdownMenuItem(
                value: 'en',
                child: Text('English', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'es',
                child: Text('Español', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'fr',
                child: Text('Français', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'de',
                child: Text('Deutsch', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'pt',
                child: Text('Português', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'ru',
                child: Text('Русский', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'it',
                child: Text('Italiano', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'zh',
                child: Text('中文', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'ja',
                child: Text('日本語', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'ko',
                child: Text('한국어', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'ar',
                child: Text('العربية', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'tr',
                child: Text('Türkçe', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'nl',
                child: Text(
                  'Nederlands',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              DropdownMenuItem(
                value: 'hi',
                child: Text('हिन्दी', style: TextStyle(color: Colors.white)),
              ),
            ],
            onChanged: (lang) {
              if (lang != null) {
                ref.read(settingsProvider.notifier).updateLanguage(lang);
              }
            },
          ),
        ),
      ),
      SettingsSearchItem(
        title: 'Vertical Motion Effect Player',
        subtitle: 'Swipe down on the expanded player to dismiss it',
        category: l10n.playbackAudio,
        widget: SwitchListTile(
          secondary: const Icon(LucideIcons.move, color: Colors.white70),
          title: const Text(
            'Vertical Motion Effect Player',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: const Text(
            'Swipe down on the expanded player to dismiss it',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.enableSlideGesture,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateEnableSlideGesture(value);
          },
        ),
      ),
      SettingsSearchItem(
        title: 'Stop Service on App Dismissal',
        subtitle:
            'Stop playback and close the app when swiped away from recent panel',
        category: l10n.playbackAudio,
        widget: SwitchListTile(
          secondary: const Icon(LucideIcons.power, color: Colors.white70),
          title: const Text(
            'Stop Service on App Dismissal',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: const Text(
            'Stop playback and close the app when swiped away from recent panel',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.stopOnTaskRemoved,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateStopOnTaskRemoved(value);
          },
        ),
      ),
      SettingsSearchItem(
        title: l10n.internetMode,
        subtitle: l10n.enableNetworkLyricsArt,
        category: l10n.playbackAudio,
        widget: SwitchListTile(
          secondary: const Icon(LucideIcons.globe, color: Colors.white70),
          title: Text(
            l10n.internetMode,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.enableNetworkLyricsArt,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.enableInternet,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateEnableInternet(value);
          },
        ),
      ),
      SettingsSearchItem(
        title: l10n.downloadMissingArtwork,
        subtitle: l10n.downloadMissingArtworkDesc,
        category: l10n.playbackAudio,
        widget: SwitchListTile(
          secondary: const Icon(LucideIcons.image, color: Colors.white70),
          title: Text(
            l10n.downloadMissingArtwork,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.downloadMissingArtworkDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.downloadArtwork,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateDownloadArtwork(value);
          },
        ),
      ),

      // 4. Audio & Playback
      SettingsSearchItem(
        title: l10n.fadePlayPauseStop,
        subtitle: l10n.fadePlayPauseStopDesc,
        category: l10n.audioPlayback,
        widget: SwitchListTile(
          secondary: const Icon(LucideIcons.music, color: Colors.white70),
          title: Text(
            l10n.fadePlayPauseStop,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            l10n.fadePlayPauseStopDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.fadePlayPauseStop,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateFadePlayPauseStop(value);
          },
        ),
      ),
      if (settings.fadePlayPauseStop)
        SettingsSearchItem(
          title: l10n.fadeDuration,
          subtitle: l10n.fadeDurationDesc,
          category: l10n.audioPlayback,
          widget: _SettingsSliderTile(
            icon: LucideIcons.sliders,
            title: l10n.fadeDuration,
            subtitle: l10n.fadeDurationDesc,
            value: settings.playPauseStopFadeLength.toDouble(),
            min: 10,
            max: 1000,
            divisions: 99,
            suffix: 'ms',
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updatePlayPauseStopFadeLength(value.round());
            },
          ),
        ),
      SettingsSearchItem(
        title: l10n.fadeOnSeek,
        subtitle: l10n.fadeOnSeekDesc,
        category: l10n.audioPlayback,
        widget: SwitchListTile(
          secondary: const Icon(LucideIcons.sliders, color: Colors.white70),
          title: Text(
            l10n.fadeOnSeek,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            l10n.fadeOnSeekDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.fadeOnSeek,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateFadeOnSeek(value);
          },
        ),
      ),
      if (settings.fadeOnSeek)
        SettingsSearchItem(
          title: l10n.seekFadeDuration,
          subtitle: l10n.seekFadeDurationDesc,
          category: l10n.audioPlayback,
          widget: _SettingsSliderTile(
            icon: LucideIcons.sliders,
            title: l10n.seekFadeDuration,
            subtitle: l10n.seekFadeDurationDesc,
            value: settings.seekFadeLength.toDouble(),
            min: 10,
            max: 500,
            divisions: 49,
            suffix: 'ms',
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSeekFadeLength(value.round());
            },
          ),
        ),
      SettingsSearchItem(
        title: l10n.audioCrossfade,
        subtitle: l10n.audioCrossfadeDesc,
        category: l10n.audioPlayback,
        widget: SwitchListTile(
          secondary: const Icon(LucideIcons.gitCompare, color: Colors.white70),
          title: Text(
            l10n.audioCrossfade,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            l10n.audioCrossfadeDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.enableCrossfade,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateEnableCrossfade(value);
          },
        ),
      ),
      if (settings.enableCrossfade) ...[
        SettingsSearchItem(
          title: l10n.autoCrossfadeDuration,
          subtitle: l10n.autoCrossfadeDurationDesc,
          category: l10n.audioPlayback,
          widget: _SettingsSliderTile(
            icon: LucideIcons.sliders,
            title: l10n.autoCrossfadeDuration,
            subtitle: l10n.autoCrossfadeDurationDesc,
            value: settings.crossfadeLength.toDouble(),
            min: 100,
            max: 15000,
            divisions: 149,
            suffix: 'ms',
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateCrossfadeLength(value.round());
            },
          ),
        ),
        SettingsSearchItem(
          title: l10n.manualCrossfadeDuration,
          subtitle: l10n.manualCrossfadeDurationDesc,
          category: l10n.audioPlayback,
          widget: _SettingsSliderTile(
            icon: LucideIcons.sliders,
            title: l10n.manualCrossfadeDuration,
            subtitle: l10n.manualCrossfadeDurationDesc,
            value: settings.shortManualCrossfadeLength.toDouble(),
            min: 10,
            max: 1000,
            divisions: 99,
            suffix: 'ms',
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateShortManualCrossfadeLength(value.round());
            },
          ),
        ),
      ],
      SettingsSearchItem(
        title: l10n.silenceBetweenTracksTitle,
        subtitle: l10n.silenceBetweenTracksDesc,
        category: l10n.audioPlayback,
        widget: _SettingsSliderTile(
          icon: LucideIcons.clock,
          title: l10n.silenceBetweenTracksTitle,
          subtitle: l10n.silenceBetweenTracksDesc,
          value: settings.silenceBetweenTracks.toDouble(),
          min: 0,
          max: 5000,
          divisions: 50,
          suffix: 'ms',
          onChanged: (value) {
            ref
                .read(settingsProvider.notifier)
                .updateSilenceBetweenTracks(value.round());
          },
        ),
      ),
      SettingsSearchItem(
        title: l10n.manageAudioFocusTitle,
        subtitle: l10n.manageAudioFocusDesc,
        category: l10n.audioPlayback,
        widget: SwitchListTile(
          secondary: const Icon(LucideIcons.phoneCall, color: Colors.white70),
          title: Text(
            l10n.manageAudioFocusTitle,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            l10n.manageAudioFocusDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.audioFocus,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateAudioFocus(value);
          },
        ),
      ),
      if (settings.audioFocus) ...[
        SettingsSearchItem(
          title: l10n.resumeAfterCallTitle,
          subtitle: l10n.resumeAfterCallDesc,
          category: l10n.audioPlayback,
          widget: SwitchListTile(
            secondary: const Icon(LucideIcons.phoneCall, color: Colors.white70),
            title: Text(
              l10n.resumeAfterCallTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.resumeAfterCallDesc,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.resumeAfterCall,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateResumeAfterCall(value);
            },
          ),
        ),
        SettingsSearchItem(
          title: l10n.resumeOnStartTitle,
          subtitle: l10n.resumeOnStartDesc,
          category: l10n.audioPlayback,
          widget: SwitchListTile(
            secondary: const Icon(LucideIcons.power, color: Colors.white70),
            title: Text(
              l10n.resumeOnStartTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.resumeOnStartDesc,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.resumeOnStart,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateResumeOnStart(value);
            },
          ),
        ),
        SettingsSearchItem(
          title: l10n.permanentFocusChangePause,
          subtitle: l10n.permanentFocusChangePauseDesc,
          category: l10n.audioPlayback,
          widget: SwitchListTile(
            secondary: const Icon(
              LucideIcons.alertCircle,
              color: Colors.white70,
            ),
            title: Text(
              l10n.permanentFocusChangePause,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.permanentFocusChangePauseDesc,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.permanentAudioFocusChange,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updatePermanentAudioFocusChange(value);
            },
          ),
        ),
      ],

      // 5. Music Library
      SettingsSearchItem(
        title: l10n.addFolder,
        subtitle: 'Scan a new folder for audio files',
        category: l10n.musicLibrary,
        widget: ListTile(
          leading: const Icon(LucideIcons.plus, color: Colors.white70),
          title: Text(
            l10n.addFolder,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            LucideIcons.chevronRight,
            color: Colors.white30,
            size: 18,
          ),
          onTap: () async {
            HapticFeedback.lightImpact();
            final String? path = await FilePicker.platform.getDirectoryPath();
            if (path != null) {
              ref.read(libraryProvider.notifier).scanLibrary(path);
            }
          },
        ),
      ),
      SettingsSearchItem(
        title: l10n.syncLyricsOffline,
        subtitle: l10n.downloadingLyricsOffline,
        category: l10n.musicLibrary,
        widget: ListTile(
          leading: const Icon(LucideIcons.downloadCloud, color: Colors.white70),
          title: Text(
            l10n.syncLyricsOffline,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            LucideIcons.chevronRight,
            color: Colors.white30,
            size: 18,
          ),
          onTap: () {
            HapticFeedback.mediumImpact();
            ref.read(libraryProvider.notifier).prefetchLibraryLyrics();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.downloadingLyricsOffline)),
            );
          },
        ),
      ),
      SettingsSearchItem(
        title: l10n.rescanLibrary,
        subtitle: l10n.scanningLibrary,
        category: l10n.musicLibrary,
        widget: ListTile(
          leading: const Icon(LucideIcons.refreshCcw, color: Colors.white70),
          title: Text(
            l10n.rescanLibrary,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            LucideIcons.chevronRight,
            color: Colors.white30,
            size: 18,
          ),
          onTap: () {
            HapticFeedback.mediumImpact();
            ref.read(libraryProvider.notifier).scanSavedFolders();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.scanningLibrary)));
          },
        ),
      ),
      SettingsSearchItem(
        title: l10n.resetLibrary,
        subtitle: 'Clear library data',
        category: l10n.musicLibrary,
        widget: ListTile(
          leading: const Icon(LucideIcons.trash2, color: Colors.redAccent),
          title: Text(
            l10n.resetLibrary,
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(
            LucideIcons.alertTriangle,
            color: Colors.redAccent,
            size: 16,
          ),
          onTap: () {
            HapticFeedback.heavyImpact();
            _showClearDialog(context, l10n);
          },
        ),
      ),

      // 6. About & Creators
      SettingsSearchItem(
        title: 'Looper Player Version',
        subtitle: 'Version 2.0.00',
        category: l10n.aboutAndMaintainers,
        widget: ListTile(
          leading: const Icon(LucideIcons.info, color: Colors.white70),
          title: const Text(
            'Looper Player',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: const Text(
            'Version 2.0.00',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          onTap: () async {
            final Uri uri = Uri.parse('https://github.com/SthrNilshaaa/looper');
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (e) {
              debugPrint('Error launching URL: $e');
            }
          },
        ),
      ),
      SettingsSearchItem(
        title: l10n.lyricsProvider,
        subtitle: 'lrclib.net',
        category: l10n.aboutAndMaintainers,
        widget: ListTile(
          leading: const Icon(LucideIcons.music, color: Colors.white70),
          title: Text(
            l10n.lyricsProvider,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: const Text(
            'lrclib.net',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          trailing: const Icon(
            LucideIcons.externalLink,
            color: Colors.white30,
            size: 16,
          ),
          onTap: () async {
            final Uri uri = Uri.parse('https://lrclib.net');
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (e) {
              debugPrint('Error launching URL: $e');
            }
          },
        ),
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
        SwitchListTile(
          secondary: const Icon(LucideIcons.palette, color: Colors.white70),
          title: Text(
            l10n.dynamicTheming,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.adaptColorsArtwork,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.enableDynamicTheming,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateDynamicTheming(value);
          },
        ),
        if (settings.enableDynamicTheming) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          SwitchListTile(
            secondary: const Icon(LucideIcons.eyeOff, color: Colors.white70),
            title: Text(
              l10n.disableBlurEffects,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.turnOffBlursOptimize,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.disableBlur,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateDisableBlur(value);
            },
          ),
        ],
        if (!settings.enableDynamicTheming) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          SwitchListTile(
            secondary: const Icon(
              LucideIcons.paintBucket,
              color: Colors.white70,
            ),
            title: const Text(
              'Dynamic Accent Color',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'Update only the accent color dynamically from the artwork',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.dynamicAccentColor,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateDynamicAccentColor(value);
            },
          ),
          const Divider(height: 1, indent: 72, color: Colors.white10),
          SwitchListTile(
            secondary: const Icon(LucideIcons.moon, color: Colors.white70),
            title: Text(
              l10n.pureBlackOled,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.useAbsoluteBlackBg,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.darkTheme,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateDarkTheme(value);
            },
          ),
          if (!settings.dynamicAccentColor) ...[
            const Divider(height: 1, indent: 72, color: Colors.white10),
            ListTile(
              leading: const Icon(LucideIcons.droplet, color: Colors.white70),
              title: Text(
                l10n.accentColor,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ColorCircle(
                    color: const Color(0xFF41C25E),
                    isSelected: settings.accentColor == 0xFF41C25E,
                    onTap: () => ref
                        .read(settingsProvider.notifier)
                        .updateAccentColor(0xFF41C25E),
                  ),
                  const SizedBox(width: 8),
                  _ColorCircle(
                    color: const Color(0xFFF7EAA6),
                    isSelected: settings.accentColor == 0xFFF7EAA6,
                    onTap: () => ref
                        .read(settingsProvider.notifier)
                        .updateAccentColor(0xFFF7EAA6),
                  ),
                  const SizedBox(width: 8),
                  _ColorCircle(
                    color: Colors.blueAccent,
                    isSelected: settings.accentColor == Colors.blueAccent.value,
                    onTap: () => ref
                        .read(settingsProvider.notifier)
                        .updateAccentColor(Colors.blueAccent.value),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 72, color: Colors.white10),
            ListTile(
              leading: const Icon(LucideIcons.palette, color: Colors.white70),
              title: Text(
                l10n.customAccentColor,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                l10n.selectCustomColor,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              trailing: _ColorCircle(
                color: Color(settings.accentColor),
                isSelected:
                    settings.accentColor != 0xFF41C25E &&
                    settings.accentColor != 0xFFF7EAA6 &&
                    settings.accentColor != Colors.blueAccent.value,
                onTap: () => _showCustomColorPicker(
                  context,
                  ref,
                  Color(settings.accentColor),
                ),
              ),
              onTap: () => _showCustomColorPicker(
                context,
                ref,
                Color(settings.accentColor),
              ),
            ),
          ],
        ],
        if (!settings.enableDynamicTheming) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          SwitchListTile(
            secondary: const Icon(LucideIcons.music, color: Colors.white70),
            title: Text(
              l10n.dynamicLyricsBg,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.dynamicBgOnlyLyrics,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.dynamicLyrics,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateDynamicLyrics(value);
            },
          ),
        ],
        if (settings.enableDynamicTheming || settings.dynamicLyrics) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          SwitchListTile(
            secondary: const Icon(LucideIcons.palette, color: Colors.white70),
            title: Text(
              l10n.dynamicColorActiveLyrics,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.dynamicColorActiveLyricsDesc,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.dynamicColorActiveLyrics,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateDynamicColorActiveLyrics(value);
            },
          ),
        ],
        const Divider(height: 1, indent: 72, color: Colors.white10),
        ListTile(
          leading: const Icon(LucideIcons.alignCenter, color: Colors.white70),
          title: Text(
            l10n.lyricsAlignment,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.lyricsAlignmentDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          trailing: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10, width: 0.5),
            ),
            padding: const EdgeInsets.all(2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAlignmentButton(
                  context: context,
                  ref: ref,
                  alignment: 'left',
                  icon: LucideIcons.alignLeft,
                  currentAlignment: settings.lyricsAlignment,
                  accentColor: Color(settings.accentColor),
                ),
                _buildAlignmentButton(
                  context: context,
                  ref: ref,
                  alignment: 'center',
                  icon: LucideIcons.alignCenter,
                  currentAlignment: settings.lyricsAlignment,
                  accentColor: Color(settings.accentColor),
                ),
                _buildAlignmentButton(
                  context: context,
                  ref: ref,
                  alignment: 'right',
                  icon: LucideIcons.alignRight,
                  currentAlignment: settings.lyricsAlignment,
                  accentColor: Color(settings.accentColor),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        SwitchListTile(
          secondary: const Icon(LucideIcons.sliders, color: Colors.white70),
          title: Text(
            l10n.flatProgressBar,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.disableSquigglyProgressBar,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.disableSquiggle,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateDisableSquiggle(value);
          },
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        SwitchListTile(
          secondary: const Icon(LucideIcons.clock, color: Colors.white70),
          title: Text(
            l10n.plainTimestamps,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.useStaticTextTimestamps,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.disableAnimatedDuration,
          onChanged: (value) {
            ref
                .read(settingsProvider.notifier)
                .updateDisableAnimatedDuration(value);
          },
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        SwitchListTile(
          secondary: const Icon(LucideIcons.info, color: Colors.white70),
          title: Text(
            l10n.showQualityBadge,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.showQualityBadgeDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.showQualityBadge,
          onChanged: (value) {
            ref
                .read(settingsProvider.notifier)
                .updateShowQualityBadge(value);
          },
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        SwitchListTile(
          secondary: const Icon(LucideIcons.sparkles, color: Colors.white70),
          title: Text(
            l10n.enablePlayerGradient,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.enablePlayerGradientDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.enablePlayerGradient,
          onChanged: (value) {
            ref
                .read(settingsProvider.notifier)
                .updateEnablePlayerGradient(value);
          },
        ),
        if (settings.enablePlayerGradient) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          SwitchListTile(
            secondary: const Icon(LucideIcons.layers, color: Colors.white70),
            title: Text(
              l10n.keepBackgroundGradient,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.keepBackgroundGradientDesc,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.keepBackgroundGradient,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateKeepBackgroundGradient(value);
     }, ),
        ],
        const Divider(height: 1, indent: 72, color: Colors.white10),
        SwitchListTile(
          secondary: const Icon(LucideIcons.activity, color: Colors.white70),
          title: const Text(
            'Performance Optimizer Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: const Text(
            'Show real-time performance optimizer stats overlay',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.showPerformanceOptimizer,
          onChanged: (value) {
            ref
                .read(settingsProvider.notifier)
                .updateShowPerformanceOptimizer(value);
          },
        ),
        if (settings.enableDynamicTheming) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          _SettingsSliderTile(
            icon: LucideIcons.home,
            title: l10n.homeDarkness,
            subtitle: l10n.homeDarknessDesc,
            value: ((settings.homeDarkness.isNaN || settings.homeDarkness == 0.0) ? 0.72 : settings.homeDarkness) * 100,
            min: 0.0,
            max: 100.0,
            divisions: 100,
            suffix: '%',
            onChanged: (val) {
              ref.read(settingsProvider.notifier).updateHomeDarkness(val / 100.0);
            },
          ),
          const Divider(height: 1, indent: 72, color: Colors.white10),
          _SettingsSliderTile(
            icon: LucideIcons.music,
            title: l10n.songsDarkness,
            subtitle: l10n.songsDarknessDesc,
            value: ((settings.songsDarkness.isNaN || settings.songsDarkness == 0.0) ? 0.72 : settings.songsDarkness) * 100,
            min: 0.0,
            max: 100.0,
            divisions: 100,
            suffix: '%',
            onChanged: (val) {
              ref.read(settingsProvider.notifier).updateSongsDarkness(val / 100.0);
            },
          ),
          const Divider(height: 1, indent: 72, color: Colors.white10),
          _SettingsSliderTile(
            icon: LucideIcons.library,
            title: l10n.libraryDarkness,
            subtitle: l10n.libraryDarknessDesc,
            value: ((settings.libraryDarkness.isNaN || settings.libraryDarkness == 0.0) ? 0.72 : settings.libraryDarkness) * 100,
            min: 0.0,
            max: 100.0,
            divisions: 100,
            suffix: '%',
            onChanged: (val) {
              ref.read(settingsProvider.notifier).updateLibraryDarkness(val / 100.0);
            },
          ),
          const Divider(height: 1, indent: 72, color: Colors.white10),
          _SettingsSliderTile(
            icon: LucideIcons.playCircle,
            title: l10n.musicDarkness,
            subtitle: l10n.musicDarknessDesc,
            value: ((settings.musicDarkness.isNaN || settings.musicDarkness == 0.0) ? 0.62 : settings.musicDarkness) * 100,
            min: 0.0,
            max: 100.0,
            divisions: 100,
            suffix: '%',
            onChanged: (val) {
              ref.read(settingsProvider.notifier).updateMusicDarkness(val / 100.0);
            },
          ),
          const Divider(height: 1, indent: 72, color: Colors.white10),
          _SettingsSliderTile(
            icon: LucideIcons.alignLeft,
            title: l10n.lyricsDarkness,
            subtitle: l10n.lyricsDarknessDesc,
            value: ((settings.lyricsDarkness.isNaN || settings.lyricsDarkness == 0.0) ? 0.55 : settings.lyricsDarkness) * 100,
            min: 0.0,
            max: 100.0,
            divisions: 100,
            suffix: '%',
            onChanged: (val) {
              ref.read(settingsProvider.notifier).updateLyricsDarkness(val / 100.0);
            },
          ),
        ] else if (settings.dynamicLyrics || settings.keepBackgroundGradient) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          _SettingsSliderTile(
            icon: LucideIcons.alignLeft,
            title: l10n.lyricsDarkness,
            subtitle: l10n.lyricsDarknessDesc,
            value: ((settings.lyricsDarkness.isNaN || settings.lyricsDarkness == 0.0) ? 0.55 : settings.lyricsDarkness) * 100,
            min: 0.0,
            max: 100.0,
            divisions: 100,
            suffix: '%',
            onChanged: (val) {
              ref.read(settingsProvider.notifier).updateLyricsDarkness(val / 100.0);
            },
          ),
        ],
      ];
    } else if (categoryId == 'dashboard') {
      children = [
        SwitchListTile(
          secondary: const Icon(LucideIcons.user, color: Colors.white70),
          title: Text(
            l10n.showArtistsRow,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.showArtistsRowDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.showHomeArtists,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateShowHomeArtists(value);
          },
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        SwitchListTile(
          secondary: const Icon(LucideIcons.disc, color: Colors.white70),
          title: Text(
            l10n.showAlbumsRow,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.showAlbumsRowDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.showHomeAlbums,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateShowHomeAlbums(value);
          },
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        SwitchListTile(
          secondary: const Icon(LucideIcons.music, color: Colors.white70),
          title: Text(
            l10n.showGenresRow,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.showGenresRowDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.showHomeGenres,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateShowHomeGenres(value);
          },
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        ListTile(
          leading: const Icon(LucideIcons.listOrdered, color: Colors.white70),
          title: Text(
            l10n.reorderDashboardSections,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.reorderDashboardSectionsDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          trailing: const Icon(LucideIcons.chevronRight, color: Colors.white30),
          onTap: () {
            _showReorderBottomSheet(context, ref, settings);
          },
        ),
      ];
    } else if (categoryId == 'playback') {
      children = [
        ListTile(
          leading: const Icon(LucideIcons.languages, color: Colors.white70),
          title: Text(
            l10n.language,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: DropdownButton<String>(
            value: settings.language,
            dropdownColor: const Color(0xFF1A1A1A),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(
                value: '',
                child: Text(
                  'System Default',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              DropdownMenuItem(
                value: 'en',
                child: Text('English', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'es',
                child: Text('Español', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'fr',
                child: Text('Français', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'de',
                child: Text('Deutsch', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'pt',
                child: Text('Português', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'ru',
                child: Text('Русский', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'it',
                child: Text('Italiano', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'zh',
                child: Text('中文', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'ja',
                child: Text('日本語', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'ko',
                child: Text('한국어', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'ar',
                child: Text('العربية', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'tr',
                child: Text('Türkçe', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'nl',
                child: Text(
                  'Nederlands',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              DropdownMenuItem(
                value: 'hi',
                child: Text('हिन्दी', style: TextStyle(color: Colors.white)),
              ),
            ],
            onChanged: (lang) {
              if (lang != null) {
                ref.read(settingsProvider.notifier).updateLanguage(lang);
              }
            },
          ),
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        SwitchListTile(
          secondary: const Icon(LucideIcons.move, color: Colors.white70),
          title: const Text(
            'Vertical Motion Effect Player',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: const Text(
            'Swipe down on the expanded player to dismiss it',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.enableSlideGesture,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateEnableSlideGesture(value);
          },
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        SwitchListTile(
          secondary: const Icon(LucideIcons.power, color: Colors.white70),
          title: const Text(
            'Stop Service on App Dismissal',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: const Text(
            'Stop playback and close the app when swiped away from recent panel',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.stopOnTaskRemoved,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateStopOnTaskRemoved(value);
          },
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        SwitchListTile(
          secondary: const Icon(LucideIcons.globe, color: Colors.white70),
          title: Text(
            l10n.internetMode,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.enableNetworkLyricsArt,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.enableInternet,
          onChanged: (value) {
            ref
                .read(settingsProvider.notifier)
                .updateKeepBackgroundGradient(value);
            ref.read(settingsProvider.notifier).updateEnableInternet(value);
          },
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        SwitchListTile(
          secondary: const Icon(LucideIcons.image, color: Colors.white70),
          title: Text(
            l10n.downloadMissingArtwork,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.downloadMissingArtworkDesc,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.downloadArtwork,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateDownloadArtwork(value);
          },
        ),
      ];
    } else if (categoryId == 'audio_playback') {
      children = [
        SwitchListTile(
          secondary: const Icon(LucideIcons.music, color: Colors.white70),
          title: const Text(
            'Fade Play/Pause/Stop',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: const Text(
            'Smoothly fade audio volume when playing, pausing or stopping',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.fadePlayPauseStop,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateFadePlayPauseStop(value);
          },
        ),
        if (settings.fadePlayPauseStop) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          _SettingsSliderTile(
            icon: LucideIcons.sliders,
            title: 'Fade Duration',
            subtitle: 'Duration of play/pause/stop fade effect',
            value: settings.playPauseStopFadeLength.toDouble(),
            min: 10,
            max: 1000,
            divisions: 99,
            suffix: 'ms',
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updatePlayPauseStopFadeLength(value.round());
            },
          ),
        ],
        const Divider(height: 1, indent: 72, color: Colors.white10),
        SwitchListTile(
          secondary: const Icon(LucideIcons.sliders, color: Colors.white70),
          title: const Text(
            'Fade on Seek',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: const Text(
            'Smoothly fade audio volume out and in when seeking',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.fadeOnSeek,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateFadeOnSeek(value);
          },
        ),
        if (settings.fadeOnSeek) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          _SettingsSliderTile(
            icon: LucideIcons.sliders,
            title: 'Seek Fade Duration',
            subtitle: 'Duration of seeking fade effect',
            value: settings.seekFadeLength.toDouble(),
            min: 10,
            max: 500,
            divisions: 49,
            suffix: 'ms',
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSeekFadeLength(value.round());
            },
          ),
        ],
        const Divider(height: 1, indent: 72, color: Colors.white10),
        SwitchListTile(
          secondary: const Icon(LucideIcons.gitCompare, color: Colors.white70),
          title: const Text(
            'Audio Crossfade',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: const Text(
            'Overlap tracks smoothly when changing songs',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.enableCrossfade,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateEnableCrossfade(value);
          },
        ),
        if (settings.enableCrossfade) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          _SettingsSliderTile(
            icon: LucideIcons.sliders,
            title: 'Auto Crossfade Duration',
            subtitle: 'Overlap duration when transitioning automatically',
            value: settings.crossfadeLength.toDouble(),
            min: 100,
            max: 15000,
            divisions: 149,
            suffix: 'ms',
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateCrossfadeLength(value.round());
            },
          ),
          const Divider(height: 1, indent: 72, color: Colors.white10),
          _SettingsSliderTile(
            icon: LucideIcons.sliders,
            title: 'Manual Crossfade Duration',
            subtitle: 'Overlap duration when skipping manually',
            value: settings.shortManualCrossfadeLength.toDouble(),
            min: 10,
            max: 1000,
            divisions: 99,
            suffix: 'ms',
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateShortManualCrossfadeLength(value.round());
            },
          ),
        ],
        const Divider(height: 1, indent: 72, color: Colors.white10),
        _SettingsSliderTile(
          icon: LucideIcons.clock,
          title: 'Silence Between Tracks',
          subtitle: 'Add a silence gap between tracks (0ms for gapless)',
          value: settings.silenceBetweenTracks.toDouble(),
          min: 0,
          max: 5000,
          divisions: 50,
          suffix: 'ms',
          onChanged: (value) {
            ref
                .read(settingsProvider.notifier)
                .updateSilenceBetweenTracks(value.round());
          },
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        SwitchListTile(
          secondary: const Icon(LucideIcons.phoneCall, color: Colors.white70),
          title: const Text(
            'Manage Audio Focus',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: const Text(
            'Request and respond to system audio focus changes',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          activeColor: Color(settings.accentColor),
          value: settings.audioFocus,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateAudioFocus(value);
          },
        ),
        if (settings.audioFocus) ...[
          const Divider(height: 1, indent: 72, color: Colors.white10),
          SwitchListTile(
            secondary: const Icon(LucideIcons.phoneCall, color: Colors.white70),
            title: const Text(
              'Resume after Call',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'Resume playing automatically on call hang up (if paused by call)',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.resumeAfterCall,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateResumeAfterCall(value);
            },
          ),
          const Divider(height: 1, indent: 72, color: Colors.white10),
          SwitchListTile(
            secondary: const Icon(LucideIcons.power, color: Colors.white70),
            title: const Text(
              'Resume on Start',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'Resume playing automatically when Looper Player is started',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.resumeOnStart,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateResumeOnStart(value);
            },
          ),
          const Divider(height: 1, indent: 72, color: Colors.white10),
          SwitchListTile(
            secondary: const Icon(
              LucideIcons.alertCircle,
              color: Colors.white70,
            ),
            title: const Text(
              'Permanent Focus Change Pause',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'Pause playing automatically on permanent audio focus loss',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            activeColor: Color(settings.accentColor),
            value: settings.permanentAudioFocusChange,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updatePermanentAudioFocusChange(value);
            },
          ),
        ],
      ];
    } else if (categoryId == 'library') {
      children = [
        const _LibraryFoldersList(),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        ListTile(
          leading: const Icon(LucideIcons.plus, color: Colors.white70),
          title: Text(
            l10n.addFolder,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            LucideIcons.chevronRight,
            color: Colors.white30,
            size: 18,
          ),
          onTap: () async {
            HapticFeedback.lightImpact();
            final String? path = await FilePicker.platform.getDirectoryPath();
            if (path != null) {
              ref.read(libraryProvider.notifier).scanLibrary(path);
            }
          },
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        ListTile(
          leading: const Icon(LucideIcons.downloadCloud, color: Colors.white70),
          title: Text(
            l10n.syncLyricsOffline,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            LucideIcons.chevronRight,
            color: Colors.white30,
            size: 18,
          ),
          onTap: () {
            HapticFeedback.mediumImpact();
            ref.read(libraryProvider.notifier).prefetchLibraryLyrics();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.downloadingLyricsOffline)),
            );
          },
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        ListTile(
          leading: const Icon(LucideIcons.refreshCcw, color: Colors.white70),
          title: Text(
            l10n.rescanLibrary,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            LucideIcons.chevronRight,
            color: Colors.white30,
            size: 18,
          ),
          onTap: () {
            HapticFeedback.mediumImpact();
            ref.read(libraryProvider.notifier).scanSavedFolders();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.scanningLibrary)));
          },
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        ListTile(
          leading: const Icon(LucideIcons.trash2, color: Colors.redAccent),
          title: Text(
            l10n.resetLibrary,
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(
            LucideIcons.alertTriangle,
            color: Colors.redAccent,
            size: 16,
          ),
          onTap: () {
            HapticFeedback.heavyImpact();
            _showClearDialog(context, l10n);
          },
        ),
      ];
    } else if (categoryId == 'about') {
      children = [
        ListTile(
          leading: const Icon(LucideIcons.info, color: Colors.white70),
          title: const Text(
            'Looper Player',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: const Text(
            'Version 2.0.00',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          onTap: () async {
            final Uri uri = Uri.parse('https://github.com/SthrNilshaaa/looper');
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (e) {
              debugPrint('Error launching URL: $e');
            }
          },
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        ListTile(
          leading: const Icon(LucideIcons.music, color: Colors.white70),
          title: Text(
            l10n.lyricsProvider,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: const Text(
            'lrclib.net',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          trailing: const Icon(
            LucideIcons.externalLink,
            color: Colors.white30,
            size: 16,
          ),
          onTap: () async {
            final Uri uri = Uri.parse('https://lrclib.net');
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (e) {
              debugPrint('Error launching URL: $e');
            }
          },
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        _MaintainerTile(
          name: 'Nilesh Suthar',
          role: l10n.creatorAndMaintainer,
          avatar: 'assets/about/maintainer_avatar.png',
          github: 'https://github.com/SthrNilshaaa',
          telegram: 'https://t.me/neelshy',
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        _MaintainerTile(
          name: 'Karan Suthar',
          role: l10n.designerAndMaintainer,
          avatar: 'assets/about/designer_avatar.png',
          github: 'https://github.com/sthrkaran',
          telegram: 'https://t.me/karanwhy',
        ),
        const Divider(height: 1, indent: 72, color: Colors.white10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.appInfoPrivacy,
                style: TextStyle(
                  fontSize: 11.ts,
                  fontWeight: FontWeight.bold,
                  color: Color(settings.accentColor).withValues(alpha: 0.8),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoSubTile(
                context: context,
                icon: LucideIcons.music,
                title: l10n.corePurpose,
                description: l10n.corePurposeDesc,
              ),
              const SizedBox(height: 12),
              _buildInfoSubTile(
                context: context,
                icon: LucideIcons.shieldCheck,
                title: l10n.whyPermissionsUsed,
                description: l10n.whyPermissionsUsedDesc,
              ),
              const SizedBox(height: 12),
              _buildInfoSubTile(
                context: context,
                icon: LucideIcons.globe,
                title: l10n.whyInternetUsed,
                description: l10n.whyInternetUsedDesc,
              ),
              const SizedBox(height: 12),
              _buildInfoSubTile(
                context: context,
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
                          borderRadius: BorderRadius.circular(14),
                          useExpanded: false,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/main_logo.svg',
                                height: 36,
                                fit: BoxFit.contain,
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                  'Version 2.0',
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
                                  final Uri uri = Uri.parse('https://github.com/SthrNilshaaa/looper');
                                  try {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
                        PremiumSection(
                          useBlur: useBlur,
                          borderRadius: BorderRadius.circular(14),
                          useExpanded: false,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            final Uri uri = Uri.parse('https://github.com/SthrNilshaaa/looper');
                            try {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } catch (e) {
                              debugPrint('Error launching URL: $e');
                            }
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Give Star on Github',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Support the project and show some love!',
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
                                size: 18,
                              ),
                            ],
                          ),
                        ),
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
                          borderRadius: BorderRadius.circular(14),
                          useExpanded: false,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              _buildAboutMaintainerRow(
                                context: context,
                                name: 'Nilesh Suthar',
                                role: l10n.creatorAndMaintainer,
                                avatar: 'assets/about/maintainer_avatar.png',
                                github: 'https://github.com/SthrNilshaaa',
                                telegram: 'https://t.me/neelshy',
                              ),
                              Divider(
                                height: 1,
                                thickness: 0.8,
                                color: Colors.white.withValues(alpha: 0.04),
                                indent: 72,
                                endIndent: 20,
                              ),
                              _buildAboutMaintainerRow(
                                context: context,
                                name: 'Karan Suthar',
                                role: l10n.designerAndMaintainer,
                                avatar: 'assets/about/designer_avatar.png',
                                github: 'https://github.com/sthrkaran',
                                telegram: 'https://t.me/karanwhy',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // App Info & Privacy Card
                        PremiumSection(
                          useBlur: useBlur,
                          borderRadius: BorderRadius.circular(14),
                          useExpanded: false,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                              _buildInfoSubTile(
                                context: context,
                                icon: LucideIcons.music,
                                title: l10n.corePurpose,
                                description: l10n.corePurposeDesc,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoSubTile(
                                context: context,
                                icon: LucideIcons.shieldCheck,
                                title: l10n.whyPermissionsUsed,
                                description: l10n.whyPermissionsUsedDesc,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoSubTile(
                                context: context,
                                icon: LucideIcons.globe,
                                title: l10n.whyInternetUsed,
                                description: l10n.whyInternetUsedDesc,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoSubTile(
                                context: context,
                                icon: LucideIcons.lock,
                                title: l10n.privacySafety,
                                description: l10n.privacySafetyDesc,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 120),
                      ]
                    : [
                        PremiumSection(
                          useBlur: useBlur,
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

  Widget _buildAboutMaintainerRow({
    required BuildContext context,
    required String name,
    required String role,
    required String avatar,
    required String github,
    required String telegram,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white10,
            backgroundImage: AssetImage(avatar),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              final Uri uri = Uri.parse(github);
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (e) {
                debugPrint('Error launching URL: $e');
              }
            },
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/about/github_icon.svg',
                width: 24,
                height: 24,
               
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              final Uri uri = Uri.parse(telegram);
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (e) {
                debugPrint('Error launching URL: $e');
              }
            },
            child: Container(
              width: 24,
              height: 24,
             
              child:SvgPicture.asset(
                'assets/about/telegram_icon.svg',
                width: 24,
                height: 24,
               
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Helper Top-Level Functions
// ---------------------------------------------------------------------

void _showCustomColorPicker(
  BuildContext context,
  WidgetRef ref,
  Color initialColor,
) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final currentAccent = ref.watch(settingsProvider).accentColor;
          return Container(
            height: 650,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Custom Accent Color',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'DMSans',
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Color(currentAccent),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: ColorPicker(
                      color: Color(currentAccent),
                      onChanged: (color) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateAccentColor(color.value);
                        setModalState(() {});
                      },
                      initialPicker: Picker.paletteHue,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: Color(currentAccent),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showReorderBottomSheet(
  BuildContext context,
  WidgetRef ref,
  AppSettings settings,
) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return StatefulBuilder(
        builder: (context, setModalState) {
          final currentSettings = ref.watch(settingsProvider);
          final currentOrder = List<String>.from(
            currentSettings.homeSectionOrder.isEmpty
                ? ['quick_picks', 'songs', 'albums', 'artists', 'genres']
                : currentSettings.homeSectionOrder,
          );

          final itemMeta = {
            'quick_picks': {
              'title': l10n.quickPicks,
              'description': l10n.quickPicksRowDesc,
              'icon': LucideIcons.sparkles,
            },
            'songs': {
              'title': l10n.songs,
              'description': l10n.recentlyAddedSongsRowDesc,
              'icon': LucideIcons.music,
            },
            'albums': {
              'title': l10n.albums,
              'description': l10n.albumsRowDesc,
              'icon': LucideIcons.disc,
            },
            'artists': {
              'title': l10n.artists,
              'description': l10n.artistsRowDesc,
              'icon': LucideIcons.user,
            },
            'genres': {
              'title': l10n.genres,
              'description': l10n.genresRowDesc,
              'icon': LucideIcons.library,
            },
          };

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  l10n.reorderDashboardSections,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DMSans',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.reorderDashboardSectionsDesc,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: currentOrder.length,
                    onReorder: (oldIndex, newIndex) {
                      HapticFeedback.lightImpact();
                      setModalState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final String item = currentOrder.removeAt(oldIndex);
                        currentOrder.insert(newIndex, item);
                        ref
                            .read(settingsProvider.notifier)
                            .updateHomeSectionOrder(currentOrder);
                      });
                    },
                    itemBuilder: (context, index) {
                      final key = currentOrder[index];
                      final meta =
                          itemMeta[key] ??
                          {
                            'title': key,
                            'description': '',
                            'icon': LucideIcons.layers,
                          };

                      final title = meta['title'] as String;
                      final desc = meta['description'] as String;
                      final icon = meta['icon'] as IconData;

                      return Container(
                        key: ValueKey(key),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(
                                currentSettings.accentColor,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              icon,
                              color: Color(currentSettings.accentColor),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            desc,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                          trailing: ReorderableDragStartListener(
                            index: index,
                            child: const Icon(
                              LucideIcons.gripVertical,
                              color: Colors.white30,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color(currentSettings.accentColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showClearDialog(BuildContext context, AppLocalizations l10n) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        l10n.resetLibrary,
        style: const TextStyle(color: Colors.white),
      ),
      content: const Text(
        'This will remove all songs from your library. Your music files will not be deleted.',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
        ),
        TextButton(
          onPressed: () async {
            await DbService.isar.writeTxn(() async {
              await DbService.isar.songs.clear();
              await DbService.isar.albums.clear();
              await DbService.isar.artists.clear();
            });
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    ),
  );
}

Widget _buildAlignmentButton({
  required BuildContext context,
  required WidgetRef ref,
  required String alignment,
  required IconData icon,
  required String currentAlignment,
  required Color accentColor,
}) {
  final isSelected = currentAlignment == alignment;
  return GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      ref.read(settingsProvider.notifier).updateLyricsAlignment(alignment);
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? accentColor : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.black : Colors.white70,
      ),
    ),
  );
}

Widget _buildInfoSubTile({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String description,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16.s, color: Colors.white60),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------
// Stateless & State Helper UI Components
// ---------------------------------------------------------------------

class _ColorCircle extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorCircle({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : Border.all(color: Colors.white24, width: 1),
        ),
      ),
    );
  }
}

class _MaintainerTile extends StatelessWidget {
  final String name;
  final String role;
  final String avatar;
  final String github;
  final String telegram;

  const _MaintainerTile({
    required this.name,
    required this.role,
    required this.avatar,
    required this.github,
    required this.telegram,
  });

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white10,
        backgroundImage: AssetImage(avatar),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        role,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/about/github_icon.svg',
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                Colors.white54,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => _launchUrl(github),
          ),
          IconButton(
            icon: const Icon(LucideIcons.send, size: 18, color: Colors.white54),
            onPressed: () => _launchUrl(telegram),
          ),
        ],
      ),
    );
  }
}

class _LibraryFoldersList extends ConsumerWidget {
  const _LibraryFoldersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(settingsProvider).libraryFolders;

    if (folders.isEmpty) return const SizedBox.shrink();

    return Column(
      children: folders
          .map(
            (path) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(LucideIcons.folder, color: Colors.white70),
              title: Text(
                path.split('/').last,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              subtitle: Text(
                path,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              trailing: IconButton(
                icon: const Icon(
                  LucideIcons.x,
                  size: 16,
                  color: Colors.white60,
                ),
                onPressed: () {
                  final newFolders = List<String>.from(folders)..remove(path);
                  ref
                      .read(settingsProvider.notifier)
                      .updateLibraryFolders(newFolders);
                },
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SettingsSliderTile extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String suffix;
  final ValueChanged<double> onChanged;

  const _SettingsSliderTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    this.divisions = 100,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${value.round()}$suffix',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: Color(ref.watch(settingsProvider).accentColor),
              inactiveTrackColor: Colors.white10,
              thumbColor: Color(ref.watch(settingsProvider).accentColor),
              overlayColor: Color(
                ref.watch(settingsProvider).accentColor,
              ).withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// Search item metadata class
class SettingsSearchItem {
  final String title;
  final String subtitle;
  final String category;
  final Widget widget;

  SettingsSearchItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.widget,
  });
}
