import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'settings_dialogs.dart';

class AddFolderTile extends ConsumerWidget {
  const AddFolderTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
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
    );
  }
}

class SyncLyricsOfflineTile extends ConsumerWidget {
  const SyncLyricsOfflineTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
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
    );
  }
}

class RescanLibraryTile extends ConsumerWidget {
  const RescanLibraryTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
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
    );
  }
}

class ResetLibraryTile extends ConsumerWidget {
  const ResetLibraryTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
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
        showClearDialog(context, l10n);
      },
    );
  }
}
