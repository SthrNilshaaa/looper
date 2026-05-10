import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../../../core/providers.dart';

final overlayServiceProvider = Provider<OverlayService>((ref) {
  return OverlayService(ref);
});

class OverlayService {
  final Ref ref;
  Rect? _previousBounds;

  OverlayService(this.ref);

  Future<void> toggleOverlay() async {
    final isOverlay = ref.read(overlayModeProvider);
    if (isOverlay) {
      await exitOverlay();
    } else {
      await enterOverlay();
    }
  }

  Future<void> enterOverlay() async {
    _previousBounds = await windowManager.getBounds();

    // Switch state first to trigger UI rebuild
    ref.read(overlayModeProvider.notifier).state = true;

    await windowManager.setAsFrameless();
    await windowManager.setHasShadow(false);
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setBackgroundColor(Colors.transparent);

    // Set to a smaller size suitable for lyrics
    await windowManager.setSize(const Size(500, 150));
    await windowManager.setOpacity(
      1.0,
    ); // Make sure the window isn't entirely invisible
  }

  Future<void> exitOverlay() async {
    // Switch state back to trigger UI rebuild
    ref.read(overlayModeProvider.notifier).state = false;

    await windowManager.setAlwaysOnTop(false);
    await windowManager.setHasShadow(true);

    // Revert styling
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

    if (_previousBounds != null) {
      await windowManager.setBounds(_previousBounds);
    } else {
      await windowManager.setSize(const Size(1300, 700));
      await windowManager.center();
    }
  }
}
