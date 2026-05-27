import 'dart:ui';
import 'dart:io';
import 'package:looper_player/core/ui_utils.dart';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/core/navigation_provider.dart';
import '../../features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/ui/widgets/color_maper.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'premium_progress_bar.dart';

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
      onSeekStart: () => ref.read(playbackProvider.notifier).startScrubbing(),
      onSeekEnd: () => ref.read(playbackProvider.notifier).stopScrubbing(),
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
  final VoidCallback? onSeekStart;
  final VoidCallback? onSeekEnd;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onLyricsToggle;
  final VoidCallback onQueueToggle;
  final VoidCallback onMuteToggle;
  final bool isLyricsActive;
  final bool isQueueActive;
  final bool isDynamic;

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
    this.onSeekStart,
    this.onSeekEnd,
    required this.onVolumeChanged,
    required this.onLyricsToggle,
    required this.onQueueToggle,
    required this.onMuteToggle,
    this.isLyricsActive = false,
    this.isQueueActive = false,
    this.isDynamic = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 900;
        final bool isVeryNarrow = constraints.maxWidth < 600;

        return Container(
          height: 80.s,
          margin: Platform.isAndroid || Platform.isIOS
              ? EdgeInsets.zero
              : EdgeInsets.only(left: 48.s, right: 48.s, bottom: 32.sp, top: 0),
          decoration: BoxDecoration(
            color: isDynamic
                ? colorScheme.primary.withOpacity(0.04)
                : colorScheme.surfaceContainer,
            borderRadius: Platform.isAndroid || Platform.isIOS
                ? BorderRadius.zero
                : BorderRadius.circular(6),
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

                    _buildControls(context, colorScheme, isVeryNarrow),

                    const SizedBox(width: 12),

                    Expanded(
                      flex: isNarrow ? 4 : 6,
                        child: ExpressiveSlider(
                          position: position,
                          duration: duration,
                          isPlaying: isPlaying,
                          onSeek: onSeek,
                          onSeekStart: onSeekStart,
                          onSeekEnd: onSeekEnd,
                          color: colorScheme.primary,
                        ),
                    ),

                    if (!isVeryNarrow) ...[
                      const SizedBox(width: 24),
                      Container(
                        height: 40,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: Colors.white10,
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (!isNarrow) ...[
                      const SizedBox(width: 16),
                      _buildVolumeControl(context),
                      const SizedBox(width: 16),
                    ],

                    const Spacer(),

                    _buildActions(context, colorScheme, isVeryNarrow),
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
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: (isVeryNarrow ? 40 : 56).s,
          height: (isVeryNarrow ? 40 : 56).s,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: OptimizedImage(
            imagePath: artPath,
            borderRadius: BorderRadius.circular(6),
            fit: BoxFit.cover,
            placeholder: Icon(
              LucideIcons.music,
              color: Colors.white24,
              size: (isVeryNarrow ? 16 : 24).s,
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
                  fontSize: (isVeryNarrow ? 12 : 14).ts,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                artist,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: (isVeryNarrow ? 10 : 12).ts,
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
            width: 12,
            height: 12,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          tooltip: 'Previous',
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onPlayPause,
          child: Container(
            width: (isVeryNarrow ? 28 : 36).s,
            height: (isVeryNarrow ? 28 : 36).s,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: isPlaying
                ? Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: (isVeryNarrow ? 12 : 18).s,
                  )
                : Icon(
                    Icons.play_arrow_sharp,
                    color: Colors.white,
                    size: (isVeryNarrow ? 12 : 18).s,
                  ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: onNext,
          icon: SvgPicture.asset(
            'assets/music_bar_Icons/next_track.svg',
            width: 12,
            height: 12,
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
        if (!isVeryNarrow)
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
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: Platform.isLinux ? 4.0 : 6.0,
                trackShape: const EqualHeightTrackShape(),
                thumbShape: LineThumbShape(
                  thumbHeight: Platform.isLinux ? 8 : 0,
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
        const SizedBox(width: 4),
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
        const SizedBox(width: 4),
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

class EqualHeightTrackShape extends RoundedRectSliderTrackShape {
  const EqualHeightTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      additionalActiveTrackHeight: 0,
    );
  }
}
