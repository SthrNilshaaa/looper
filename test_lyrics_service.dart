import 'package:one_player/features/playback/data/lyrics_service.dart';

void main() async {
  final service = LyricsService();
  final response = await service.getLyrics(
    trackName: 'Some Weird Song',
    artistName: 'Unknown Guy',
    albumName: '',
    durationSeconds: 0,
  );

  if (response != null) {
    print('Got lyrics! Has synced: ${response.syncedLyrics != null}, Has plain: ${response.plainLyrics != null}');
  } else {
    print('No lyrics found.');
  }
}
