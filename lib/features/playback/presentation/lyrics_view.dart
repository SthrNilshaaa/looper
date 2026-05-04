import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_player/features/library/domain/models/models.dart';
import 'package:one_player/features/playback/presentation/playback_notifier.dart';
import 'package:one_player/features/playback/data/lyrics_service.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import '../domain/lyric_models.dart';
import 'widgets/advanced_lyric_renderer.dart';
import 'package:one_player/l10n/app_localizations.dart';
import 'package:animate_gradient/animate_gradient.dart';

enum LyricsSyncMode { line, word, char }

class LyricsView extends ConsumerStatefulWidget {
  const LyricsView({super.key});

  @override
  ConsumerState<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends ConsumerState<LyricsView> {
  String? _rawLrc;
  bool _isLoading = false;
  LyricsSyncMode _syncMode = LyricsSyncMode.line;
  List<LyricLine> _parsedLines = [];
  
  // Keep the old controller for LINE mode if we still want to use flutter_lyric package
  // But for consistency we might use the new renderer for everything.
  // The user asked to keep using existing LyricView for line mode.
  late LyricController _lyricController;

  @override
  void initState() {
    super.initState();
    _lyricController = LyricController();
    _lyricController.setOnTapLineCallback((position) {
      ref.read(playbackProvider.notifier).seek(position);
    });
    _fetchLyrics();
  }

  @override
  void dispose() {
    _lyricController.dispose();
    super.dispose();
  }

  Future<void> _fetchLyrics() async {
    final currentSong = ref.read(playbackProvider).currentSong;
    if (currentSong == null) return;

    setState(() => _isLoading = true);
    final service = LyricsService();
    final response = await service.getLyrics(
      trackName: currentSong.title.trim(),
      artistName: (currentSong.artist ?? '').trim(),
      albumName: (currentSong.album ?? '').trim(),
      durationSeconds: (currentSong.duration ?? 0) ~/ 1000,
    );
    
    if (mounted) {
      setState(() {
        _rawLrc = response?.syncedLyrics ?? response?.plainLyrics;
        _updateParsedLines();
        if (_rawLrc != null) {
          _lyricController.loadLyric(_rawLrc!);
        }
        _isLoading = false;
      });
    }
  }

  void _updateParsedLines() {
    if (_rawLrc == null) return;
    
    final currentSong = ref.read(playbackProvider).currentSong;
    final totalDuration = currentSong?.duration != null 
        ? Duration(milliseconds: currentSong!.duration!) 
        : const Duration(minutes: 5);
        
    _parsedLines = LrcParser.parse(_rawLrc!, totalDuration);
  }

  @override
  Widget build(BuildContext context) {
    // Only watch currentSong for the main layout
    final currentSong = ref.watch(playbackProvider.select((s) => s.currentSong));
    
    // Listen for song changes to fetch new lyrics
    ref.listen(playbackProvider.select((s) => s.currentSong?.id), (previous, next) {
      if (next != previous) {
        _fetchLyrics();
      }
    });

    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.tertiary;

    return Stack(
      children: [
        // Motion Gradient Background
        Positioned.fill(
          child: AnimateGradient(
            primaryBegin: Alignment.topLeft,
            primaryEnd: Alignment.bottomLeft,
            secondaryBegin: Alignment.bottomLeft,
            secondaryEnd: Alignment.topRight,
            primaryColors: [
              primaryColor.withOpacity(0.15),
              secondaryColor.withOpacity(0.1),
              Colors.transparent,
            ],
            secondaryColors: [
              Colors.transparent,
              primaryColor.withOpacity(0.1),
              secondaryColor.withOpacity(0.15),
            ],
          ),
        ),
        // Content
        Column(
          children: [
            // _buildHeader(currentSong),
            if (_syncMode != LyricsSyncMode.line) _buildDisclaimer(),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _rawLrc == null
                  ? const Center(child: Text('Lyrics not available.', style: TextStyle(color: Colors.grey)))
                  : Consumer(
                      builder: (context, ref, child) {
                        // Only watch position here to avoid rebuilding the entire screen
                        final position = ref.watch(playbackProvider.select((s) => s.position));
                        return _buildContent(position);
                      },
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.info_outline, size: 12, color: Colors.orange),
          SizedBox(width: 6),
          Text(
            'Approximated Sync (No Word Timings)',
            style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Duration position) {
    return AdvancedLyricRenderer(
      lines: _parsedLines,
      currentPosition: position,
      mode: _syncMode,
      onSeek: (pos) => ref.read(playbackProvider.notifier).seek(pos),
    );
  }

  Widget _buildHeader(Song? currentSong) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 600;
        final bool isShort = MediaQuery.of(context).size.height < 500;
        
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: isNarrow || isShort ? 8 : 24, 
            horizontal: isNarrow ? 16 : 32
          ),
          child: isNarrow 
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentSong != null) ...[
                    _buildSongInfoCompact(currentSong, isShort),
                    SizedBox(height: isShort ? 8 : 16),
                  ],
                  _buildModeSelector(isShort),
                ],
              )
            : Row(
                children: [
                  if (currentSong != null) ...[
                    _buildArt(currentSong, isShort ? 60 : 80),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildSongText(currentSong, isShort),
                    ),
                  ],
                  _buildModeSelector(isShort),
                ],
              ),
        );
      },
    );
  }

  Widget _buildArt(Song currentSong, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
        image: currentSong.artPath != null 
          ? DecorationImage(
              image: FileImage(File(currentSong.artPath!)),
              fit: BoxFit.cover,
            )
          : null,
      ),
      child: currentSong.artPath == null 
        ? Icon(Icons.music_note, color: Colors.grey[600], size: size / 2)
        : null,
    );
  }

  Widget _buildSongText(Song currentSong, bool isShort) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          currentSong.title, 
          style: TextStyle(fontSize: isShort ? 20 : 28, fontWeight: FontWeight.bold), 
          maxLines: 1, 
          overflow: TextOverflow.ellipsis
        ),
        Text(
          currentSong.artist ?? 'Unknown Artist', 
          style: TextStyle(fontSize: isShort ? 14 : 18, color: Colors.grey[400])
        ),
      ],
    );
  }

  Widget _buildSongInfoCompact(Song currentSong, bool isShort) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isShort ? 40 : 50,
          height: isShort ? 40 : 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white.withOpacity(0.05),
            image: currentSong.artPath != null 
              ? DecorationImage(
                  image: FileImage(File(currentSong.artPath!)),
                  fit: BoxFit.cover,
                )
              : null,
          ),
          child: currentSong.artPath == null 
            ? Icon(Icons.music_note, color: Colors.grey[600], size: isShort ? 20 : 24)
            : null,
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentSong.title, 
                style: TextStyle(fontSize: isShort ? 14 : 18, fontWeight: FontWeight.bold), 
                maxLines: 1, 
                overflow: TextOverflow.ellipsis
              ),
              Text(
                currentSong.artist ?? 'Unknown Artist', 
                style: TextStyle(fontSize: isShort ? 12 : 14, color: Colors.grey[400]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector([bool isShort = false]) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), 
        borderRadius: BorderRadius.circular(32)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeButton(
            label: 'LINE', 
            isSelected: _syncMode == LyricsSyncMode.line, 
            isShort: isShort,
            onTap: () {
              setState(() => _syncMode = LyricsSyncMode.line);
            }
          ),
          _ModeButton(
            label: 'WORD', 
            isSelected: _syncMode == LyricsSyncMode.word, 
            isShort: isShort,
            onTap: () {
              setState(() => _syncMode = LyricsSyncMode.word);
            }
          ),
          _ModeButton(
            label: 'CHAR', 
            isSelected: _syncMode == LyricsSyncMode.char, 
            isShort: isShort,
            onTap: () {
              setState(() => _syncMode = LyricsSyncMode.char);
            }
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isShort;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label, 
    required this.isSelected, 
    required this.onTap,
    this.isShort = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isShort ? 12 : 20, 
          vertical: isShort ? 6 : 10
        ),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isShort ? 10 : 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Theme.of(context).colorScheme.onPrimary : Colors.grey[400],
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
