import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/features/library/domain/models/models.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final useBlur = settings.enableDynamicTheming;

    return Material(
      color: Colors.transparent,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                child: Text(
                  l10n.settings,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              _PremiumSectionWrapper(
                title: l10n.theme,
                useBlur: useBlur,
                children: [
                  SwitchListTile(
                    secondary: const Icon(LucideIcons.palette, color: Colors.white70),
                    title: const Text('Dynamic Theming', style: TextStyle(color: Colors.white)),
                    subtitle: const Text(
                      'Adapt app colors to album artwork',
                      style: TextStyle(color: Colors.white54),
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
                      title: const Text('Pure Black (OLED)', style: TextStyle(color: Colors.white)),
                      subtitle: const Text(
                        'Use absolute black for backgrounds',
                        style: TextStyle(color: Colors.white54),
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
                      title: const Text('Accent Color', style: TextStyle(color: Colors.white)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ColorCircle(
                            color: const Color(0xFF41C25E), // New default accent color
                            isSelected: settings.accentColor == 0xFF41C25E,
                            onTap: () => ref.read(settingsProvider.notifier).updateAccentColor(0xFF41C25E),
                          ),
                          const SizedBox(width: 8),
                          _ColorCircle(
                            color: const Color(0xFFF7EAA6), // Previous accent color
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
                      title: const Text('Dynamic Lyrics BG', style: TextStyle(color: Colors.white)),
                      subtitle: const Text(
                        'Dynamic background only for lyrics',
                        style: TextStyle(color: Colors.white54),
                      ),
                      activeColor: Color(settings.accentColor),
                      value: settings.dynamicLyrics,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).updateDynamicLyrics(value);
                      },
                    ),
                  ],
                ],
              ),
  
              const SizedBox(height: 16),
  
              _PremiumSectionWrapper(
                title: l10n.language,
                useBlur: useBlur,
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.languages, color: Colors.white70),
                    title: Text(l10n.language, style: const TextStyle(color: Colors.white)),
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
                ],
              ),
  
              const SizedBox(height: 16),
  
              _PremiumSectionWrapper(
                title: 'Library',
                useBlur: useBlur,
                children: [
                  const _LibraryFoldersList(),
                ],
              ),
  
              const SizedBox(height: 12),
  
              PremiumSection(
                useBlur: useBlur,
                borderRadius: BorderRadius.circular(20),
                useExpanded: false,
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final String? path = await FilePicker.platform.getDirectoryPath();
                  if (path != null) {
                    ref.read(libraryProvider.notifier).scanLibrary(path);
                  }
                },
                child: ListTile(
                  leading: const Icon(LucideIcons.plus, color: Colors.white70),
                  title: Text(l10n.addFolder, style: const TextStyle(color: Colors.white)),
                  trailing: const Icon(LucideIcons.chevronRight, color: Colors.white24, size: 20),
                ),
              ),
  
              const SizedBox(height: 8),
  
              PremiumSection(
                useBlur: useBlur,
                borderRadius: BorderRadius.circular(20),
                useExpanded: false,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(libraryProvider.notifier).prefetchLibraryLyrics();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading lyrics for offline use...')),
                  );
                },
                child: const ListTile(
                  leading: Icon(LucideIcons.downloadCloud, color: Colors.white70),
                  title: Text('Sync Lyrics (Offline)', style: TextStyle(color: Colors.white)),
                  trailing: Icon(LucideIcons.chevronRight, color: Colors.white24, size: 20),
                ),
              ),
  
              const SizedBox(height: 8),
  
              PremiumSection(
                useBlur: useBlur,
                borderRadius: BorderRadius.circular(20),
                useExpanded: false,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(libraryProvider.notifier).scanSavedFolders();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scanning library...')),
                  );
                },
                child: const ListTile(
                  leading: Icon(LucideIcons.refreshCcw, color: Colors.white70),
                  title: Text('Rescan Library', style: TextStyle(color: Colors.white)),
                  trailing: Icon(LucideIcons.chevronRight, color: Colors.white24, size: 20),
                ),
              ),
  
              const SizedBox(height: 8),
  
              PremiumSection(
                useBlur: useBlur,
                borderRadius: BorderRadius.circular(20),
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                useExpanded: false,
                onTap: () {
                  HapticFeedback.heavyImpact();
                  _showClearDialog(context, l10n);
                },
                child: ListTile(
                  leading: const Icon(LucideIcons.trash2, color: Colors.redAccent),
                  title: Text(
                    l10n.resetLibrary,
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(LucideIcons.alertTriangle, color: Colors.redAccent, size: 20),
                ),
              ),
  
              const SizedBox(height: 16),
  
              _PremiumSectionWrapper(
                title: l10n.about,
                useBlur: useBlur,
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.info, color: Colors.white70),
                    title: const Text('Looper Player', style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Version 1.5.1', style: TextStyle(color: Colors.white54)),
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.github, color: Colors.white70),
                    title: const Text('Source Code', style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Visit on GitHub', style: TextStyle(color: Colors.white54)),
                    onTap: () {},
                  ),
                ],
              ),
  
              const SizedBox(height: 16),
              
              const _MaintainerInfo(),
              
              const SizedBox(height: 140), // Padding for mini player
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(l10n.resetLibrary, style: const TextStyle(color: Colors.white)),
        content: const Text(
          'This will remove all songs from your library. Your music files will not be deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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

class _PremiumSectionWrapper extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool useBlur;

  const _PremiumSectionWrapper({
    required this.title,
    required this.children,
    required this.useBlur,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.4),
              letterSpacing: 1.2,
            ),
          ),
        ),
        PremiumSection(
          useBlur: useBlur,
          borderRadius: BorderRadius.circular(24),
          useExpanded: false,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _MaintainerInfo extends StatelessWidget {
  const _MaintainerInfo();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final settings = ref.watch(settingsProvider);
        final useBlur = settings.enableDynamicTheming;

        return _PremiumSectionWrapper(
          title: 'Maintainer & Designer',
          useBlur: useBlur,
          children: [
            _MaintainerTile(
              name: 'Nilesh Suthar',
              role: 'Creator and maintainer',
              avatar: 'assets/about/maintainer_avatar.png',
              github: 'https://github.com/SthrNilshaaa',
              telegram: 'https://t.me/neelshy',
            ),
            const Divider(height: 1, indent: 72, color: Colors.white10),
            _MaintainerTile(
              name: 'Karan Suthar',
              role: 'Designer and maintainer',
              avatar: 'assets/about/designer_avatar.png',
              github: 'https://github.com/sthrkaran',
              telegram: 'https://t.me/karanwhy',
            ),
          ],
        );
      },
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10, width: 1),
        ),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white10,
          backgroundImage: AssetImage(avatar),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        role,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 13,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.github, size: 20, color: Colors.white70),
            onPressed: () => _launchUrl(github),
          ),
          IconButton(
            icon: const Icon(LucideIcons.send, size: 20, color: Colors.white70),
            onPressed: () => _launchUrl(telegram),
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
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
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
              leading: const Icon(LucideIcons.folder, color: Colors.white70),
              title: Text(path.split('/').last, style: const TextStyle(color: Colors.white)),
              subtitle: Text(path, style: const TextStyle(color: Colors.white54)),
              trailing: IconButton(
                icon: const Icon(LucideIcons.x, size: 18, color: Colors.white70),
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
