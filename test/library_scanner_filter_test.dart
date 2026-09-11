import 'package:flutter_test/flutter_test.dart';
import 'package:looper_player/features/library/data/scanner.dart';

void main() {
  group('library scan exclusions', () {
    test('keeps ordinary custom music folders', () {
      expect(
        isIgnoredScanPath('/storage/emulated/0/MyWhatsAppMusic/song.flac'),
        isFalse,
      );
      expect(
        isIgnoredScanPath('/storage/1234-ABCD/Custom Songs/song.mp3'),
        isFalse,
      );
    });

    test('excludes system and messaging audio by default', () {
      expect(
        isIgnoredScanPath('/storage/emulated/0/Ringtones/tone.ogg'),
        isTrue,
      );
      expect(
        isIgnoredScanPath(
          '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Audio/message.opus',
        ),
        isTrue,
      );
    });

    test('includes optional audio when enabled', () {
      expect(
        isIgnoredScanPath(
          '/storage/emulated/0/Notifications/alert.ogg',
          includeSystemAndMessagingAudio: true,
        ),
        isFalse,
      );
      expect(
        isIgnoredScanPath(
          '/storage/emulated/0/Android/media/org.telegram/Telegram/Telegram Audio/message.ogg',
          includeSystemAndMessagingAudio: true,
        ),
        isFalse,
      );
    });

    test('always excludes protected application data', () {
      expect(
        isIgnoredScanPath(
          '/storage/emulated/0/Android/data/example/files/song.mp3',
          includeSystemAndMessagingAudio: true,
        ),
        isTrue,
      );
    });
  });
}
