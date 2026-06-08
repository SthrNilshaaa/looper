import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/app_icons.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/core/ui_utils.dart';
import '../widgets/premium_section.dart';
import '../widgets/empty_library_view.dart';
import '../widgets/premium_loading_view.dart';

class AndroidSongsTab extends ConsumerStatefulWidget {
  const AndroidSongsTab({super.key});

  @override
  ConsumerState<AndroidSongsTab> createState() => _AndroidSongsTabState();
}

class _AndroidSongsTabState extends ConsumerState<AndroidSongsTab> {
  late final ScrollController _scrollController;
  bool _isButtonVisible = true;
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final currentOffset = _scrollController.offset;
    if (currentOffset <= 0) {
      if (!_isButtonVisible) {
        setState(() {
          _isButtonVisible = true;
        });
      }
    } else if (currentOffset > _lastOffset && currentOffset > 50) {
      if (_isButtonVisible) {
        setState(() {
          _isButtonVisible = false;
        });
      }
    } else if (currentOffset < _lastOffset) {
      if (!_isButtonVisible) {
        setState(() {
          _isButtonVisible = true;
        });
      }
    }
    _lastOffset = currentOffset;
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryProvider);
    final settings = ref.watch(settingsProvider);
    final song = ref.watch(playbackProvider.select((s) => s.currentSong));
    final l10n = AppLocalizations.of(context)!;
    
    if (library.isScanning && library.songs.isEmpty) {
      return const PremiumLoadingView();
    }

    return library.songs.isEmpty
        ? EmptyLibraryView(
            title: l10n.noSongsFound,
          )
        : Container(
            color: (settings.enableDynamicTheming || settings.keepBackgroundGradient)
                ? Colors.transparent
                : Theme.of(context).colorScheme.surface,
            child: Stack(
              children: [
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             PremiumSection(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(32),
                                    bottomLeft: Radius.circular(32),
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                  width: 48,
                                  height: 48,
                                  useBlur: true,
                                  useExpanded: false,
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    ref.read(appNavigationProvider.notifier).setItem(NavItem.search);
                                  },
                                  child: const Icon(
                                    LucideIcons.search,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                Text(
                                  l10n.allSongs,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                PremiumSection(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    topRight: Radius.circular(32),
                                    bottomRight: Radius.circular(32),
                                  ),
                                  width: 48,
                                  height: 48,
                                  useExpanded: false,
                                  useBlur: true,
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    ref.read(appNavigationProvider.notifier).setItem(NavItem.settings);
                                  },
                                  child: const Icon(
                                    LucideIcons.settings,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                          ],
                        ),
                      ),
                      // Thin divider below the header
                      Container(
                        height: 0.5,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SongsList(
                          songs: library.songs,
                          controller: _scrollController,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 300),
                    offset: _isButtonVisible ? Offset.zero : const Offset(0, 2),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _isButtonVisible ? 1.0 : 0.0,
                      child: AnimatedPadding(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.only(bottom: song != null ? 200 : 120, right: 40),
                        child: PremiumSection(
                          width: 48,
                          height: 48,
                          borderRadius: BorderRadius.circular(24),
                          useBlur: true,
                          useExpanded: false,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            final songs = library.songs;
                            if (songs.isNotEmpty) {
                              final randomSongList = List<Song>.from(songs)..shuffle();
                              ref.read(playbackProvider.notifier).setPlaylist(randomSongList, initialIndex: 0);
                            }
                          },
                          child: const Icon(LucideIcons.shuffle, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
