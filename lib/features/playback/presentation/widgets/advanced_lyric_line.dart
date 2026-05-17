import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lyrics_search_provider.dart';
import '../../domain/lyric_models.dart';
import '../lyrics_view.dart';

class AdvancedLyricLine extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = line.getProgress(currentPosition);
    final isPast = currentPosition > line.endTime;

    // Calculate absolute distance for opacity and duration
    final absIndex = relativeIndex.abs();
    
    // Calculate dynamic opacity based on distance from active line
    double lineOpacity = 1.0;
    if (!isActive) {
      lineOpacity = (0.5 / (absIndex * 0.9)).clamp(0.3, 0.5);
    }

    // Active color (Theme Primary)
    final activeColor = Theme.of(context).colorScheme.primary;

    // Language-aware font selection
    final bool isHindiText = _isHindi(line.text);
    final baseStyle =
        (isHindiText ? GoogleFonts.poppins() : GoogleFonts.spaceGrotesk())
            .copyWith(
              fontSize: isActive ? 32 : 30, // Increased active size, no scale
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w500,
              letterSpacing: isHindiText ? 0.0 : -0.5,
              height: 1.2,
              color: isActive ? activeColor : Colors.white.withOpacity(lineOpacity),
              shadows: isActive ? [
                Shadow(
                  color: activeColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )
              ] : null,
            );

    // Staggered animation durations based on absolute distance
    final animDuration = Duration(milliseconds: 600 + (absIndex * 20).clamp(0, 200));
    
    // Smooth curve for all transitions
    final curve = Curves.fastOutSlowIn;

    // Watch the search query for highlighting
    final searchQuery = ref.watch(lyricsSearchQueryProvider).toLowerCase();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: animDuration,
          curve: curve,
          transformAlignment: Alignment.centerLeft,
          transform: Matrix4.identity()..translate(0.0, isActive ? -4.0 : 0.0),
          child: AnimatedPadding(
            duration: animDuration,
            curve: curve,
            padding: EdgeInsets.symmetric(
              vertical: isActive ? 24 : 10,
              horizontal: 0,
            ),
            child: AnimatedOpacity(
              duration: animDuration,
              curve: curve,
              opacity: isActive ? 1.0 : (lineOpacity * 1.5).clamp(0.1, 1.0),
              child: AnimatedDefaultTextStyle(
                duration: animDuration,
                curve: curve,
                style: baseStyle,
                softWrap: true,
                textAlign: TextAlign.start,
                child: _buildModeContent(
                  context,
                  progress,
                  isPast,
                  baseStyle,
                  activeColor,
                  searchQuery,
                ),
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
    String searchQuery,
  ) {
    final String text = line.text;
    final bool isInstrumental =
        text.isEmpty ||
        text.toLowerCase().contains('instrumental') ||
        text.toLowerCase().contains('[music]') ||
        text.trim() == '♪';

    // If there is a search match, always highlight it
    final bool isSearchMatch = searchQuery.isNotEmpty && text.toLowerCase().contains(searchQuery);

    if (!isActive && !isPast) {
      return isInstrumental
          ? const Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.music_note, color: Colors.white24, size: 30),
            )
          : Text(
              text,
              style: isSearchMatch ? baseStyle.copyWith(color: activeColor.withOpacity(0.9)) : null,
              textAlign: TextAlign.start,
              softWrap: true,
              overflow: TextOverflow.visible,
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
              textAlign: TextAlign.start,
              softWrap: true,
              overflow: TextOverflow.visible,
              // Inherits muted color from baseStyle
            );
    }

    // For active line, add music symbols if it's instrumental
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
                  : Hero(
                      tag: 'active_lyric_line',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          displayText,
                          textAlign: TextAlign.start,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style: baseStyle.copyWith(decoration: TextDecoration.none),
                        ),
                      ),
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
                duration: const Duration(milliseconds: 250), // Smoother word transition
                curve: Curves.easeOutCubic,
                style: baseStyle.copyWith(
                  color: isWordActive ? activeColor : baseStyle.color?.withOpacity(0.5),
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
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ],
    );
  }
}
