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
    Widget imageWidget;

    if (imagePath != null && File(imagePath!).existsSync()) {
      imageWidget = Image.file(
        File(imagePath!),
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheWidth ?? (width != null ? (width! * 2).toInt() : 300),
        cacheHeight: cacheHeight,
        errorBuilder: (context, error, stackTrace) =>
            placeholder ?? const SizedBox(),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? const SizedBox(),
        errorWidget: (context, url, error) => placeholder ?? const SizedBox(),
        memCacheWidth:
            cacheWidth ?? (width != null ? (width! * 2).toInt() : 300),
      );
    } else {
      imageWidget = placeholder ?? const SizedBox();
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
