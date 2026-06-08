import 'dart:io';
import 'package:flutter/material.dart';
import 'package:looper_player/ui/widgets/song_options_bottom_sheet.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/ui/screens/android/song/song_info_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:isar/isar.dart';
import '../widgets/premium_section.dart';
import '../widgets/song_details_bottom_sheet.dart';
import '../widgets/empty_library_view.dart';
import '../widgets/premium_loading_view.dart';

class AndroidHomeTab extends ConsumerStatefulWidget {
  const AndroidHomeTab({super.key});

  @override
  ConsumerState<AndroidHomeTab> createState() => _AndroidHomeTabState();
}

class _AndroidHomeTabState extends ConsumerState<AndroidHomeTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  int _currentQuickPickPage = 0;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _showSongOptions(BuildContext context, Song song) {
    showSongOptionsBottomSheet(context: context, ref: ref, song: song);
  }

  Widget _buildHorizontalSection({
    required String title,
    required String actionText,
    required VoidCallback onActionTap,
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    if (itemCount == 0) return const SizedBox.shrink();
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PremiumSection(
                  borderRadius: BorderRadius.circular(32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  height: 36,
                  useExpanded: false,
                  onTap: onActionTap,
                  useBlur: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        LucideIcons.arrowRight,
                        size: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: itemCount,
              itemBuilder: itemBuilder,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistItem(Artist artist, AppLocalizations l10n) {
    return Container(
      width: 110,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: () async {
          HapticFeedback.lightImpact();
          final songs = await DbService.isar.songs
              .filter()
              .artistEqualTo(artist.name)
              .findAll();
          ref
              .read(appNavigationProvider.notifier)
              .showCollection(
                title: artist.name,
                subtitle: l10n.artist,
                art: artist.artPath,
                imageUrl: artist.artistImageUrl,
                songs: songs,
              );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              backgroundImage: artist.artistImageUrl != null
                  ? FileImage(File(artist.artistImageUrl!))
                  : null,
              child: artist.artistImageUrl == null
                  ? const Icon(
                      LucideIcons.user,
                      size: 28,
                      color: Colors.white38,
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              artist.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumItem(Album album, AppLocalizations l10n) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: () async {
          HapticFeedback.lightImpact();
          final songs = await DbService.isar.songs
              .filter()
              .albumEqualTo(album.name)
              .findAll();
          ref
              .read(appNavigationProvider.notifier)
              .showCollection(
                title: album.name,
                subtitle: album.artist ?? l10n.unknownArtist,
                art: album.artPath,
                songs: songs,
              );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: OptimizedImage(
                  imagePath: album.artPath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              album.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              album.artist ?? l10n.unknownArtist,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreItem(
    String genre,
    List<Song> genreSongs,
    AppLocalizations l10n,
  ) {
    // Hash the genre string to produce a consistent vibrant color gradient
    final int hash = genre.hashCode;
    final double hue = (hash.abs() % 360).toDouble();
    final Color startColor = HSLColor.fromAHSL(1.0, hue, 0.70, 0.35).toColor();
    final Color endColor = HSLColor.fromAHSL(1.0, (hue + 45) % 360, 0.80, 0.18).toColor();

    // Get first song with art if available
    final firstSongWithArt = genreSongs.firstWhere(
      (s) => s.artPath != null,
      orElse: () => genreSongs.first,
    );

    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          ref
              .read(appNavigationProvider.notifier)
              .showCollection(
                title: genre,
                subtitle: l10n.genre,
                songs: genreSongs,
              );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Rotated Album Art in the bottom right corner
              if (firstSongWithArt.artPath != null)
                Positioned(
                  bottom: -12,
                  right: -12,
                  child: Transform.rotate(
                    angle: 0.25,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: OptimizedImage(
                          imagePath: firstSongWithArt.artPath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Positioned(
                  bottom: -10,
                  right: -10,
                  child: Transform.rotate(
                    angle: 0.25,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.music,
                        size: 28,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              
              // Genre info on the left side
              Positioned(
                left: 16,
                top: 16,
                bottom: 16,
                right: 56, // Leave room so text doesn't overlap the album art too much
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      genre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${genreSongs.length} ${l10n.songs}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryProvider);
    final currentSong = ref.watch(playbackProvider.select((s) => s.currentSong));
    final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    final genresMap = <String, List<Song>>{};
    for (var song in library.songs) {
      final genre = song.genre ?? l10n.unknown;
      genresMap.putIfAbsent(genre, () => []).add(song);
    }
    final genres = genresMap.keys.toList()..sort();

    if (library.isScanning && library.songs.isEmpty) {
      return const PremiumLoadingView();
    }

    if (library.songs.isEmpty) {
      return SafeArea(child: EmptyLibraryView(title: l10n.noSongsFound));
    }

    // Sort songs for Quick Picks (most played)
    final allSongs = List<Song>.from(library.songs);
    allSongs.sort((a, b) => b.playCount.compareTo(a.playCount));
    // Provide up to 18 songs for 3 pages of 6 items each
    final allQuickPicks = allSongs.take(18).toList();

    // Sort songs by date added (newest first)
    final dateAddedSongs = List<Song>.from(library.songs);
    dateAddedSongs.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

    final orderedSlivers = <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                useExpanded: false,
                useBlur: true,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(appNavigationProvider.notifier)
                      .setItem(NavItem.search);
                },
                child: const Icon(
                  LucideIcons.search,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              //const SizedBox(width: 4),
               Text(
                              "Looper Player",
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
                  ref
                      .read(appNavigationProvider.notifier)
                      .setItem(NavItem.settings);
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
      ),
    ];

    for (final section in settings.homeSectionOrder) {
      if (section == 'quick_picks') {
        orderedSlivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.quickPicks,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.todayMixForYou,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  PremiumSection(
                    borderRadius: BorderRadius.circular(32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    height: 40,
                    useExpanded: false,
                    useBlur: true,
                    onTap: () {
                      if (allQuickPicks.isNotEmpty) {
                        HapticFeedback.mediumImpact();
                        final shuffledPicks = List<Song>.from(allQuickPicks)
                          ..shuffle();
                        ref
                            .read(playbackProvider.notifier)
                            .setPlaylist(shuffledPicks, initialIndex: 0);
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.shuffle,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.play,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        orderedSlivers.add(
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = (constraints.maxWidth - 32).clamp(
                  0.0,
                  double.infinity,
                );
                final itemWidth = ((availableWidth - 16) / 3).clamp(
                  0.0,
                  double.infinity,
                );
                final gridHeight = ((itemWidth * 2) + 8).clamp(
                  8.0,
                  double.infinity,
                );

                final pageCount = (allQuickPicks.length / 6).ceil();
                final validPageCount = pageCount == 0 ? 1 : pageCount;

                return Column(
                  children: [
                    SizedBox(
                      height: gridHeight,
                      child: PageView.builder(
                        onPageChanged: (index) {
                          setState(() {
                            _currentQuickPickPage = index;
                          });
                        },
                        itemCount: validPageCount,
                        itemBuilder: (context, pageIndex) {
                          final startIndex = pageIndex * 6;
                          if (startIndex >= allQuickPicks.length &&
                              allQuickPicks.isNotEmpty) {
                            return const SizedBox();
                          }

                          final pageItems = allQuickPicks
                              .skip(startIndex)
                              .take(6)
                              .toList();

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: GridView.builder(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1.0,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                              itemCount: pageItems.length,
                                itemBuilder: (context, index) {
                                final song = pageItems[index];
                                final isCurrent =
                                    currentSong?.path ==
                                    song.path;

                                return GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(playbackProvider.notifier)
                                        .setPlaylist(
                                          allQuickPicks,
                                          initialIndex: startIndex + index,
                                        );
                                  },
                                  onLongPress: () {
                                    HapticFeedback.mediumImpact();
                                    _showSongOptions(context, song);
                                  },
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: OptimizedImage(
                                            imagePath: song.artPath,
                                            width: itemWidth,
                                            height: itemWidth,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withAlpha(204),
                                              ],
                                              stops: const [0.5, 1.0],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 8,
                                        bottom: 8,
                                        right: 8,
                                        child: Text(
                                          song.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: AnimatedOpacity(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          opacity:
                                              isCurrent &&
                                                  isPlaying
                                              ? 1.0
                                              : 0.0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 
                                                0.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'assets/android_icons/Playing.gif',
                                                width: 32,
                                                height: 32,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(validPageCount, (index) {
                        final isActive = _currentQuickPickPage == index;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : Colors.white24,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        );
        orderedSlivers.add(
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        );
      } else if (section == 'songs') {
        orderedSlivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.songs,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PremiumSection(
                    borderRadius: BorderRadius.circular(32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    height: 40,
                    useExpanded: false,
                    useBlur: true,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(appNavigationProvider.notifier)
                          .setItem(NavItem.songs);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.viewAll,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          LucideIcons.arrowRight,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        orderedSlivers.add(
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = dateAddedSongs[index];
                final isCurrent = currentSong?.path == song.path;

                return ListTile(
                  contentPadding: const EdgeInsets.only(
                    left: 16,
                    right: 4,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      children: [
                        OptimizedImage(
                          imagePath: song.artPath,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                        Positioned.fill(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: isCurrent && isPlaying
                                ? 1.0
                                : 0.0,
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
                  title: Text(
                    song.title,
                    style: TextStyle(
                      color: isCurrent
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    song.artist ?? l10n.unknown,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _showSongOptions(context, song);
                    },
                  ),
                  onTap: () {
                    ref
                        .read(playbackProvider.notifier)
                        .setPlaylist(dateAddedSongs, initialIndex: index);
                  },
                );
              },
              childCount: dateAddedSongs.length > 10
                  ? 10
                  : dateAddedSongs.length,
            ),
          ),
        );
        orderedSlivers.add(
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        );
      } else if (section == 'artists') {
        if (settings.showHomeArtists && library.artists.isNotEmpty) {
          orderedSlivers.add(
            _buildHorizontalSection(
              title: l10n.artists,
              actionText: l10n.viewAll,
              onActionTap: () {
                HapticFeedback.mediumImpact();
                ref
                    .read(appNavigationProvider.notifier)
                    .setItem(NavItem.artists);
              },
              itemCount: library.artists.length,
              itemBuilder: (context, index) {
                return _buildArtistItem(library.artists[index], l10n);
              },
            ),
          );
        }
      } else if (section == 'albums') {
        if (settings.showHomeAlbums && library.albums.isNotEmpty) {
          orderedSlivers.add(
            _buildHorizontalSection(
              title: l10n.albums,
              actionText: l10n.viewAll,
              onActionTap: () {
                HapticFeedback.mediumImpact();
                ref
                    .read(appNavigationProvider.notifier)
                    .setItem(NavItem.albums);
              },
              itemCount: library.albums.length,
              itemBuilder: (context, index) {
                return _buildAlbumItem(library.albums[index], l10n);
              },
            ),
          );
        }
      } else if (section == 'genres') {
        if (settings.showHomeGenres && genres.isNotEmpty) {
          orderedSlivers.add(
            _buildHorizontalSection(
              title: l10n.genres,
              actionText: l10n.viewAll,
              onActionTap: () {
                HapticFeedback.mediumImpact();
                ref
                    .read(appNavigationProvider.notifier)
                    .setItem(NavItem.genres);
              },
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                return _buildGenreItem(genre, genresMap[genre]!, l10n);
              },
            ),
          );
        }
      }
    }

    orderedSlivers.add(const SliverToBoxAdapter(child: SizedBox(height: 200)));

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: orderedSlivers,
      ),
    );
  }
}
