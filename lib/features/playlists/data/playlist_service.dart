import 'package:isar/isar.dart';
import 'package:one_player/core/db_service.dart';
import 'package:one_player/features/library/domain/models/models.dart';

class PlaylistService {
  static Future<void> addSongToPlaylist(Playlist playlist, Song song) async {
    if (playlist.songPaths.contains(song.path)) return;
    
    final updatedPaths = List<String>.from(playlist.songPaths)..add(song.path);
    
    await DbService.isar.writeTxn(() async {
      playlist.songPaths = updatedPaths;
      playlist.dateModified = DateTime.now();
      await DbService.isar.playlists.put(playlist);
    });
  }

  static Future<void> removeSongFromPlaylist(Playlist playlist, Song song) async {
    final updatedPaths = List<String>.from(playlist.songPaths)..remove(song.path);
    
    await DbService.isar.writeTxn(() async {
      playlist.songPaths = updatedPaths;
      playlist.dateModified = DateTime.now();
      await DbService.isar.playlists.put(playlist);
    });
  }

  static Future<List<Playlist>> getAllPlaylists() async {
    return await DbService.isar.playlists.where().sortByDateModifiedDesc().findAll();
  }
}
