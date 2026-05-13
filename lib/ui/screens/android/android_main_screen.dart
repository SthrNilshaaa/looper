import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:looper_player/ui/screens/home_screen.dart'; // for Sidebar
import 'android_home_tab.dart';
import 'android_search_tab.dart';
import 'android_library_tab.dart';
import 'android_expanded_player.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';

class AndroidMainScreen extends ConsumerStatefulWidget {
  const AndroidMainScreen({super.key});

  @override
  ConsumerState<AndroidMainScreen> createState() => _AndroidMainScreenState();
}

class _AndroidMainScreenState extends ConsumerState<AndroidMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const AndroidHomeTab(),
    const AndroidSearchTab(),
    const AndroidLibraryTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final playback = ref.watch(playbackProvider);
    final song = playback.currentSong;

    return Scaffold(
      backgroundColor: Colors.black, // Dark theme base from image
      drawer: Drawer(
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Sidebar(l10n: l10n),
        ),
      ),
      body: Stack(
        children: [
          _tabs[_currentIndex],

          // Mini Player
          if (song != null)
            Positioned(
              bottom: 0,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  // Navigate to expanded player
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AndroidExpandedPlayer(),
                    ),
                  );
                },
                child: Container(
                  height: 64,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E), // Dark gray
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: OptimizedImage(
                            imagePath: song.artPath,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              song.artist ?? 'Unknown Artist',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          playback.isPlaying
                              ? LucideIcons.pause
                              : LucideIcons.play,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          ref.read(playbackProvider.notifier).togglePlay();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(32),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.library),
              label: 'Library',
            ),
          ],
        ),
      ),
    );
  }
}
