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
      fontSize: isActive ? 38 : 32,
      fontWeight: FontWeight.bold,
      color: Colors.white.withOpacity(isActive ? 0.4 : 0.25),
    );

    // Active color (Theme Primary)
    final activeColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: _buildModeContent(context, progress, isPast, baseStyle, activeColor),
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
        isInstrumental ? '♫ Instrumental ♫' : text, 
        style: baseStyle, 
        textAlign: TextAlign.start
      );
    }

    if (isPast) {
      return Text(
        isInstrumental ? '♫ Instrumental ♫' : text, 
        style: baseStyle.copyWith(color: activeColor.withOpacity(0.5)), 
        textAlign: TextAlign.start
      );
    }

    // For active line, add music symbols if it's instrumental or just for style
    final displayText = isInstrumental ? '♫ Instrumental ♫' : text;

    switch (mode) {
      case LyricsSyncMode.line:
        return Row(
          children: [
            if (isActive) Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.music_note, color: activeColor, size: baseStyle.fontSize),
            ),
            Expanded(
              child: Text(
                displayText, 
                style: baseStyle.copyWith(color: activeColor), 
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
        if (isActive) Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 4.0),
          child: Icon(Icons.music_note, color: activeColor, size: baseStyle.fontSize),
        ),
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 8,
            children: List.generate(words.length, (index) {
              final isWordActive = index <= activeWordIndex;
              return Text(
                words[index],
                style: baseStyle.copyWith(
                  color: isWordActive ? activeColor : baseStyle.color,
                ),
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
        if (isActive) Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 4.0),
          child: Icon(Icons.music_note, color: activeColor, size: baseStyle.fontSize),
        ),
        Expanded(
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              // Create a narrow gradient window at the progress point for a smoother 'liquid' look
              const gradientWidth = 0.05; 
              final start = (progress - gradientWidth).clamp(0.0, 1.0);
              final end = (progress + gradientWidth).clamp(0.0, 1.0);
              
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  activeColor, 
                  activeColor.withOpacity(0.5), 
                  baseStyle.color!
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
