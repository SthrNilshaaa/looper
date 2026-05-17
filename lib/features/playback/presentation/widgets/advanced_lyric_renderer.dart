import 'dart:io';
import 'package:looper_player/core/ui_utils.dart';
import 'package:flutter/material.dart';
import '../../domain/lyric_models.dart';
import '../lyrics_view.dart';
import '../lyrics_search_provider.dart';
import 'advanced_lyric_line.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdvancedLyricRenderer extends ConsumerStatefulWidget {
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
  ConsumerState<AdvancedLyricRenderer> createState() => _AdvancedLyricRendererState();
}

class _AdvancedLyricRendererState extends ConsumerState<AdvancedLyricRenderer> {
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
    final searchQuery = ref.read(lyricsSearchQueryProvider).toLowerCase();
    
    // If there's a search query, prioritize showing that match
    if (searchQuery.isNotEmpty) {
      final searchIndex = widget.lines.indexWhere(
        (line) => line.text.toLowerCase().contains(searchQuery),
      );
      if (searchIndex != -1 && (searchIndex != _currentLineIndex || forceScroll)) {
        _currentLineIndex = searchIndex;
        _scrollToIndex(searchIndex, isSearch: true);
        if (mounted) setState(() {});
        return;
      }
    }

    final index = widget.lines.indexWhere(
      (line) =>
          widget.currentPosition >= line.startTime &&
          widget.currentPosition < line.endTime,
    );

    if (index != -1 && (index != _currentLineIndex || forceScroll)) {
      _currentLineIndex = index;
      _scrollToIndex(index);
      if (mounted) setState(() {});
    }
  }

  void _scrollToIndex(int index, {bool isSearch = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _lineKeys[index];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
          alignment: isSearch ? 0.5 : 0.2, // Center more for search matches
        );
      } else {
        if (_scrollController.hasClients) {
          _scrollController
              .animateTo(
                (index * 80.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
              )
              .then((_) {
                if (mounted && _lineKeys[index]?.currentContext != null) {
                  Scrollable.ensureVisible(
                    _lineKeys[index]!.currentContext!,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.fastOutSlowIn,
                    alignment: isSearch ? 0.5 : 0.2,
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
      physics: const BouncingScrollPhysics(),
      itemCount: widget.lines.length,
      padding: EdgeInsets.only(
        top: 60.s,
        bottom: (Platform.isAndroid || Platform.isIOS) ? 120.s : 400.s,
        left: 24.s,
        right: 24.s,
      ),
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
            relativeIndex: _currentLineIndex == -1
                ? index
                : index - _currentLineIndex,
            onTap: () => widget.onSeek(line.startTime),
          ),
        );
      },
    );
  }
}
