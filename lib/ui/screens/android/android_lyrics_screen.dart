import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/playback/presentation/lyrics_view.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/core/app_icons.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/ui/widgets/scrolling_text.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class AndroidLyricsScreen extends ConsumerStatefulWidget {
  const AndroidLyricsScreen({super.key});

  @override
  ConsumerState<AndroidLyricsScreen> createState() =>
      _AndroidLyricsScreenState();
}

class _AndroidLyricsScreenState extends ConsumerState<AndroidLyricsScreen> {
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

  Widget _buildHeroTextShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final Hero fromHero = fromHeroContext.widget as Hero;
    final Hero toHero = toHeroContext.widget as Hero;

    String text = '';
    TextStyle? fromStyle;
    TextStyle? toStyle;

    if (fromHero.child is ScrollingText) {
      final s = fromHero.child as ScrollingText;
      text = s.text;
      fromStyle = s.style;
    } else if (fromHero.child is Text) {
      final t = fromHero.child as Text;
      text = t.data ?? '';
      fromStyle = t.style;
    }

    if (toHero.child is ScrollingText) {
      final s = toHero.child as ScrollingText;
      text = s.text;
      toStyle = s.style;
    } else if (toHero.child is Text) {
      final t = toHero.child as Text;
      text = t.data ?? '';
      toStyle = t.style;
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Material(
          type: MaterialType.transparency,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: TextStyle.lerp(fromStyle, toStyle, animation.value),
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
    final playback = ref.watch(playbackProvider);
    final song = playback.currentSong;
    final settings = ref.watch(settingsProvider);

    if (song == null) return const SizedBox.shrink();

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
            // Dynamic Background with Slow Motion (Optimized)
            if ((settings.enableDynamicTheming || settings.dynamicLyrics) &&
                song.artPath != null) ...[
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 1.0, end: 1.1),
                duration: const Duration(seconds: 30),
                curve: Curves.linear,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Image.file(
                      File(song.artPath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      cacheWidth: 100, // Tiny resolution is perfect for blur
                      cacheHeight: 100,
                    ),
                  );
                },
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(color: Colors.black.withOpacity(0.7)),
                ),
              ),
            ] else ...[
              Positioned.fill(
                child: Container(color: Theme.of(context).colorScheme.surface),
              ),
            ],

            SafeArea(
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
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 14,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Play/Pause with Hero
                        PremiumSection(
                          borderRadius: BorderRadius.circular(32),
                          width: 48.s,
                          height: 48.s,
                          useExpanded: false,
                          useBlur:
                              settings.enableDynamicTheming ||
                              settings.dynamicLyrics,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            ref.read(playbackProvider.notifier).togglePlay();
                          },
                          child: Hero(
                            tag: 'play_pause_icon',
                            child: SvgPicture.asset(
                              playback.isPlaying
                                  ? AppIcons.pause
                                  : AppIcons.play,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                              width: AppIcons.sizeSmall.s,
                              height: AppIcons.sizeSmall.s,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Down Arrow
                        PremiumSection(
                          borderRadius: BorderRadius.circular(32),
                          // shape: BoxShape.circle,
                          width: 48.s,
                          height: 48.s,
                          useExpanded: false,
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
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),

                  // Lyrics Content
                  const Expanded(child: LyricsView()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
