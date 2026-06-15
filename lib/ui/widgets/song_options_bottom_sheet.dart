import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/playlists/presentation/playlist_view.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/ui/screens/android/widgets/song_details_bottom_sheet.dart';
import 'package:looper_player/ui/screens/android/song/song_info_screen.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/features/playlists/data/playlist_service.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/core/providers.dart';

void showSongOptionsBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Song song,
  Playlist? playlist,
  bool showDeleteOption = true,
  bool showRenameOption = true,
}) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    builder: (modalContext) => _SongOptionsSheetContent(
      song: song,
      playlist: playlist,
      showDeleteOption: showDeleteOption,
      showRenameOption: showRenameOption,
      parentContext: context,
    ),
  );
}

class _SongOptionsSheetContent extends ConsumerWidget {
  final Song song;
  final Playlist? playlist;
  final bool showDeleteOption;
  final bool showRenameOption;
  final BuildContext parentContext;

  const _SongOptionsSheetContent({
    required this.song,
    this.playlist,
    required this.showDeleteOption,
    required this.showRenameOption,
    required this.parentContext,
  });

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: song.title);
    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).colorScheme.surfaceContainer,
          title: Text(l10n.renameSong, style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: l10n.newTitle,
              labelStyle: const TextStyle(color: Colors.grey),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final result = await ref
                    .read(playbackProvider.notifier)
                    .renameSong(song, controller.text);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  String message = '';
                  Color bgColor = Colors.transparent;
                  if (result == FileActionResult.success) {
                    message = l10n.songRenamedSuccess;
                    bgColor = Colors.green.shade800;
                  } else if (result == FileActionResult.dbOnly) {
                    message = l10n.songRenamedDbOnly;
                    bgColor = Colors.orange.shade800;
                  } else {
                    message = l10n.songRenameFailed;
                    bgColor = Colors.red.shade800;
                  }
                  scaffoldMessengerKey.currentState?.clearSnackBars();
                  scaffoldMessengerKey.currentState?.showSnackBar(
                    SnackBar(
                      content: Text(
                        message,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: bgColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(l10n.rename, style: const TextStyle(color: Colors.yellow)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).colorScheme.surfaceContainer,
          title: Text(l10n.deleteSong, style: const TextStyle(color: Colors.white)),
          content: Text(
            l10n.deleteSongConfirm,
            style: const TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final result = await ref.read(playbackProvider.notifier).deleteSong(song);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  String message = '';
                  Color bgColor = Colors.transparent;
                  if (result == FileActionResult.success) {
                    message = l10n.songDeletedSuccess;
                    bgColor = Colors.green.shade800;
                  } else if (result == FileActionResult.dbOnly) {
                    message = l10n.songDeletedDbOnly;
                    bgColor = Colors.orange.shade800;
                  } else {
                    message = l10n.songDeleteFailed;
                    bgColor = Colors.red.shade800;
                  }
                  scaffoldMessengerKey.currentState?.clearSnackBars();
                  scaffoldMessengerKey.currentState?.showSnackBar(
                    SnackBar(
                      content: Text(
                        message,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: bgColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showPlaylistSelector(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final playlists = ref.watch(playlistProvider);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).colorScheme.surfaceContainer,
        title: Text('${l10n.addToFavorites.split(' ')[0]} ${l10n.playlists}'),
        content: playlists.isEmpty
            ? Text(l10n.noPlaylistsCreated)
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (dialogContext, index) {
                    final p = playlists[index];
                    return ListTile(
                      leading: const Icon(LucideIcons.listMusic),
                      title: Text(p.name),
                      onTap: () async {
                        if (!p.songPaths.contains(song.path)) {
                          p.songPaths = [...p.songPaths, song.path];
                          p.dateModified = DateTime.now();
                          await DbService.isar.writeTxn(
                            () => DbService.isar.playlists.put(p),
                          );
                        }
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                          scaffoldMessengerKey.currentState?.clearSnackBars();
                          scaffoldMessengerKey.currentState?.showSnackBar(
                            SnackBar(
                              content: Text(l10n.addedTo(p.name)),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final playbackState = ref.watch(playbackProvider);
    final useBlur = settings.enableDynamicTheming && !settings.disableBlur;
    final isPureBlack = settings.darkTheme;
    final accentColor = Color(settings.accentColor);

    final sheetBg = isPureBlack 
        ? Colors.black 
        : (useBlur ? Colors.black.withValues(alpha: 0.6) : const Color(0xFF1E1E1E));

    Widget sheetContent = Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isPureBlack ? Colors.white10 : Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Beautiful Standardized Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                OptimizedImage(
                  imagePath: song.artPath,
                  width: 52,
                  height: 52,
                  borderRadius: BorderRadius.circular(12),
                  placeholder: Container(
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.music, color: Colors.white54),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: AppFonts.jost,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist ?? l10n.unknownArtist,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white54,
                          fontFamily: AppFonts.jost,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Builder(
                  builder: (context) {
                    final options = <Widget>[
                      _MenuOptionTile(
                        label: l10n.playNext,
                        icon: LucideIcons.playCircle,
                        iconColor: accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(playbackProvider.notifier).addNext(song);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.willPlayNext),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      _MenuOptionTile(
                        label: l10n.addToQueue,
                        icon: LucideIcons.listPlus,
                        iconColor: accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(playbackProvider.notifier).addToQueue(song);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.addedToQueue),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      _MenuOptionTile(
                        label: l10n.addToPlaylists,
                        icon: LucideIcons.listMusic,
                        iconColor: accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          _showPlaylistSelector(parentContext, ref, l10n);
                        },
                      ),
                      _MenuOptionTile(
                        label: playbackState.isSleepTimerActive
                            ? 'Sleep Timer (${_formatSleepTimerRemaining(playbackState)})'
                            : 'Sleep Timer',
                        icon: LucideIcons.timer,
                        iconColor: playbackState.isSleepTimerActive ? accentColor : Colors.white70,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          _showSleepTimerBottomSheet(parentContext, ref);
                        },
                      ),
                      _MenuOptionTile(
                        label: song.isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
                        icon: song.isFavorite ? Icons.favorite : Icons.favorite_border,
                        iconColor: song.isFavorite ? Colors.redAccent : Colors.white70,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(libraryProvider.notifier).toggleFavorite(song);
                          Navigator.pop(context);
                        },
                      ),
                      if (playlist != null)
                        _MenuOptionTile(
                          label: l10n.removeFromPlaylist,
                          icon: LucideIcons.trash2,
                          iconColor: Colors.redAccent,
                          onTap: () async {
                            HapticFeedback.mediumImpact();
                            final messenger = ScaffoldMessenger.of(context);
                            await PlaylistService.removeSongFromPlaylist(playlist!, song);
                            if (context.mounted) {
                              Navigator.pop(context);
                              messenger.showSnackBar(
                                SnackBar(content: Text(l10n.removedFromPlaylist)),
                              );
                            }
                          },
                        ),
                      if (showRenameOption)
                        _MenuOptionTile(
                          label: l10n.renameFile,
                          icon: LucideIcons.edit2,
                          iconColor: Colors.white70,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                            _showRenameDialog(parentContext, ref);
                          },
                        ),
                      _MenuOptionTile(
                        label: l10n.songDetails,
                        icon: LucideIcons.info,
                        iconColor: Colors.white70,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            useRootNavigator: true,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => SongDetailsBottomSheet(song: song),
                          );
                        },
                      ),
                      _MenuOptionTile(
                        label: l10n.technicalInfoFrequency,
                        icon: LucideIcons.activity,
                        iconColor: Colors.white70,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SongInfoScreen(song: song),
                            ),
                          );
                        },
                      ),
                      _MenuOptionTile(
                        label: l10n.share,
                        icon: LucideIcons.share2,
                        iconColor: Colors.white70,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(playbackProvider.notifier).shareSong(song);
                          Navigator.pop(context);
                        },
                      ),
                      if (showDeleteOption)
                        _MenuOptionTile(
                          label: l10n.deleteFile,
                          icon: LucideIcons.trash2,
                          iconColor: Colors.redAccent,
                          onTap: () {
                            HapticFeedback.heavyImpact();
                            Navigator.pop(context);
                            _showDeleteDialog(parentContext, ref);
                          },
                        ),
                    ];

                    return PremiumSection(
                      borderRadius: BorderRadius.circular(20),
                      padding: EdgeInsets.zero,
                      useExpanded: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(options.length * 2 - 1, (index) {
                          if (index.isOdd) {
                            return Divider(
                              height: 1,
                              thickness: 0.8,
                              color: Colors.white.withValues(alpha: 0.04),
                              indent: 20,
                              endIndent: 20,
                            );
                          }
                          return options[index ~/ 2];
                        }),
                      ),
                    );
                  }
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (useBlur && !isPureBlack) {
      return RepaintBoundary(
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: sheetContent,
          ),
        ),
      );
    }

    return sheetContent;
  }
}

class _MenuOptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _MenuOptionTile({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: Colors.white.withValues(alpha: 0.9),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatSleepTimerRemaining(PlaybackState state) {
  if (state.sleepTimerDurationRemaining != null) {
    final duration = state.sleepTimerDurationRemaining!;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  } else if (state.sleepTimerSongsRemaining != null) {
    final count = state.sleepTimerSongsRemaining!;
    return count == 1 ? '1 song left' : '$count songs left';
  }
  return '';
}

void _showSleepTimerBottomSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    builder: (modalContext) => const _SleepTimerSheetContent(),
  );
}

class _SleepTimerSheetContent extends ConsumerStatefulWidget {
  const _SleepTimerSheetContent();

  @override
  ConsumerState<_SleepTimerSheetContent> createState() => _SleepTimerSheetContentState();
}

class _SleepTimerSheetContentState extends ConsumerState<_SleepTimerSheetContent> {
  int _customSongs = 3;
  int _customMinutes = 15;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final useBlur = settings.enableDynamicTheming && !settings.disableBlur;
    final isPureBlack = settings.darkTheme;
    final accentColor = Color(settings.accentColor);
    final playbackState = ref.watch(playbackProvider);

    final sheetBg = isPureBlack 
        ? Colors.black 
        : (useBlur ? Colors.black.withValues(alpha: 0.6) : const Color(0xFF1E1E1E));

    Widget sheetContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isPureBlack ? Colors.white10 : Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(LucideIcons.timer, color: accentColor, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Sleep Timer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: AppFonts.jost,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              playbackState.isSleepTimerActive
                  ? (playbackState.sleepTimerDurationRemaining != null
                      ? 'Active: Stopping in ${_formatSleepTimerRemaining(playbackState)}'
                      : 'Active: Stopping after ${_formatSleepTimerRemaining(playbackState)}')
                  : 'Select when to pause music playback',
              style: TextStyle(
                fontSize: 14,
                color: playbackState.isSleepTimerActive ? accentColor : Colors.white54,
                fontFamily: AppFonts.jost,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'STOP BY TIME',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white38,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            PremiumSection(
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              useExpanded: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          if (_customMinutes > 1) {
                            setState(() => _customMinutes--);
                          }
                        },
                        icon: const Icon(LucideIcons.minus, color: Colors.white70),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white10,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$_customMinutes ${_customMinutes == 1 ? 'Min' : 'Mins'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _customMinutes++);
                        },
                        icon: const Icon(LucideIcons.plus, color: Colors.white70),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white10,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref.read(playbackProvider.notifier).startSleepTimer(duration: Duration(minutes: _customMinutes));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      'Start',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildCustomChip(label: '1 Min', onTap: () => _startTimer(const Duration(minutes: 1))),
                  _buildCustomChip(label: '5 Min', onTap: () => _startTimer(const Duration(minutes: 5))),
                  _buildCustomChip(label: '10 Min', onTap: () => _startTimer(const Duration(minutes: 10))),
                  _buildCustomChip(label: '30 Min', onTap: () => _startTimer(const Duration(minutes: 30))),
                  _buildCustomChip(label: '45 Min', onTap: () => _startTimer(const Duration(minutes: 45))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'STOP BY SONG COUNT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white38,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            PremiumSection(
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              useExpanded: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          if (_customSongs > 1) {
                            setState(() => _customSongs--);
                          }
                        },
                        icon: const Icon(LucideIcons.minus, color: Colors.white70),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white10,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$_customSongs ${_customSongs == 1 ? 'Song' : 'Songs'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _customSongs++);
                        },
                        icon: const Icon(LucideIcons.plus, color: Colors.white70),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white10,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref.read(playbackProvider.notifier).startSleepTimer(songCount: _customSongs);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      'Start',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildCustomChip(label: '1 Song', onTap: () => _startSongs(1)),
                  _buildCustomChip(label: '2 Songs', onTap: () => _startSongs(2)),
                  _buildCustomChip(label: '3 Songs', onTap: () => _startSongs(3)),
                  _buildCustomChip(label: '5 Songs', onTap: () => _startSongs(5)),
                  _buildCustomChip(label: '10 Songs', onTap: () => _startSongs(10)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (playbackState.isSleepTimerActive)
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(playbackProvider.notifier).stopSleepTimer();
                  Navigator.pop(context);
                },
                icon: const Icon(LucideIcons.xCircle, size: 20),
                label: const Text('Cancel Sleep Timer', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  side: const BorderSide(color: Colors.redAccent, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );

    if (useBlur && !isPureBlack) {
      return RepaintBoundary(
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: sheetContent,
          ),
        ),
      );
    }

    return sheetContent;
  }

  void _startTimer(Duration duration) {
    ref.read(playbackProvider.notifier).startSleepTimer(duration: duration);
    Navigator.pop(context);
  }

  void _startSongs(int count) {
    ref.read(playbackProvider.notifier).startSleepTimer(songCount: count);
    Navigator.pop(context);
  }

  Widget _buildCustomChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.white.withValues(alpha: 0.06),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
