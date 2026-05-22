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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final useBlur = settings.enableDynamicTheming;

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
                subtitle: UiUtils.tr(context, 'Customize app colors, theme, and lyrics backgrounds', 'ऐप के रंग, थीम और बोल के बैकग्राउंड बदलें'),
                icon: LucideIcons.palette,
                colorScheme: Theme.of(context).colorScheme,
                useBlur: useBlur,
                children: [
                  SwitchListTile(
                    secondary: const Icon(LucideIcons.palette, color: Colors.white70),
                    title: Text(
                      UiUtils.tr(context, 'Dynamic Theming', 'डायनामिक थीमिंग'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      UiUtils.tr(context, 'Adapt app colors to album artwork', 'एल्बम आर्टवर्क के अनुसार ऐप के रंग बदलें'),
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    activeColor: Color(settings.accentColor),
                    value: settings.enableDynamicTheming,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateDynamicTheming(value);
                    },
                  ),
                  if (!settings.enableDynamicTheming) ...[
                    const Divider(height: 1, indent: 72, color: Colors.white10),
                    SwitchListTile(
                      secondary: const Icon(LucideIcons.moon, color: Colors.white70),
                      title: Text(
                        UiUtils.tr(context, 'Pure Black (OLED)', 'गहरा काला (OLED)'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        UiUtils.tr(context, 'Use absolute black for backgrounds', 'बैकग्राउंड के लिए पूरी तरह से काले रंग का उपयोग करें'),
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
                        UiUtils.tr(context, 'Accent Color', 'एक्सेंट रंग'),
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
                  ],
                  if (!settings.enableDynamicTheming) ...[
                    const Divider(height: 1, indent: 72, color: Colors.white10),
                    SwitchListTile(
                      secondary: const Icon(LucideIcons.music, color: Colors.white70),
                      title: Text(
                        UiUtils.tr(context, 'Dynamic Lyrics BG', 'डायनामिक बोल बैकग्राउंड'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        UiUtils.tr(context, 'Dynamic background only for lyrics', 'केवल बोल के लिए डायनामिक बैकग्राउंड'),
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
                      UiUtils.tr(context, 'Flat Progress Bar', 'समतल प्रगति बार'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      UiUtils.tr(context, 'Disable squiggly wave progress bar animation', 'लहरदार लहर प्रगति बार एनीमेशन अक्षम करें'),
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
                      UiUtils.tr(context, 'Plain Timestamps', 'सादा टाइमस्टैम्प'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      UiUtils.tr(context, 'Use static text instead of rolling animation for progress duration', 'रोलिंग एनीमेशन के बजाय स्थिर पाठ का उपयोग करें'),
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
                title: UiUtils.tr(context, 'Playback & Audio', 'प्लेबैक और ऑडियो'),
                subtitle: UiUtils.tr(context, 'Manage language preferences and caller focus state', 'भाषा प्राथमिकताएं और कॉलर फ़ोकस प्रबंधित करें'),
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
                      UiUtils.tr(context, 'Manage Audio Focus', 'ऑडियो फ़ोकस प्रबंधित करें'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      UiUtils.tr(context, 'Mute or pause during calls and other audio activity', 'कॉल और अन्य ऑडियो गतिविधि के दौरान म्यूट या पॉज करें'),
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    activeColor: Color(settings.accentColor),
                    value: settings.audioFocus,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateAudioFocus(value);
                    },
                  ),
                ],
              ),

              // 3. Music Library Group
              _buildCategoryGroup(
                id: 'library',
                title: UiUtils.tr(context, 'Music Library', 'संगीत लाइब्रेरी'),
                subtitle: UiUtils.tr(context, 'Folders, rescan triggers, reset database, and offline sync', 'फ़ोल्डर, रीस्कैन, रीसेट डेटाबेस और ऑफ़लाइन सिंक'),
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
                      UiUtils.tr(context, 'Sync Lyrics (Offline)', 'ऑफ़लाइन बोल सिंक करें'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(LucideIcons.chevronRight, color: Colors.white30, size: 18),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.read(libraryProvider.notifier).prefetchLibraryLyrics();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            UiUtils.tr(context, 'Downloading lyrics for offline use...', 'ऑफ़लाइन उपयोग के लिए बोल डाउनलोड किए जा रहे हैं...'),
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
                      UiUtils.tr(context, 'Rescan Library', 'लाइब्रेरी रीस्कैन करें'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(LucideIcons.chevronRight, color: Colors.white30, size: 18),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.read(libraryProvider.notifier).scanSavedFolders();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            UiUtils.tr(context, 'Scanning library...', 'लाइब्रेरी स्कैन की जा रही है...'),
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
                title: UiUtils.tr(context, 'About & Maintainers', 'हमारे बारे में और डेवलपर्स'),
                subtitle: UiUtils.tr(context, 'Application details, creator, and design team info', 'एप्लिकेशन विवरण, निर्माता और डिज़ाइन टीम की जानकारी'),
                icon: LucideIcons.info,
                colorScheme: Theme.of(context).colorScheme,
                useBlur: useBlur,
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.info, color: Colors.white70),
                    title: const Text('Looper Player', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    subtitle: const Text('Version 1.5.1', style: TextStyle(color: Colors.white54, fontSize: 12)),
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
                      UiUtils.tr(context, 'Lyrics Provider', 'बोल प्रदाता'),
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
                    role: UiUtils.tr(context, 'Creator and Maintainer', 'निर्माता और डेवलपर'),
                    avatar: 'assets/about/maintainer_avatar.png',
                    github: 'https://github.com/SthrNilshaaa',
                    telegram: 'https://t.me/neelshy',
                  ),
                  const Divider(height: 1, indent: 72, color: Colors.white10),
                  _MaintainerTile(
                    name: 'Karan Suthar',
                    role: UiUtils.tr(context, 'Designer and Maintainer', 'डिज़ाइनर और डेवलपर'),
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
                          UiUtils.tr(context, 'APP INFO & PRIVACY', 'ऐप की जानकारी और गोपनीयता'),
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
                          title: UiUtils.tr(context, 'Core Purpose', 'मुख्य उद्देश्य'),
                          description: UiUtils.tr(
                            context,
                            'Looper Player is an offline-first, high-fidelity audio player designed for music enthusiasts who want absolute control over their local library, gapless playback, and fluid, synchronized lyrics scrolling.',
                            'लूपर प्लेयर एक ऑफ़लाइन-फ़र्स्ट, उच्च-गुणवत्ता वाला ऑडियो प्लेयर है जिसे उन संगीत प्रेमियों के लिए डिज़ाइन किया गया है जो अपनी स्थानीय लाइब्रेरी, गैपलेस प्लेबैक और सिंक किए गए बोल पर पूरा नियंत्रण चाहते हैं।'
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Permissions Explanation
                        _buildInfoSubTile(
                          context: context,
                          icon: LucideIcons.shieldCheck,
                          title: UiUtils.tr(context, 'Why Permissions are Used', 'अनुमतियों का उपयोग क्यों किया जाता है'),
                          description: UiUtils.tr(
                            context,
                            '• Storage / Media Access: Required to discover, read, and index local audio tracks stored on your device.\n• Notifications: Required to display active playback control widgets in your status bar and system drawer.',
                            '• स्टोरेज / मीडिया एक्सेस: आपके डिवाइस में स्टोर किए गए स्थानीय ऑडियो ट्रैक्स को खोजने, पढ़ने और इंडेक्स करने के लिए आवश्यक है।\n• नोटिफिकेशन: आपके स्टेटस बार और सिस्टम ड्रावर में सक्रिय प्लेबैक नियंत्रण विजेट दिखाने के लिए आवश्यक है।'
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Internet Explanation
                        _buildInfoSubTile(
                          context: context,
                          icon: LucideIcons.globe,
                          title: UiUtils.tr(context, 'Why Internet is Used', 'इंटरनेट का उपयोग क्यों किया जाता है'),
                          description: UiUtils.tr(
                            context,
                            '• Dynamic Lyrics Syncing: Used solely to securely fetch and download synchronized lyrics (LRC formats) from online databases. No personal data, settings, or media files are ever uploaded or shared.',
                            '• डायनामिक बोल सिंक: ऑनलाइन डेटाबेस से गानों के सिंक किए गए बोल (LRC प्रारूप) को सुरक्षित रूप से खोजने और डाउनलोड करने के लिए किया जाता है। कोई भी व्यक्तिगत डेटा, सेटिंग्स या मीडिया फाइलें कभी भी अपलोड या साझा नहीं की जाती हैं।'
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Privacy Policy
                        _buildInfoSubTile(
                          context: context,
                          icon: LucideIcons.lock,
                          title: UiUtils.tr(context, 'Privacy & Safety', 'गोपनीयता और सुरक्षा'),
                          description: UiUtils.tr(
                            context,
                            '100% private and offline-first. Your tracks, playback history, favorites, and configuration stay strictly inside a secure Isar database on your local device. We do not track, collect, or share your usage data or preferences.',
                            '100% निजी और ऑफ़लाइन-फ़र्स्ट। आपके गाने, प्लेबैक इतिहास, पसंदीदा और सेटिंग्स केवल आपके स्थानीय डिवाइस पर एक सुरक्षित इसार डेटाबेस के अंदर रहते हैं। हम आपके किसी भी उपयोग डेटा या संगीत प्राथमिकताओं को ट्रैक, एकत्र या साझा नहीं करते हैं।'
                          ),
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
