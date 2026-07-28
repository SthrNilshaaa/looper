import 'package:flutter/material.dart';

class SleepTimerClockPainter extends CustomPainter {
  final double progress;
  final Color color;

  SleepTimerClockPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 2.0) / 2;

    // Draw background circle track
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw active progress arc clockwise starting from top (-pi / 2)
    if (progress > 0) {
      final activePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      const startAngle = -3.141592653589793 / 2;
      final sweepAngle = 2 * 3.141592653589793 * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SleepTimerClockPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
