import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../features/library/domain/models/models.dart';

class DbService {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [SongSchema, AlbumSchema, ArtistSchema, PlaylistSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }
}
