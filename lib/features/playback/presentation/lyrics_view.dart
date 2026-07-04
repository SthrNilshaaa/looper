import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/playback/presentation/lyrics_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/fluid_background.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'widgets/advanced_lyric_renderer.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'overlay_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:looper_player/ui/widgets/app_loading_indicator.dart';

enum LyricsSyncMode { line, word, char }

class LyricsView extends ConsumerStatefulWidget {
  const LyricsView({super.key});

  @override
  ConsumerState<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends ConsumerState<LyricsView> {
  LyricsSyncMode _syncMode = LyricsSyncMode.line;

  @override
  void initState() {
    super.initState();
    _enableWakelock();
  }

  @override
  void dispose() {
    _disableWakelock();
    super.dispose();
  }

  Future<void> _enableWakelock() async {
    try {
      await WakelockPlus.enable();
    } catch (e) {

    }
  }

  Future<void> _disableWakelock() async {
    try {
      await WakelockPlus.disable();
    } catch (e) {

    }
  }

  @override
  Widget build(BuildContext context) {
    final lyricsState = ref.watch(lyricsProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;
    //final playback = ref.watch(playbackProvider);
    // final song = playback.currentSong;
    // final settings = ref.watch(settingsProvider);

    // final lyricsDarkness = settings.lyricsDarkness.isNaN
    //     ? 0.55
    //     : settings.lyricsDarkness;

    // final showDynamicBg = (settings.enableDynamicTheming || settings.dynamicLyrics) &&
    //     !settings.blurredArtworkForLyrics &&
    //     song?.artPath != null;

    // final showBlurredArtworkBg = settings.blurredArtworkForLyrics &&
    //     song?.artPath != null;

    return Stack(
      children: [
        // if (showDynamicBg)
        //   Positioned.fill(
        //     child: FluidBackground(
        //       key: ValueKey('lyrics_fluid_bg_${song!.path}'),
        //       imageProvider: FileImage(File(song.artPath!)),
        //       animate: playback.isPlaying,
        //       blurSigma: 80,
        //       overlayDarken: lyricsDarkness,
        //       child: const SizedBox.expand(),
        //     ),
        //   )
        // else if (showBlurredArtworkBg)
        //   Positioned.fill(
        //     child: Stack(
        //       children: [
        //         Positioned.fill(
        //           child: ImageFiltered(
        //             imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        //             child: Image.file(
        //               File(song!.artPath!),
        //               fit: BoxFit.cover,
        //               filterQuality: FilterQuality.low,
        //             ),
        //           ),
        //         ),
        //         Positioned.fill(
        //           child: Container(
        //             color: Colors.black.withValues(alpha: lyricsDarkness),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        Column(
          children: [
            //const SizedBox(height: 48), // Space for floating button
            if (_syncMode != LyricsSyncMode.line) _buildDisclaimer(),
            Expanded(
              child: lyricsState.isLoading
                  ? const AppLoadingIndicator()
                  : lyricsState.rawLrc == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_note,
                            size: 80,
                            color: primaryColor.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Lyrics not available.',
                            style: AppFonts.spaceGroteskStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : AdvancedLyricRenderer(
                      lines: lyricsState.parsedLines,
                      mode: _syncMode,
                      onSeek: (pos) =>
                          ref.read(playbackProvider.notifier).seek(pos),
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
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, size: 12, color: Colors.orange),
          const SizedBox(width: 6),
          Text(
            'Approximated Sync (No Word Timings)',
            style: AppFonts.spaceGroteskStyle(
              fontSize: 10,
              color: Colors.orange,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector([bool isShort = false]) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
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
            },
          ),
          _ModeButton(
            label: 'WORD',
            isSelected: _syncMode == LyricsSyncMode.word,
            isShort: isShort,
            onTap: () {
              setState(() => _syncMode = LyricsSyncMode.word);
            },
          ),
          _ModeButton(
            label: 'CHAR',
            isSelected: _syncMode == LyricsSyncMode.char,
            isShort: isShort,
            onTap: () {
              setState(() => _syncMode = LyricsSyncMode.char);
            },
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
          vertical: isShort ? 6 : 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          label,
          style: AppFonts.jostStyle(
            fontSize: isShort ? 10 : 11,
            fontWeight: FontWeight.normal,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Colors.grey[400],
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
