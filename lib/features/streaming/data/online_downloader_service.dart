import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/streaming/domain/models/online_track.dart';

class OnlineDownloaderService {
  /// Downloads an online track directly to device storage and registers it in Isar DB
  Future<Song?> downloadTrack(OnlineTrack track, String directStreamUrl) async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final musicFolder = Directory('${docs.path}/DownloadedMusic');
      if (!await musicFolder.exists()) {
        await musicFolder.create(recursive: true);
      }

      final sanitizedTitle = track.title.replaceAll(RegExp(r'[^\w\s\.-]'), '');
      final filePath = '${musicFolder.path}/${track.id}_$sanitizedTitle.m4a';
      final file = File(filePath);

      final response = await http.get(Uri.parse(directStreamUrl));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);

        // Create Song model for local DB
        final song = Song()
          ..title = track.title
          ..artist = track.artist
          ..album = 'SpatialFlow Downloads'
          ..path = filePath
          ..artPath = track.thumbnailUrl
          ..duration = track.duration.inMilliseconds
          ..dateAdded = DateTime.now();

        await DbService.isar.writeTxn(() async {
          await DbService.isar.songs.put(song);
        });

        return song;
      }
    } catch (_) {}
    return null;
  }
}
