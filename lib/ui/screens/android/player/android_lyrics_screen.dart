import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:adaptive_palette/adaptive_palette.dart' hide FluidBackground;
import 'package:looper_player/ui/widgets/fluid_background.dart';

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
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatusChanged);
    _disableWakelock();
    super.dispose();
  }

  Future<void> _enableWakelock() async {
    try {
      await WakelockPlus.enable();
    } catch (e) {
      debugPrint('Failed to enable wakelock: $e');
    }
  }

  Future<void> _disableWakelock() async {
    try {
      await WakelockPlus.disable();
    } catch (e) {
      debugPrint('Failed to disable wakelock: $e');
    }
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
        ? TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)
        : const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);

    final fallbackTo = isArtist
        ? TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 18)
        : const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold);

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
    final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
    final settings = ref.watch(settingsProvider);

    if (song == null) return const SizedBox.shrink();

    final mainContent = SafeArea(
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
                          style: const TextStyle(
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
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
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
                // Play/Pause with Hero
                PremiumSection(
                  borderRadius: BorderRadius.circular(32),
                  width: 48.s,
                  height: 48.s,
                  useExpanded: false,
                  forceNoBlur: true,
                  useBlur:
                      settings.enableDynamicTheming ||
                      settings.dynamicLyrics,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ref.read(playbackProvider.notifier).togglePlay();
                  },
                  child:  SvgPicture.asset(
                      isPlaying ? AppIcons.pause : AppIcons.play,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      width: AppIcons.sizeSmall.s,
                      height: AppIcons.sizeSmall.s,
                    ),
                  
                ),
                const SizedBox(width: 8),
                // Down Arrow
                PremiumSection(
                  borderRadius: BorderRadius.circular(32),
                  width: 48.s,
                  height: 48.s,
                  useExpanded: false,
                  forceNoBlur: true,
                  useBlur:
                      settings.enableDynamicTheming ||
                      settings.dynamicLyrics,
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
    );

    final lyricsDarkness = (settings.lyricsDarkness.isNaN || settings.lyricsDarkness == 0.0)
        ? 0.55
        : settings.lyricsDarkness;

    final route = ModalRoute.of(context);
    final isExiting = route != null && route.animation?.status == AnimationStatus.reverse;

    final showDynamicBg = !isExiting &&
        _delayCompleted &&
        (settings.enableDynamicTheming || settings.dynamicLyrics) &&
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
      child: Scaffold(
        body: Stack(
          children: [
            // Background Layer: AnimatedSwitcher smoothly transitions between fallback static background and the dynamic fluid background
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: transitionDuration,
                child: showDynamicBg
                    ? FluidBackground(
                        key: const ValueKey('fluid_bg'),
                        imageProvider: FileImage(File(song.artPath!)),
                        animate: isPlaying,
                        blurSigma: 80,
                        overlayDarken: lyricsDarkness,
                        child: const SizedBox.expand(),
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
                      ),
              ),
            ),
            // Foreground Content Layer: Kept outside of AnimatedSwitcher to prevent state/scroll resets
            Positioned.fill(
              child: mainContent,
            ),
          ],
        ),
      ),
    );
  }
}
