import 'package:flutter_test/flutter_test.dart';
import 'package:looper_player/core/ui_utils.dart';

void main() {
  group('formatPlaybackDuration', () {
    test('uses minutes and seconds below one hour', () {
      expect(
        UiUtils.formatPlaybackDuration(const Duration(minutes: 3, seconds: 7)),
        '03:07',
      );
    });

    test('includes hours for long tracks', () {
      expect(
        UiUtils.formatPlaybackDuration(
          const Duration(hours: 2, minutes: 3, seconds: 7),
        ),
        '2:03:07',
      );
    });

    test('can keep the position width aligned with a long duration', () {
      expect(
        UiUtils.formatPlaybackDuration(
          const Duration(minutes: 3, seconds: 7),
          showHours: true,
        ),
        '0:03:07',
      );
    });
  });
}
