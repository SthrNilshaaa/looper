import 'dart:io';
import 'package:ffmpeg_kit_flutter_new_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_full/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_full/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new_full/level.dart';
import 'package:ffmpeg_kit_flutter_new_full/return_code.dart';
import 'package:flutter/foundation.dart';

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
  static Future<AudioAnalysis?> analyze(String filePath) async {
    try {
      final session = await FFprobeKit.getMediaInformation(filePath);
      final info = session.getMediaInformation();

      if (info == null) return null;

      final streams = info.getStreams();
      final audioStream = streams.firstWhere(
        (s) => s.getAllProperties()?['codec_type'] == 'audio',
        orElse: () => throw Exception('No audio stream found'),
      );

      final props = audioStream.getAllProperties() ?? {};
      final infoProps = info.getAllProperties() ?? {};
      final tags = info.getTags() ?? {};
      
      final codec = props['codec_name']?.toString().toUpperCase() ?? 'UNKNOWN';
      final container = infoProps['format_name']?.toString().toUpperCase() ?? 'UNKNOWN';
      final sampleRate = int.tryParse(props['sample_rate']?.toString() ?? '') ?? 0;
      final channels = int.tryParse(props['channels']?.toString() ?? '') ?? 0;
      final duration = double.tryParse(info.getDuration() ?? '') ?? 0;
      
      int bitrate = int.tryParse(props['bit_rate']?.toString() ?? '') ?? 
                    int.tryParse(info.getBitrate() ?? '') ?? 0;
      
      if (bitrate == 0 && duration > 0) {
        final fileSize = await File(filePath).length();
        bitrate = (fileSize * 8 / duration).round();
      }

      int bitsPerSample = 0;
      if (['FLAC', 'ALAC', 'WAV', 'APE'].contains(codec)) {
        bitsPerSample = int.tryParse(props['bits_per_raw_sample']?.toString() ?? '') ?? 
                        int.tryParse(props['bits_per_sample']?.toString() ?? '') ?? 0;
      }

      return AudioAnalysis(
        codec: codec,
        container: container,
        sampleRate: sampleRate,
        channels: channels,
        bitrate: bitrate,
        bitsPerSample: bitsPerSample,
        duration: duration,
        isrc: tags['isrc']?.toString() ?? tags['ISRC']?.toString(),
        copyright: tags['copyright']?.toString() ?? tags['COPYRIGHT']?.toString(),
        composer: tags['composer']?.toString() ?? tags['COMPOSER']?.toString(),
        label: tags['label']?.toString() ?? tags['LABEL']?.toString() ?? tags['organization']?.toString(),
        encoder: tags['encoder']?.toString(),
      );
    } catch (e) {
      debugPrint('Error analyzing audio: $e');
      return null;
    }
  }

  static Future<Map<String, double>?> getLoudness(String filePath) async {
    await FFmpegKitConfig.setLogLevel(Level.avLogInfo);
    try {
      final session = await FFmpegKit.executeWithArguments([
        '-hide_banner',
        '-nostats',
        '-i', filePath,
        '-af', 'ebur128=peak=true',
        '-f', 'null',
        '-',
      ]);

      final logs = await session.getLogsAsString();
      final integratedMatches = RegExp(r'I:\s+(-?\d+\.?\d*)\s+LUFS').allMatches(logs);
      final integrated = integratedMatches.isEmpty
          ? null
          : double.tryParse(integratedMatches.last.group(1) ?? '');

      double? truePeak;
      for (final match in RegExp(r'Peak:\s+(-?\d+\.?\d*)\s+dBFS').allMatches(logs)) {
        final value = double.tryParse(match.group(1) ?? '');
        if (value != null && (truePeak == null || value > truePeak)) {
          truePeak = value;
        }
      }

      if (integrated != null || truePeak != null) {
        return {
          'lufs': integrated ?? 0.0,
          'truePeak': truePeak ?? 0.0,
        };
      }
    } catch (e) {
      debugPrint('Error analyzing loudness: $e');
    } finally {
      await FFmpegKitConfig.setLogLevel(Level.avLogError);
    }
    return null;
  }
}
