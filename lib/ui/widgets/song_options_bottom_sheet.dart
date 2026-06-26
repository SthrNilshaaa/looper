import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/ui/widgets/app_loading_indicator.dart';
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
import 'package:looper_player/ui/screens/android/player/android_equalizer_screen.dart';

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

  /// Shows the advanced Edit Song sheet (bottom sheet).
  void _showEditSongSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (ctx) => EditSongSheet(song: song),
    );
  }

  /// Shows a confirmation dialog for deleting a song.
  /// Captures the notifier BEFORE showing the dialog so ref is not used after
  /// the ConsumerWidget is disposed (which happens when the bottom sheet closes).
  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    // Capture everything needed before the async gap
    final notifier = ref.read(playbackProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 22),
                const SizedBox(width: 10),
                Text(l10n.deleteSong, style: AppFonts.jostStyle(color: Colors.white)),
              ],
            ),
            content: Text(
              l10n.deleteSongConfirm,
              style: AppFonts.jostStyle(color: Colors.white60, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: isDeleting ? null : () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel, style: AppFonts.jostStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: isDeleting
                    ? null
                    : () async {
                        setDialogState(() => isDeleting = true);
                        final result = await notifier.deleteSong(song);
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                        String message;
                        Color bgColor;
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
                            content: Text(message,
                                style: AppFonts.jostStyle(color: Colors.white)),
                            backgroundColor: bgColor,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isDeleting
                    ? const AppLoadingIndicator(size: 36)
                    : Text(l10n.delete),
              ),
            ],
          ),
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
        // border: Border.all(
        //   color: isPureBlack ? Colors.white10 : Colors.white.withValues(alpha: 0.08),
        //   width: 1,
        // ),
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
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
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
                        style: AppFonts.jostStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist ?? l10n.unknownArtist,
                        style: AppFonts.jostStyle(
                          fontSize: 13,
                          color: Colors.white54,
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
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                          label: 'Edit Song Info',
                          icon: LucideIcons.edit3,
                          iconColor: accentColor,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                            _showEditSongSheet(parentContext, ref);
                          },
                        ),
                      _MenuOptionTile(
                        label: 'Equalizer',
                        icon: LucideIcons.sliders,
                        iconColor: accentColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          Navigator.push(
                            parentContext,
                            MaterialPageRoute(
                              builder: (context) => const AndroidEqualizerScreen(),
                            ),
                          );
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
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
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

// ─── Advanced Edit Song Sheet ────────────────────────────────────────────────

class EditSongSheet extends ConsumerStatefulWidget {
  final Song song;
  const EditSongSheet({super.key, required this.song});

  @override
  ConsumerState<EditSongSheet> createState() => _EditSongSheetState();
}

class _EditSongSheetState extends ConsumerState<EditSongSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _artistCtrl;
  late final TextEditingController _albumCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _genreCtrl;
  late final TextEditingController _lyricsCtrl;

  String? _pickedArtPath; // null = unchanged, '' = cleared, '/path' = new path
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.song.title);
    _artistCtrl = TextEditingController(text: widget.song.artist ?? '');
    _albumCtrl = TextEditingController(text: widget.song.album ?? '');
    _yearCtrl = TextEditingController(
        text: widget.song.year != null && widget.song.year! > 0
            ? widget.song.year.toString()
            : '');
    _genreCtrl = TextEditingController(text: widget.song.genre ?? '');
    _lyricsCtrl = TextEditingController(text: widget.song.lyrics ?? '');
    _pickedArtPath = null; // unchanged
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _artistCtrl.dispose();
    _albumCtrl.dispose();
    _yearCtrl.dispose();
    _genreCtrl.dispose();
    _lyricsCtrl.dispose();
    super.dispose();
  }

  String get _currentArtPath => _pickedArtPath ?? widget.song.artPath ?? '';

  Future<void> _pickArtwork() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        setState(() => _pickedArtPath = result.files.single.path!);
      }
    } catch (_) {}
  }

  void _clearArtwork() => setState(() => _pickedArtPath = '');

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    final notifier = ref.read(playbackProvider.notifier);
    final success = await notifier.editSongMetadata(
      widget.song,
      title: _titleCtrl.text,
      artist: _artistCtrl.text,
      album: _albumCtrl.text,
      year: int.tryParse(_yearCtrl.text) ?? 0,
      genre: _genreCtrl.text,
      artPath: _pickedArtPath, // null = unchanged
      lyrics: _lyricsCtrl.text,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(success ? 'Song info updated!' : 'Failed to save changes.'),
          backgroundColor: success ? Colors.green.shade800 : Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final accentColor = Color(settings.accentColor);

    Widget content = Container(
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.93,
        minChildSize: 0.5,
        maxChildSize: 0.97,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(LucideIcons.edit3, color: accentColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edit Song Info',
                            style: AppFonts.jostStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text('Tap a field to edit',
                            style: AppFonts.jostStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: [
                  // ── Artwork picker ────────────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: _pickArtwork,
                      child: Stack(
                        children: [
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: accentColor.withValues(alpha: 0.4), width: 2),
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: accentColor.withValues(alpha: 0.2),
                              //     blurRadius: 30,
                              //     spreadRadius: 2,
                              //   )
                              // ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: _currentArtPath.isNotEmpty
                                  ? Image.file(
                                      File(_currentArtPath),
                                      width: 180,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _artPlaceholder(accentColor),
                                    )
                                  : _artPlaceholder(accentColor),
                            ),
                          ),
                          // Camera badge
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: accentColor.withValues(alpha: 0.5),
                                      blurRadius: 10)
                                ],
                              ),
                              child: const Icon(LucideIcons.camera,
                                  color: Colors.black, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_currentArtPath.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton.icon(
                        onPressed: _clearArtwork,
                        icon: const Icon(LucideIcons.x,
                            size: 14, color: Colors.redAccent),
                        label: Text('Remove artwork',
                            style: AppFonts.jostStyle(
                                color: Colors.redAccent, fontSize: 12)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // ── Fields ────────────────────────────────────────────────
                  _SectionLabel('TRACK INFO'),
                  const SizedBox(height: 12),
                  _EditField(
                    controller: _titleCtrl,
                    label: 'Title',
                    icon: LucideIcons.music,
                    accentColor: accentColor,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _EditField(
                    controller: _artistCtrl,
                    label: 'Artist',
                    icon: LucideIcons.mic2,
                    accentColor: accentColor,
                  ),
                  const SizedBox(height: 12),
                  _EditField(
                    controller: _albumCtrl,
                    label: 'Album',
                    icon: LucideIcons.disc,
                    accentColor: accentColor,
                  ),
                  const SizedBox(height: 28),

                  _SectionLabel('DETAILS'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _EditField(
                          controller: _yearCtrl,
                          label: 'Year',
                          icon: LucideIcons.calendar,
                          accentColor: accentColor,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: _EditField(
                          controller: _genreCtrl,
                          label: 'Genre',
                          icon: LucideIcons.tag,
                          accentColor: accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  _SectionLabel('LYRICS'),
                  const SizedBox(height: 12),
                  _EditField(
                    controller: _lyricsCtrl,
                    label: 'Lyrics (Plain text or LRC)',
                    icon: LucideIcons.fileText,
                    accentColor: accentColor,
                    maxLines: 8,
                    keyboardType: TextInputType.multiline,
                    hintText: 'Enter plain lyrics or synchronized LRC lyrics format [00:00.00]...',
                  ),

                  const SizedBox(height: 32),


                  // ── File path (read-only info) ─────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.fileAudio,
                            color: Colors.white38, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.song.path.split('/').last,
                            style: AppFonts.jostStyle(
                                color: Colors.white38, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Save button ────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor:
                            accentColor.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        elevation: 4,
                        shadowColor: accentColor.withValues(alpha: 0.4),
                      ),
                      child: _isSaving
                          ? const AppLoadingIndicator(size: 44)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(LucideIcons.check, size: 20),
                                const SizedBox(width: 8),
                                Text('Save Changes',
                                    style: AppFonts.jostStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Blur wrapper when dynamic theming is on
    if (settings.enableDynamicTheming && !settings.disableBlur) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: content,
        ),
      );
    }
    return content;
  }

  Widget _artPlaceholder(Color accentColor) => Container(
        color: Colors.white.withValues(alpha: 0.05),
        child: Icon(LucideIcons.imageOff,
            color: accentColor.withValues(alpha: 0.5), size: 56),
      );
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppFonts.jostStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      );
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool required;
  final TextInputType keyboardType;
  final int? maxLength;
  final int maxLines;
  final String? hintText;

  const _EditField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.maxLines = 1,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        style: AppFonts.jostStyle(color: Colors.white, fontSize: 15),
        keyboardType: keyboardType,
        maxLength: maxLength,
        maxLines: maxLines,
        buildCounter: maxLength != null
            ? (ctx, {required currentLength, required isFocused, maxLength}) =>
                null
            : null,
        decoration: InputDecoration(
          labelText: '$label${required ? ' *' : ''}',
          labelStyle:
              AppFonts.jostStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
          hintText: hintText,
          hintStyle: AppFonts.jostStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 13),
          prefixIcon: Icon(icon, color: accentColor, size: 20),
          alignLabelWithHint: maxLines > 1,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: accentColor, width: 1.5),
          ),
        ),
      );
}

// ─── Menu Option Tile ─────────────────────────────────────────────────────────

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
                style: AppFonts.jostStyle(
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

// ─── Sleep Timer helpers ──────────────────────────────────────────────────────

String _formatSleepTimerRemaining(PlaybackState state) {
  if (state.sleepTimerDurationRemaining != null) {
    final duration = state.sleepTimerDurationRemaining!;
    final minutes = duration.inMinutes;
    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
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
  ConsumerState<_SleepTimerSheetContent> createState() =>
      _SleepTimerSheetContentState();
}

class _SleepTimerSheetContentState
    extends ConsumerState<_SleepTimerSheetContent> {
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
        : (useBlur
            ? Colors.black.withValues(alpha: 0.6)
            : const Color(0xFF1E1E1E));

    Widget sheetContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isPureBlack
              ? Colors.white10
              : Colors.white.withValues(alpha: 0.08),
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
                Text(
                  'Sleep Timer',
                  style: AppFonts.jostStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
              style: AppFonts.jostStyle(
                fontSize: 14,
                color: playbackState.isSleepTimerActive
                    ? accentColor
                    : Colors.white54,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'STOP BY TIME',
              style: AppFonts.jostStyle(
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$_customMinutes ${_customMinutes == 1 ? 'Min' : 'Mins'}',
                        style: AppFonts.jostStyle(
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref
                          .read(playbackProvider.notifier)
                          .startSleepTimer(duration: Duration(minutes: _customMinutes));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text('Start',
                        style: AppFonts.jostStyle(fontWeight: FontWeight.bold)),
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
                  _buildCustomChip(
                      label: '1 Min',
                      onTap: () => _startTimer(const Duration(minutes: 1))),
                  _buildCustomChip(
                      label: '5 Min',
                      onTap: () => _startTimer(const Duration(minutes: 5))),
                  _buildCustomChip(
                      label: '10 Min',
                      onTap: () => _startTimer(const Duration(minutes: 10))),
                  _buildCustomChip(
                      label: '30 Min',
                      onTap: () => _startTimer(const Duration(minutes: 30))),
                  _buildCustomChip(
                      label: '45 Min',
                      onTap: () => _startTimer(const Duration(minutes: 45))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'STOP BY SONG COUNT',
              style: AppFonts.jostStyle(
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$_customSongs ${_customSongs == 1 ? 'Song' : 'Songs'}',
                        style: AppFonts.jostStyle(
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref
                          .read(playbackProvider.notifier)
                          .startSleepTimer(songCount: _customSongs);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text('Start',
                        style: AppFonts.jostStyle(fontWeight: FontWeight.bold)),
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
                  _buildCustomChip(
                      label: '1 Song', onTap: () => _startSongs(1)),
                  _buildCustomChip(
                      label: '2 Songs', onTap: () => _startSongs(2)),
                  _buildCustomChip(
                      label: '3 Songs', onTap: () => _startSongs(3)),
                  _buildCustomChip(
                      label: '5 Songs', onTap: () => _startSongs(5)),
                  _buildCustomChip(
                      label: '10 Songs', onTap: () => _startSongs(10)),
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
                label: Text('Cancel Sleep Timer',
                    style: AppFonts.jostStyle(fontWeight: FontWeight.bold)),
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
                style: AppFonts.jostStyle(
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
