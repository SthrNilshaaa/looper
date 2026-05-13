import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:squiggly_slider/slider.dart';
import '../../features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandedPlayer extends ConsumerWidget {
  const ExpandedPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackProvider);
    final song = playback.currentSong;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (song == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.2),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.s, vertical: 16.s),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.chevronDown, color: Colors.white),
                      onPressed: () => ref.read(appNavigationProvider.notifier).setPlayerExpansion(false),
                    ),
                    Text(
                      'NOW PLAYING',
                      style: GoogleFonts.dmSans(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12.ts,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.moreVertical, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Album Art
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 48.s),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.s),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.s),
                      child: OptimizedImage(
                        imagePath: song.artPath,
                        fit: BoxFit.cover,
                        placeholder: Container(
                          color: Colors.white10,
                          child: Icon(
                            LucideIcons.music,
                            color: Colors.white24,
                            size: 80.s,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Title & Artist
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.s),
                child: Column(
                  children: [
                    Text(
                      song.title,
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 24.ts,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      song.artist ?? l10n.unknownArtist,
                      style: GoogleFonts.dmSans(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16.ts,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Progress Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.s),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        activeTrackColor: colorScheme.primary,
                        inactiveTrackColor: Colors.white10,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: SquigglySlider(
                        value: playback.duration.inMilliseconds > 0
                            ? (playback.position.inMilliseconds / playback.duration.inMilliseconds).clamp(0.0, 1.0)
                            : 0.0,
                        onChanged: (val) {
                          ref.read(playbackProvider.notifier).seek(playback.duration * val);
                        },
                        activeColor: colorScheme.primary,
                        inactiveColor: Colors.white10,
                        squiggleAmplitude: playback.isPlaying ? 2.0 : 0.0,
                        squiggleWavelength: 4.5,
                        squiggleSpeed: 0.08,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(playback.position),
                          style: TextStyle(color: Colors.white60, fontSize: 12.ts),
                        ),
                        Text(
                          _formatDuration(playback.duration),
                          style: TextStyle(color: Colors.white60, fontSize: 12.ts),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Controls
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.s),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        playback.isShuffle ? LucideIcons.shuffle : LucideIcons.shuffle,
                        color: playback.isShuffle ? colorScheme.primary : Colors.white60,
                        size: 24.s,
                      ),
                      onPressed: () => ref.read(playbackProvider.notifier).toggleShuffle(),
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.skipBack, color: Colors.white, size: 32.s),
                      onPressed: () => ref.read(playbackProvider.notifier).skipPrevious(),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(playbackProvider.notifier).togglePlay(),
                      child: Container(
                        width: 72.s,
                        height: 72.s,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          playback.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 40.s,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.skipForward, color: Colors.white, size: 32.s),
                      onPressed: () => ref.read(playbackProvider.notifier).skipNext(),
                    ),
                    IconButton(
                      icon: Icon(
                        playback.repeatMode == RepeatMode.one
                            ? LucideIcons.repeat1
                            : LucideIcons.repeat,
                        color: playback.repeatMode != RepeatMode.off
                            ? colorScheme.primary
                            : Colors.white60,
                        size: 24.s,
                      ),
                      onPressed: () =>
                          ref.read(playbackProvider.notifier).nextRepeatMode(),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Bottom Actions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.s, vertical: 32.s),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        song.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: song.isFavorite ? Colors.red : Colors.white60,
                        size: 24.s,
                      ),
                      onPressed: () => ref.read(playbackProvider.notifier).toggleFavorite(),
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.listMusic, color: Colors.white60, size: 24.s),
                      onPressed: () {
                        ref.read(appNavigationProvider.notifier).setPlayerExpansion(false);
                        ref.read(appNavigationProvider.notifier).setItem(NavItem.queue);
                      },
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.languages, color: Colors.white60, size: 24.s),
                      onPressed: () {
                        ref.read(appNavigationProvider.notifier).setPlayerExpansion(false);
                        ref.read(appNavigationProvider.notifier).setItem(NavItem.lyrics);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
