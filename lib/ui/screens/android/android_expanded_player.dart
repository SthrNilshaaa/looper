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
import 'widgets/premium_section.dart';
import 'android_lyrics_screen.dart';
import 'song_info_screen.dart';
import 'package:looper_player/ui/widgets/scrolling_text.dart';
import 'package:looper_player/features/playback/presentation/lyrics_notifier.dart';
import 'package:looper_player/features/playback/domain/lyric_models.dart';
import 'package:google_fonts/google_fonts.dart';

class AndroidExpandedPlayer extends ConsumerWidget {
  const AndroidExpandedPlayer({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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

    final settings = ref.watch(settingsProvider);
    final useBlur = settings.enableDynamicTheming;

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
              Positioned.fill(
                child: RepaintBoundary(
                  child: Image.file(
                    File(song.artPath!),
                    fit: BoxFit.cover,
                    cacheWidth: 100, // Tiny resolution is enough for blur
                    cacheHeight: 100,
                  ),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ),
            ] else ...[
              Positioned.fill(
                child: Container(color: Theme.of(context).colorScheme.surface),
              ),
            ],
            SafeArea(
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  children: [
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          PremiumSection(
                            borderRadius: BorderRadius.circular(32),
                            width: 48,
                            showShadow: false,
                            height: 48,
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
                          const Text(
                            'Now Playing',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          PremiumSection(
                            borderRadius: BorderRadius.circular(32),
                            width: 48,
                            height: 48,
                            useExpanded: false,
                            showShadow: false,
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
                            Consumer(
                              builder: (context, ref, child) {
                                final lyricsState = ref.watch(lyricsProvider);
                                final position = ref.watch(playbackProvider.select((s) => s.position));
                                
                                if (lyricsState.parsedLines.isEmpty) return const SizedBox(height: 80);
                                
                                final currentLine = lyricsState.parsedLines.firstWhere(
                                  (l) => position >= l.startTime && position < l.endTime,
                                  orElse: () => LyricLine(startTime: Duration.zero, endTime: Duration.zero, text: ""),
                                );
                                
                                return Container(
                                  height: 80,
                                  alignment: Alignment.bottomLeft,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.0, 0.2),
                                            end: Offset.zero,
                                          ).animate(CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOutCubic,
                                          )),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: currentLine.text.isEmpty 
                                      ? const SizedBox(height: 80)
                                      : Hero(
                                          tag: 'active_lyric_line',
                                          child: Material(
                                            type: MaterialType.transparency,
                                            child: Text(
                                              currentLine.text,
                                              key: ValueKey(currentLine.startTime),
                                              textAlign: TextAlign.left,
                                              style: GoogleFonts.dmSans(
                                                color: Theme.of(context).colorScheme.primary,
                                                fontSize: 24,
                                                fontWeight: FontWeight.w500,
                                                decoration: TextDecoration.none,
                                                shadows: const [
                                                  Shadow(
                                                    blurRadius: 8,
                                                    color: Colors.black,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => _showLyrics(context),
                              onDoubleTapDown: (details) {
                                final screenWidth = MediaQuery.of(context).size.width;
                                if (details.globalPosition.dx < screenWidth / 2) {
                                  // Seek backward
                                  ref.read(playbackProvider.notifier).seekRelative(-10);
                                } else {
                                  // Seek forward
                                  ref.read(playbackProvider.notifier).seekRelative(10);
                                }
                              },
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Hero(
                                  tag: 'album_art',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: OptimizedImage(
                                      imagePath: song.artPath,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
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
                                              style: TextStyle.lerp(
                                                fromStyle,
                                                toStyle,
                                                animation.value,
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
                                              style: TextStyle.lerp(
                                                fromStyle,
                                                toStyle,
                                                animation.value,
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
                          PremiumSection(
                            borderRadius: BorderRadius.circular(32),
                            width: 56,
                            height: 56,
                            useExpanded: false,
                            showShadow: false,
                            useBlur: useBlur,
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

                    const SizedBox(height: 24),

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
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                width: AppIcons.expandedPlayerMainControl.s,
                                height: AppIcons.expandedPlayerMainControl.s,
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
                            heroTag: 'nav_morph_4',
                            height: 64,
                            useBlur: useBlur,
                            showShadow: false,
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

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
