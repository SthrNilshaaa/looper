import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/playback/presentation/lyrics_view.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/core/app_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/ui/widgets/scrolling_text.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:looper_player/ui/widgets/fluid_background.dart';

import 'package:looper_player/features/playback/presentation/lyrics_notifier.dart';
import 'package:looper_player/ui/widgets/premium_progress_bar.dart';

class AndroidLyricsScreen extends ConsumerStatefulWidget {
  const AndroidLyricsScreen({super.key});

  @override
  ConsumerState<AndroidLyricsScreen> createState() =>
      _AndroidLyricsScreenState();
}

class _AndroidLyricsScreenState extends ConsumerState<AndroidLyricsScreen> {
  bool _delayCompleted = false;
  Timer? _delayTimer;
  Animation<double>? _routeAnimation;

  // Manual scroll & bottom controller states
  bool _showController = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    final isPlaying = ref.read(playbackProvider).isPlaying;
    if (isPlaying) {
      _enableWakelock();
    } else {
      _disableWakelock();
    }

    _delayTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _delayCompleted = true;
        });
      }
    });

    _resetHideTimer(const Duration(seconds: 3));

    // Reset manual scroll provider when opening lyrics screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lyricsManualScrollProvider.notifier).state = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.animation != _routeAnimation) {
      _routeAnimation?.removeStatusListener(_onRouteAnimationStatusChanged);
      _routeAnimation = route.animation;
      _routeAnimation?.addStatusListener(_onRouteAnimationStatusChanged);
    }
  }

  void _onRouteAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.reverse) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _hideTimer?.cancel();
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatusChanged);
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



  void _onUserScrolled() {
    if (!mounted) return;
    ref.read(lyricsManualScrollProvider.notifier).state = true;
    if (!_showController) {
      setState(() {
        _showController = true;
      });
    }
    _resetHideTimer();
  }

  void _resetHideTimer([Duration duration = const Duration(seconds: 4)]) {
    _hideTimer?.cancel();
    _hideTimer = Timer(duration, () {
      if (mounted) {
        setState(() {
          _showController = false;
        });
      }
    });
  }

  TextStyle _getHeroStyle(Hero hero, TextStyle fallback) {
    final child = hero.child;
    if (child is ScrollingText) {
      return child.style;
    }
    if (child is Text) {
      return child.style ?? fallback;
    }
    return fallback;
  }

  Widget _buildHeroTextShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final Hero fromHero = fromHeroContext.widget as Hero;
    final Hero toHero = toHeroContext.widget as Hero;

    final isArtist = fromHero.tag == 'song_artist' || toHero.tag == 'song_artist';
    final playback = ref.read(playbackProvider);
    final song = playback.currentSong;
    if (song == null) return const SizedBox.shrink();

    final text = isArtist ? (song.artist ?? 'Unknown Artist') : song.title;

    final fallbackFrom = isArtist
        ? AppFonts.jostStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)
        : AppFonts.jostStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);

    final fallbackTo = isArtist
        ? AppFonts.jostStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 18)
        : AppFonts.jostStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold);

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
              text,
              style: TextStyle.lerp(fromStyle, toStyle, lerpValue),
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PlaybackState>(playbackProvider, (previous, next) {
      if (next.isPlaying != previous?.isPlaying) {
        if (next.isPlaying) {
          _enableWakelock();
        } else {
          _disableWakelock();
        }
      }
    });

    final song = ref.watch(playbackProvider.select((s) => s.currentSong));
    final isManualScroll = ref.watch(lyricsManualScrollProvider);
    final settings = ref.watch(settingsProvider);

    if (song == null) return const SizedBox.shrink();

    final mainContent = SafeArea(
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            if (notification.dragDetails != null) {
              _onUserScrolled();
            }
          } else if (notification is ScrollStartNotification) {
            if (notification.dragDetails != null) {
              _onUserScrolled();
            }
          } else if (notification is UserScrollNotification) {
            if (notification.direction != ScrollDirection.idle) {
              _onUserScrolled();
            }
          }
          return false;
        },
        child: Column(
          children: [
            // Top Row: Album Art + Song Info
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                children: [
                  Hero(
                    tag: 'album_art',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: OptimizedImage(
                        imagePath: song.artPath,
                        width: 60.s,
                        height: 60.s,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'song_title',
                          flightShuttleBuilder: _buildHeroTextShuttle,
                          child: ScrollingText(
                            text: song.title,
                            style: AppFonts.jostStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        Hero(
                          tag: 'song_artist',
                          flightShuttleBuilder: _buildHeroTextShuttle,
                          child: ScrollingText(
                            text: song.artist ?? 'Unknown Artist',
                            style: AppFonts.jostStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  //   child: SizedBox(
                  //     height: 36,
                  //     child: VerticalDivider(
                  //       width: 1,
                  //       thickness: 0.5,
                  //       color: Colors.white.withValues(alpha: 0.15),
                  //     ),
                  //   ),
                  // ),
                  // // Play/Pause with Hero
                  // PremiumSection(
                  //   borderRadius: BorderRadius.circular(32),
                  //   width: 48.s,
                  //   height: 48.s,
                  //   useExpanded: false,
                  //   forceNoBlur: true,
                  //   useBlur:
                  //       settings.enableDynamicTheming ||
                  //       settings.dynamicLyrics,
                  //   onTap: () {
                  //     HapticFeedback.mediumImpact();
                  //     ref.read(playbackProvider.notifier).togglePlay();
                  //   },
                  //   child:  SvgPicture.asset(
                  //       isPlaying ? AppIcons.pause : AppIcons.play,
                  //       colorFilter: const ColorFilter.mode(
                  //         Colors.white,
                  //         BlendMode.srcIn,
                  //       ),
                  //       width: AppIcons.sizeSmall.s,
                  //       height: AppIcons.sizeSmall.s,
                  //     ),
                    
                  // ),
                  // const SizedBox(width: 8),
                  // Down Arrow
                  PremiumSection(
                    borderRadius: BorderRadius.circular(32),
                    width: 48.s,
                    height: 48.s,
                    useExpanded: false,
                    forceNoBlur: true,
                    useBlur:
                        settings.enableDynamicTheming ||
                        settings.dynamicLyrics || settings.blurredArtworkForLyrics,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      LucideIcons.chevronDown,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Thin grey line
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 0.5,
                width: double.infinity,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),

            // Lyrics Content
            const Expanded(child: LyricsView()),
          ],
        ),
      ),
    );

    final lyricsDarkness = settings.lyricsDarkness.isNaN
        ? 0.55
        : settings.lyricsDarkness;

    final route = ModalRoute.of(context);
    final isExiting = route != null && route.animation?.status == AnimationStatus.reverse;

    final showDynamicBg = !isExiting &&
        _delayCompleted &&
        (settings.enableDynamicTheming || settings.dynamicLyrics) &&
        !settings.blurredArtworkForLyrics &&
        song.artPath != null;

    final showBlurredArtworkBg = !isExiting &&
        _delayCompleted &&
        settings.blurredArtworkForLyrics &&
        song.artPath != null;

    final transitionDuration = isExiting
        ? Duration.zero
        : const Duration(milliseconds: 1000);

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 300) {
          HapticFeedback.mediumImpact();
          Navigator.of(context).pop();
        }
      },
      onTap: () {
        setState(() {
          _showController = !_showController;
        });
        if (_showController) {
          _resetHideTimer();
        } else {
          _hideTimer?.cancel();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background Layer: AnimatedSwitcher smoothly transitions between fallback static background and the dynamic fluid background
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: transitionDuration,
                child: showDynamicBg
                    ? Consumer(
                        key: ValueKey('fluid_bg_${song.path}'),
                        builder: (context, ref, child) {
                          final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
                          return FluidBackground(
                            key: ValueKey('fluid_bg_child_${song.path}'),
                            imageProvider: FileImage(File(song.artPath!)),
                            animate: isPlaying,
                            blurSigma: 80,
                            overlayDarken: lyricsDarkness,
                            child: const SizedBox.expand(),
                          );
                        },
                      )
                    : (showBlurredArtworkBg
                        ? RepaintBoundary(
                            key: ValueKey('blurred_art_bg_${song.path}'),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ImageFiltered(
                                    imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                                    child: Image.file(
                                      File(song.artPath!),
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.low,
                                      cacheWidth: 100,
                                      cacheHeight: 100,
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withValues(alpha: lyricsDarkness),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            key: const ValueKey('static_bg'),
                            children: [
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
                              ),
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black.withValues(alpha: lyricsDarkness),
                                ),
                              ),
                            ],
                          )),
              ),
            ),
            // Foreground Content Layer: Kept outside of AnimatedSwitcher to prevent state/scroll resets
            Positioned.fill(
              child: mainContent,
            ),
            // Re-sync Pill Button
            
            // Bottom Controller Layer (Includes gradient dark shadow + controls)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedOpacity(
                opacity: _showController ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: IgnorePointer(
                  ignoring: !_showController,
                  child:  Container(
                      height: 350.s,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                            Colors.black.withValues(alpha: 0.95),
                            Colors.black,
                          ],
                          stops: const [0.0, 0.2, 0.75, 1.0],
                        ),
                      ),
                      padding: EdgeInsets.only(
                        left: 24.s,
                        right: 24.s,
                        bottom: MediaQuery.of(context).padding.bottom + 24.s,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // ExpressiveSlider Seek Bar (from android_expanded_player.dart)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Consumer(
                              builder: (context, ref, child) {
                                final currentPosition = ref.watch(playbackProvider.select((s) => s.position));
                                final duration = ref.watch(playbackProvider.select((s) => s.duration));
                                final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
                                return Hero(
                                  tag: 'player_seek_bar',
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: ExpressiveSlider(
                                      position: currentPosition,
                                      duration: duration,
                                      isPlaying: isPlaying,
                                      onSeek: (pos) {
                                        _resetHideTimer();
                                        ref.read(playbackProvider.notifier).seek(pos);
                                      },
                                      onSeekStart: () {
                                        _resetHideTimer();
                                        ref.read(playbackProvider.notifier).startScrubbing();
                                      },
                                      onSeekEnd: () {
                                        _resetHideTimer();
                                        ref.read(playbackProvider.notifier).stopScrubbing();
                                      },
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Playback Controls Row matching android_expanded_player.dart exactly
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                            child: Consumer(
                              builder: (context, ref, child) {
                                final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
                                return Row(
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
                                      useBlur: settings.enableDynamicTheming,
                                      forceNoBlur: true,
                                      onTap: () {
                                        _resetHideTimer();
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
                                    PremiumSection(
                                      heroTag: 'player_play_pause_btn',
                                      borderRadius: BorderRadius.circular(12),
                                      height: 80,
                                      showShadow: false,
                                      useBlur: settings.enableDynamicTheming,
                                      forceNoBlur: true,
                                      backgroundColor: isPlaying
                                          ? null
                                          : Theme.of(context).colorScheme.primary,
                                      onTap: () {
                                        _resetHideTimer();
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
                                      useBlur: settings.enableDynamicTheming,
                                      showShadow: false,
                                      forceNoBlur: true,
                                      onTap: () {
                                        _resetHideTimer();
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
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                ),
              ),
            ),

            AnimatedPositioned(
              bottom: _showController ? 350.s : 50.s,
              left: 0,
              right: 0,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              child: Center(
                child: AnimatedOpacity(
                  opacity: isManualScroll ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: AnimatedScale(
                    scale: isManualScroll ? 1.0 : 0.8,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    child: IgnorePointer(
                      ignoring: !isManualScroll,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ref.read(lyricsManualScrollProvider.notifier).state = false;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.refreshCw,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Re-sync',
                                style: AppFonts.jostStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
