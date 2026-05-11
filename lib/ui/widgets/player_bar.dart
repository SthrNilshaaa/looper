import 'dart:ui';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:squiggly_slider/slider.dart';
import '../../features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/ui/widgets/color_maper.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerBar extends ConsumerWidget {
  const PlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackProvider);
    final song = playback.currentSong;
    if (song == null) return const SizedBox.shrink();

    return _PremiumPlayerBar(
      title: song.title,
      artist: song.artist ?? AppLocalizations.of(context)!.unknownArtist,
      artPath: song.artPath,
      position: playback.position,
      duration: playback.duration,
      isPlaying: playback.isPlaying,
      isShuffle: playback.isShuffle,
      repeatMode: playback.repeatMode,
      volume: playback.volume,
      onPlayPause: () => ref.read(playbackProvider.notifier).togglePlay(),
      onNext: () => ref.read(playbackProvider.notifier).skipNext(),
      onPrevious: () => ref.read(playbackProvider.notifier).skipPrevious(),
      onShuffle: () => ref.read(playbackProvider.notifier).toggleShuffle(),
      onRepeat: () => ref.read(playbackProvider.notifier).nextRepeatMode(),
      onSeek: (pos) => ref.read(playbackProvider.notifier).seek(pos),
      onVolumeChanged: (vol) =>
          ref.read(playbackProvider.notifier).setVolume(vol),
      onLyricsToggle: () =>
          ref.read(appNavigationProvider.notifier).toggleItem(NavItem.lyrics),
      onQueueToggle: () =>
          ref.read(appNavigationProvider.notifier).toggleItem(NavItem.queue),
      onMuteToggle: () => ref.read(playbackProvider.notifier).toggleMute(),
      onFavoriteToggle: () =>
          ref.read(playbackProvider.notifier).toggleFavorite(),
      isFavorite: song.isFavorite,
      isLoading: playback.isLoading,
      isLyricsActive:
          ref.watch(appNavigationProvider).activeItem == NavItem.lyrics,
      isQueueActive:
          ref.watch(appNavigationProvider).activeItem == NavItem.queue,
      isDynamic: ref.watch(settingsProvider).enableDynamicTheming,
    );
  }
}

class _PremiumPlayerBar extends StatelessWidget {
  final String title;
  final String artist;
  final String? artPath;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isShuffle;
  final bool isFavorite;
  final RepeatMode repeatMode;
  final double volume;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;
  final VoidCallback onFavoriteToggle;
  final ValueChanged<Duration> onSeek;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onLyricsToggle;
  final VoidCallback onQueueToggle;
  final VoidCallback onMuteToggle;
  final bool isLyricsActive;
  final bool isQueueActive;
  final bool isDynamic;
  final bool isLoading;

  const _PremiumPlayerBar({
    required this.title,
    required this.artist,
    this.artPath,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isShuffle,
    required this.isFavorite,
    required this.repeatMode,
    required this.volume,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onShuffle,
    required this.onRepeat,
    required this.onFavoriteToggle,
    required this.onSeek,
    required this.onVolumeChanged,
    required this.onLyricsToggle,
    required this.onQueueToggle,
    required this.onMuteToggle,
    this.isLyricsActive = false,
    this.isQueueActive = false,
    this.isDynamic = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLarge = constraints.maxWidth < 1100;
        final bool isNarrow = constraints.maxWidth < 900;
        final bool isVeryNarrow = constraints.maxWidth < 600;

        return Container(
          height: 80,
          margin: const EdgeInsets.only(
            left: 48,
            right: 48,
            bottom: 32,
            top: 0,
          ),
          decoration: BoxDecoration(
            color: isDynamic
                ? colorScheme.primary.withOpacity(0.04)
                // : Colors.white.withOpacity(0.04),
                : Color(0xFF0E0E0E),
            borderRadius: BorderRadius.circular(6),
            // border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 24,
                spreadRadius: -4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Row(
                  children: [
                    //Container(color:Colors.red,width: 30,height: 30),
                    // Left: Album Art + Info
                    Expanded(
                      flex: isVeryNarrow ? 3 : 4,
                      child: _buildSongInfo(context, isVeryNarrow),
                    ),

                    if (!isVeryNarrow)
                      Container(
                        height: 40,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: Colors.white10,
                      ),

                    // Center: Playback Controls
                    _buildControls(context, colorScheme, isVeryNarrow),

                    const SizedBox(width: 12),

                    // Middle-Right: Animated Progress Bar
                    Expanded(
                      flex: isNarrow
                          ? 4
                          : 6, // Adjusted to balance with song info
                      child: _ExpressiveSlider(
                        position: position,
                        duration: duration,
                        isPlaying: isPlaying,
                        onSeek: onSeek,
                        color: colorScheme.primary,
                      ),
                    ),

                    if (!isVeryNarrow) ...[
                      SizedBox(width: 24),
                      Container(
                        height: 40,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: Colors.white10,
                      ),
                      SizedBox(width: 12),
                    ],
                    if (!isNarrow) ...[
                      Flexible(flex: 1, child: SizedBox(width: 24)),
                      // Right: Volume
                      Flexible(flex: 2, child: _buildVolumeControl(context)),
                      SizedBox(width: 24),
                    ],

                    // Far Right: Actions
                    if (!isNarrow) Spacer(),
                    if (isLarge) Spacer(),

                    _buildActions(context, colorScheme, isVeryNarrow),
                    // Container(color:Colors.red,height: 100,width: 50,)
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSongInfo(BuildContext context, bool isVeryNarrow) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isVeryNarrow ? 40 : 56,
          height: isVeryNarrow ? 40 : 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            //color: Colors.white.withOpacity(0.05),
            boxShadow: [
              // BoxShadow(
              //   color: Colors.black.withOpacity(0.2),
              //   blurRadius: 8,
              //   offset: const Offset(0, 4),
              // ),
            ],
          ),
          child: OptimizedImage(
            imagePath: artPath,
            borderRadius: BorderRadius.circular(6),
            fit: BoxFit.cover,
            placeholder: Icon(
              LucideIcons.music,
              color: Colors.white24,
              size: isVeryNarrow ? 16 : 24,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: isVeryNarrow ? 12 : 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                artist,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: isVeryNarrow ? 10 : 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(
    BuildContext context,
    ColorScheme colorScheme,
    bool isVeryNarrow,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: SvgPicture.asset(
            'assets/music_bar_Icons/prev_track.svg',
            width: isVeryNarrow ? 12 : 12,
            height: isVeryNarrow ? 12 : 12,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          tooltip: 'Previous',
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onPlayPause,
          child: Container(
            width: isVeryNarrow ? 28 : 36,
            height: isVeryNarrow ? 28 : 36,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isPlaying
                        ? Icon(
                            Icons.pause,
                            key: const ValueKey('pause'),
                            color: Colors.white,
                            size: isVeryNarrow ? 12 : 18,
                          )
                        : Icon(
                            Icons.play_arrow_sharp,
                            key: const ValueKey('play'),
                            color: Colors.white,
                            size: isVeryNarrow ? 12 : 18,
                          ),
                  ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: onNext,
          icon: SvgPicture.asset(
            'assets/music_bar_Icons/next_track.svg',
            width: isVeryNarrow ? 12 : 12,
            height: isVeryNarrow ? 12 : 12,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          tooltip: 'Next',
        ),
        if (!isVeryNarrow)
          Container(
            height: 40,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.white10,
          ),

        if (!isVeryNarrow) ...[
          const SizedBox(width: 12),
          IconButton(
            onPressed: onShuffle,
            icon: SvgPicture.asset(
              'assets/music_bar_Icons/shuffle.svg',
              width: 12,
              height: 12,
              colorFilter: ColorFilter.mode(
                isShuffle ? colorScheme.primary : Colors.white38,
                BlendMode.srcIn,
              ),
            ),
            tooltip: 'Shuffle',
          ),
        ],
        //const SizedBox(width: 8),
        if (!isVeryNarrow)
          // SizedBox(width: 8),
          IconButton(
            onPressed: onRepeat,
            icon: SvgPicture.asset(
              repeatMode == RepeatMode.one
                  ? 'assets/music_bar_Icons/repeat_1.svg'
                  : 'assets/music_bar_Icons/repeat.svg',
              width: 12,
              height: 12,
              colorFilter: repeatMode == RepeatMode.one
                  ? null
                  : ColorFilter.mode(
                      repeatMode == RepeatMode.all
                          ? Colors.white
                          : Colors.white38,
                      BlendMode.srcIn,
                    ),
              colorMapper: repeatMode == RepeatMode.one
                  ? AccentColorMapper(colorScheme.primary)
                  : null,
            ),
            tooltip: 'Repeat',
          ),
      ],
    );
  }

  Widget _buildVolumeControl(BuildContext context) {
    return ClipRect(
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onMuteToggle,
            icon: SvgPicture.asset(
              volume == 0
                  ? 'assets/music_bar_Icons/mute.svg'
                  : 'assets/music_bar_Icons/volume.svg',
              width: 12,
              height: 12,
              colorFilter: ColorFilter.mode(
                volume == 0 ? Colors.white38 : Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  trackShape: const RoundedRectSliderTrackShape(),
                  //  RectangularSliderTrackShape(

                  // ),
                  thumbShape: const _LineThumbShape(
                    thumbHeight: 0,
                    thumbWidth: 3,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  thumbColor: Colors.white,
                ),
                child: Slider(value: volume, onChanged: onVolumeChanged),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    ColorScheme colorScheme,
    bool isVeryNarrow,
  ) {
    return Row(
      children: [
        if (!isVeryNarrow)
          IconButton(
            icon: SvgPicture.asset(
              isFavorite
                  ? 'assets/music_bar_Icons/liked.svg'
                  : 'assets/music_bar_Icons/like.svg',
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                isFavorite ? Colors.red : Colors.white54,
                BlendMode.srcIn,
              ),
            ),
            onPressed: onFavoriteToggle,
            tooltip: 'Favorite',
          ),
        SizedBox(width: 4),
        IconButton(
          icon: SvgPicture.asset(
            'assets/music_bar_Icons/lyrics.svg',
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(
              isLyricsActive ? colorScheme.primary : Colors.white54,
              BlendMode.srcIn,
            ),
          ),
          onPressed: onLyricsToggle,
          tooltip: 'Lyrics',
        ),
        SizedBox(width: 4),
        IconButton(
          icon: Icon(
            LucideIcons.listMusic,
            size: 16,
            color: isQueueActive ? colorScheme.primary : Colors.white54,
          ),
          onPressed: onQueueToggle,
          tooltip: 'Queue',
        ),
      ],
    );
  }
}

class _ExpressiveSlider extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final ValueChanged<Duration> onSeek;
  final Color color;

  const _ExpressiveSlider({
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.onSeek,
    required this.color,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildAnimatedDuration(String duration, bool isRightAligned) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: isRightAligned
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: duration.characters.map((char) {
        return SizedBox(
          width: char == ':' ? 4 : 8,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final isIn = (child as Text).data == char;
              return ClipRect(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0.0, isIn ? 0.5 : -0.5),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
              );
            },
            child: Text(
              char,
              key: ValueKey(char),
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 12,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValidDuration =
        duration.inMilliseconds > 0 && position.inMilliseconds >= 0;

    final double progress = hasValidDuration
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool showTimestamps = constraints.maxWidth > 150;

        return Row(
          children: [
            if (showTimestamps) ...[
              SizedBox(
                width: 45,
                child: _buildAnimatedDuration(_formatDuration(position), true),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 1.8,
                  activeTrackColor: color,
                  inactiveTrackColor: Colors.white10,
                  thumbShape: const _LineThumbShape(
                    thumbHeight: 12,
                    thumbWidth: 3,
                  ),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: SquigglySlider(
                  value: progress,
                  onChanged: (val) {
                    onSeek(duration * val);
                    if (val == 0.0 || val == 1.0) {
                      HapticFeedback.lightImpact();
                    }
                  },
                  activeColor: color,
                  inactiveColor: Colors.white10,
                  squiggleAmplitude: isPlaying ? 2.0 : 0.0,
                  squiggleWavelength: 4.5,
                  squiggleSpeed: 0.08,
                  useLineThumb: false,
                ),
              ),
            ),
            if (showTimestamps) ...[
              const SizedBox(width: 12),
              SizedBox(
                width: 45,
                child: _buildAnimatedDuration(
                  hasValidDuration ? _formatDuration(duration) : '--:--',
                  false,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _LineThumbShape extends SliderComponentShape {
  final double thumbHeight;
  final double thumbWidth;

  const _LineThumbShape({this.thumbHeight = 12, this.thumbWidth = 2});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbWidth, thumbHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: thumbWidth, height: thumbHeight),
        Radius.circular(thumbWidth / 2),
      ),
      paint,
    );
  }
}
