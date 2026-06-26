import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:adaptive_palette/adaptive_palette.dart';

/// Fallback palette mode when image is unavailable or extraction fails.
enum FluidFallbackMode {
  dark,
  light,
  auto,
}

/// A highly-optimized, lightweight fluid background that uses radial mesh gradient blobs
/// animated on the GPU via composited layer translation.
class FluidBackground extends StatefulWidget {
  const FluidBackground({
    super.key,
    this.imageProvider,
    required this.child,
    this.blurSigma = 40, // Kept for API compatibility, but soft radial gradients replace heavy image blurs
    this.overlayDarken = 0.10,
    this.animate = false,
    this.fallbackMode = FluidFallbackMode.auto,
    this.transitionDuration = const Duration(milliseconds: 1400),
  });

  final ImageProvider? imageProvider;
  final Widget child;
  final double blurSigma;
  final double overlayDarken;
  final bool animate;
  final FluidFallbackMode fallbackMode;
  final Duration transitionDuration;

  @override
  State<FluidBackground> createState() => _FluidBackgroundState();
}

class _FluidBackgroundState extends State<FluidBackground>
    with TickerProviderStateMixin {
  FluidPalette? _oldPalette;
  FluidPalette? _palette;
  int _loadSession = 0;
  bool _routeTransitionFinished = false;
  Animation<double>? _routeAnimation;

  late final AnimationController _revealController = AnimationController(
    vsync: this,
    duration: widget.transitionDuration,
  );

  late final AnimationController _motionController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12), // Slow, premium fluid drifting
  );

  FluidPalette _fallbackFor(BuildContext context) {
    switch (widget.fallbackMode) {
      case FluidFallbackMode.dark:
        return const FluidPalette.fallback();
      case FluidFallbackMode.light:
        return const FluidPalette.fallbackLight();
      case FluidFallbackMode.auto:
        final brightness = Theme.of(context).brightness;
        return brightness == Brightness.light
            ? const FluidPalette.fallbackLight()
            : const FluidPalette.fallback();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _motionController.repeat();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    final animation = route?.animation;
    if (_routeAnimation != animation) {
      _routeAnimation?.removeStatusListener(_onRouteAnimationStatusChanged);
      _routeAnimation = animation;
      if (animation != null) {
        if (animation.isCompleted) {
          _routeTransitionFinished = true;
          _kickLoad();
          if (widget.animate) {
            _motionController.repeat();
          }
        } else {
          _routeTransitionFinished = false;
          animation.addStatusListener(_onRouteAnimationStatusChanged);
        }
      } else {
        _routeTransitionFinished = true;
        _kickLoad();
        if (widget.animate) {
          _motionController.repeat();
        }
      }
    }
  }

  void _onRouteAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (mounted) {
        setState(() {
          _routeTransitionFinished = true;
        });
        _kickLoad();
        if (widget.animate) {
          _motionController.repeat();
        }
      }
    } else {
      if (mounted && _routeTransitionFinished) {
        setState(() {
          _routeTransitionFinished = false;
        });
        _motionController.stop();
      }
    }
  }

  @override
  void didUpdateWidget(covariant FluidBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animate != widget.animate) {
      if (widget.animate && _routeTransitionFinished) {
        _motionController.repeat();
      } else {
        _motionController.stop();
      }
    }

    if (oldWidget.imageProvider != widget.imageProvider) {
      _kickLoad();
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatusChanged);
    _motionController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _kickLoad() {
    if (!_routeTransitionFinished) return;
    final int loadToken = ++_loadSession;

    final provider = widget.imageProvider;
    if (provider == null) {
      setState(() {
        _oldPalette = _palette ?? _fallbackFor(context);
        _palette = null;
      });
      _revealController.forward(from: 0);
      return;
    }
    // Downsample the image to 64x64 using ResizeImage to minimize GPU memory and shader processing overhead
    final downsampledProvider = ResizeImage(provider, width: 64, height: 64);
    _load(downsampledProvider, loadToken: loadToken);
  }

  Future<void> _load(ImageProvider provider, {required int loadToken}) async {
    try {
      final ui.Image img = await loadImageFromProvider(provider);
      final FluidPalette pal =
          await FluidPaletteExtractor.buildPaletteFromImage(img);

      // Immediately dispose of the decoded image reference to free native resources
      img.dispose();

      if (!mounted || loadToken != _loadSession) return;
      setState(() {
        _oldPalette = _palette ?? _fallbackFor(context);
        _palette = pal;
      });

      _revealController.forward(from: 0);
    } catch (_) {
      if (!mounted || loadToken != _loadSession) return;
      setState(() {
        _oldPalette = _palette ?? _fallbackFor(context);
        _palette = null;
      });
      _revealController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallbackPalette = _fallbackFor(context);
    final FluidPalette target = _palette ?? fallbackPalette;
    final overlayColor = fallbackPalette.baseDark.computeLuminance() > 0.55
        ? Colors.white.withValues(alpha: widget.overlayDarken * 0.45)
        : Colors.black.withValues(alpha: widget.overlayDarken);

    return Container(
      color: target.baseDark,
      child: AnimatedBuilder(
        animation: _revealController,
        child: RepaintBoundary(child: widget.child),
        builder: (context, child) {
          final double k = _revealController.value;
          final FluidPalette current =
              FluidPalette.lerp(_oldPalette ?? fallbackPalette, target, k);

          return Stack(
            fit: StackFit.expand,
            children: [
              // Matte Base Gradient
              _MatteBase(palette: current),

              // Animated Mesh Gradient Blobs (only animated and rendered when transition is finished and palette loaded)
              if (_palette != null && _routeTransitionFinished)
                _AnimatedBlobs(
                  palette: current,
                  controller: _motionController,
                  animate: widget.animate,
                ),

              // Corner glows for secondary lighting and depth
              _CornerGlows(
                tl: current.accent1,
                tr: current.accent2,
                bl: current.accent3,
                br: current.accent4,
              ),

              // Legibility overlay (static layer)
              IgnorePointer(
                child: Container(color: overlayColor),
              ),

              // Foregrounds Child
              child!,
            ],
          );
        },
      ),
    );
  }
}

/// Matte gradient base layer.
class _MatteBase extends StatelessWidget {
  const _MatteBase({required this.palette});
  final FluidPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.accent1.withValues(alpha: 0.35),
            palette.baseDark,
          ],
        ),
      ),
    );
  }
}

/// Highly-optimized individual soft glowing blob.
/// Radial gradient transparent falloff provides native GPU blur at zero CPU cost.
class _Blob extends StatelessWidget {
  const _Blob({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.30),
              color.withValues(alpha: 0.10),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Stack of floating mesh blobs animated purely using GPU translation matrices.
class _AnimatedBlobs extends StatelessWidget {
  const _AnimatedBlobs({
    required this.palette,
    required this.controller,
    required this.animate,
  });

  final FluidPalette palette;
  final AnimationController controller;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Base size of blobs
        final blobSize = (width * 0.85).clamp(300.0, 600.0);

        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final t = controller.value;

            // Orbiter math to move blobs in slow, distinct circular paths
            final offset1 = Offset(
              width * 0.15 + math.sin(t * 2 * math.pi) * (width * 0.12),
              height * 0.20 + math.cos(t * 2 * math.pi) * (height * 0.10),
            );

            final offset2 = Offset(
              width * 0.65 + math.cos((t + 0.25) * 2 * math.pi) * (width * 0.15),
              height * 0.15 + math.sin((t + 0.25) * 2 * math.pi) * (height * 0.12),
            );

            final offset3 = Offset(
              width * 0.10 + math.sin((t + 0.50) * 2 * math.pi) * (width * 0.10),
              height * 0.65 + math.cos((t + 0.50) * 2 * math.pi) * (height * 0.15),
            );

            final offset4 = Offset(
              width * 0.60 + math.cos((t + 0.75) * 2 * math.pi) * (width * 0.14),
              height * 0.70 + math.sin((t + 0.75) * 2 * math.pi) * (height * 0.12),
            );

            return Stack(
              children: [
                // Blob 1
                Transform.translate(
                  offset: offset1 - Offset(blobSize / 2, blobSize / 2),
                  child: _Blob(color: palette.accent1, size: blobSize),
                ),
                // Blob 2
                Transform.translate(
                  offset: offset2 - Offset(blobSize / 2, blobSize / 2),
                  child: _Blob(color: palette.accent2, size: blobSize),
                ),
                // Blob 3
                Transform.translate(
                  offset: offset3 - Offset(blobSize / 2, blobSize / 2),
                  child: _Blob(color: palette.accent3, size: blobSize),
                ),
                // Blob 4
                Transform.translate(
                  offset: offset4 - Offset(blobSize / 2, blobSize / 2),
                  child: _Blob(color: palette.accent4, size: blobSize),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Corner radial glow accents utilizing fast native radial gradients.
class _CornerGlows extends StatelessWidget {
  const _CornerGlows({
    required this.tl,
    required this.tr,
    required this.bl,
    required this.br,
  });

  final Color tl;
  final Color tr;
  final Color bl;
  final Color br;

  @override
  Widget build(BuildContext context) {
    Widget glow(Color c, Alignment a) {
      return Align(
        alignment: a,
        child: Container(
          width: 420,
          height: 420,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                c.withValues(alpha: 0.20),
                c.withValues(alpha: 0.05),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      );
    }

    return IgnorePointer(
      child: Stack(
        children: [
          glow(tl, Alignment.topLeft),
          glow(tr, Alignment.topRight),
          glow(bl, Alignment.bottomLeft),
          glow(br, Alignment.bottomRight),
        ],
      ),
    );
  }
}
