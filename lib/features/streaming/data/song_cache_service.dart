import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SongCacheService {
  Directory? _cacheDir;

  Future<Directory> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final temp = await getTemporaryDirectory();
    final dir = Directory('${temp.path}/spatialflow_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cacheDir = dir;
    return dir;
  }

  /// Returns cached local file path if stream was previously cached
  Future<String?> getCachedFilePath(String trackId) async {
    final dir = await _getCacheDir();
    final file = File('${dir.path}/$trackId.m4a');
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  /// Saves stream bytes to local cache
  Future<String> saveToCache(String trackId, List<int> bytes) async {
    final dir = await _getCacheDir();
    final file = File('${dir.path}/$trackId.m4a');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
