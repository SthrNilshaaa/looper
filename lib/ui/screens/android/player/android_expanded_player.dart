import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/core/app_icons.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:squiggly_slider/slider.dart';
import 'package:looper_player/ui/screens/android/widgets/queue_bottom_sheet.dart';
import 'package:looper_player/ui/screens/android/widgets/song_details_bottom_sheet.dart';
import 'package:looper_player/features/playback/presentation/lyrics_view.dart';
import 'package:looper_player/ui/widgets/premium_progress_bar.dart';
import '../widgets/premium_section.dart';
import 'android_lyrics_screen.dart';
import '../song/song_info_screen.dart';
import 'package:looper_player/ui/widgets/scrolling_text.dart';
import 'package:looper_player/features/playback/presentation/lyrics_notifier.dart';
import 'package:looper_player/features/playback/domain/lyric_models.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:looper_player/features/playback/data/audio_analyzer.dart';

final currentSongAnalysisProvider = FutureProvider<AudioAnalysis?>((ref) async {
  final playbackState = ref.watch(playbackProvider);
  final currentSong = playbackState.currentSong;
  if (currentSong == null) return null;
  
  // 300ms debounce to prevent multiple concurrent probes when fast-skipping
  await Future.delayed(const Duration(milliseconds: 300));
  
  return AudioAnalyzer.analyze(currentSong.path);
});

class AndroidExpandedPlayer extends ConsumerWidget {
  const AndroidExpandedPlayer({super.key});

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
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: const Text('Rename Song', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'New Title',
            labelStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(playbackProvider.notifier)
                  .renameSong(song, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Rename', style: TextStyle(color: Colors.yellow)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Song song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: const Text('Delete Song', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this song from disk?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref.read(playbackProvider.notifier).deleteSong(song);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLyrics(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AndroidLyricsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showMoreOptionsBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  LucideIcons.listOrdered,
                  color: Colors.white,
                ),
                title: const Text(
                  'Add to Queue',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  final currentSong = ref.read(playbackProvider).currentSong;
                  if (currentSong != null) {
                    ref.read(playbackProvider.notifier).addToQueue(currentSong);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.heart, color: Colors.white),
                title: const Text(
                  'Toggle Favorite',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  final currentSong = ref.read(playbackProvider).currentSong;
                  if (currentSong != null) {
                    ref.read(playbackProvider.notifier).toggleFavorite();
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.edit2, color: Colors.white),
                title: const Text(
                  'Rename File',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  final currentSong = ref.read(playbackProvider).currentSong;
                  if (currentSong != null) {
                    _showRenameDialog(context, ref, currentSong);
                  }
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.share2, color: Colors.white),
                title: const Text(
                  'Share File',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  final currentSong = ref.read(playbackProvider).currentSong;
                  if (currentSong != null) {
                    ref.read(playbackProvider.notifier).shareSong(currentSong);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.trash2, color: Colors.white),
                title: const Text(
                  'Delete File',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  final currentSong = ref.read(playbackProvider).currentSong;
                  if (currentSong != null) {
                    _showDeleteDialog(context, ref, currentSong);
                  }
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.info, color: Colors.white),
                title: const Text(
                  'Song Details & Frequency',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  final currentSong = ref.read(playbackProvider).currentSong;
                  if (currentSong != null) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SongInfoScreen(song: currentSong),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackProvider);
    final song = playback.currentSong;

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
      final bitDepthStr = cachedAnalysis.bitsPerSample > 0 ? '${cachedAnalysis.bitsPerSample}-bit' : '';
      final sampleRateStr = '${(cachedAnalysis.sampleRate / 1000).toStringAsFixed(1)} kHz';
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
          final bitDepthStr = analysis.bitsPerSample > 0 ? '${analysis.bitsPerSample}-bit' : '';
          final sampleRateStr = '${(analysis.sampleRate / 1000).toStringAsFixed(1)} kHz';
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
    //final useBlur = false;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 300) {
          HapticFeedback.mediumImpact();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Dynamic Background (Optimized with low-res cache for blur)
            if (useBlur && song.artPath != null) ...[
              // Positioned.fill(
              //   child: RepaintBoundary(
              //     child: OptimizedImage(
              //       imagePath: !song.artPath!.startsWith('http') ? song.artPath : null,
              //       imageUrl: song.artPath!.startsWith('http') ? song.artPath : null,
              //       fit: BoxFit.cover,
              //       cacheWidth: 100, // Tiny resolution is enough for blur
              //       cacheHeight: 100,
              //     ),
              //   ),
              // ),
              // Positioned.fill(
              //   child: BackdropFilter(
              //     filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              //     child: Container(
              //       color: Colors.black.withOpacity(0.7),
              //     ),
              //   ),
              // ),
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(song!.artPath),
                  tween: Tween(begin: 1.0, end: 1.08),
                  duration: const Duration(seconds: 30),
                  curve: Curves.linear,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: 18,
                          sigmaY: 18,
                        ),
                        child: RepaintBoundary(
                          child: Image.file(
                            File(song.artPath!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,

                            // VERY IMPORTANT
                            filterQuality: FilterQuality.low,

                            // Massive optimization
                            cacheWidth: 80,
                            cacheHeight: 80,

                            gaplessPlayback: true,

                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Dark overlay
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.72),
                ),
              ),
            ] else ...[
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topRight,
                      radius: 1.5,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.18),
                        Theme.of(context).colorScheme.surface,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),
            ],
            SafeArea(
              child: 
              Column(
                  children: [
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                         8,16,0
                      ),
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
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              width: AppIcons.sizeTiny.s,
                              height: AppIcons.sizeTiny.s,
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
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.12),
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
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
                        padding: const EdgeInsets.symmetric(horizontal: 32),
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
                                  flightShuttleBuilder: (
                                     flightContext,
                                     animation,
                                     flightDirection,
                                     fromHeroContext,
                                     toHeroContext,
                                   ) {
                                     final Hero fromHero = fromHeroContext.widget as Hero;
                                     final Hero toHero = toHeroContext.widget as Hero;

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

                                     final fromStyle = _getHeroStyle(fromHero, fallbackFrom);
                                     final toStyle = _getHeroStyle(toHero, fallbackTo);

                                     return AnimatedBuilder(
                                        animation: animation,
                                        builder: (context, child) {
                                          final lerpValue = flightDirection == HeroFlightDirection.push
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
                                  flightShuttleBuilder: (
                                     flightContext,
                                     animation,
                                     flightDirection,
                                     fromHeroContext,
                                     toHeroContext,
                                   ) {
                                     final Hero fromHero = fromHeroContext.widget as Hero;
                                     final Hero toHero = toHeroContext.widget as Hero;

                                     final fallbackFrom = TextStyle(
                                       color: Colors.white.withValues(alpha: 0.5),
                                       fontSize: 14,
                                       letterSpacing: 0.2,
                                     );
                                     final fallbackTo = TextStyle(
                                       color: Colors.white.withValues(alpha: 0.6),
                                       fontSize: 18,
                                       letterSpacing: 0.2,
                                     );

                                     final fromStyle = _getHeroStyle(fromHero, fallbackFrom);
                                     final toStyle = _getHeroStyle(toHero, fallbackTo);

                                     return AnimatedBuilder(
                                        animation: animation,
                                        builder: (context, child) {
                                          final lerpValue = flightDirection == HeroFlightDirection.push
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
                                      color: Colors.white.withOpacity(0.6),
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
                                      color: Colors.white.withOpacity(0.15),
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
                              HapticFeedback.selectionClick();
                              ref
                                  .read(playbackProvider.notifier)
                                  .toggleFavorite();
                            },
                            child: SvgPicture.asset(
                              AppIcons.heart,
                              colorFilter: ColorFilter.mode(
                                song.isFavorite ? Colors.yellow : Colors.white.withOpacity(0.4), 
                                BlendMode.srcIn
                              ),
                              width: AppIcons.sizeMedium.s,
                              height: AppIcons.sizeMedium.s,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Seek Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: ExpressiveSlider(
                        position: playback.position,
                        duration: playback.duration,
                        isPlaying: playback.isPlaying,
                        onSeek: (pos) => ref.read(playbackProvider.notifier).seek(pos),
                        onSeekStart: () => ref.read(playbackProvider.notifier).startScrubbing(),
                        onSeekEnd: () => ref.read(playbackProvider.notifier).stopScrubbing(),
                        color: Theme.of(context).colorScheme.primary,
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
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              width: AppIcons.expandedPlayerMainControl.s,
                              height: AppIcons.expandedPlayerMainControl.s,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Play/Pause
                          PremiumSection(
                            borderRadius: BorderRadius.circular(12),
                            height: 80,
                            showShadow: false,
                            useBlur: useBlur,
                            
                            forceNoBlur: true,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ref.read(playbackProvider.notifier).togglePlay();
                            },
                            child: Hero(
                              tag: 'play_pause_icon',
                              child: AnimatedScale(
                                scale: playback.isPlaying ? 0.9 : 1.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutBack,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0.0, end: playback.isPlaying ? 1.0 : 0.0),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOutCubic,
                                  builder: (context, value, child) {
                                    return AnimatedIcon(
                                      icon: AnimatedIcons.play_pause,
                                      progress: AlwaysStoppedAnimation(value),
                                      color: Colors.white,
                                      size: AppIcons.expandedPlayerPlayPauseIcon.s,
                                    );
                                  },
                                ),
                              ),
                            ),
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
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
                          PremiumSection(
                            heroTag: 'nav_morph_1',
                            height: 64,
                            useBlur: useBlur,
                            showShadow: false,
                            
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
                                playback.isShuffle
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.white70,
                                BlendMode.srcIn
                              ),
                              width: AppIcons.expandedPlayerSecondaryControl.s,
                              height: AppIcons.expandedPlayerSecondaryControl.s,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Repeat
                          PremiumSection(
                            heroTag: 'nav_morph_2',
                            height: 64,
                            showShadow: false,
                            useBlur: useBlur,
                            
                            forceNoBlur: true,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ref.read(playbackProvider.notifier).nextRepeatMode();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: SvgPicture.asset(
                              AppIcons.repeat,
                              colorFilter: ColorFilter.mode(
                                playback.repeatMode != RepeatMode.off
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.white70,
                                BlendMode.srcIn
                              ),
                              width: AppIcons.expandedPlayerSecondaryControl.s,
                              height: AppIcons.expandedPlayerSecondaryControl.s,
                            ),
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
                              colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
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
                              colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
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
      ),
    );
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
      if (_isSwipeTriggered || _dragOffset.abs() > 10.0 || _snapController.isAnimating) {
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
    final playback = ref.watch(playbackProvider);
    final queue = playback.queue;
    final currentIdx = queue.indexWhere((s) => s.path == widget.song.path);

    Song? nextSong;
    Song? prevSong;

    if (currentIdx != -1) {
      if (currentIdx + 1 < queue.length) {
        nextSong = queue[currentIdx + 1];
      } else if (playback.repeatMode == RepeatMode.all && queue.isNotEmpty) {
        nextSong = queue[0];
      }

      if (currentIdx - 1 >= 0) {
        prevSong = queue[currentIdx - 1];
      } else if (playback.repeatMode == RepeatMode.all && queue.isNotEmpty) {
        prevSong = queue[queue.length - 1];
      }
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final dragPercent = (_dragOffset / screenWidth).abs().clamp(0.0, 1.0);
    final Song? bgSong = _dragOffset < 0 ? nextSong : (_dragOffset > 0 ? prevSong : null);

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

        if (_dragOffset < -threshold || (details.primaryVelocity != null && details.primaryVelocity! < -300)) {
          // Swipe Left -> Skip Next
          setState(() {
            _isNext = true;
            _isSwipeTriggered = true;
          });
          HapticFeedback.mediumImpact();
          final start = _dragOffset;
          final end = -screenWidth;
          final animation = Tween<double>(begin: start, end: end).animate(
            CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
          );
          animation.addListener(() {
            setState(() {
              _dragOffset = animation.value;
            });
          });
          _snapController.forward(from: 0.0).then((_) {
            ref.read(playbackProvider.notifier).skipNext();
           // _triggerFeedback('next');
            setState(() {
              _dragOffset = 0.0;
            });
          });
        } else if (_dragOffset > threshold || (details.primaryVelocity != null && details.primaryVelocity! > 300)) {
          // Swipe Right -> Skip Previous
          setState(() {
            _isNext = false;
            _isSwipeTriggered = true;
          });
          HapticFeedback.mediumImpact();
          final start = _dragOffset;
          final end = screenWidth;
          final animation = Tween<double>(begin: start, end: end).animate(
            CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
          );
          animation.addListener(() {
            setState(() {
              _dragOffset = animation.value;
            });
          });
          _snapController.forward(from: 0.0).then((_) {
            ref.read(playbackProvider.notifier).skipPrevious();
            //_triggerFeedback('previous');
            setState(() {
              _dragOffset = 0.0;
            });
          });
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Card for real-time carousel transitions (flat horizontal slide)
          if (bgSong != null && _dragOffset.abs() > 1.0)
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(_dragOffset < 0 ? _dragOffset + screenWidth : _dragOffset - screenWidth, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: OptimizedImage(
                    imagePath: bgSong.artPath != null && !bgSong.artPath!.startsWith('http')
                        ? bgSong.artPath
                        : null,
                    imageUrl: bgSong.artPath != null && bgSong.artPath!.startsWith('http')
                        ? bgSong.artPath
                        : null,
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
                    layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                      return Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      if (_skipSlideTransition) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      }

                      final keyVal = child.key is ValueKey<String>
                          ? (child.key as ValueKey<String>).value
                          : '';
                      final isIncoming = keyVal == widget.song.path;

                      Offset beginOffset;
                      Offset endOffset;

                      if (_isNext) {
                        beginOffset = isIncoming ? const Offset(1.1, 0.0) : const Offset(-1.1, 0.0);
                        endOffset = isIncoming ? Offset.zero : Offset.zero;
                      } else {
                        beginOffset = isIncoming ? const Offset(-1.1, 0.0) : const Offset(1.1, 0.0);
                        endOffset = isIncoming ? Offset.zero : Offset.zero;
                      }

                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: beginOffset,
                          end: endOffset,
                        ).animate(animation),
                        child: child,
                      );
                    },
                    child: AspectRatio(
                      key: ValueKey<String>(widget.song.path),
                      aspectRatio: 1.0,
                      child: OptimizedImage(
                        imagePath: widget.song.artPath != null &&
                                !widget.song.artPath!.startsWith('http')
                            ? widget.song.artPath
                            : null,
                        imageUrl: widget.song.artPath != null &&
                                widget.song.artPath!.startsWith('http')
                            ? widget.song.artPath
                            : null,
                        borderRadius: BorderRadius.circular(24),
                        fit: BoxFit.cover,
                      ),
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
                      color: Colors.black.withOpacity(0.35 * opacity),
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
