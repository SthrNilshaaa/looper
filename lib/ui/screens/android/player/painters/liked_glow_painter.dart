import 'dart:math' as math;
import 'package:flutter/material.dart';

class LikedGlowPainter extends CustomPainter {
  final double progress;
  final List<double> randomAngles;
  final List<double> randomRadii;
  final List<double> randomSpeeds;

  LikedGlowPainter({
    required this.progress,
    required this.randomAngles,
    required this.randomRadii,
    required this.randomSpeeds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0 || progress == 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = 24.0 + progress * 10.0;
    final fade = 1.0 - progress;

    // Glowing circle stroke
    final circlePaint = Paint()
      ..color = Colors.yellow.withOpacity(0.35 * fade)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(center, baseRadius, circlePaint);

    final linePaint = Paint()
      ..color = Colors.yellow.withOpacity(0.5 * fade)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, baseRadius, linePaint);

    // Circulating dots
    final dotPaint = Paint()
      ..color = Colors.yellow.withOpacity(fade)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < randomAngles.length; i++) {
      final currentAngle =
          randomAngles[i] + (randomSpeeds[i] * progress * 2.0 * math.pi);
      final r = baseRadius + randomRadii[i];
      final dx = center.dx + r * math.cos(currentAngle);
      final dy = center.dy + r * math.sin(currentAngle);

      // Dot glow
      final dotGlowPaint = Paint()
        ..color = Colors.amber.withOpacity(0.55 * fade)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      canvas.drawCircle(Offset(dx, dy), 4.5, dotGlowPaint);

      // Core dot
      canvas.drawCircle(Offset(dx, dy), 2.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LikedGlowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
