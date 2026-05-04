import 'package:flutter/material.dart';
import '../../domain/lyric_models.dart';
import '../lyrics_view.dart';

class AdvancedLyricLine extends StatelessWidget {
  final LyricLine line;
  final Duration currentPosition;
  final LyricsSyncMode mode;
  final bool isActive;
  final VoidCallback onTap;

  const AdvancedLyricLine({
    super.key,
    required this.line,
    required this.currentPosition,
    required this.mode,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = line.getProgress(currentPosition);
    final isPast = currentPosition > line.endTime;
    
    // Base style for all text
    final baseStyle = TextStyle(
      fontSize: isActive ? 48 : 36,
      fontWeight: FontWeight.w800, // Thicker font
      letterSpacing: 0.5,
      height: 1.3, // More breathing room
      color: Colors.white.withOpacity(isActive ? 0.9 : 0.2), // Dimmer inactive, brighter active
    );

    // Active color (Theme Primary)
    final activeColor = Theme.of(context).colorScheme.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: isActive ? 24 : 12, horizontal: 16),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            style: baseStyle,
            child: _buildModeContent(context, progress, isPast, baseStyle, activeColor),
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
    Color activeColor
  ) {
    final String text = line.text;
    final bool isInstrumental = text.toLowerCase().contains('instrumental') || 
                               text.toLowerCase().contains('[music]') ||
                               text.trim() == '♪';

    if (!isActive && !isPast) {
      return Text(
        isInstrumental ? '♫' : text,
        style: baseStyle, 
        textAlign: TextAlign.start
      );
    }

    if (isPast) {
      return Text(
        isInstrumental ? '♫' : text,
        style: baseStyle.copyWith(color: Colors.white.withOpacity(0.3)),
        textAlign: TextAlign.start
      );
    }

    // For active line, add music symbols if it's instrumental or just for style
    final displayText = isInstrumental ? '♫' : text;

    switch (mode) {
      case LyricsSyncMode.line:
        return Row(
          children: [
            Expanded(
              child: Text(
                displayText, 
                style: baseStyle.copyWith(color: Colors.white), // Very bright white for active line
                textAlign: TextAlign.start
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

  Widget _buildWordMode(String text, double progress, TextStyle baseStyle, Color activeColor) {
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
                  color: isWordActive ? Colors.white : baseStyle.color,
                  shadows: isWordActive ? [
                    Shadow(color: Colors.white.withOpacity(0.5), blurRadius: 16)
                  ] : null,
                ),
                child: Text(words[index]),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCharMode(String text, double progress, TextStyle baseStyle, Color activeColor) {
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
                  Colors.white,
                  Colors.white.withOpacity(0.8),
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
