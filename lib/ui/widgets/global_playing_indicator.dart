import 'package:flutter/material.dart';
import 'dart:math' as math;

class GlobalPlayingIndicator extends StatefulWidget {
  final double size;
  final Color? color;

  const GlobalPlayingIndicator({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  State<GlobalPlayingIndicator> createState() => _GlobalPlayingIndicatorState();
}

class _GlobalPlayingIndicatorState extends State<GlobalPlayingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double value = math.sin((_controller.value * 2 * math.pi) + (index * math.pi / 3));
              final double heightFactor = 0.5 + (value.abs() * 0.5);
              
              return Container(
                width: widget.size / 6,
                height: widget.size * heightFactor,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(widget.size / 12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class PlayingOverlay extends StatelessWidget {
  final Widget child;
  final bool isPlaying;
  final double borderRadius;

  const PlayingOverlay({
    super.key,
    required this.child,
    required this.isPlaying,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isPlaying)
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: const Center(
                child: GlobalPlayingIndicator(size: 28),
              ),
            ),
          ),
      ],
    );
  }
}
