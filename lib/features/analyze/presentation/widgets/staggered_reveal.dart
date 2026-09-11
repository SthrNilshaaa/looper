import 'package:flutter/material.dart';

/// Fades and slides [child] in shortly after it mounts. Wrapping each report
/// section in one with an increasing [delay] gives the whole screen a
/// staggered entrance without needing a single shared AnimationController.
class StaggeredReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const StaggeredReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<StaggeredReveal> createState() => _StaggeredRevealState();
}

class _StaggeredRevealState extends State<StaggeredReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.08),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
