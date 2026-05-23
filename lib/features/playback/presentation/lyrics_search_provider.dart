import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track the current search query specifically for lyrics highlighting and scrolling.
final lyricsSearchQueryProvider = StateProvider<String>((ref) => '');
