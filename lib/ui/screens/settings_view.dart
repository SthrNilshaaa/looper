import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          l10n.settings,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.normal),
        ),
        const SizedBox(height: 32),
        _Section(
          title: 'Appearance',
          children: [
            SwitchListTile(
              secondary: const Icon(LucideIcons.palette),
              title: const Text('Dynamic Theming'),
              subtitle: const Text(
                'Enable album-based colors and dynamic effects',
              ),
              value: settings.enableDynamicTheming,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateDynamicTheming(value);
              },
            ),
            // if (settings.enableDynamicTheming)
            //   SwitchListTile(
            //     secondary: const SizedBox(width: 24), // Indent for hierarchy
            //     title: const Text('Save Dynamic Color'),
            //     subtitle:
            //         const Text('Keep the last extracted color after restart'),
            //     value: settings.saveDynamicColor,
            //     onChanged: (value) {
            //       ref
            //           .read(settingsProvider.notifier)
            //           .updateSaveDynamicColor(value);
            //     },
            //   ),
          ],
        ),
        _Section(
          title: l10n.language,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.languages),
              title: Text(l10n.language),
              trailing: DropdownButton<String>(
                value: settings.language,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
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
        _Section(
          title: 'Library',
          children: [
            const _LibraryFoldersList(),
            ListTile(
              leading: const Icon(LucideIcons.plus),
              title: Text(l10n.addFolder),
              onTap: () async {
                final String? path = await FilePicker.platform
                    .getDirectoryPath();
                if (path != null) {
                  ref.read(libraryProvider.notifier).scanLibrary(path);
                }
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.refreshCcw),
              title: const Text('Rescan Library'),
              onTap: () {
                ref.read(libraryProvider.notifier).scanSavedFolders();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scanning library...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.trash2, color: Colors.red),
              title: Text(
                l10n.resetLibrary,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () => _showClearDialog(context, l10n),
            ),
          ],
        ),
        _Section(
          title: l10n.about,
          children: [
            ListTile(
              leading: Image.asset(
                'assets/icon.png',
                height: 24,
              ),
              title: const Text('Looper Player'),
              subtitle: const Text('Version 1.0.0'),
            ),
            ListTile(
              leading: const Icon(LucideIcons.github),
              title: const Text('Source Code'),
              subtitle: const Text('Visit on GitHub'),
              onTap: () {},
            ),
          ],
        ),
        const _MaintainerInfo(),
      ],
    );
  }

  void _showClearDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetLibrary),
        content: const Text(
          'This will remove all songs from your library. Your music files will not be deleted.',
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
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _MaintainerInfo extends StatelessWidget {
  const _MaintainerInfo();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Maintainer & Designer',
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
          fontWeight: FontWeight.normal,
          fontSize: 16,
          letterSpacing: -0.2,
        ),
      ),
      subtitle: Text(
        role,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
          letterSpacing: -0.1,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/about/github_icon.svg',
              width: 18,
              height: 18,
              // colorFilter:
              //     const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
            ),
            onPressed: () => _launchUrl(github),
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/about/telegram_icon.svg',
              width: 18,
              height: 18,
              // colorFilter:
              //     const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
            ),
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
              leading: const Icon(LucideIcons.folder),
              title: Text(path.split('/').last),
              subtitle: Text(path),
              trailing: IconButton(
                icon: const Icon(LucideIcons.x, size: 18),
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

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Card(child: Column(children: children)),
        const SizedBox(height: 16),
      ],
    );
  }
}
