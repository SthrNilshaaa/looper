import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lottie/lottie.dart';

class AppRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<AppRefreshIndicator> createState() => _AppRefreshIndicatorState();
}

class _AppRefreshIndicatorState extends State<AppRefreshIndicator> with TickerProviderStateMixin {
  double _dragOffset = 0.0;
  double _maxDragOffset = 0.0;
  bool _isRefreshing = false;
  bool _isDragging = false;

  late AnimationController _scaleController;
  late AnimationController _positionController;

  static const double _triggerThreshold = 120.0;
 
  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _positionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isRefreshing) return false;
    if (notification.depth != 0) return false;
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification is ScrollStartNotification) {
      _isDragging = true;
      _maxDragOffset = 0.0;
    } else if (notification is ScrollUpdateNotification) {
      if (notification.dragDetails != null) {
        _isDragging = true;
      }
      if (_isDragging) {
        final double metricsPixels = notification.metrics.pixels;
        if (metricsPixels < 0) {
          setState(() {
            _dragOffset = -metricsPixels;
          });
          if (_dragOffset > _maxDragOffset) {
            _maxDragOffset = _dragOffset;
          }
          // Scale from 0.0 to 1.0 based on drag
          _scaleController.value = (_dragOffset / _triggerThreshold).clamp(0.0, 1.0);
        } else {
          if (_dragOffset != 0) {
            setState(() {
              _dragOffset = 0.0;
            });
            _scaleController.value = 0.0;
          }
        }
      }
    } else if (notification is UserScrollNotification) {
      if (notification.direction != ScrollDirection.idle) {
        _isDragging = true;
      } else if (notification.direction == ScrollDirection.idle && _isDragging) {
        _isDragging = false;
        if (_maxDragOffset >= _triggerThreshold || _dragOffset >= _triggerThreshold) {
          _startRefresh();
        } else {
          _resetIndicator();
        }
      }
    } else if (notification is ScrollEndNotification) {
      if (_isDragging) {
        _isDragging = false;
        if (_maxDragOffset >= _triggerThreshold || _dragOffset >= _triggerThreshold) {
          _startRefresh();
        } else {
          _resetIndicator();
        }
      }
    }
    return false;
  }

  Future<void> _startRefresh() async {
    setState(() {
      _isRefreshing = true;
      _dragOffset = _triggerThreshold;
      _maxDragOffset = _triggerThreshold;
    });
    _scaleController.animateTo(1.0);
    _positionController.animateTo(1.0);

    try {
      // Force a minimum loading duration of 1.5 seconds so that the loading indicator is clearly visible to the user.
      await Future.wait([
        widget.onRefresh(),
        Future.delayed(const Duration(milliseconds: 1500)),
      ]);
    } finally {
      if (mounted) {
        // Animate out
        await _scaleController.animateTo(0.0, duration: const Duration(milliseconds: 200));
        setState(() {
          _isRefreshing = false;
          _dragOffset = 0.0;
          _maxDragOffset = 0.0;
        });
        _positionController.value = 0.0;
      }
    }
  }

  void _resetIndicator() {
    _scaleController.animateTo(0.0);
    setState(() {
      _dragOffset = 0.0;
      _maxDragOffset = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final indicatorY = _isRefreshing 
        ? 20.0 
        : (_dragOffset * 0.7 ).clamp(20.0, 60.0); // smooth dampening

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          widget.child,
          // Floating Refresh Indicator
          Positioned(
            top: indicatorY,
            child: ScaleTransition(
              scale: _scaleController,
              child: SizedBox(
                width: 168,
                height: 168,
                child: Lottie.asset(
                  'assets/loading.json',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
