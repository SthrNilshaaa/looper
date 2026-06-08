import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adaptive_palette/adaptive_palette.dart';
import '../playback_notifier.dart';
import '../lyrics_search_provider.dart';
import '../../domain/lyric_models.dart';
import '../lyrics_view.dart';
import '../../../settings/presentation/settings_notifier.dart';

final artworkColorProvider = FutureProvider<Color?>((ref) async {
  final currentSong = ref.watch(playbackProvider.select((s) => s.currentSong));
  final artPath = currentSong?.artPath;
  if (artPath == null) return null;

  final file = File(artPath);
  if (!await file.exists()) return null;

  try {
    final colors = await FluidPaletteExtractor.extractColors(
      FileImage(file),
      count: 1,
    );
    if (colors.isNotEmpty) {
      final extractedColor = colors.first;
      final HSLColor hsl = HSLColor.fromColor(extractedColor);
      double newLightness = hsl.lightness + 0.15;
      if (newLightness < 0.60) {
        newLightness = 0.60;
      }
      newLightness = newLightness.clamp(0.0, 0.95);
      return hsl.withLightness(newLightness).toColor();
    }
  } catch (e) {
    debugPrint('Error extracting color in artworkColorProvider: $e');
  }
  return null;
});

class AdvancedLyricLine extends ConsumerWidget {
  final LyricLine line;
  final LyricsSyncMode mode;
  final bool isActive;
  final int relativeIndex;
  final VoidCallback onTap;
  final double fontScale;

  const AdvancedLyricLine({
    super.key,
    required this.line,
    required this.mode,
    required this.isActive,
    required this.relativeIndex,
    required this.onTap,
    this.fontScale = 1.0,
  });

  bool _isHindi(String text) {
    return RegExp(r'[\u0900-\u097F]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch position if this line is active and in word/char sync modes, avoiding rebuilds of all other lines
    final needsPosition = isActive && (mode == LyricsSyncMode.word || mode == LyricsSyncMode.char);
    final currentPosition = needsPosition
        ? ref.watch(playbackProvider.select((s) => s.position))
        : Duration.zero;

    final progress = line.getProgress(currentPosition);
    final isPast = isActive ? false : (ref.read(playbackProvider).position > line.endTime);

    // Calculate absolute distance for opacity and duration
    final absIndex = relativeIndex.abs();
    
    // Calculate dynamic opacity based on distance from active line
    double lineOpacity = 1.0;
    if (!isActive) {
      lineOpacity = (0.6 / (absIndex * 0.3)).clamp(0.3, 0.5);
    }

    final settings = ref.watch(settingsProvider);
    final alignmentString = settings.lyricsAlignment;
    final useDynamicColor = settings.dynamicColorActiveLyrics && 
        (settings.enableDynamicTheming || settings.dynamicLyrics);

    final textAlign = alignmentString == 'left'
        ? TextAlign.left
        : alignmentString == 'right'
            ? TextAlign.right
            : TextAlign.center;

    final iconAlignment = alignmentString == 'left'
        ? Alignment.centerLeft
        : alignmentString == 'right'
            ? Alignment.centerRight
            : Alignment.center;

    final wrapAlignment = alignmentString == 'left'
        ? WrapAlignment.start
        : alignmentString == 'right'
            ? WrapAlignment.end
            : WrapAlignment.center;

    // Extract dynamic color from artwork or fallback to Theme primary / white
    final artworkColorAsync = ref.watch(artworkColorProvider);
    final artworkColor = artworkColorAsync.valueOrNull;

    final activeColor = useDynamicColor 
        ? (artworkColor ?? Theme.of(context).colorScheme.primary) 
        : ((!settings.dynamicLyrics && !settings.dynamicColorActiveLyrics)
            ? Color(settings.accentColor)
            : Colors.white);

    // Language-aware font selection
    final bool isHindiText = _isHindi(line.text);
    final baseStyle =
        (isHindiText ? GoogleFonts.poppins() : GoogleFonts.spaceGrotesk())
            .copyWith(
              fontSize: (isActive ? 30.5 : 30) * fontScale,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w500,
              letterSpacing: isHindiText ? 0.0 : -0.5,
              height: 1.2,
              color: isActive ? activeColor : Colors.white.withValues(alpha: lineOpacity),
              shadows: isActive && useDynamicColor ? [
                Shadow(
                  color: activeColor.withValues(alpha: 0.01),
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
        child: AnimatedPadding(
          duration: animDuration,
          curve: curve,
          padding: EdgeInsets.only(
            top: (isActive ? 12 : 8) * fontScale,
            bottom: (isActive ? 20 : 8) * fontScale,
          ),
          child: AnimatedDefaultTextStyle(
            duration: animDuration,
            curve: curve,
            style: baseStyle,
            softWrap: true,
            textAlign: textAlign,
            child: _buildModeContent(
              context,
              progress,
              isPast,
              baseStyle,
              activeColor,
              searchQuery,
              textAlign,
              iconAlignment,
              wrapAlignment,
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
    TextAlign textAlign,
    Alignment iconAlignment,
    WrapAlignment wrapAlignment,
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
          ? Align(
              alignment: iconAlignment,
              child: Icon(Icons.music_note, color: Colors.white24, size: 30 * fontScale),
            )
          : Text(
              text,
              style: isSearchMatch ? baseStyle.copyWith(color: activeColor.withValues(alpha: 0.9)) : null,
              textAlign: textAlign,
              softWrap: true,
              overflow: TextOverflow.visible,
            );
    }

    if (isPast) {
      return isInstrumental
          ? Align(
              alignment: iconAlignment,
              child: Icon(Icons.music_note, color: Colors.white10, size: 30 * fontScale),
            )
          : Text(
              text,
              textAlign: textAlign,
              softWrap: true,
              overflow: TextOverflow.visible,
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
                  ? Align(
                      alignment: iconAlignment,
                      child: Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 40 * fontScale,
                      ),
                    )
                  : Hero(
                      tag: 'active_lyric_line',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          displayText,
                          textAlign: textAlign,
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
        return _buildWordMode(displayText, progress, baseStyle, activeColor, wrapAlignment);

      case LyricsSyncMode.char:
        return _buildCharMode(displayText, progress, baseStyle, activeColor, textAlign);
    }
  }

  Widget _buildWordMode(
    String text,
    double progress,
    TextStyle baseStyle,
    Color activeColor,
    WrapAlignment wrapAlignment,
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
            alignment: wrapAlignment,
            spacing: 12 * fontScale,
            children: List.generate(words.length, (index) {
              final isWordActive = index <= activeWordIndex;
              return AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                style: baseStyle.copyWith(
                  color: isWordActive ? activeColor : baseStyle.color?.withValues(alpha: 0.5),
                  shadows: isWordActive
                      ? [
                          Shadow(
                            color: activeColor.withValues(alpha: 0.3),
                            blurRadius: 16 * fontScale,
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
    TextAlign textAlign,
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
                  activeColor.withValues(alpha: 0.8),
                  baseStyle.color ?? Colors.white24,
                ],
                stops: [start, progress, end],
              ).createShader(bounds);
            },
            child: Text(
              text,
              style: baseStyle.copyWith(color: Colors.white),
              textAlign: textAlign,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ],
    );
  }
}
