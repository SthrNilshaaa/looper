import 'package:flutter/material.dart';

enum MiniPlayerGestureAction {
  none,
  clearQueue,
  expand,
  skipPrevious,
  skipNext,
}

class UiCalculations {
  /// Calculates play/seek progress fraction (0.0 to 1.0)
  static double getProgressFraction(Duration position, Duration duration) {
    if (duration.inMilliseconds <= 0) return 0.0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Calculates sleep timer progress and text label
  static (double progress, String label) getSleepTimerProgress({
    required bool isActive,
    Duration? durationRemaining,
    Duration? durationInitial,
    int? songsRemaining,
    int? songsInitial,
  }) {
    if (!isActive) return (1.0, '');

    double progress = 1.0;
    String label = '';

    if (durationRemaining != null) {
      if (durationInitial != null && durationInitial.inMilliseconds > 0) {
        progress = (durationRemaining.inMilliseconds / durationInitial.inMilliseconds).clamp(0.0, 1.0);
      }
      final minutes = durationRemaining.inMinutes;
      if (minutes >= 1) {
        label = '${minutes}m';
      } else {
        final seconds = durationRemaining.inSeconds;
        label = '${seconds}s';
      }
    } else if (songsRemaining != null) {
      if (songsInitial != null && songsInitial > 0) {
        progress = (songsRemaining / songsInitial).clamp(0.0, 1.0);
      }
      label = '$songsRemaining';
    }

    return (progress, label);
  }

  /// Calculates MiniPlayer perspective tilt matrix based on drag offset
  static Matrix4 getMiniPlayerTiltMatrix(Offset offset) {
    final double tiltX = (offset.dx / 100).clamp(-0.2, 0.2);
    final double tiltY = (offset.dy / 100).clamp(-0.1, 0.1);
    
    final matrix = Matrix4.identity();
    if (tiltX != 0 || tiltY != 0) {
      matrix.setEntry(3, 2, 0.001); // perspective
      matrix.rotateX(-tiltY);
      matrix.rotateY(tiltX);
      matrix.translate(offset.dx * 0.3, offset.dy * 0.3);
    }
    return matrix;
  }

  /// Determines action based on drag offset for MiniPlayer
  static MiniPlayerGestureAction getMiniPlayerAction(Offset offset, {double threshold = 70.0}) {
    final dx = offset.dx;
    final dy = offset.dy;

    if (dy > threshold && dy.abs() > dx.abs()) {
      return MiniPlayerGestureAction.clearQueue;
    } else if (dy < -threshold && dy.abs() > dx.abs()) {
      return MiniPlayerGestureAction.expand;
    } else if (dx.abs() > dy.abs()) {
      if (dx > threshold) {
        return MiniPlayerGestureAction.skipPrevious;
      } else if (dx < -threshold) {
        return MiniPlayerGestureAction.skipNext;
      }
    }
    return MiniPlayerGestureAction.none;
  }

  /// Calculates layout values (margins, border radius) for sliding MiniPlayer
  static double getMiniPlayerMargin(double progress, bool enableSlideGesture) {
    return enableSlideGesture ? 16.0 * (1.0 - progress) : 0.0;
  }

  static double getMiniPlayerBorderRadius(bool enableSlideGesture) {
    return enableSlideGesture ? 36.0 : 0.0;
  }

  /// Calculates Navbar padding
  static EdgeInsets getNavbarPadding(double bottomPadding) {
    return EdgeInsets.fromLTRB(16, 2, 16, 16 + bottomPadding);
  }
}
