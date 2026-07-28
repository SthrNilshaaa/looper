import 'dart:io';

class UiUtils {
  static bool get isAndroid => Platform.isAndroid;
  static bool get isLinux => Platform.isLinux;

  /// Returns a scaling factor for UI components.
  /// Android gets a smaller scale (0.85) to fit more content.
  static double get scale => isAndroid ? 0.85 : 1.0;

  /// Scales a value based on the platform.
  static double s(double value) => value * scale;

  /// Scales text size.
  static double ts(double value) => value * scale;

  /// Returns a smaller spacing for Android.
  static double spacing(double value) => isAndroid ? value * 0.7 : value;

  /// Formats a Duration object into a string (e.g. 'm:ss').
  static String formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Formats milliseconds into a string.
  static String formatDurationMs(int? ms) {
    if (ms == null) return '0:00';
    return formatDuration(Duration(milliseconds: ms));
  }

  /// Formats double seconds into a string.
  static String formatDurationSeconds(double seconds) {
    return formatDuration(Duration(milliseconds: (seconds * 1000).toInt()));
  }

  /// Gets the formatted audio quality text based on file path extension.
  static String getAudioQualityText(String path) {
    final ext = path.split('.').last.toLowerCase().toUpperCase();
    if (['FLAC', 'WAV', 'ALAC', 'APE'].contains(ext)) {
      return 'Lossless • $ext';
    } else if (ext == 'MP3' || ext == 'M4A' || ext == 'AAC') {
      return 'High Quality • $ext';
    } else {
      return 'High Quality • Audio';
    }
  }
}

extension UiScalingExtension on num {
  double get s => UiUtils.s(toDouble());
  double get ts => UiUtils.ts(toDouble());
  double get sp => UiUtils.spacing(toDouble());
}
