import 'dart:ui';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/widgets/song_options_bottom_sheet.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/core/app_icons.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/ui/screens/android/widgets/queue_bottom_sheet.dart';
import 'package:looper_player/core/ui_calculations.dart';
import 'package:looper_player/ui/widgets/premium_progress_bar.dart';
import '../widgets/premium_section.dart';
import 'android_lyrics_screen.dart';
import 'painters/sleep_timer_clock_painter.dart';
import 'package:looper_player/ui/screens/android/player/widgets/expanded_player_header.dart';
import 'package:looper_player/ui/screens/android/player/widgets/sleep_timer_clock.dart';
import 'painters/liked_glow_painter.dart';
import 'package:looper_player/ui/widgets/scrolling_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:looper_player/features/playback/data/audio_analyzer.dart';
import 'package:looper_player/core/player_expand_provider.dart';

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
  final GlobalKey _playerRootKey = GlobalKey();
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

  Animation<double>? _routeAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeAnimation = ModalRoute.of(context)?.animation;
    final enableSlide = ref.read(settingsProvider).enableSlideGesture;
    if (!enableSlide && _routeAnimation != routeAnimation) {
      _routeAnimation?.removeListener(_onRouteAnimationTick);
      _routeAnimation = routeAnimation;
      _routeAnimation?.addListener(_onRouteAnimationTick);
      _onRouteAnimationTick();
    }
  }

  void _onRouteAnimationTick() {
    final anim = _routeAnimation;
    if (anim != null) {
      final screenHeight = MediaQuery.of(context).size.height;
      final dragProgress = 1.0 - (_verticalDragOffset / (screenHeight > 0 ? screenHeight : 1.0)).clamp(0.0, 1.0);
      final progress = anim.value * dragProgress;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(playerExpandProgressProvider.notifier).state = progress;
        }
      });
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeListener(_onRouteAnimationTick);
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
      _onRouteAnimationTick();
    });
    _dismissController.forward(from: 0.0);
  }




  void _showLyrics(BuildContext context) {
    HapticFeedback.lightImpact();
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
    final l10n = AppLocalizations.of(context)!;

    if (song == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body:  Center(
          child: Text('No song playing', style: AppFonts.jostStyle(color: Colors.white)),
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
          if (analysis == null) return UiUtils.getAudioQualityText(song.path);
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
        loading: () => UiUtils.getAudioQualityText(song.path),
        error: (_, _) => UiUtils.getAudioQualityText(song.path),
      );
    }

    final settings = ref.watch(settingsProvider);
    final useBlur = settings.enableDynamicTheming;
    final enableSlide = settings.enableSlideGesture;
    final musicDarkness = settings.musicDarkness.isNaN
        ? 0.62
        : settings.musicDarkness;

    final progress = enableSlide ? ref.watch(playerExpandProgressProvider) : 1.0;
    final double contentOpacity = settings.enableSlideGesture ? ((progress - 0.25) / 0.75).clamp(0.0, 1.0) : 1.0;

    Widget buildHero({
      required String tag,
      required Widget child,
      HeroFlightShuttleBuilder? flightShuttleBuilder,
    }) {
      if (enableSlide) return child;
      return Hero(
        tag: tag,
        flightShuttleBuilder: flightShuttleBuilder,
        child: child,
      );
    }

    final child = Scaffold(
      key: _playerRootKey,
      backgroundColor: (!enableSlide || !useBlur) ? Theme.of(context).colorScheme.surface : Colors.transparent,
      body: Stack(
        children: [
          // Background stack (Only active when slide gesture is disabled, since the parent panel draws it otherwise)
          if (!enableSlide) ...[
            if (useBlur && song.artPath != null) ...[
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: BlurredBackgroundArt(
                    key: ValueKey(song.artPath),
                    song: song,
                  ),
                ),
              ),
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
          ],
          SafeArea(
            left: false,
            right: false,
            child: Column(
              children: [
                ExpandedPlayerHeader(
                  enableSlide: enableSlide,
                  settings: settings,
                  qualityText: qualityText,
                  contentOpacity: contentOpacity,
                  onMorePressed: () => _showMoreOptionsBottomSheet(context, ref),
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
                          child: PositionReporter(
                            ancestorKey: _playerRootKey,
                            onPositionChanged: (y) {
                              ref.read(playerArtworkTopProvider.notifier).state = y;
                            },
                            child: Opacity(
                              opacity: (enableSlide && progress < 0.99) ? 0.0 : 1.0,
                              child: RepaintBoundary(
                                child: GestureArtworkWithFeedback(
                                  song: song,
                                  onTap: () => _showLyrics(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Opacity(
                  opacity: contentOpacity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                                  buildHero(
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

                                          final fallbackFrom = AppFonts.jostStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.3,
                                          );
                                          final fallbackTo = AppFonts.jostStyle(
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
                                      style: AppFonts.jostStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  buildHero(
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

                                          final fallbackFrom = AppFonts.jostStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                            fontSize: 14,
                                            letterSpacing: 0.2,
                                          );
                                          final fallbackTo = AppFonts.jostStyle(
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
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () async {
                                          if (song.artist != null) {
                                            final artistSongs = await DbService.isar.songs
                                                .filter()
                                                .artistEqualTo(song.artist!)
                                                .findAll();
                                            final artist = await DbService.isar.artists
                                                .filter()
                                                .nameEqualTo(song.artist!)
                                                .findFirst();
                                            
                                            if (enableSlide) {
                                              ref.read(playerCollapseTriggerProvider.notifier).update((state) => state + 1);
                                            }
                                            
                                            ref
                                                .read(appNavigationProvider.notifier)
                                                .showCollection(
                                              title: song.artist!,
                                              subtitle: l10n.artists,
                                              art: artist?.artPath ?? song.artPath,
                                              imageUrl: artist?.artistImageUrl,
                                              songs: artistSongs,
                                            );
                                          }
                                          if (!enableSlide) {
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: ScrollingText(
                                          text: song.artist ?? 'Unknown Artist',
                                          style: AppFonts.jostStyle(
                                            color: Colors.white.withValues(alpha: 0.6),
                                            fontSize: 18,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
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
                            FavoriteButtonWithGlow(
                              song: song,
                              ref: ref,
                              useBlur: useBlur,
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
                            return buildHero(
                              tag: 'player_seek_bar',
                              child: Material(
                                type: MaterialType.transparency,
                                child: RepaintBoundary(
                                  child: ExpressiveSlider(
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
                                  ),
                                ),
                              ),
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
                              heroTag: 'player_prev_btn',
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
                                  heroTag: 'player_play_pause_btn',
                                  borderRadius: BorderRadius.circular(12),
                                  height: 80,
                                  showShadow: false,
                                  useBlur: useBlur,
                                  forceNoBlur: true,
                                  animate: true,
                                  backgroundColor: isPlaying
                                      ? null
                                      : Theme.of(context).colorScheme.primary,
                                  onTap: () {
                                    HapticFeedback.mediumImpact();
                                    ref.read(playbackProvider.notifier).togglePlay();
                                  },
                                  child: AnimatedScale(
                                    scale: 1.1,
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
                                          color: isPlaying
                                              ? Colors.white
                                              : HSLColor.fromColor(Theme.of(context).colorScheme.primary)
                                                  .withLightness(0.15)
                                                  .toColor(),
                                          size: AppIcons.expandedPlayerPlayPauseIcon.s,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 6),
                            // Next
                            PremiumSection(
                              heroTag: 'player_next_btn',
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
                                  animate: true,
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
                                  animate: true,
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
                                    repeatMode == RepeatMode.one
                                        ? 'assets/music_bar_Icons/repeat_1.svg'
                                        : AppIcons.repeat,
                                    colorFilter: repeatMode == RepeatMode.one
                                        ? null
                                        : ColorFilter.mode(
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
                              borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                    topRight: Radius.circular(32),
                                    bottomRight: Radius.circular(32),
                                  ),
                              height:64,
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
                                  Colors.white70,
                                  BlendMode.srcIn,
                                ),
                                width: AppIcons.sizeTiny.s,
                                height: AppIcons.sizeTiny.s,
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
        ],
      ),
    );

    final mainContent = enableSlide
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {}, // Absorb taps to prevent bubbling to parent PremiumMusicBar gesture detector
            child: child,
          )
        : GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! > 300) {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop();
              }
            },
            child: child,
          );

    if (enableSlide) {
      final isExpanded = progress > 0.05;
      return PopScope(
        canPop: !isExpanded,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (isExpanded) {
            ref.read(playerCollapseTriggerProvider.notifier).update((state) => state + 1);
          }
        },
        child: mainContent,
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop();
      },
      child: mainContent,
    );
  }
}

class PositionReporter extends ConsumerStatefulWidget {
  final Widget child;
  final ValueChanged<double> onPositionChanged;
  final GlobalKey ancestorKey;

  const PositionReporter({
    required this.child,
    required this.onPositionChanged,
    required this.ancestorKey,
    super.key,
  });

  @override
  ConsumerState<PositionReporter> createState() => _PositionReporterState();
}

class _PositionReporterState extends ConsumerState<PositionReporter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportPosition());
  }

  void _reportPosition() {
    if (!mounted) return;
    final double progress = ref.read(playerExpandProgressProvider);
    final enableSlide = ref.read(settingsProvider).enableSlideGesture;
    // Only report position when the player is fully expanded or slide gesture is disabled.
    // Reporting during animation/dragging causes layout feedback loop and artwork vibration.
    if (enableSlide && progress < 0.99) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final RenderBox? ancestorBox = widget.ancestorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && ancestorBox != null) {
      final position = ancestorBox.globalToLocal(renderBox.localToGlobal(Offset.zero));
      widget.onPositionChanged(position.dy);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<double>(playerExpandProgressProvider, (previous, next) {
      if (next > 0.99 && (previous == null || previous <= 0.99)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _reportPosition());
      }
    });
    return widget.child;
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
    final settings = ref.watch(settingsProvider);
    final enableSlide = settings.enableSlideGesture;
    final expandProgress = settings.enableSlideGesture
        ? ref.watch(playerExpandProgressProvider)
        : 1.0;
    final double artworkOpacity = !settings.enableSlideGesture || expandProgress > 0.99 ? 1.0 : 0.0;
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

    final artworkSwitcher = ClipRRect(
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
          final keyVal = child.key is ValueKey<String>
              ? (child.key as ValueKey<String>).value
              : '';
          final isIncoming = keyVal == widget.song.path;

          if (_skipSlideTransition) {
            if (isIncoming) {
              return SlideTransition(
                position: const AlwaysStoppedAnimation<Offset>(Offset.zero),
                child: child,
              );
            } else {
              final double offset = _isNext ? -1.1 : 1.1;
              return SlideTransition(
                position: AlwaysStoppedAnimation<Offset>(Offset(offset, 0.0)),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 1.0, end: 0.0).animate(animation),
                  child: child,
                ),
              );
            }
          }

          Offset beginOffset;
          Offset endOffset;

          if (_isNext) {
            beginOffset = isIncoming
                ? const Offset(1.1, 0.0)
                : const Offset(-1.1, 0.0);
            endOffset = Offset.zero;
          } else {
            beginOffset = isIncoming
                ? const Offset(-1.1, 0.0)
                : const Offset(1.1, 0.0);
            endOffset = Offset.zero;
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
    );


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
              ref.read(playbackProvider.notifier).skipPrevious(force: true);
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
      child: Opacity(
        opacity: artworkOpacity,
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
                      borderRadius: BorderRadius.circular(24),
                      fit: BoxFit.cover,
                      cacheWidth: (screenWidth * dpr).toInt(),
                    ),
                  ),
                ),
              ),

            // Active Sliding Artwork (flat horizontal slide)
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(_dragOffset, 0),
                child: enableSlide
                    ? artworkSwitcher
                    : Hero(
                        tag: 'album_art',
                        child: artworkSwitcher,
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
                              Text(
                                '-10s',
                                style: AppFonts.jostStyle(
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
                              Text(
                                '+10s',
                                style: AppFonts.jostStyle(
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
                              Text(
                                'Next',
                                style: AppFonts.jostStyle(
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
                              Text(
                                'Previous',
                                style: AppFonts.jostStyle(
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
    return RepaintBoundary(
      child: Transform.scale(
        scale: 1.08,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            filterQuality: FilterQuality.low,
            cacheWidth: 32,
            cacheHeight: 32,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
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
    final double dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;

    return AspectRatio(
      aspectRatio: 1.0,
      child: OptimizedImage(
        imagePath: song.artPath != null && !song.artPath!.startsWith('http')
            ? song.artPath
            : null,
        imageUrl: song.artPath != null && song.artPath!.startsWith('http')
            ? song.artPath
            : null,
        borderRadius: BorderRadius.circular(24),
        fit: BoxFit.cover,
        cacheWidth: (screenWidth * dpr).toInt(),
      ),
    );
  }
}




class FavoriteButtonWithGlow extends StatefulWidget {
  final Song song;
  final WidgetRef ref;
  final bool useBlur;

  const FavoriteButtonWithGlow({
    super.key,
    required this.song,
    required this.ref,
    required this.useBlur,
  });

  @override
  State<FavoriteButtonWithGlow> createState() => _FavoriteButtonWithGlowState();
}

class _FavoriteButtonWithGlowState extends State<FavoriteButtonWithGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  final math.Random _random = math.Random();
  final List<double> _randomAngles = [];
  final List<double> _randomRadii = [];
  final List<double> _randomSpeeds = [];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _generateRandomParticles();
  }

  void _generateRandomParticles() {
    _randomAngles.clear();
    _randomRadii.clear();
    _randomSpeeds.clear();
    for (int i = 0; i < 12; i++) {
      _randomAngles.add(_random.nextDouble() * 2 * math.pi);
      _randomRadii.add((_random.nextDouble() - 0.5) * 8.0);
      _randomSpeeds.add((_random.nextBool() ? 1 : -1) * (0.4 + _random.nextDouble() * 0.6));
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FavoriteButtonWithGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.song.isFavorite && widget.song.isFavorite) {
      if (_glowController.status != AnimationStatus.forward) {
        _generateRandomParticles();
        _glowController.forward(from: 0.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        PremiumSection(
          borderRadius: BorderRadius.circular(32),
          width: 56,
          height: 56,
          useExpanded: false,
          showShadow: false,
          useBlur: widget.useBlur,
          forceNoBlur: true,
          backgroundColor: widget.song.isFavorite
              ? Colors.amber.withOpacity(0.15)
              : Colors.transparent,
          onTap: () {
            HapticFeedback.selectionClick();
            if (!widget.song.isFavorite) {
              _generateRandomParticles();
              _glowController.forward(from: 0.0);
            }
            widget.ref.read(playbackProvider.notifier).toggleFavorite();
          },
          child: Center(
            child: SvgPicture.asset(
              widget.song.isFavorite ? AppIcons.like : AppIcons.unlike,
              colorFilter: ColorFilter.mode(
                widget.song.isFavorite
                    ? Colors.yellow
                    : Colors.white.withOpacity(0.4),
                BlendMode.srcIn,
              ),
              width: AppIcons.sizeLarge.s,
              height: AppIcons.sizeLarge.s,
            ),
          ),
        ),
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(56, 56),
                painter: LikedGlowPainter(
                  progress: _glowController.value,
                  randomAngles: _randomAngles,
                  randomRadii: _randomRadii,
                  randomSpeeds: _randomSpeeds,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


