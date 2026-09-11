import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as p;

class AudioAnalysis {
  final String codec;
  final String container;
  final int sampleRate;
  final int channels;
  final int bitrate;
  final int bitsPerSample;
  final double duration;
  final double? integratedLufs;
  final double? truePeakDb;

  // Extended Metadata
  final String? isrc;
  final String? copyright;
  final String? composer;
  final String? label;
  final String? encoder;

  AudioAnalysis({
    required this.codec,
    required this.container,
    required this.sampleRate,
    required this.channels,
    required this.bitrate,
    required this.bitsPerSample,
    required this.duration,
    this.integratedLufs,
    this.truePeakDb,
    this.isrc,
    this.copyright,
    this.composer,
    this.label,
    this.encoder,
  });

  String get bitDepth => bitsPerSample > 0 ? '$bitsPerSample-bit' : 'N/A';
  String get sampleRateKhz => '${(sampleRate / 1000).toStringAsFixed(1)} kHz';
  String get bitrateKbps => '${(bitrate / 1000).round()} kbps';
}

class AudioAnalyzer {
  static final Map<String, AudioAnalysis> _cache = {};

  static AudioAnalysis? getCachedAnalysis(String filePath) {
    return _cache[filePath];
  }

  static Future<AudioAnalysis?> analyze(String filePath) async {
    if (_cache.containsKey(filePath)) {
      return _cache[filePath];
    }
    try {
      final ext = p.extension(filePath).replaceAll('.', '').toUpperCase();
      final file = File(filePath);
      final fileSize = await file.length();
      final technical = await _readTechnicalInfo(file, ext);

      Metadata? metadata;
      try {
        metadata = await MetadataGod.readMetadata(file: filePath);
      } catch (_) {}

      final metadataDuration = (metadata?.durationMs ?? 0) / 1000.0;
      final durationSec = metadataDuration > 0
          ? metadataDuration
          : technical.duration;
      final bitrate = technical.bitrate > 0
          ? technical.bitrate
          : durationSec > 0
          ? ((fileSize * 8) / durationSec).round()
          : 0;

      final analysis = AudioAnalysis(
        codec: ext.isNotEmpty ? ext : 'AUDIO',
        container: ext.isNotEmpty ? ext : 'FILE',
        sampleRate: technical.sampleRate,
        channels: technical.channels,
        bitrate: bitrate,
        bitsPerSample: technical.bitsPerSample,
        duration: durationSec,
      );
      _cache[filePath] = analysis;
      return analysis;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, double>?> getLoudness(String filePath) async {
    return null;
  }

  static Future<_TechnicalAudioInfo> _readTechnicalInfo(
    File file,
    String extension,
  ) async {
    final length = await file.length();
    final handle = await file.open();
    try {
      final bytes = await handle.read(math.min(length, 1024 * 1024));
      if (extension == 'FLAC') return _parseFlac(bytes);
      if (extension == 'WAV' || extension == 'WAVE') return _parseWave(bytes);
      return const _TechnicalAudioInfo();
    } finally {
      await handle.close();
    }
  }

  static _TechnicalAudioInfo _parseFlac(Uint8List bytes) {
    if (bytes.length < 42 ||
        bytes[0] != 0x66 ||
        bytes[1] != 0x4c ||
        bytes[2] != 0x61 ||
        bytes[3] != 0x43) {
      return const _TechnicalAudioInfo();
    }

    var offset = 4;
    while (offset + 4 <= bytes.length) {
      final type = bytes[offset] & 0x7f;
      final blockLength =
          (bytes[offset + 1] << 16) |
          (bytes[offset + 2] << 8) |
          bytes[offset + 3];
      final dataOffset = offset + 4;
      if (dataOffset + blockLength > bytes.length) break;
      if (type == 0 && blockLength >= 34) {
        final packed = ByteData.sublistView(
          bytes,
          dataOffset + 10,
          dataOffset + 18,
        ).getUint64(0, Endian.big);
        final sampleRate = (packed >> 44) & 0xfffff;
        final channels = ((packed >> 41) & 0x7) + 1;
        final bitsPerSample = ((packed >> 36) & 0x1f) + 1;
        final totalSamples = packed & 0xfffffffff;
        return _TechnicalAudioInfo(
          sampleRate: sampleRate,
          channels: channels,
          bitsPerSample: bitsPerSample,
          duration: sampleRate > 0 ? totalSamples / sampleRate : 0,
        );
      }
      offset = dataOffset + blockLength;
    }
    return const _TechnicalAudioInfo();
  }

  static _TechnicalAudioInfo _parseWave(Uint8List bytes) {
    if (bytes.length < 12 ||
        !((bytes[0] == 0x52 &&
                bytes[1] == 0x49 &&
                bytes[2] == 0x46 &&
                bytes[3] == 0x46) ||
            (bytes[0] == 0x52 &&
                bytes[1] == 0x46 &&
                bytes[2] == 0x36 &&
                bytes[3] == 0x34)) ||
        bytes[8] != 0x57 ||
        bytes[9] != 0x41 ||
        bytes[10] != 0x56 ||
        bytes[11] != 0x45) {
      return const _TechnicalAudioInfo();
    }

    final data = ByteData.sublistView(bytes);
    var offset = 12;
    while (offset + 8 <= bytes.length) {
      final chunkSize = data.getUint32(offset + 4, Endian.little);
      final dataOffset = offset + 8;
      if (bytes[offset] == 0x66 &&
          bytes[offset + 1] == 0x6d &&
          bytes[offset + 2] == 0x74 &&
          bytes[offset + 3] == 0x20 &&
          chunkSize >= 16 &&
          dataOffset + 16 <= bytes.length) {
        final formatTag = data.getUint16(dataOffset, Endian.little);
        final containerBits = data.getUint16(dataOffset + 14, Endian.little);
        final validBits =
            formatTag == 0xfffe &&
                chunkSize >= 20 &&
                dataOffset + 20 <= bytes.length
            ? data.getUint16(dataOffset + 18, Endian.little)
            : 0;
        return _TechnicalAudioInfo(
          channels: data.getUint16(dataOffset + 2, Endian.little),
          sampleRate: data.getUint32(dataOffset + 4, Endian.little),
          bitrate: data.getUint32(dataOffset + 8, Endian.little) * 8,
          bitsPerSample: validBits > 0 ? validBits : containerBits,
        );
      }
      offset = dataOffset + chunkSize + (chunkSize.isOdd ? 1 : 0);
    }
    return const _TechnicalAudioInfo();
  }
}

class _TechnicalAudioInfo {
  final int sampleRate;
  final int channels;
  final int bitsPerSample;
  final int bitrate;
  final double duration;

  const _TechnicalAudioInfo({
    this.sampleRate = 0,
    this.channels = 0,
    this.bitsPerSample = 0,
    this.bitrate = 0,
    this.duration = 0,
  });
}
