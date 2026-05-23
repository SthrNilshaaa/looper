import 'package:flutter/material.dart';
import 'package:marqueer/marqueer.dart';

class ScrollingText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double? height;
  final TextAlign textAlign;

  const ScrollingText({
    super.key,
    required this.text,
    required this.style,
    this.height,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();

        if (textPainter.width > constraints.maxWidth) {
          return SizedBox(
            height: height ?? (style.fontSize! * 1.5),
            child: Marqueer(
              pps: 30.0,
              infinity: true,
              direction: MarqueerDirection.rtl,
              autoStart: true,
              autoStartAfter: const Duration(seconds: 3),
              
              child: Padding(
                padding: const EdgeInsets.only(right: 40.0),
                child: Text(
                  text,
                  style: style,
                  textAlign: textAlign,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          );
        } else {
          return Text(
            text,
            style: style,
            textAlign: textAlign,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }
      },
    );
  }
}
