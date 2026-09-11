import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/core/app_icons.dart';

/// Shared scale+fade transition used by every animated transport icon below,
/// in place of the built-in `AnimatedIcon` glyph morph (which only works
/// with Flutter's own bundled AnimatedIconData, not custom SVG assets).
Widget _transportIconSwitcher({
  required Widget child,
  required Duration duration,
}) {
  return AnimatedSwitcher(
    duration: duration,
    switchInCurve: Curves.easeOutBack,
    switchOutCurve: Curves.easeIn,
    transitionBuilder: (child, animation) => ScaleTransition(
      scale: animation,
      child: FadeTransition(opacity: animation, child: child),
    ),
    child: child,
  );
}

/// Animated swap between the app's own play/pause SVG assets
/// ([AppIcons.play] / [AppIcons.pause]). Cross-fades and scales the
/// outgoing/incoming icon instead of a true path-morph, which reads just as
/// smoothly for a two-icon swap.
class AnimatedPlayPauseIcon extends StatelessWidget {
  final bool isPlaying;
  final double size;
  final Color color;
  final Duration duration;

  const AnimatedPlayPauseIcon({
    super.key,
    required this.isPlaying,
    required this.size,
    required this.color,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return _transportIconSwitcher(
      duration: duration,
      child: SvgPicture.asset(
        isPlaying ? AppIcons.pause : AppIcons.play,
        key: ValueKey<bool>(isPlaying),
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        width: size,
        height: size,
      ),
    );
  }
}

/// Same scale+fade "pop" as [AnimatedPlayPauseIcon], but for an icon that
/// doesn't swap assets on tap (next/previous). It replays whenever
/// [triggerKey] changes, so pass a counter that this specific button's own
/// `onTap` bumps - each button (prev/next) needs its own counter. Keying
/// both buttons off a shared value like the current song's id would replay
/// both animations together whenever either button is pressed.
class AnimatedTransportIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color color;
  final Object? triggerKey;
  final Duration duration;

  const AnimatedTransportIcon({
    super.key,
    required this.asset,
    required this.size,
    required this.color,
    required this.triggerKey,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return _transportIconSwitcher(
      duration: duration,
      child: SvgPicture.asset(
        asset,
        key: ValueKey<Object?>(triggerKey),
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        width: size,
        height: size,
      ),
    );
  }
}
