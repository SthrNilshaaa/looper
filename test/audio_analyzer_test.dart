import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:looper_player/features/playback/data/audio_analyzer.dart';

void main() {
  test('reads bit depth and sample rate from FLAC STREAMINFO', () async {
    final bytes = Uint8List(42);
    bytes.setAll(0, [0x66, 0x4c, 0x61, 0x43]); // fLaC
    bytes.setAll(4, [
      0x80,
      0x00,
      0x00,
      0x22,
    ]); // Last block, STREAMINFO, 34 bytes

    const sampleRate = 96000;
    const channels = 2;
    const bitsPerSample = 24;
    const totalSamples = 960000;
    final packed =
        (sampleRate << 44) |
        ((channels - 1) << 41) |
        ((bitsPerSample - 1) << 36) |
        totalSamples;
    ByteData.sublistView(bytes, 18, 26).setUint64(0, packed, Endian.big);

    final directory = await Directory.systemTemp.createTemp(
      'looper_audio_test_',
    );
    final file = File('${directory.path}/sample.flac');
    await file.writeAsBytes(bytes);
    addTearDown(() => directory.delete(recursive: true));

    final analysis = await AudioAnalyzer.analyze(file.path);
    expect(analysis, isNotNull);
    expect(analysis!.sampleRate, sampleRate);
    expect(analysis.channels, channels);
    expect(analysis.bitsPerSample, bitsPerSample);
    expect(analysis.duration, 10.0);
  });
}
