import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

class AndroidSongsTab extends ConsumerWidget {
  const AndroidSongsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final settings = ref.watch(settingsProvider);
    final playbackState = ref.watch(playbackProvider);
    final song = playbackState.currentSong;
    
    if (library.isScanning && library.songs.isEmpty) {
      return const PremiumLoadingView();
    }

    return library.songs.isEmpty
        ? EmptyLibraryView(
            title: UiUtils.tr(context, 'No songs found', 'कोई गाना नहीं मिला'),
          )
        : Scaffold(
            backgroundColor: settings.enableDynamicTheming
                ? Colors.transparent
                : Theme.of(context).colorScheme.surface,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          UiUtils.tr(context, 'All Songs', 'सभी गाने'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PremiumSection(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                              width: 44,
                              height: 44,
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
                            const SizedBox(width: 4),
                            PremiumSection(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              width: 44,
                              height: 44,
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
                      ],
                    ),
                  ),
                  Expanded(child: SongsList(songs: library.songs)),
                ],
              ),
            ),
          );
  }
}
