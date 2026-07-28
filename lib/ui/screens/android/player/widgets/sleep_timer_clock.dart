import 'package:flutter/material.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/ui/screens/android/player/painters/sleep_timer_clock_painter.dart';

class SleepTimerClock extends StatelessWidget {
  final double progress;
  final String label;
  final Color color;

  const SleepTimerClock({
    super.key,
    required this.progress,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double size = 28.s;
    return SizedBox(
      width: size,
      height: size,
      child: RepaintBoundary(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: SleepTimerClockPainter(
                progress: progress,
                color: color,
              ),
            ),
            Center(
              child: Text(
                label,
                style: AppFonts.jostStyle(
                  fontSize: 8.ts,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
