import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:one_player/features/library/presentation/library_notifier.dart';
import 'package:file_picker/file_picker.dart';
import 'package:one_player/features/settings/presentation/settings_notifier.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Settings', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        
        _SectionHeader(title: 'Library'),
        const _LibraryFoldersList(),
        ListTile(
          leading: const Icon(LucideIcons.plus),
          title: const Text('Add Folder'),
          subtitle: const Text('Select a new folder to scan'),
          onTap: () async {
            final String? path = await FilePicker.platform.getDirectoryPath();
            if (path != null) {
              ref.read(libraryProvider.notifier).scanLibrary(path);
            }
          },
        ),
        ListTile(
          leading: const Icon(LucideIcons.refreshCw),
          title: const Text('Rescan Library'),
          subtitle: const Text('Force a full scan of your music folders'),
          onTap: () {
            ref.read(libraryProvider.notifier).scanSavedFolders();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Scanning library...')));
          },
        ),
        
        const Divider(height: 48),
        _SectionHeader(title: 'Appearance'),
        SwitchListTile(
          secondary: const Icon(LucideIcons.palette),
          title: const Text('Dynamic Themes'),
          subtitle: const Text('Adapt app colors to album artwork'),
          value: true, // TODO: Persist setting
          onChanged: (val) {
            // TODO: Toggle dynamic theme
          },
        ),
        ListTile(
          leading: const Icon(LucideIcons.moon),
          title: const Text('Theme Mode'),
          subtitle: const Text('Switch between light and dark mode'),
          trailing: const Text('System'),
          onTap: () {
            // TODO: Theme mode selection
          },
        ),
        
        const Divider(height: 48),
        _SectionHeader(title: 'Audio'),
        ListTile(
          leading: const Icon(LucideIcons.volume2),
          title: const Text('Equalizer'),
          subtitle: const Text('Fine-tune your audio output'),
          trailing: const Icon(LucideIcons.chevronRight),
          onTap: () {
            // TODO: EQ
          },
        ),
        
        const Divider(height: 48),
        _SectionHeader(title: 'About'),
        const ListTile(
          title: Text('OnePlayer'),
          subtitle: Text('Version 1.0.0'),
        ),
        ListTile(
          leading: const Icon(LucideIcons.github),
          title: const Text('Source Code'),
          subtitle: const Text('View on GitHub'),
          onTap: () {},
        ),
      ],
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
          icon: const Icon(LucideIcons.trash2, size: 18),
          onPressed: () {
            final newFolders = List<String>.from(folders)..remove(path);
            ref.read(settingsProvider.notifier).updateLibraryFolders(newFolders);
          },
        ),
      )).toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
