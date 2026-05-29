import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  // Tracks which section is currently expanded. Null means all collapsed.
  String? _expandedSection;

  void _toggleSection(String section) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_expandedSection == section) {
        _expandedSection = null;
      } else {
        _expandedSection = section;
      }
    });
  }

  void _showCustomColorPicker(BuildContext context, WidgetRef ref, Color initialColor) {
    showModalBottomSheet(
      context: context,

      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currentAccent = ref.watch(settingsProvider).accentColor;
            return Container(
              padding:  EdgeInsets.symmetric(horizontal: 24,vertical:12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                          ref.read(settingsProvider.notifier).updateAccentColor(color.value);
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
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            physics: const BouncingScrollPhysics(),
            children: [
              // Header title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
                child: Text(
                  l10n.settings,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              
              // 1. Theme & Appearance Accordion Group
              _buildCategoryGroup(
                id: 'theme',
                title: l10n.theme,
                subtitle: l10n.customizeColorsTheme,
                icon: LucideIcons.palette,
                colorScheme: Theme.of(context).colorScheme,
                useBlur: useBlur,
                children: [
                  SwitchListTile(
                    secondary: const Icon(LucideIcons.palette, color: Colors.white70),
                    title: Text(
                      l10n.dynamicTheming,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
                      secondary: const Icon(LucideIcons.moon, color: Colors.white70),
                      title: Text(
                        l10n.pureBlackOled,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
                    const Divider(height: 1, indent: 72, color: Colors.white10),
                    ListTile(
                      leading: const Icon(LucideIcons.droplet, color: Colors.white70),
                      title: Text(
                        l10n.accentColor,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ColorCircle(
                            color: const Color(0xFF41C25E),
                            isSelected: settings.accentColor == 0xFF41C25E,
                            onTap: () => ref.read(settingsProvider.notifier).updateAccentColor(0xFF41C25E),
                          ),
                          const SizedBox(width: 8),
                          _ColorCircle(
                            color: const Color(0xFFF7EAA6),
                            isSelected: settings.accentColor == 0xFFF7EAA6,
                            onTap: () => ref.read(settingsProvider.notifier).updateAccentColor(0xFFF7EAA6),
                          ),
                          const SizedBox(width: 8),
                          _ColorCircle(
                            color: Colors.blueAccent,
                            isSelected: settings.accentColor == Colors.blueAccent.value,
                            onTap: () => ref.read(settingsProvider.notifier).updateAccentColor(Colors.blueAccent.value),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, indent: 72, color: Colors.white10),
                    ListTile(
                      leading: const Icon(LucideIcons.palette, color: Colors.white70),
                      title: Text(
                        l10n.customAccentColor,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        l10n.selectCustomColor,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      trailing: _ColorCircle(
                        color: Color(settings.accentColor),
                        isSelected: settings.accentColor != 0xFF41C25E &&
                            settings.accentColor != 0xFFF7EAA6 &&
                            settings.accentColor != Colors.blueAccent.value,
                        onTap: () => _showCustomColorPicker(context, ref, Color(settings.accentColor)),
                      ),
                      onTap: () => _showCustomColorPicker(context, ref, Color(settings.accentColor)),
                    ),
                  ],
                  if (!settings.enableDynamicTheming) ...[
                    const Divider(height: 1, indent: 72, color: Colors.white10),
                    SwitchListTile(
                      secondary: const Icon(LucideIcons.music, color: Colors.white70),
                      title: Text(
                        l10n.dynamicLyricsBg,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
                  const Divider(height: 1, indent: 72, color: Colors.white10),
                  SwitchListTile(
                    secondary: const Icon(LucideIcons.sliders, color: Colors.white70),
                    title: Text(
                      l10n.flatProgressBar,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      l10n.useStaticTextTimestamps,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    activeColor: Color(settings.accentColor),
                    value: settings.disableAnimatedDuration,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateDisableAnimatedDuration(value);
                    },
                  ),
                ],
              ),

              // 2. Playback & Language Group
              _buildCategoryGroup(
                id: 'playback',
                title: l10n.playbackAudio,
                subtitle: l10n.manageLanguageAndFocus,
                icon: LucideIcons.playCircle,
                colorScheme: Theme.of(context).colorScheme,
                useBlur: useBlur,
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.languages, color: Colors.white70),
                    title: Text(l10n.language, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    trailing: DropdownButton<String>(
                      value: settings.language,
                      dropdownColor: const Color(0xFF1A1A1A),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'hi', child: Text('हिन्दी', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'es', child: Text('Español', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'fr', child: Text('Français', style: TextStyle(color: Colors.white))),
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
                    secondary: const Icon(LucideIcons.phoneCall, color: Colors.white70),
                    title: Text(
                      l10n.manageAudioFocus,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      l10n.muteOrPauseCalls,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    activeColor: Color(settings.accentColor),
                    value: settings.audioFocus,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateAudioFocus(value);
                    },
                  ),
                  const Divider(height: 1, indent: 72, color: Colors.white10),
                  SwitchListTile(
                    secondary: const Icon(LucideIcons.globe, color: Colors.white70),
                    title: Text(
                      l10n.internetMode,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
                ],
              ),

              // 3. Music Library Group
              _buildCategoryGroup(
                id: 'library',
                title: l10n.musicLibrary,
                subtitle: l10n.libraryFoldersSync,
                icon: LucideIcons.database,
                colorScheme: Theme.of(context).colorScheme,
                useBlur: useBlur,
                children: [
                  // List of library folders currently active
                  const _LibraryFoldersList(),
                  const Divider(height: 1, indent: 72, color: Colors.white10),
                  
                  // Add folder
                  ListTile(
                    leading: const Icon(LucideIcons.plus, color: Colors.white70),
                    title: Text(l10n.addFolder, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    trailing: const Icon(LucideIcons.chevronRight, color: Colors.white30, size: 18),
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final String? path = await FilePicker.platform.getDirectoryPath();
                      if (path != null) {
                        ref.read(libraryProvider.notifier).scanLibrary(path);
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 72, color: Colors.white10),

                  // Sync lyrics
                  ListTile(
                    leading: const Icon(LucideIcons.downloadCloud, color: Colors.white70),
                    title: Text(
                      l10n.syncLyricsOffline,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(LucideIcons.chevronRight, color: Colors.white30, size: 18),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.read(libraryProvider.notifier).prefetchLibraryLyrics();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.downloadingLyricsOffline,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 72, color: Colors.white10),

                  // Rescan library
                  ListTile(
                    leading: const Icon(LucideIcons.refreshCcw, color: Colors.white70),
                    title: Text(
                      l10n.rescanLibrary,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(LucideIcons.chevronRight, color: Colors.white30, size: 18),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.read(libraryProvider.notifier).scanSavedFolders();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.scanningLibrary,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 72, color: Colors.white10),

                  // Reset library (Red color tile)
                  ListTile(
                    leading: const Icon(LucideIcons.trash2, color: Colors.redAccent),
                    title: Text(
                      l10n.resetLibrary,
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(LucideIcons.alertTriangle, color: Colors.redAccent, size: 16),
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      _showClearDialog(context, l10n);
                    },
                  ),
                ],
              ),

              // 4. About & Creators Group
              _buildCategoryGroup(
                id: 'about',
                title: l10n.aboutAndMaintainers,
                subtitle: l10n.appDetailsCreator,
                icon: LucideIcons.info,
                colorScheme: Theme.of(context).colorScheme,
                useBlur: useBlur,
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.info, color: Colors.white70),
                    title: const Text('Looper Player', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    subtitle: const Text('Version 1.7.0', style: TextStyle(color: Colors.white54, fontSize: 12)),
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
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text('lrclib.net', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    trailing: const Icon(LucideIcons.externalLink, color: Colors.white30, size: 16),
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
                  
                  // Detailed Purpose, Permissions & Privacy Disclosure Card
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
                            color: Color(settings.accentColor).withOpacity(0.8),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Core Purpose
                        _buildInfoSubTile(
                          context: context,
                          icon: LucideIcons.music,
                          title: l10n.corePurpose,
                          description: l10n.corePurposeDesc,
                        ),
                        const SizedBox(height: 12),
                        // Permissions Explanation
                        _buildInfoSubTile(
                          context: context,
                          icon: LucideIcons.shieldCheck,
                          title: l10n.whyPermissionsUsed,
                          description: l10n.whyPermissionsUsedDesc,
                        ),
                        const SizedBox(height: 12),
                        // Internet Explanation
                        _buildInfoSubTile(
                          context: context,
                          icon: LucideIcons.globe,
                          title: l10n.whyInternetUsed,
                          description: l10n.whyInternetUsedDesc,
                        ),
                        const SizedBox(height: 12),
                        // Privacy Policy
                        _buildInfoSubTile(
                          context: context,
                          icon: LucideIcons.lock,
                          title: l10n.privacySafety,
                          description: l10n.privacySafetyDesc,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 140), // Bottom breathing room for expanded player bar
            ],
          ),
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
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGroup({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
    required ColorScheme colorScheme,
    required bool useBlur,
  }) {
    final bool isExpanded = _expandedSection == id;

    return Column(
      children: [
        PremiumSection(
          useBlur: useBlur,
          borderRadius: BorderRadius.circular(20),
          useExpanded: false,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Accordion Header Row
              InkWell(
                onTap: () => _toggleSection(id),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isExpanded
                              ? Color(ref.watch(settingsProvider).accentColor).withOpacity(0.12)
                              : Colors.white.withOpacity(0.03),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: isExpanded
                              ? Color(ref.watch(settingsProvider).accentColor)
                              : Colors.white.withOpacity(0.8),
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
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.25 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: Icon(
                          LucideIcons.chevronRight,
                          color: Colors.white.withOpacity(0.4),
                          size: 18.s,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Collapsible settings list panel
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: isExpanded
                    ? Column(
                        children: [
                          Divider(
                            height: 1,
                            thickness: 0.8,
                            color: Colors.white.withOpacity(0.05),
                            indent: 20,
                            endIndent: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Column(
                              children: children,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _showClearDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.resetLibrary, style: const TextStyle(color: Colors.white)),
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
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

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
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.github, size: 18, color: Colors.white54),
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
              title: Text(path.split('/').last, style: const TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text(path, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              trailing: IconButton(
                icon: const Icon(LucideIcons.x, size: 16, color: Colors.white60),
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
