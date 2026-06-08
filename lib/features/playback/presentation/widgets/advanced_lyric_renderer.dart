import 'dart:io';
import 'package:looper_player/core/ui_utils.dart';
import 'package:flutter/material.dart';
import '../../domain/lyric_models.dart';
import '../lyrics_view.dart';
import '../lyrics_search_provider.dart';
import 'advanced_lyric_line.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';

class AdvancedLyricRenderer extends ConsumerStatefulWidget {
  final List<LyricLine> lines;
  final LyricsSyncMode mode;
  final Function(Duration) onSeek;

  const AdvancedLyricRenderer({
    super.key,
    required this.lines,
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
  double _fontScale = 1.0;
  double _baseScale = 1.0;

  bool _transitionFinished = false;
  Animation<double>? _routeAnimation;

  @override
  void initState() {
    super.initState();
    final currentPos = ref.read(playbackProvider).position;
    _updateActiveLine(currentPos, forceScroll: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    final animation = route?.animation;
    if (_routeAnimation != animation) {
      _routeAnimation?.removeStatusListener(_onRouteAnimationStatusChanged);
      _routeAnimation = animation;
      if (animation != null) {
        if (animation.isCompleted) {
          _transitionFinished = true;
          final currentPos = ref.read(playbackProvider).position;
          _updateActiveLine(currentPos, forceScroll: true);
        } else {
          _transitionFinished = false;
          animation.addStatusListener(_onRouteAnimationStatusChanged);
        }
      } else {
        _transitionFinished = true;
        final currentPos = ref.read(playbackProvider).position;
        _updateActiveLine(currentPos, forceScroll: true);
      }
    }
  }

  void _onRouteAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (mounted) {
        setState(() {
          _transitionFinished = true;
        });
        final currentPos = ref.read(playbackProvider).position;
        _updateActiveLine(currentPos, forceScroll: true);
      }
      _routeAnimation?.removeStatusListener(_onRouteAnimationStatusChanged);
    }
  }

  @override
  void didUpdateWidget(AdvancedLyricRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentPos = ref.read(playbackProvider).position;
    _updateActiveLine(currentPos, forceScroll: oldWidget.mode != widget.mode);
  }

  void _updateActiveLine(Duration position, {bool forceScroll = false}) {
    final searchQuery = ref.read(lyricsSearchQueryProvider).toLowerCase();
    
    // If there's a search query, prioritize showing that match
    if (searchQuery.isNotEmpty) {
      final searchIndex = widget.lines.indexWhere(
        (line) => line.text.toLowerCase().contains(searchQuery),
      );
      if (searchIndex != -1 && (searchIndex != _currentLineIndex || forceScroll)) {
        _currentLineIndex = searchIndex;
        if (_transitionFinished) {
          _scrollToIndex(searchIndex, isSearch: true);
        }
        if (mounted) setState(() {});
        return;
      }
    }

    final index = widget.lines.indexWhere(
      (line) =>
          position >= line.startTime &&
          position < line.endTime,
    );

    if (index != -1 && (index != _currentLineIndex || forceScroll)) {
      _currentLineIndex = index;
      if (_transitionFinished) {
        _scrollToIndex(index);
      }
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
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatusChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Duration>(
      playbackProvider.select((s) => s.position),
      (previous, next) {
        if (next != null) {
          _updateActiveLine(next);
        }
      },
    );

    return GestureDetector(
      onScaleStart: (details) {
        _baseScale = _fontScale;
      },
      onScaleUpdate: (details) {
        if (details.pointerCount >= 2) {
          setState(() {
            _fontScale = (_baseScale * details.scale).clamp(0.6, 2.5);
          });
        }
      },
      child: ListView.builder(
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
              mode: widget.mode,
              isActive: isActive,
              fontScale: _fontScale,
              relativeIndex: _currentLineIndex == -1
                  ? index
                  : index - _currentLineIndex,
              onTap: () => widget.onSeek(line.startTime),
            ),
          );
        },
      ),
    );
  }
}
