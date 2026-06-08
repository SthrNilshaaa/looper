import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:looper_player/ui/widgets/song_options_bottom_sheet.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/core/app_icons.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:squiggly_slider/slider.dart';
import 'package:looper_player/ui/screens/android/widgets/queue_bottom_sheet.dart';
import 'package:looper_player/ui/screens/android/widgets/song_details_bottom_sheet.dart';
import 'package:looper_player/features/playback/presentation/lyrics_view.dart';
import 'package:looper_player/ui/widgets/premium_progress_bar.dart';
import '../widgets/premium_section.dart';
import 'android_lyrics_screen.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import '../song/song_info_screen.dart';
import 'package:looper_player/ui/widgets/scrolling_text.dart';
import 'package:looper_player/features/playback/presentation/lyrics_notifier.dart';
import 'package:looper_player/features/playback/domain/lyric_models.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:looper_player/features/playback/data/audio_analyzer.dart';

final currentSongAnalysisProvider = FutureProvider<AudioAnalysis?>((ref) async {
  final currentSongPath = ref.watch(playbackProvider.select((s) => s.currentSong?.path));
  if (currentSongPath == null) return null;

  // 300ms debounce to prevent multiple concurrent probes when fast-skipping
  await Future.delayed(const Duration(milliseconds: 300));

  return AudioAnalyzer.analyze(currentSongPath);
});

class AndroidExpandedPlayer extends ConsumerStatefulWidget {
  const AndroidExpandedPlayer({super.key});

  @override
  ConsumerState<AndroidExpandedPlayer> createState() =>
      _AndroidExpandedPlayerState();
}

class _AndroidExpandedPlayerState extends ConsumerState<AndroidExpandedPlayer>
    with SingleTickerProviderStateMixin {
  double _verticalDragOffset = 0.0;
  late AnimationController _dismissController;

  @override
  void initState() {
    super.initState();
    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _dismissController.dispose();
    super.dispose();
  }

  void _animateDragBack() {
    final start = _verticalDragOffset;
    final animation = Tween<double>(begin: start, end: 0.0).animate(
      CurvedAnimation(parent: _dismissController, curve: Curves.easeOutCubic),
    );
    animation.addListener(() {
      setState(() {
        _verticalDragOffset = animation.value;
      });
    });
    _dismissController.forward(from: 0.0);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _getFallbackQualityText(Song song) {
    final ext = song.path.split('.').last.toLowerCase().toUpperCase();
    if (['FLAC', 'WAV', 'ALAC', 'APE'].contains(ext)) {
      return 'Lossless • $ext';
    } else if (ext == 'MP3' || ext == 'M4A' || ext == 'AAC') {
      return 'High Quality • $ext';
    } else {
      return 'High Quality • Audio';
    }
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, Song song) {
    final controller = TextEditingController(text: song.title);
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          title: Text(
            l10n.renameSong,
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: l10n.newTitle,
              labelStyle: const TextStyle(color: Colors.grey),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                final result = await ref
                    .read(playbackProvider.notifier)
                    .renameSong(song, controller.text);
                if (context.mounted) {
                  navigator.pop(); // Close dialog
                  String message = '';
                  Color bgColor = Colors.transparent;
                  if (result == FileActionResult.success) {
                    message = 'Song renamed successfully';
                    bgColor = Colors.green.shade800;
                  } else if (result == FileActionResult.dbOnly) {
                    message = 'Song renamed in app library (physical file read-only)';
                    bgColor = Colors.orange.shade800;
                  } else {
                    message = 'Failed to rename song';
                    bgColor = Colors.red.shade800;
                  }
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        message,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: bgColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(
                l10n.rename,
                style: const TextStyle(color: Colors.yellow),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Song song) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          title: Text(
            l10n.deleteSong,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            l10n.deleteSongConfirm,
            style: const TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                final result = await ref.read(playbackProvider.notifier).deleteSong(song);
                if (context.mounted) {
                  navigator.pop(); // Close dialog
                  String message = '';
                  Color bgColor = Colors.transparent;
                  if (result == FileActionResult.success) {
                    message = 'Song deleted successfully';
                    bgColor = Colors.green.shade800;
                    navigator.pop(); // Close expanded player
                  } else if (result == FileActionResult.dbOnly) {
                    message = 'Song removed from library (physical file read-only)';
                    bgColor = Colors.orange.shade800;
                    navigator.pop(); // Close expanded player
                  } else {
                    message = 'Failed to delete song';
                    bgColor = Colors.red.shade800;
                  }
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        message,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: bgColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(
                l10n.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLyrics(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AndroidLyricsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showMoreOptionsBottomSheet(BuildContext context, WidgetRef ref) {
    final currentSong = ref.read(playbackProvider).currentSong;
    if (currentSong != null) {
      showSongOptionsBottomSheet(context: context, ref: ref, song: currentSong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final song = ref.watch(playbackProvider.select((s) => s.currentSong));

    if (song == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(
          child: Text('No song playing', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    // Synchronously check the cache first to avoid any 300ms debounce flickering
    final cachedAnalysis = AudioAnalyzer.getCachedAnalysis(song.path);
    final String qualityText;

    if (cachedAnalysis != null) {
      final codecStr = cachedAnalysis.codec.toUpperCase();
      final bitDepthStr = cachedAnalysis.bitsPerSample > 0
          ? '${cachedAnalysis.bitsPerSample}-bit'
          : '';
      final sampleRateStr =
          '${(cachedAnalysis.sampleRate / 1000).toStringAsFixed(1)} kHz';
      final bitrateStr = '${(cachedAnalysis.bitrate / 1000).round()} kbps';

      final list = <String>[];
      if (['FLAC', 'WAV', 'ALAC', 'APE'].contains(codecStr)) {
        list.add('Lossless');
      } else if (['MP3', 'M4A', 'AAC', 'OGG'].contains(codecStr)) {
        if (cachedAnalysis.bitrate > 0 && cachedAnalysis.bitrate < 192000) {
          list.add('Standard Quality');
        } else {
          list.add('High Quality');
        }
      } else {
        list.add('Standard Quality');
      }
      list.add(codecStr);
      if (bitDepthStr.isNotEmpty) list.add(bitDepthStr);
      list.add(sampleRateStr);
      if (!['FLAC', 'WAV', 'ALAC', 'APE'].contains(codecStr)) {
        list.add(bitrateStr);
      }
      qualityText = list.join(' • ');
    } else {
      final analysisAsync = ref.watch(currentSongAnalysisProvider);
      qualityText = analysisAsync.when(
        data: (analysis) {
          if (analysis == null) return _getFallbackQualityText(song);
          final codecStr = analysis.codec.toUpperCase();
          final bitDepthStr = analysis.bitsPerSample > 0
              ? '${analysis.bitsPerSample}-bit'
              : '';
          final sampleRateStr =
              '${(analysis.sampleRate / 1000).toStringAsFixed(1)} kHz';
          final bitrateStr = '${(analysis.bitrate / 1000).round()} kbps';

          final list = <String>[];
          if (['FLAC', 'WAV', 'ALAC', 'APE'].contains(codecStr)) {
            list.add('Lossless');
          } else if (['MP3', 'M4A', 'AAC', 'OGG'].contains(codecStr)) {
            if (analysis.bitrate > 0 && analysis.bitrate < 192000) {
              list.add('Standard Quality');
            } else {
              list.add('High Quality');
            }
          } else {
            list.add('Standard Quality');
          }
          list.add(codecStr);
          if (bitDepthStr.isNotEmpty) list.add(bitDepthStr);
          list.add(sampleRateStr);
          if (!['FLAC', 'WAV', 'ALAC', 'APE'].contains(codecStr)) {
            list.add(bitrateStr);
          }
          return list.join(' • ');
        },
        loading: () => _getFallbackQualityText(song),
        error: (_, __) => _getFallbackQualityText(song),
      );
    }

    final settings = ref.watch(settingsProvider);
    final useBlur = settings.enableDynamicTheming;
    final enableSlide = settings.enableSlideGesture;
    final musicDarkness = (settings.musicDarkness.isNaN || settings.musicDarkness == 0.0)
        ? 0.62
        : settings.musicDarkness;

    final child = Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dynamic Background (Optimized with low-res cache for blur)
          if (useBlur && song.artPath != null) ...[
            // Positioned.fill(
            //   child:AnimatedSwitcher(
            //     duration: const Duration(milliseconds: 800),
            //     transitionBuilder: (child, animation) {
            //       return FadeTransition(opacity: animation, child: child);
            //     },
            //     child:
            //    RepaintBoundary(
            //     child: OptimizedImage(
            //       imagePath: !song.artPath!.startsWith('http') ? song.artPath : null,
            //       imageUrl: song.artPath!.startsWith('http') ? song.artPath : null,
            //       fit: BoxFit.cover,
            //       cacheWidth: 100, // Tiny resolution is enough for blur
            //       cacheHeight: 100,
            //     ),
            //   ),),
            // ),
            // Positioned.fill(
            //   child: BackdropFilter(
            //     filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            //     child: Container(
            //       color: Colors.black.withValues(alpha: 0.7),
            //     ),
            //   ),
            // ),
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: BlurredBackgroundArt(
                  key: ValueKey(song!.artPath),
                  song: song,
                ),
              ),
            ),

            // Dark overlay
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: musicDarkness)),
            ),
          ] else ...[
            if (settings.enablePlayerGradient)
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topRight,
                      radius: 1.5,
                      colors: [
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
                        Theme.of(context).colorScheme.surface,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              )
            else
              Positioned.fill(
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
          ],
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PremiumSection(
                        borderRadius: BorderRadius.circular(32),
                        width: 48,
                        showShadow: false,
                        height: 48,
                        forceNoBlur: true,
                        useExpanded: false,
                        useBlur: useBlur,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                        child: SvgPicture.asset(
                          AppIcons.close,
                          // colorFilter: const ColorFilter.mode(
                          //   Colors.white,
                          //   BlendMode.srcIn,
                          // ),
                          width:8,
                          height: 8,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Now Playing',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (settings.showQualityBadge)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                qualityText,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      PremiumSection(
                        borderRadius: BorderRadius.circular(32),
                        width: 48,
                        height: 48,
                        useExpanded: false,
                        showShadow: false,
                        forceNoBlur: true,
                        useBlur: useBlur,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          showModalBottomSheet(
                            context: context,
                            useRootNavigator: true,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const QueueBottomSheet(),
                          );
                        },
                        child: SvgPicture.asset(
                          AppIcons.queue,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          width: AppIcons.sizeTiny.s,
                          height: AppIcons.sizeTiny.s,
                        ),
                      ),
                    ],
                  ),
                ),

                // Large Album Art and Lyrics above it
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Active Lyric Line (Moved above art)
                        AspectRatio(
                          aspectRatio: 1.0,
                          child: GestureArtworkWithFeedback(
                            song: song,
                            onTap: () => _showLyrics(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Song Info and Favorite Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: 'song_title',
                              flightShuttleBuilder:
                                  (
                                    flightContext,
                                    animation,
                                    flightDirection,
                                    fromHeroContext,
                                    toHeroContext,
                                  ) {
                                    final Hero fromHero =
                                        fromHeroContext.widget as Hero;
                                    final Hero toHero =
                                        toHeroContext.widget as Hero;

                                    final fallbackFrom = const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    );
                                    final fallbackTo = const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    );

                                    final fromStyle = _getHeroStyle(
                                      fromHero,
                                      fallbackFrom,
                                    );
                                    final toStyle = _getHeroStyle(
                                      toHero,
                                      fallbackTo,
                                    );

                                    return AnimatedBuilder(
                                      animation: animation,
                                      builder: (context, child) {
                                        final lerpValue =
                                            flightDirection ==
                                                HeroFlightDirection.push
                                            ? animation.value
                                            : 1.0 - animation.value;
                                        return Material(
                                          type: MaterialType.transparency,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              song.title,
                                              style: TextStyle.lerp(
                                                fromStyle,
                                                toStyle,
                                                lerpValue,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                              child: ScrollingText(
                                text: song.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Hero(
                              tag: 'song_artist',
                              flightShuttleBuilder:
                                  (
                                    flightContext,
                                    animation,
                                    flightDirection,
                                    fromHeroContext,
                                    toHeroContext,
                                  ) {
                                    final Hero fromHero =
                                        fromHeroContext.widget as Hero;
                                    final Hero toHero =
                                        toHeroContext.widget as Hero;

                                    final fallbackFrom = TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontSize: 14,
                                      letterSpacing: 0.2,
                                    );
                                    final fallbackTo = TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontSize: 18,
                                      letterSpacing: 0.2,
                                    );

                                    final fromStyle = _getHeroStyle(
                                      fromHero,
                                      fallbackFrom,
                                    );
                                    final toStyle = _getHeroStyle(
                                      toHero,
                                      fallbackTo,
                                    );

                                    return AnimatedBuilder(
                                      animation: animation,
                                      builder: (context, child) {
                                        final lerpValue =
                                            flightDirection ==
                                                HeroFlightDirection.push
                                            ? animation.value
                                            : 1.0 - animation.value;
                                        return Material(
                                          type: MaterialType.transparency,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              song.artist ?? 'Unknown Artist',
                                              style: TextStyle.lerp(
                                                fromStyle,
                                                toStyle,
                                                lerpValue,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                              child: ScrollingText(
                                text: song.artist ?? 'Unknown Artist',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 18,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: SizedBox(
                          height: 36,
                          child: VerticalDivider(
                            width: 1,
                            thickness: 0.5,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                      ),

                      PremiumSection(
                        borderRadius: BorderRadius.circular(32),
                        width: 56,
                        height: 56,
                        useExpanded: false,
                        showShadow: false,
                        useBlur: useBlur,
                        forceNoBlur: true,
                        onTap: () {
                         setState(() {
                            HapticFeedback.selectionClick();
                          ref.read(playbackProvider.notifier).toggleFavorite();
                         });
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top:3.0),
                            child: SvgPicture.asset(
                              song.isFavorite ?
                              AppIcons.like:
                              AppIcons.unlike,
                              colorFilter: ColorFilter.mode(
                                song.isFavorite
                                    ? Colors.yellow
                                    : Colors.white.withValues(alpha: 0.4),
                                    
                                BlendMode.srcIn,
                              ),
                              width: AppIcons.sizeMedium.s,
                              height: AppIcons.sizeMedium.s,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Seek Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Consumer(
                    builder: (context, ref, child) {
                      final position = ref.watch(playbackProvider.select((s) => s.position));
                      final duration = ref.watch(playbackProvider.select((s) => s.duration));
                      final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
                      return ExpressiveSlider(
                        position: position,
                        duration: duration,
                        isPlaying: isPlaying,
                        onSeek: (pos) =>
                            ref.read(playbackProvider.notifier).seek(pos),
                        onSeekStart: () =>
                            ref.read(playbackProvider.notifier).startScrubbing(),
                        onSeekEnd: () =>
                            ref.read(playbackProvider.notifier).stopScrubbing(),
                        color: Theme.of(context).colorScheme.primary,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Playback Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Previous
                      PremiumSection(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          bottomLeft: Radius.circular(40),
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        height: 80,
                        showShadow: false,
                        useBlur: useBlur,
                        forceNoBlur: true,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(playbackProvider.notifier).skipPrevious();
                        },
                        child: SvgPicture.asset(
                          AppIcons.prev,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          width: AppIcons.expandedPlayerMainControl.s,
                          height: AppIcons.expandedPlayerMainControl.s,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Play/Pause
                      Consumer(
                        builder: (context, ref, child) {
                          final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
                          return PremiumSection(
                            borderRadius: BorderRadius.circular(12),
                            height: 80,
                            showShadow: false,
                            useBlur: useBlur,
                            forceNoBlur: true,
                             backgroundColor: isPlaying
                                ?null
                                :  Theme.of(context).colorScheme.primary,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ref.read(playbackProvider.notifier).togglePlay();
                            },
                            child: Hero(
                              tag: 'play_pause_icon',
                              child: AnimatedScale(
                                scale:  1.1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutBack,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    end: isPlaying ? 1.0 : 0.0,
                                  ),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOutCubic,
                                  builder: (context, value, child) {
                                    return AnimatedIcon(
                                      icon: AnimatedIcons.play_pause,
                                      progress: AlwaysStoppedAnimation(value),
                                      color: 
                                       isPlaying
                                       ? Colors.white
                                    : HSLColor.fromColor(Theme.of(context).colorScheme.primary)
                                        .withLightness(0.15)
                                        .toColor()
                                    ,
                                      size: AppIcons.expandedPlayerPlayPauseIcon.s,
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      // Next
                      PremiumSection(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          topRight: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        height: 80,
                        useBlur: useBlur,
                        showShadow: false,

                        forceNoBlur: true,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(playbackProvider.notifier).skipNext();
                        },
                        child: SvgPicture.asset(
                          AppIcons.next,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          width: AppIcons.expandedPlayerMainControl.s,
                          height: AppIcons.expandedPlayerMainControl.s,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Bottom Controls (Utilities)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Shuffle
                      Consumer(
                        builder: (context, ref, child) {
                          final isShuffle = ref.watch(playbackProvider.select((s) => s.isShuffle));
                          return PremiumSection(
                            heroTag: 'nav_morph_1',
                            height: 64,
                            useBlur: useBlur,
                            showShadow: false,
                            backgroundColor: isShuffle
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            forceNoBlur: true,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ref.read(playbackProvider.notifier).toggleShuffle();
                            },
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32),
                              bottomLeft: Radius.circular(32),
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            child: SvgPicture.asset(
                              AppIcons.shuffle,
                              colorFilter: ColorFilter.mode(
                                isShuffle
                                    ? HSLColor.fromColor(Theme.of(context).colorScheme.primary)
                                        .withLightness(0.15)
                                        .toColor()
                                    : Colors.white70,
                                BlendMode.srcIn,
                              ),
                              width: AppIcons.expandedPlayerSecondaryControl.s,
                              height: AppIcons.expandedPlayerSecondaryControl.s,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      // Repeat
                      Consumer(
                        builder: (context, ref, child) {
                          final repeatMode = ref.watch(playbackProvider.select((s) => s.repeatMode));
                          return PremiumSection(
                            heroTag: 'nav_morph_2',
                            height: 64,
                            showShadow: false,
                            useBlur: useBlur,
                            backgroundColor: repeatMode != RepeatMode.off
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            forceNoBlur: true,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ref.read(playbackProvider.notifier).nextRepeatMode();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: SvgPicture.asset(
                              AppIcons.repeat,
                              colorFilter: ColorFilter.mode(
                                repeatMode != RepeatMode.off
                                    ? HSLColor.fromColor(Theme.of(context).colorScheme.primary)
                                        .withLightness(0.15)
                                        .toColor()
                                    : Colors.white70,
                                BlendMode.srcIn,
                              ),
                              width: AppIcons.expandedPlayerSecondaryControl.s,
                              height: AppIcons.expandedPlayerSecondaryControl.s,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      // Lyrics
                      PremiumSection(
                        heroTag: 'nav_morph_3',
                        height: 64,
                        useBlur: useBlur,
                        showShadow: false,

                        forceNoBlur: true,
                        onTap: () => _showLyrics(context),
                        borderRadius: BorderRadius.circular(12),
                        child: SvgPicture.asset(
                          AppIcons.lyrics,
                          colorFilter: const ColorFilter.mode(
                            Colors.white70,
                            BlendMode.srcIn,
                          ),
                          width: AppIcons.expandedPlayerSecondaryControl.s,
                          height: AppIcons.expandedPlayerSecondaryControl.s,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // More
                      PremiumSection(
                        height: 64,
                        useBlur: useBlur,
                        showShadow: false,

                        forceNoBlur: true,
                        onTap: () => _showMoreOptionsBottomSheet(context, ref),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          topRight: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                        child: SvgPicture.asset(
                          AppIcons.more,
                          colorFilter: const ColorFilter.mode(
                            Colors.white70,
                            BlendMode.srcIn,
                          ),
                          width: AppIcons.expandedPlayerSecondaryControl.s,
                          height: AppIcons.expandedPlayerSecondaryControl.s,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );

    if (enableSlide) {
      return GestureDetector(
        onVerticalDragUpdate: (details) {
          setState(() {
            _verticalDragOffset = (_verticalDragOffset + details.delta.dy)
                .clamp(0.0, double.infinity);
          });
        },
        onVerticalDragEnd: (details) {
          final screenHeight = MediaQuery.of(context).size.height;
          if (_verticalDragOffset > screenHeight * 0.25 ||
              (details.primaryVelocity != null &&
                  details.primaryVelocity! > 300)) {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop();
          } else {
            _animateDragBack();
          }
        },
        child: Transform.translate(
          offset: Offset(0.0, _verticalDragOffset),
          child: child,
        ),
      );
    } else {
      return GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 300) {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop();
          }
        },
        child: child,
      );
    }
  }
}

class GestureArtworkWithFeedback extends ConsumerStatefulWidget {
  final Song song;
  final VoidCallback onTap;

  const GestureArtworkWithFeedback({
    super.key,
    required this.song,
    required this.onTap,
  });

  @override
  ConsumerState<GestureArtworkWithFeedback> createState() =>
      _GestureArtworkWithFeedbackState();
}

class _GestureArtworkWithFeedbackState
    extends ConsumerState<GestureArtworkWithFeedback>
    with TickerProviderStateMixin {
  String? _feedbackType; // 'rewind', 'forward', 'next', 'previous'
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _snapController;
  bool _isNext = true;
  double _dragOffset = 0.0;
  bool _skipSlideTransition = false;
  bool _isSwipeTriggered = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void didUpdateWidget(GestureArtworkWithFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song.path != widget.song.path) {
      if (_isSwipeTriggered ||
          _dragOffset.abs() > 10.0 ||
          _snapController.isAnimating) {
        _skipSlideTransition = true;
        _isSwipeTriggered = false;
      } else {
        _skipSlideTransition = false;
      }
      setState(() {
        _dragOffset = 0.0;
      });
      // Safely extract queue indexes to determine slide direction
      final queue = ref.read(playbackProvider).queue;
      final oldIdx = queue.indexWhere((s) => s.path == oldWidget.song.path);
      final newIdx = queue.indexWhere((s) => s.path == widget.song.path);
      if (oldIdx != -1 && newIdx != -1) {
        setState(() {
          _isNext = newIdx >= oldIdx;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _snapController.dispose();
    super.dispose();
  }

  void _triggerFeedback(String type) {
    if (!mounted) return;
    setState(() {
      _feedbackType = type;
    });
    _fadeController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _feedbackType = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
    final double targetPadding = isPlaying ? 0.0 : 2.0;
    final queue = ref.watch(playbackProvider.select((s) => s.queue));
    final repeatMode = ref.watch(playbackProvider.select((s) => s.repeatMode));
    final currentIdx = queue.indexWhere((s) => s.path == widget.song.path);

    Song? nextSong;
    Song? prevSong;

    if (currentIdx != -1) {
      if (currentIdx + 1 < queue.length) {
        nextSong = queue[currentIdx + 1];
      } else if (repeatMode == RepeatMode.all && queue.isNotEmpty) {
        nextSong = queue[0];
      }

      if (currentIdx - 1 >= 0) {
        prevSong = queue[currentIdx - 1];
      } else if (repeatMode == RepeatMode.all && queue.isNotEmpty) {
        prevSong = queue[queue.length - 1];
      }
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final artSize = screenWidth - 48;
    final double dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    final int computedCacheWidth = (artSize * dpr).toInt();

    if (nextSong?.artPath != null && File(nextSong!.artPath!).existsSync()) {
      precacheImage(
        ResizeImage(
          FileImage(File(nextSong.artPath!)),
          width: computedCacheWidth,
        ),
        context,
      );
    }
    if (prevSong?.artPath != null && File(prevSong!.artPath!).existsSync()) {
      precacheImage(
        ResizeImage(
          FileImage(File(prevSong.artPath!)),
          width: computedCacheWidth,
        ),
        context,
      );
    }
    final dragPercent = (_dragOffset / screenWidth).abs().clamp(0.0, 1.0);
    final Song? bgSong = _dragOffset < 0
        ? (nextSong ?? widget.song)
        : (_dragOffset > 0 ? (prevSong ?? widget.song) : null);

    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTapDown: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final localPos = box.globalToLocal(details.globalPosition);
        final isLeft = localPos.dx < box.size.width / 2;

        if (isLeft) {
          ref.read(playbackProvider.notifier).seekRelative(-10);
          _triggerFeedback('rewind');
        } else {
          ref.read(playbackProvider.notifier).seekRelative(10);
          _triggerFeedback('forward');
        }
      },
      onHorizontalDragUpdate: (details) {
        _snapController.stop();
        setState(() {
          _dragOffset += details.delta.dx;
        });
      },
      onHorizontalDragEnd: (details) {
        final threshold = screenWidth * 0.25;

        if (_dragOffset < -threshold ||
            (details.primaryVelocity != null &&
                details.primaryVelocity! < -300)) {
          // Swipe Left -> Skip Next
          if (nextSong == null) {
            final start = _dragOffset;
            final animation = Tween<double>(begin: start, end: 0.0).animate(
              CurvedAnimation(
                parent: _snapController,
                curve: Curves.elasticOut,
              ),
            );
            animation.addListener(() {
              setState(() {
                _dragOffset = animation.value;
              });
            });
            _snapController.forward(from: 0.0);
          } else {
            setState(() {
              _isNext = true;
              _isSwipeTriggered = true;
            });
            HapticFeedback.mediumImpact();
            final start = _dragOffset;
            final end = -screenWidth;
            final animation = Tween<double>(begin: start, end: end).animate(
              CurvedAnimation(
                parent: _snapController,
                curve: Curves.easeOutCubic,
              ),
            );
            animation.addListener(() {
              setState(() {
                _dragOffset = animation.value;
              });
            });
            _snapController.forward(from: 0.0).then((_) {
              ref.read(playbackProvider.notifier).skipNext();
            });
          }
        } else if (_dragOffset > threshold ||
            (details.primaryVelocity != null &&
                details.primaryVelocity! > 300)) {
          // Swipe Right -> Skip Previous
          if (prevSong == null) {
            final start = _dragOffset;
            final animation = Tween<double>(begin: start, end: 0.0).animate(
              CurvedAnimation(
                parent: _snapController,
                curve: Curves.elasticOut,
              ),
            );
            animation.addListener(() {
              setState(() {
                _dragOffset = animation.value;
              });
            });
            _snapController.forward(from: 0.0);
          } else {
            setState(() {
              _isNext = false;
              _isSwipeTriggered = true;
            });
            HapticFeedback.mediumImpact();
            final start = _dragOffset;
            final end = screenWidth;
            final animation = Tween<double>(begin: start, end: end).animate(
              CurvedAnimation(
                parent: _snapController,
                curve: Curves.easeOutCubic,
              ),
            );
            animation.addListener(() {
              setState(() {
                _dragOffset = animation.value;
              });
            });
            _snapController.forward(from: 0.0).then((_) {
              ref.read(playbackProvider.notifier).skipPrevious();
            });
          }
        } else {
          // Snap Back
          final start = _dragOffset;
          final animation = Tween<double>(begin: start, end: 0.0).animate(
            CurvedAnimation(parent: _snapController, curve: Curves.elasticOut),
          );
          animation.addListener(() {
            setState(() {
              _dragOffset = animation.value;
            });
          });
          _snapController.forward(from: 0.0);
        }
      },
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.all(targetPadding),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Card for real-time carousel transitions (flat horizontal slide)
            if (bgSong != null && _dragOffset.abs() > 1.0)
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(
                    _dragOffset < 0
                        ? _dragOffset + screenWidth
                        : _dragOffset - screenWidth,
                    0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: OptimizedImage(
                      imagePath:
                          bgSong.artPath != null &&
                              !bgSong.artPath!.startsWith('http')
                          ? bgSong.artPath
                          : null,
                      imageUrl:
                          bgSong.artPath != null &&
                              bgSong.artPath!.startsWith('http')
                          ? bgSong.artPath
                          : null,
                      width: artSize,
                      height: artSize,
                      borderRadius: BorderRadius.circular(24),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            // Active Sliding Artwork (flat horizontal slide)
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(_dragOffset, 0),
                child: Hero(
                  tag: 'album_art',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      layoutBuilder:
                          (
                            Widget? currentChild,
                            List<Widget> previousChildren,
                          ) {
                            return Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                ...previousChildren,
                                if (currentChild != null) currentChild,
                              ],
                            );
                          },
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            final keyVal = child.key is ValueKey<String>
                                ? (child.key as ValueKey<String>).value
                                : '';
                            final isIncoming = keyVal == widget.song.path;

                            if (_skipSlideTransition) {
                              if (isIncoming) {
                                return child;
                              } else {
                                return const SizedBox.shrink();
                              }
                            }

                            Offset beginOffset;
                            Offset endOffset;

                            if (_isNext) {
                              beginOffset = isIncoming
                                  ? const Offset(1.1, 0.0)
                                  : const Offset(-1.1, 0.0);
                              endOffset = isIncoming
                                  ? Offset.zero
                                  : Offset.zero;
                            } else {
                              beginOffset = isIncoming
                                  ? const Offset(-1.1, 0.0)
                                  : const Offset(1.1, 0.0);
                              endOffset = isIncoming
                                  ? Offset.zero
                                  : Offset.zero;
                            }

                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: beginOffset,
                                end: endOffset,
                              ).animate(animation),
                              child: child,
                            );
                          },
                      child: ForegroundAlbumArt(
                        key: ValueKey<String>(widget.song.path),
                        song: widget.song,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Feedback Overlay
            if (_feedbackType != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      final progress = _fadeAnimation.value;
                      final opacity = (1.0 - progress).clamp(0.0, 1.0);
                      final scale = 0.8 + (progress * 0.3);

                      Widget feedbackChild;
                      Alignment alignment = Alignment.center;

                      switch (_feedbackType) {
                        case 'rewind':
                          alignment = const Alignment(-0.5, 0.0);
                          feedbackChild = Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.replay_10_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                '-10s',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                          break;
                        case 'forward':
                          alignment = const Alignment(0.5, 0.0);
                          feedbackChild = Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.forward_10_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                '+10s',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                          break;
                        case 'next':
                          feedbackChild = Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.skip_next_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Next',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                          break;
                        case 'previous':
                          feedbackChild = Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.skip_previous_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Previous',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                          break;
                        default:
                          feedbackChild = const SizedBox.shrink();
                      }

                      return Container(
                        color: Colors.black.withValues(alpha: 0.35 * opacity),
                        alignment: alignment,
                        child: Opacity(
                          opacity: opacity,
                          child: Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: feedbackChild,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

TextStyle _getHeroStyle(Hero hero, TextStyle fallback) {
  final child = hero.child;
  if (child is ScrollingText) {
    return child.style ?? fallback;
  }
  if (child is Text) {
    return child.style ?? fallback;
  }
  return fallback;
}

class BlurredBackgroundArt extends StatelessWidget {
  final Song song;
  const BlurredBackgroundArt({required this.song, super.key});

  @override
  Widget build(BuildContext context) {
    final path = song.artPath;
    if (path == null) return const SizedBox.shrink();
    return Transform.scale(
      scale: 1.08,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: RepaintBoundary(
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            filterQuality: FilterQuality.low,
            cacheWidth: 80,
            cacheHeight: 80,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class ForegroundAlbumArt extends StatelessWidget {
  final Song song;
  const ForegroundAlbumArt({required this.song, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final artSize = screenWidth - 48;

    return AspectRatio(
      aspectRatio: 1.0,
      child: OptimizedImage(
        imagePath: song.artPath != null && !song.artPath!.startsWith('http')
            ? song.artPath
            : null,
        imageUrl: song.artPath != null && song.artPath!.startsWith('http')
            ? song.artPath
            : null,
        width: artSize,
        height: artSize,
        borderRadius: BorderRadius.circular(24),
        fit: BoxFit.cover,
      ),
    );
  }
}
