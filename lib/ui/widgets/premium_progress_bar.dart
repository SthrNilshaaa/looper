import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:squiggly_slider/slider.dart';

class ExpressiveSlider extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final ValueChanged<Duration> onSeek;
  final VoidCallback? onSeekStart;
  final VoidCallback? onSeekEnd;
  final Color color;
  final bool showTimestamps;

  const ExpressiveSlider({
    super.key,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.onSeek,
    this.onSeekStart,
    this.onSeekEnd,
    required this.color,
    this.showTimestamps = true,
  });

  @override
  State<ExpressiveSlider> createState() => _ExpressiveSliderState();
}

class _ExpressiveSliderState extends State<ExpressiveSlider> {
  double? _dragValue;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildAnimatedDuration(String durationStr, bool isRightAligned) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: isRightAligned
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: durationStr.characters.map((char) {
        return SizedBox(
          width: char == ':' ? 6 : 10,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final isIn = (child as Text).data == char;
              return ClipRect(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0.0, isIn ? 0.5 : -0.5),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
              );
            },
            child: Text(
              char,
              key: ValueKey(char),
              style: GoogleFonts.dmSans(
                color: Colors.white70,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress = widget.duration.inMilliseconds > 0
        ? (widget.position.inMilliseconds / widget.duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    final displayValue = _dragValue ?? progress;
    final displayPosition = _dragValue != null 
        ? widget.duration * _dragValue! 
        : widget.position;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2.8,
            activeTrackColor: widget.color,
            inactiveTrackColor: Colors.white10,
            thumbShape: const LineThumbShape(
              thumbHeight: 12,
              thumbWidth: 3,
            ),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: SquigglySlider(
            value: displayValue,
            onChanged: (val) {
              setState(() => _dragValue = val);
              widget.onSeek(widget.duration * val);
            },
            onChangeStart: (val) {
              setState(() => _dragValue = val);
              widget.onSeekStart?.call();
            },
            onChangeEnd: (val) {
              setState(() => _dragValue = null);
              widget.onSeekEnd?.call();
            },
            activeColor: widget.color,
            inactiveColor: Colors.white10,
            squiggleAmplitude: widget.isPlaying ? 2.0 : 0.0,
            squiggleWavelength: 4.5,
            squiggleSpeed: 0.08,
            useLineThumb: false,
          ),
        ),
        if (widget.showTimestamps) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAnimatedDuration(_formatDuration(displayPosition), false),
                _buildAnimatedDuration(_formatDuration(widget.duration), true),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class LineThumbShape extends SliderComponentShape {
  final double thumbHeight;
  final double thumbWidth;

  const LineThumbShape({this.thumbHeight = 12, this.thumbWidth = 2});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbWidth, thumbHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: thumbWidth, height: thumbHeight),
        Radius.circular(thumbWidth / 2),
      ),
      paint,
    );
  }
}
