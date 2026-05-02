import 'dart:convert';
import 'package:http/http.dart' as http;

class ArtistImageService {
  static const String baseUrl = 'https://api.deezer.com';

  Future<String?> getArtistImage(String artistName) async {
    try {
      final url = Uri.parse('$baseUrl/search/artist').replace(queryParameters: {
        'q': artistName,
        'limit': '1',
      });

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          return data['data'][0]['picture_big'] ?? data['data'][0]['picture_medium'];
        }
      }
    } catch (e) {
      print('Error fetching artist image: $e');
    }
    return null;
  }
}
