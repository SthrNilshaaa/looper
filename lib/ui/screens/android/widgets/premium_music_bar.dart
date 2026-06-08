import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/screens/android/player/android_expanded_player.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/core/app_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/ui/widgets/scrolling_text.dart';

import 'premium_section.dart';

// Keeping the provider for future use but it won't be used by navbar now
final navbarBounceProvider = StateProvider<Offset>((ref) => Offset.zero);

class PremiumMusicBar extends ConsumerStatefulWidget {
  const PremiumMusicBar({super.key});

  @override
  ConsumerState<PremiumMusicBar> createState() => _PremiumMusicBarState();
}

class _PremiumMusicBarState extends ConsumerState<PremiumMusicBar> with TickerProviderStateMixin {
  late AnimationController _dragController;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _dragController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final song = ref.watch(playbackProvider.select((s) => s.currentSong));
    final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
    final settings = ref.watch(settingsProvider);
    final useBlur = settings.enableDynamicTheming;

    if (song == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _dragOffset += details.delta;
          });
        },
        onPanEnd: (details) {
          final dx = _dragOffset.dx;
          final dy = _dragOffset.dy;

          // Prioritize the direction with the largest displacement
          if (dy > 70 && dy.abs() > dx.abs()) {
            // Swipe down to clear/close
            HapticFeedback.heavyImpact();
            ref.read(playbackProvider.notifier).clearQueue();
          } else if (dy < -70 && dy.abs() > dx.abs()) {
            // Swipe up to expand
            _triggerHaptic();
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const AndroidExpandedPlayer(),
                transitionDuration: const Duration(milliseconds: 400),
                reverseTransitionDuration: const Duration(milliseconds: 400),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          } else if (dx.abs() > dy.abs()) {
            // Horizontal swipe for next/prev
            if (dx > 70) {
              _triggerHaptic();
              ref.read(playbackProvider.notifier).skipPrevious();
            } else if (dx < -70) {
              _triggerHaptic();
              ref.read(playbackProvider.notifier).skipNext();
            }
          }

          setState(() {
            _dragOffset = Offset.zero;
            _isDragging = false;
          });
        },
        onTapUp: (details) {
          if (_isDragging) return;
          
          final RenderBox box = context.findRenderObject() as RenderBox;
          final localX = details.localPosition.dx;
          final width = box.size.width;

          // If tapped on the right 20% of the bar (where play button is), toggle play
          if (localX > width * 0.75) {
            HapticFeedback.lightImpact();
            ref.read(playbackProvider.notifier).togglePlay();
          } else {
            // Otherwise open expanded player
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const AndroidExpandedPlayer(),
                transitionDuration: const Duration(milliseconds: 400),
                reverseTransitionDuration: const Duration(milliseconds: 400),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          }
        },
        child: TweenAnimationBuilder<Offset>(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: Offset.zero, end: _dragOffset),
          builder: (context, offset, child) {
            final double tiltX = (offset.dx / 100).clamp(-0.2, 0.2);
            final double tiltY = (offset.dy / 100).clamp(-0.1, 0.1);
            
            final matrix = Matrix4.identity();
            if (tiltX != 0 || tiltY != 0) {
              matrix.setEntry(3, 2, 0.001); // perspective
              matrix.rotateX(-tiltY);
              matrix.rotateY(tiltX);
              matrix.translate(offset.dx * 0.3, offset.dy * 0.3);
            }
            
            return Transform(
              transform: matrix,
              alignment: Alignment.center,
              child: child,
            );
          },
          child: 
         // Hero(
            //tag: 'music_bar_container',
           // child:
             SizedBox(
              height: 72,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Section: Song Info
                  PremiumSection(
                    flex: 8,
                    useBlur: useBlur,
                    keepSurfaceOnDisableBlur: true,
                    //forceBlur true,
                    useExpanded: true,
                    onTap: null, // Handled by parent GestureDetector
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(36),
                      bottomLeft: Radius.circular(36),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Hero(
                              tag: 'album_art',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    OptimizedImage(
                                      imagePath: song.artPath != null && !song.artPath!.startsWith('http') ? song.artPath : null,
                                      imageUrl: song.artPath != null && song.artPath!.startsWith('http') ? song.artPath : null,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned.fill(
                                      child: AnimatedOpacity(
                                        duration: const Duration(milliseconds: 300),
                                        opacity: isPlaying ? 1.0 : 0.0,
                                        child: Container(
                                          color: Colors.black.withValues(alpha: 0.4),
                                          child: Center(
                                            child: Image.asset(
                                              'assets/android_icons/Playing.gif',
                                              width: 24,
                                              height: 24,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Hero(
                                tag: 'song_title',
                                child: ScrollingText(
                                  text: song.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.ts,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              //const SizedBox(height: 4,),
                              Hero(
                                tag: 'song_artist',
                                child: ScrollingText(
                                  text: song.artist ?? 'Unknown Artist',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 16.ts,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Right Section: Play/Pause Button
                  PremiumSection(
                    flex: 2, 
                    useBlur: useBlur,
                    keepSurfaceOnDisableBlur: true,
                    //forceBlur true,
                    useExpanded: true,
                    onTap: null, // Handled by parent GestureDetector
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      topRight: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                    child: Center(
                      child: Hero(
                        tag: 'play_pause_icon',
                        child: Padding(
                          padding: const EdgeInsets.only(right: 2.0),
                          child: AnimatedScale(
                            scale:  1.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(end: isPlaying ? 1.0 : 0.0),
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
                    ),
                  ),
                ],
              ),
            ),
         // ),
        ),
      ),
    );
  }
}
  