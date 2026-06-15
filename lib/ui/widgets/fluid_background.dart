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

/// A highly-optimized local version of FluidBackground to resolve animation stutter.
class FluidBackground extends StatefulWidget {
  const FluidBackground({
    super.key,
    this.imageProvider,
    required this.child,
    this.blurSigma = 80,
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
  ui.Image? _image;
  FluidPalette? _palette;

  static const Duration _motionDuration = Duration(seconds: 12);

  late final AnimationController _motionController = AnimationController(
    vsync: this,
    duration: _motionDuration,
  );

  double _frozenMotionT = 0.35;
  int _motionSession = 0;
  int _loadSession = 0;
  bool _routeTransitionFinished = false;
  Animation<double>? _routeAnimation;

  late final AnimationController _revealController = AnimationController(
    vsync: this,
    duration: widget.transitionDuration,
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
            _resumeMotionFromFrozen();
          }
        } else {
          _routeTransitionFinished = false;
          animation.addStatusListener(_onRouteAnimationStatusChanged);
        }
      } else {
        _routeTransitionFinished = true;
        _kickLoad();
        if (widget.animate) {
          _resumeMotionFromFrozen();
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
          _resumeMotionFromFrozen();
        }
      }
    } else {
      if (mounted && _routeTransitionFinished) {
        setState(() {
          _routeTransitionFinished = false;
        });
        _freezeMotion();
      }
    }
  }

  @override
  void didUpdateWidget(covariant FluidBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animate != widget.animate) {
      if (widget.animate && _routeTransitionFinished) {
        _resumeMotionFromFrozen();
      } else {
        _freezeMotion();
      }
      if (mounted) setState(() {});
    }

    if (oldWidget.imageProvider != widget.imageProvider) {
      _kickLoad();
    }
  }

  void _freezeMotion() {
    _motionSession++;
    _frozenMotionT = _motionController.value;
    _motionController.stop(canceled: false);
  }

  void _resumeMotionFromFrozen() {
    if (!widget.animate || !_routeTransitionFinished) return;
    final int session = ++_motionSession;

    _motionController.value = _frozenMotionT;
    final remaining = (1.0 - _frozenMotionT).clamp(0.0, 1.0).toDouble();

    if (remaining <= 0.0001) {
      _motionController.repeat();
      return;
    }

    final remainingMs =
        (_motionDuration.inMilliseconds * remaining).round().clamp(1, 600000);

    _motionController
        .animateTo(
      1.0,
      duration: Duration(milliseconds: remainingMs),
      curve: Curves.linear,
    )
        .then((_) {
      if (!mounted || !widget.animate || !_routeTransitionFinished || session != _motionSession) return;
      _motionController.repeat();
    }).catchError((_) {
      // Safe to ignore ticker cancellation during rapid animate toggles.
    });
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

    _revealController.value = 0;
    _image = null;
    _palette = null;

    final provider = widget.imageProvider;
    if (provider == null) {
      setState(() {});
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

      if (!mounted || loadToken != _loadSession) return;
      setState(() {
        _image = img;
        _palette = pal;
      });

      await _revealController.forward(from: 0);
    } catch (_) {
      if (!mounted || loadToken != _loadSession) return;
      _image = null;
      _palette = null;
      setState(() {});
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
      color: fallbackPalette.baseDark,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          // Downscale factor of 16 for shader layer rendering and blur performance
          final lowResWidth = (width / 16.0).clamp(1.0, 150.0);
          final lowResHeight = (height / 16.0).clamp(1.0, 300.0);
          final lowResSigma = (widget.blurSigma / 16.0).clamp(1.0, 15.0);

          // Top-level AnimatedBuilder ONLY listens to _revealController.
          // This avoids rebuilding the matte base, corner glows, overlay, and main content on every motion frame.
          return AnimatedBuilder(
            animation: _revealController,
            child: RepaintBoundary(child: widget.child),
            builder: (context, child) {
              final double k = _revealController.value;
              final FluidPalette current =
                  FluidPalette.lerp(fallbackPalette, target, k);

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Matte fallback base (always visible, only repaints during transition reveal)
                  _MatteFallbackBase(palette: current),

                  // Fluid shader layers (motion animation is isolated internally)
                  // Only render the expensive blur/shader layers when route transition is fully finished
                  if (_image != null && _routeTransitionFinished && k > 0.0)
                    Opacity(
                      opacity: Curves.easeInOutCubic.transform(k),
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: _FluidShaderTicker(
                          controller: _motionController,
                          animate: widget.animate,
                          image: _image!,
                          width: lowResWidth,
                          height: lowResHeight,
                          sigma: lowResSigma,
                          frozenT: _frozenMotionT,
                        ),
                      ),
                    ),

                  // High-performance Corner glows (native gradient based, only repaints during transition reveal)
                  _CornerGlows(
                    tl: current.accent1,
                    tr: current.accent2,
                    bl: current.accent3,
                    br: current.accent4,
                  ),

                  // Adaptive overlay for legibility (static)
                  Container(color: overlayColor),

                  // User content (cached and isolated via RepaintBoundary)
                  child!,
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Matte gradient fallback base layer.
class _MatteFallbackBase extends StatelessWidget {
  const _MatteFallbackBase({required this.palette});
  final FluidPalette palette;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                palette.accent1.withValues(alpha: 0.55),
                palette.accent2.withValues(alpha: 0.45),
                palette.baseDark,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        const _MatteNoiseOverlay(),
      ],
    );
  }
}

class _FluidShaderTicker extends StatefulWidget {
  const _FluidShaderTicker({
    required this.controller,
    required this.animate,
    required this.image,
    required this.width,
    required this.height,
    required this.sigma,
    required this.frozenT,
  });

  final AnimationController controller;
  final bool animate;
  final ui.Image image;
  final double width;
  final double height;
  final double sigma;
  final double frozenT;

  @override
  State<_FluidShaderTicker> createState() => _FluidShaderTickerState();
}

class _FluidShaderTickerState extends State<_FluidShaderTicker> {
  late double _t;

  @override
  void initState() {
    super.initState();
    _t = widget.frozenT;
    widget.controller.addListener(_onTick);
  }

  @override
  void didUpdateWidget(covariant _FluidShaderTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTick);
      widget.controller.addListener(_onTick);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    if (!widget.animate) return;
    const double step = 1.0 / 288.0;
    final double newT = ((widget.controller.value / step).round() * step);
    if (newT != _t) {
      setState(() {
        _t = newT;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: widget.sigma,
          sigmaY: widget.sigma,
          tileMode: ui.TileMode.clamp,
        ),
        child: CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _FluidShaderPainter(
            image: widget.image,
            t: widget.animate ? _t : widget.frozenT,
          ),
        ),
      ),
    );
  }
}

/// Fluid shader painter with multiple transformed image layers.
class _FluidShaderPainter extends CustomPainter {
  _FluidShaderPainter({required this.image, required this.t});

  final ui.Image image;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0F1419),
    );

    final layers = <_ShaderLayer>[
      _ShaderLayer(
        scale: 1.35,
        rot: math.sin(t * 2 * math.pi) * 0.09,
        dx: _orbitX(0.10, t),
        dy: _orbitY(0.08, t),
        alpha: 0.55,
      ),
      _ShaderLayer(
        scale: 0.95,
        rot: math.cos(t * 2 * math.pi) * 0.09,
        dx: _orbitX(0.18, t + 0.33),
        dy: _orbitY(0.14, t + 0.33),
        alpha: 0.45,
      ),
      _ShaderLayer(
        scale: 0.70,
        rot: math.sin((t + 0.25) * 2 * math.pi) * 0.11,
        dx: _orbitX(0.22, t + 0.66),
        dy: _orbitY(0.18, t + 0.66),
        alpha: 0.35,
      ),
      _ShaderLayer(
        scale: 1.85,
        rot: math.cos((t + 0.5) * 2 * math.pi) * 0.08,
        dx: _orbitX(0.06, t + 0.18),
        dy: _orbitY(0.06, t + 0.18),
        alpha: 0.25,
      ),
    ];

    for (final layer in layers) {
      final Matrix4 m = Matrix4.identity()
        ..translate(size.width * 0.5, size.height * 0.5)
        ..translate(size.width * layer.dx, size.height * layer.dy)
        ..rotateZ(layer.rot)
        ..scale(layer.scale, layer.scale)
        ..translate(-image.width / 2.0, -image.height / 2.0);

      final paint = Paint()
        ..shader = ui.ImageShader(
          image,
          ui.TileMode.clamp,
          ui.TileMode.clamp,
          m.storage,
        )
        ..color = Colors.white.withValues(alpha: layer.alpha)
        ..blendMode = ui.BlendMode.srcOver;

      canvas.drawRect(Offset.zero & size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FluidShaderPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.image != image;

  static double _orbitX(double amp, double t) =>
      math.sin(t * 2 * math.pi) * amp;
  static double _orbitY(double amp, double t) =>
      math.cos(t * 2 * math.pi) * amp;
}

/// Shader layer configuration.
class _ShaderLayer {
  const _ShaderLayer({
    required this.scale,
    required this.rot,
    required this.dx,
    required this.dy,
    required this.alpha,
  });

  final double scale;
  final double rot;
  final double dx;
  final double dy;
  final double alpha;
}

/// Corner radial glow accents optimized to use native radial gradients instead of heavy image blurs.
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
                c.withValues(alpha: 0.24),
                c.withValues(alpha: 0.08),
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

/// Matte noise overlay for texture.
class _MatteNoiseOverlay extends StatelessWidget {
  const _MatteNoiseOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.06,
        child: CustomPaint(painter: _NoisePainter()),
      ),
    );
  }
}

/// Simple noise texture painter.
class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final rnd = math.Random(1);
    for (int i = 0; i < 1200; i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      final a = 20 + rnd.nextInt(30);
      paint.color = Colors.white.withAlpha(a);
      canvas.drawRect(Rect.fromLTWH(dx, dy, 1, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
