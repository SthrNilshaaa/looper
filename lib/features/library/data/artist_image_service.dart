import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ArtistImageService {
  static const String baseUrl = 'https://api.deezer.com';

  Future<String?> getArtistImage(String artistName) async {
    try {
      final url = Uri.parse(
        '$baseUrl/search/artist',
      ).replace(queryParameters: {'q': artistName, 'limit': '1'});

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          final imageUrl = data['data'][0]['picture_big'] ??
              data['data'][0]['picture_medium'];
          
          if (imageUrl != null) {
            return await _downloadAndSaveImage(artistName, imageUrl);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching artist image: $e');
    }
    return null;
  }

  Future<String?> _downloadAndSaveImage(String artistName, String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final appDir = await getApplicationSupportDirectory();
        final artistDir = Directory(p.join(appDir.path, 'artist_images'));
        if (!await artistDir.exists()) await artistDir.create(recursive: true);

        final fileName = '${artistName.replaceAll(RegExp(r'[^\w\s]+'), '')}.jpg';
        final file = File(p.join(artistDir.path, fileName));
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (e) {
      debugPrint('Error downloading artist image: $e');
    }
    return null;
  }
}
