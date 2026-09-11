import 'package:flutter_test/flutter_test.dart';
import 'package:looper_player/features/library/data/scanner.dart';

void main() {
  group('ArtistParser Tests', () {
    test('parses single artist correctly', () {
      final result = ArtistParser.parse('Daft Punk');
      expect(result, equals(['Daft Punk']));
      expect(ArtistParser.primaryArtist('Daft Punk'), equals('Daft Punk'));
    });

    test('parses multiple artists with semicolon delimiter', () {
      final result = ArtistParser.parse('Artist A; Artist B');
      expect(result, equals(['Artist A', 'Artist B']));
    });

    test('parses multiple artists with feat. delimiter', () {
      final result = ArtistParser.parse('Main Artist feat. Guest Artist');
      expect(result, equals(['Main Artist', 'Guest Artist']));
      expect(ArtistParser.primaryArtist('Main Artist feat. Guest Artist'), equals('Main Artist'));
    });

    test('parses multiple artists with slash and ampersand delimiters', () {
      final result = ArtistParser.parse('Artist 1 / Artist 2 & Artist 3');
      expect(result, equals(['Artist 1', 'Artist 2', 'Artist 3']));
    });

    test('handles empty or null artist gracefully', () {
      expect(ArtistParser.parse(null), equals(['Unknown Artist']));
      expect(ArtistParser.parse(''), equals(['Unknown Artist']));
      expect(ArtistParser.parse('Unknown Artist'), equals(['Unknown Artist']));
    });
  });
}
