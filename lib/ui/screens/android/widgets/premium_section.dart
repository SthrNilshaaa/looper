import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import 'package:looper_player/features/settings/presentation/settings_notifier.dart';

class PremiumSection extends ConsumerWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;
  final bool isSelected;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final bool useExpanded;
  final Color? backgroundColor;
  final int flex;
  final String? heroTag;
  final bool showLeftBorder;
  final bool showRightBorder;
  final bool showShadow;
  final double blurAmount;
  final bool useBlur;
  final bool forceNoBlur;
  final bool forceBlur;
  final bool keepSurfaceOnDisableBlur;
  final bool animate;

  final bool useCenter;

  const PremiumSection({
    super.key,
    required this.child,
    required this.borderRadius,
    this.onTap,
    this.isSelected = false,
    this.height,
    this.width,
    this.padding,
    this.useExpanded = true,
    this.backgroundColor,
    this.flex = 1,
    this.heroTag,
    this.showLeftBorder = true,
    this.showRightBorder = true,
    this.showShadow = false,
    this.blurAmount = 3,
    this.useBlur = false,
    this.forceNoBlur = false,
    this.forceBlur = false,
    this.keepSurfaceOnDisableBlur = false,
    this.animate = false,
    this.useCenter = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final bool disableBlur = settings.disableBlur;

    // Detect if we are transitioning (route or tab transitions)
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool isRouteTransitioning = parentRoute != null && (
      parentRoute.animation?.status == AnimationStatus.forward ||
      parentRoute.animation?.status == AnimationStatus.reverse ||
      parentRoute.secondaryAnimation?.status == AnimationStatus.forward ||
      parentRoute.secondaryAnimation?.status == AnimationStatus.reverse
    );
    final bool isTabTransitioning = TransitionStatusProvider.of(context);
    final bool isTransitioning = isRouteTransitioning || isTabTransitioning;

    final bool isBlurActive = (useBlur || forceBlur) && !disableBlur && !isTransitioning;

    final borderSide = BorderSide(
      color: Colors.white.withValues(alpha: 0.05),
      width: 1.2,
    );

    final decoration = BoxDecoration(
      color: backgroundColor ?? (isBlurActive 
          ? Colors.white.withValues(alpha: 0.05) 
          : ((useBlur || forceBlur)
              ? (isTransitioning 
                  ? Colors.black.withValues(alpha: 0.12)
                  : (disableBlur && !keepSurfaceOnDisableBlur 
                      ? Colors.white.withValues(alpha: 0.05)
                      : Theme.of(context).colorScheme.surfaceContainer))
              : Theme.of(context).colorScheme.surfaceContainer)),
      borderRadius: borderRadius,
      border: Border(
        top: borderSide,
        bottom: borderSide,
        left: showLeftBorder ? borderSide : BorderSide.none,
        right: showRightBorder ? borderSide : BorderSide.none,
      ),
      boxShadow: showShadow
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );

    Widget containerBody = animate
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            height: height,
            width: width,
            padding: padding,
            decoration: decoration,
            child: useCenter ? Center(child: child) : child,
          )
        : Container(
            height: height,
            width: width,
            padding: padding,
            decoration: decoration,
            child: useCenter ? Center(child: child) : child,
          );

    final bool enableBlur = isBlurActive && !forceNoBlur;

    if (enableBlur) {
      containerBody = RepaintBoundary(
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blurAmount.clamp(0.0, 16.0),
              sigmaY: blurAmount.clamp(0.0, 16.0),
            ),
            child: containerBody,
          ),
        ),
      );
    }

    Widget content;
    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: containerBody,
      );
    } else {
      content = containerBody;
    }

    if (heroTag != null) {
      content = Hero(
        tag: heroTag!,
        child: Material(
          type: MaterialType.transparency,
          child: content,
        ),
      );
    }

    if (useExpanded) {
      return Expanded(
        flex: flex,
        child: content,
      );
    }
    return content;
  }
}

class TransitionStatusProvider extends InheritedWidget {
  final bool isTransitioning;

  const TransitionStatusProvider({
    super.key,
    required this.isTransitioning,
    required super.child,
  });

  static bool of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<TransitionStatusProvider>();
    return provider?.isTransitioning ?? false;
  }

  @override
  bool updateShouldNotify(TransitionStatusProvider oldWidget) {
    return oldWidget.isTransitioning != isTransitioning;
  }
}

