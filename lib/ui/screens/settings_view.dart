import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:one_player/features/library/presentation/library_notifier.dart';
import 'package:one_player/features/library/domain/models/models.dart';
import 'package:one_player/core/db_service.dart';
import 'package:isar/isar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:one_player/features/settings/presentation/settings_notifier.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:one_player/l10n/app_localizations.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.settings, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
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
                final String? path = await FilePicker.platform.getDirectoryPath();
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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Scanning library...')));
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.trash2, color: Colors.red),
              title: Text(l10n.resetLibrary, style: const TextStyle(color: Colors.red)),
              onTap: () => _showClearDialog(context, l10n),
            ),
          ],
        ),
        _Section(
          title: l10n.about,
          children: [
            ListTile(
              leading: SvgPicture.asset(
                'assets/Vector (1).svg',
                height: 24,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              title: const Text('Aspen'),
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
      ],
    );
  }

  void _showClearDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetLibrary),
        content: const Text('This will remove all songs from your library. Your music files will not be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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

class _LibraryFoldersList extends ConsumerWidget {
  const _LibraryFoldersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(settingsProvider).libraryFolders;
    
    if (folders.isEmpty) return const SizedBox.shrink();

    return Column(
      children: folders.map((path) => ListTile(
        leading: const Icon(LucideIcons.folder),
        title: Text(path.split('/').last),
        subtitle: Text(path),
        trailing: IconButton(
          icon: const Icon(LucideIcons.x, size: 18),
          onPressed: () {
            final newFolders = List<String>.from(folders)..remove(path);
            ref.read(settingsProvider.notifier).updateLibraryFolders(newFolders);
          },
        ),
      )).toList(),
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
          child: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        Card(
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
