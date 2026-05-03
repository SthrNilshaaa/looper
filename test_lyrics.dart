import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final baseUrl = 'https://lrclib.net/api';
  final url = Uri.parse('$baseUrl/get').replace(queryParameters: {
    'track_name': 'Billie Jean',
    'artist_name': 'Michael Jackson',
    'album_name': 'Thriller',
    // Omit duration for testing
  });

  print('Requesting: $url');
  try {
    final response = await http.get(url);
    print('Status Code: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
