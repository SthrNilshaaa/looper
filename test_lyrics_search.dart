import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final baseUrl = 'https://lrclib.net/api';
  final url = Uri.parse('$baseUrl/search').replace(queryParameters: {
    'track_name': 'Billie Jean',
    'artist_name': 'Michael Jackson',
    'album_name': 'Thriller',
  });

  print('Requesting: $url');
  try {
    final response = await http.get(url);
    print('Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      print('Found ${list.length} results');
      if (list.isNotEmpty) {
         print('First result duration: ${list[0]['duration']}');
      }
    } else {
      print('Body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
