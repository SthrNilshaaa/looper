import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OptimizedImage extends StatelessWidget {
  final String? imagePath;
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final BoxFit fit;
  final int? cacheWidth;
  final int? cacheHeight;

  const OptimizedImage({
    super.key,
    this.imagePath,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = placeholder ?? Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: Colors.white.withOpacity(0.3),
          size: width != null ? (width! * 0.5).clamp(16, 48) : 32,
        ),
      ),
    );

    Widget imageWidget;

    if (imagePath != null && File(imagePath!).existsSync()) {
      imageWidget = Image.file(
        File(imagePath!),
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheWidth ?? (width != null ? (width! * 2.5).toInt() : 800),
        cacheHeight: cacheHeight,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => fallback,
        errorWidget: (context, url, error) => fallback,
        memCacheWidth:
            cacheWidth ?? (width != null ? (width! * 2.5).toInt() : 800),
      );
    } else {
      imageWidget = fallback;
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: SizedBox(width: width, height: height, child: imageWidget),
      );
    }

    return SizedBox(width: width, height: height, child: imageWidget);
  }
}
