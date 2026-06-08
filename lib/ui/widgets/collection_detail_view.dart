import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/playlists/presentation/playlist_view.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/l10n/app_localizations.dart';

class CollectionDetailView extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final String? artPath;
  final String? imageUrl;
  final List<Song> songs;
  final Playlist? playlist;

  const CollectionDetailView({
    super.key,
    required this.title,
    this.subtitle,
    this.artPath,
    this.imageUrl,
    required this.songs,
    this.playlist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSong = ref.watch(playbackProvider.select((s) => s.currentSong));

    // Reactively watch the playlist object if it is passed, so the title updates when renamed
    final reactivePlaylist = playlist != null
        ? ref.watch(playlistProvider.select((list) => list.firstWhere((p) => p.id == playlist!.id, orElse: () => playlist!)))
        : null;

    final titleToRender = reactivePlaylist != null ? reactivePlaylist.name : title;

    // Reactively watch songs of this playlist using playlistSongsProvider
    final playlistSongsAsync = playlist != null
        ? ref.watch(playlistSongsProvider(playlist!.id))
        : null;

    final songsToRender = playlistSongsAsync != null
        ? (playlistSongsAsync.value ?? <Song>[])
        : songs;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 450;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                        child: IconButton(
                          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
                          onPressed: () => ref.read(appNavigationProvider.notifier).goBack(),
                        ),
                      ),
                      // Header - Now always a Row for cover and name
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: isNarrow
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(child: _buildArt(context, true)),
                                  const SizedBox(height: 20),
                                  _buildInfo(context, ref, true, activeSong?.artPath, reactivePlaylist, titleToRender, songsToRender),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildArt(context, true),
                                  const SizedBox(width: 20),
                                  Expanded(child: _buildInfo(context, ref, true, activeSong?.artPath, reactivePlaylist, titleToRender, songsToRender)),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
                if (songsToRender.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = songsToRender[index];
                        final l10n = AppLocalizations.of(context)!;
                        return SongTile(
                          song: song,
                          l10n: l10n,
                          songs: songsToRender,
                          playlist: reactivePlaylist,
                        );
                      },
                      childCount: songsToRender.length,
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 200), // Added padding to fix navbar overlap
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildArt(BuildContext context, bool isNarrow) {
    final double size = 140; // Unified size for a cleaner Row look
    return OptimizedImage(
      imagePath: artPath,
      imageUrl: imageUrl,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(16),
      placeholder: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          LucideIcons.music,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context, WidgetRef ref, bool isNarrow, String? activeArtworkPath, Playlist? reactivePlaylist, String titleToRender, List<Song> songsToRender) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleToRender,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            PremiumSection(
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 44,
              useExpanded: false,
              onTap: () {
                HapticFeedback.mediumImpact();
                ref.read(playbackProvider.notifier).setPlaylist(songsToRender);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)!.playAll,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PremiumSection(
              borderRadius: BorderRadius.circular(12),
              width: 44,
              height: 44,
              useExpanded: false,
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(playbackProvider.notifier).toggleShuffle();
                ref.read(playbackProvider.notifier).setPlaylist(songsToRender);
              },
              child: const Icon(LucideIcons.shuffle, size: 16, color: Colors.white),
            ),
            if (reactivePlaylist != null) ...[
              const SizedBox(width: 8),
              PremiumSection(
                borderRadius: BorderRadius.circular(12),
                width: 44,
                height: 44,
                useExpanded: false,
                onTap: () => _showPlaylistOptions(context, ref, reactivePlaylist),
                child: const Icon(LucideIcons.moreHorizontal, size: 18, color: Colors.white),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _showPlaylistOptions(BuildContext context, WidgetRef ref, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (context) {
        final settings = ref.watch(settingsProvider);
        final useBlur = settings.enableDynamicTheming && !settings.disableBlur;
        final isPureBlack = settings.darkTheme;

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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.listMusic, size: 24, color: Colors.orangeAccent),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          playlist.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 8),
                PremiumSection(
                  borderRadius: BorderRadius.circular(20),
                  padding: EdgeInsets.zero,
                  useExpanded: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showRenameDialog(context, ref, playlist);
                        },
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.edit2, size: 22, color: Colors.greenAccent),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  'Rename Playlist',
                                  style: TextStyle(
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
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.8,
                        color: Colors.white.withValues(alpha: 0.04),
                        indent: 20,
                        endIndent: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteDialog(context, ref, playlist);
                        },
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.trash2, size: 22, color: Colors.redAccent),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  'Delete Playlist',
                                  style: TextStyle(
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );

        if (useBlur && !isPureBlack) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: sheetContent,
            ),
          );
        }

        return sheetContent;
      },
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, Playlist playlist) {
    final controller = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          title: Text(l10n.renamePlaylist),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: l10n.newPlaylist),
            autofocus: true,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty && controller.text != playlist.name) {
                  await DbService.isar.writeTxn(() async {
                    playlist.name = controller.text;
                    playlist.dateModified = DateTime.now();
                    await DbService.isar.playlists.put(playlist);
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.rename),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          title: Text(l10n.deletePlaylist),
          content: Text(l10n.deletePlaylistConfirm(playlist.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                await DbService.isar.writeTxn(() => DbService.isar.playlists.delete(playlist.id));
                Navigator.pop(context); // Close dialog
                ref.read(appNavigationProvider.notifier).goBack(); // Go back using appNavigationProvider to stay in sync
              },
              child: Text(l10n.delete, style: const TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}
