import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/lyric_models.dart';
import '../lyrics_view.dart';

class AdvancedLyricLine extends StatelessWidget {
  final LyricLine line;
  final Duration currentPosition;
  final LyricsSyncMode mode;
  final bool isActive;
  final int relativeIndex;
  final VoidCallback onTap;

  const AdvancedLyricLine({
    super.key,
    required this.line,
    required this.currentPosition,
    required this.mode,
    required this.isActive,
    required this.relativeIndex,
    required this.onTap,
  });

  bool _isHindi(String text) {
    return RegExp(r'[\u0900-\u097F]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final progress = line.getProgress(currentPosition);
    final isPast = currentPosition > line.endTime;

    // Calculate dynamic opacity based on distance from active line
    double lineOpacity = 1.0;
    if (!isActive) {
      lineOpacity = (0.5 / (relativeIndex * 0.9)).clamp(0.12, 0.4);
    }

    // Language-aware font selection
    final bool isHindiText = _isHindi(line.text);
    final baseStyle =
        (isHindiText ? GoogleFonts.poppins() : GoogleFonts.spaceGrotesk())
            .copyWith(
              fontSize: isActive ? 36 : 32,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w500,
              letterSpacing: isHindiText ? 0.0 : -0.5,
              height: 1.2,
              color: Colors.white.withOpacity(isActive ? 1.0 : lineOpacity),
            );

    // Active color (Theme Primary)
    final activeColor = Theme.of(context).colorScheme.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastLinearToSlowEaseIn,
          padding: EdgeInsets.symmetric(
            vertical: isActive ? 24 : 12,
            horizontal: 16,
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            opacity: isActive ? 1.0 : (lineOpacity * 1.5).clamp(0.0, 1.0),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              style: baseStyle,
              child: _buildModeContent(
                context,
                progress,
                isPast,
                baseStyle,
                activeColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeContent(
    BuildContext context,
    double progress,
    bool isPast,
    TextStyle baseStyle,
    Color activeColor,
  ) {
    final String text = line.text;
    final bool isInstrumental =
        text.isEmpty ||
        text.toLowerCase().contains('instrumental') ||
        text.toLowerCase().contains('[music]') ||
        text.trim() == '♪';

    if (!isActive && !isPast) {
      return isInstrumental
          ? const Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.music_note, color: Colors.white24, size: 30),
            )
          : Text(
              text,
              style: baseStyle.copyWith(color: Colors.white.withOpacity(0.5)),
              textAlign: TextAlign.start,
            );
    }

    if (isPast) {
      return isInstrumental
          ? const Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.music_note, color: Colors.white10, size: 30),
            )
          : Text(
              text,
              style: baseStyle.copyWith(color: Colors.white.withOpacity(0.3)),
              textAlign: TextAlign.start,
            );
    }

    // For active line, add music symbols if it's instrumental or just for style
    final displayText = isInstrumental ? '♫' : text;

    switch (mode) {
      case LyricsSyncMode.line:
        return Row(
          children: [
            Expanded(
              child: isInstrumental
                  ? const Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 40,
                      ),
                    )
                  : Text(
                      displayText,
                      style: baseStyle.copyWith(
                        color: activeColor,
                      ), // Dynamic color for active line
                      textAlign: TextAlign.start,
                    ),
            ),
          ],
        );

      case LyricsSyncMode.word:
        return _buildWordMode(displayText, progress, baseStyle, activeColor);

      case LyricsSyncMode.char:
        return _buildCharMode(displayText, progress, baseStyle, activeColor);
    }
  }

  Widget _buildWordMode(
    String text,
    double progress,
    TextStyle baseStyle,
    Color activeColor,
  ) {
    final words = text.split(' ');
    if (words.isEmpty) return const SizedBox.shrink();

    // Estimate progress per word
    final wordCount = words.length;
    final activeWordIndex = (progress * wordCount).floor();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 12,
            children: List.generate(words.length, (index) {
              final isWordActive = index <= activeWordIndex;
              return AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: baseStyle.copyWith(
                  color: isWordActive ? activeColor : baseStyle.color,
                  shadows: isWordActive
                      ? [
                          Shadow(
                            color: activeColor.withOpacity(0.3),
                            blurRadius: 16,
                          ),
                        ]
                      : null,
                ),
                child: Text(words[index]),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCharMode(
    String text,
    double progress,
    TextStyle baseStyle,
    Color activeColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              // Create a sharp gradient for Apple Music style karaoke
              const gradientWidth = 0.01;
              final start = (progress - gradientWidth).clamp(0.0, 1.0);
              final end = (progress + gradientWidth).clamp(0.0, 1.0);

              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  activeColor,
                  activeColor.withOpacity(0.8),
                  baseStyle.color ?? Colors.white24,
                ],
                stops: [start, progress, end],
              ).createShader(bounds);
            },
            child: Text(
              text,
              style: baseStyle.copyWith(color: Colors.white),
              textAlign: TextAlign.start,
            ),
          ),
        ),
      ],
    );
  }
}
