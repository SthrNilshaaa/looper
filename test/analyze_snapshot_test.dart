import 'package:flutter_test/flutter_test.dart';
import 'package:looper_player/features/analyze/domain/analyze_models.dart';
import 'package:looper_player/features/library/domain/models/models.dart';

Song _song({
  required String path,
  required String title,
  String? artist,
  String? album,
  String? genre,
  int playCount = 0,
  int? duration,
  int totalListenedMs = 0,
}) {
  return Song()
    ..path = path
    ..title = title
    ..artist = artist
    ..album = album
    ..genre = genre
    ..playCount = playCount
    ..duration = duration
    ..totalListenedMs = totalListenedMs
    ..dateAdded = DateTime(2026, 1, 1);
}

PlayEvent _event(DateTime playedAt) {
  return PlayEvent()
    ..songPath = 'p'
    ..songTitle = 't'
    ..playedAt = playedAt;
}

void main() {
  group('AnalyzeSnapshot.compute — rankings', () {
    test('ranks songs by play count descending and skips unplayed songs', () {
      final songs = [
        _song(path: 'a', title: 'A', playCount: 3),
        _song(path: 'b', title: 'B', playCount: 10),
        _song(path: 'c', title: 'C', playCount: 0), // never played
        _song(path: 'd', title: 'D', playCount: 7),
      ];

      final snapshot = AnalyzeSnapshot.compute(songs: songs, events: const []);

      expect(snapshot.topSongs.map((s) => s.song.title), ['B', 'D', 'A']);
      expect(snapshot.topSongs.first.rank, 1);
      expect(snapshot.topSongs.first.share, 1.0);
      expect(snapshot.uniqueSongsPlayed, 3);
      expect(snapshot.totalSongsInLibrary, 4);
      expect(snapshot.totalPlays, 20);
    });

    test('caps the top songs list at 20 entries', () {
      final songs = [
        for (var i = 0; i < 30; i++)
          _song(path: 'song$i', title: 'Song $i', playCount: 30 - i),
      ];

      final snapshot = AnalyzeSnapshot.compute(songs: songs, events: const []);

      expect(snapshot.topSongs.length, 20);
      expect(snapshot.topSongs.first.song.title, 'Song 0');
      expect(snapshot.topSongs.last.song.title, 'Song 19');
    });

    test('aggregates artists across songs and falls back for unknown artist', () {
      final songs = [
        _song(path: 'a', title: 'A', artist: 'Alice', playCount: 5),
        _song(path: 'b', title: 'B', artist: 'Alice', playCount: 4),
        _song(path: 'c', title: 'C', artist: 'Bob', playCount: 20),
        _song(path: 'd', title: 'D', artist: null, playCount: 1),
      ];

      final snapshot = AnalyzeSnapshot.compute(songs: songs, events: const []);

      expect(snapshot.topArtists.first.name, 'Bob');
      expect(snapshot.topArtists.first.totalPlays, 20);
      final alice = snapshot.topArtists.firstWhere((a) => a.name == 'Alice');
      expect(alice.totalPlays, 9);
      expect(alice.songCount, 2);
      expect(
        snapshot.topArtists.any((a) => a.name == 'Unknown Artist'),
        isTrue,
      );
    });

    test('rolls extra genres up into an "Other" slice beyond the top 6', () {
      final songs = [
        for (var i = 0; i < 8; i++)
          _song(
            path: 'g$i',
            title: 'G$i',
            genre: 'Genre$i',
            playCount: 8 - i, // strictly descending so ranking is deterministic
          ),
      ];

      final snapshot = AnalyzeSnapshot.compute(songs: songs, events: const []);

      expect(snapshot.topGenres.length, 7); // top 6 + Other
      expect(snapshot.topGenres.last.name, 'Other');
      // Genre6 (2 plays) + Genre7 (1 play) rolled into Other.
      expect(snapshot.topGenres.last.totalPlays, 3);
    });

    test('sums real tracked listening time, never play count times duration', () {
      final songs = [
        // Played 2 times but only ever actually listened to ~5s total (e.g.
        // skipped almost immediately both times) - must NOT be inflated to
        // playCount * duration.
        _song(
          path: 'a',
          title: 'A',
          playCount: 2,
          duration: 180000,
          totalListenedMs: 5000,
        ),
        _song(
          path: 'b',
          title: 'B',
          playCount: 3,
          duration: 200000,
          totalListenedMs: 45000,
        ),
      ];

      final snapshot = AnalyzeSnapshot.compute(songs: songs, events: const []);

      expect(snapshot.totalListenedMs, 5000 + 45000);
    });

    test('reports no history when nothing has been played', () {
      final songs = [_song(path: 'a', title: 'A', playCount: 0)];
      final snapshot = AnalyzeSnapshot.compute(songs: songs, events: const []);

      expect(snapshot.hasHistory, isFalse);
      expect(snapshot.topSongs, isEmpty);
      expect(snapshot.streak.current, 0);
    });
  });

  group('AnalyzeSnapshot.compute — streaks', () {
    test('counts a current streak of consecutive days ending today', () {
      final now = DateTime(2026, 6, 10, 20);
      final events = [
        _event(DateTime(2026, 6, 10, 9)),
        _event(DateTime(2026, 6, 9, 9)),
        _event(DateTime(2026, 6, 8, 9)),
      ];

      final snapshot = AnalyzeSnapshot.compute(
        songs: const [],
        events: events,
        now: now,
      );

      expect(snapshot.streak.current, 3);
      expect(snapshot.streak.longest, 3);
    });

    test('still counts yesterday as current if today has no plays yet', () {
      final now = DateTime(2026, 6, 10, 1); // just past midnight, not played yet
      final events = [
        _event(DateTime(2026, 6, 9, 22)),
        _event(DateTime(2026, 6, 8, 22)),
      ];

      final snapshot = AnalyzeSnapshot.compute(
        songs: const [],
        events: events,
        now: now,
      );

      expect(snapshot.streak.current, 2);
    });

    test('resets current streak to 0 once a day is missed', () {
      final now = DateTime(2026, 6, 10, 20);
      final events = [
        _event(DateTime(2026, 6, 5, 9)),
        _event(DateTime(2026, 6, 4, 9)),
      ];

      final snapshot = AnalyzeSnapshot.compute(
        songs: const [],
        events: events,
        now: now,
      );

      expect(snapshot.streak.current, 0);
      expect(snapshot.streak.longest, 2);
    });

    test('longest streak can exceed the current one across a gap', () {
      final now = DateTime(2026, 6, 20, 20);
      final events = [
        // A broken 4-day run earlier in the month...
        _event(DateTime(2026, 6, 1, 9)),
        _event(DateTime(2026, 6, 2, 9)),
        _event(DateTime(2026, 6, 3, 9)),
        _event(DateTime(2026, 6, 4, 9)),
        // ...then a fresh, shorter, current 2-day run.
        _event(DateTime(2026, 6, 19, 9)),
        _event(DateTime(2026, 6, 20, 9)),
      ];

      final snapshot = AnalyzeSnapshot.compute(
        songs: const [],
        events: events,
        now: now,
      );

      expect(snapshot.streak.current, 2);
      expect(snapshot.streak.longest, 4);
    });
  });
}
