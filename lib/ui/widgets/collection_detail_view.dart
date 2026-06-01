import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/playlists/presentation/playlist_view.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/core/navigation_provider.dart';

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
    final activeSong = ref.watch(playbackProvider).currentSong;

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
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 200), // Added padding to fix navbar overlap
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildArt(context, true),
                        const SizedBox(width: 20),
                        Expanded(child: _buildInfo(context, ref, true, activeSong?.artPath, reactivePlaylist, titleToRender, songsToRender)),
                      ],
                    ),
                  ),
                  // Songs List
                  SongsList(
                    songs: songsToRender,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    playlist: reactivePlaylist,
                  ),
                ],
              ),
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
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Play All',
                    style: TextStyle(
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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            ListTile(
              leading: const Icon(LucideIcons.edit2, color: Colors.greenAccent),
              title: const Text('Rename Playlist', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, ref, playlist);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.trash2, color: Colors.redAccent),
              title: const Text('Delete Playlist', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context, ref, playlist);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, Playlist playlist) {
    final controller = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: const Text('Rename Playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Playlist name'),
          autofocus: true,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: const Text('Delete Playlist'),
        content: Text('Are you sure you want to delete "${playlist.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DbService.isar.writeTxn(() => DbService.isar.playlists.delete(playlist.id));
              Navigator.pop(context); // Close dialog
              ref.read(appNavigationProvider.notifier).goBack(); // Go back using appNavigationProvider to stay in sync
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
