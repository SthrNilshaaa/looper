import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';

class PremiumSection extends StatelessWidget {
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
    this.showShadow = true,
    this.blurAmount = 10,
    this.useBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderSide = BorderSide(
      color: Colors.white.withOpacity(0.05),
      width: 1.2,
    );

    Widget containerBody = AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? (useBlur ? Colors.white.withOpacity(0.05) : Theme.of(context).colorScheme.surfaceContainer),
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
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(child: child),
    );

    // Optimization: On Android, multiple BackdropFilters are very expensive.
    // We only use it if specifically requested and for larger sections.
    final bool shouldBlur = useBlur;// && (!Platform.isAndroid || blurAmount > 15);

    if (shouldBlur) {
      containerBody = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: containerBody,
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
