import 'package:flutter/material.dart';
import '../../domain/lyric_models.dart';
import '../lyrics_view.dart';
import 'advanced_lyric_line.dart';

class AdvancedLyricRenderer extends StatefulWidget {
  final List<LyricLine> lines;
  final Duration currentPosition;
  final LyricsSyncMode mode;
  final Function(Duration) onSeek;

  const AdvancedLyricRenderer({
    super.key,
    required this.lines,
    required this.currentPosition,
    required this.mode,
    required this.onSeek,
  });

  @override
  State<AdvancedLyricRenderer> createState() => _AdvancedLyricRendererState();
}

class _AdvancedLyricRendererState extends State<AdvancedLyricRenderer> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _lineKeys = {};
  int _currentLineIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateActiveLine(forceScroll: true);
    });
  }

  @override
  void didUpdateWidget(AdvancedLyricRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateActiveLine(forceScroll: oldWidget.mode != widget.mode);
  }

  void _updateActiveLine({bool forceScroll = false}) {
    final index = widget.lines.indexWhere((line) => 
      widget.currentPosition >= line.startTime && 
      widget.currentPosition < line.endTime
    );

    if (index != -1 && (index != _currentLineIndex || forceScroll)) {
      _currentLineIndex = index;
      _scrollToIndex(index);
      if (mounted) setState(() {});
    }
  }

  void _scrollToIndex(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _lineKeys[index];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          alignment: 0.5, // Center the active line
        );
      } else {
        // Fallback for off-screen items
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            (index * 70.0), // rough estimate to get it in view
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ).then((_) {
            // Try again once it's likely built
            if (mounted && _lineKeys[index]?.currentContext != null) {
              Scrollable.ensureVisible(
                _lineKeys[index]!.currentContext!,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: 0.5,
              );
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.lines.length,
      padding: const EdgeInsets.symmetric(vertical: 300, horizontal: 48), // More padding for better centering
      itemBuilder: (context, index) {
        final line = widget.lines[index];
        final isActive = index == _currentLineIndex;
        
        // Assign or retrieve key for this line
        final key = _lineKeys.putIfAbsent(index, () => GlobalKey());

        return Padding(
          key: key,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AdvancedLyricLine(
            line: line,
            currentPosition: widget.currentPosition,
            mode: widget.mode,
            isActive: isActive,
            onTap: () => widget.onSeek(line.startTime),
          ),
        );
      },
    );
  }
}
