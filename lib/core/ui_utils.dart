import 'dart:io';
import 'package:flutter/material.dart';

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
}

extension UiScalingExtension on num {
  double get s => UiUtils.s(this.toDouble());
  double get ts => UiUtils.ts(this.toDouble());
  double get sp => UiUtils.spacing(this.toDouble());
}
