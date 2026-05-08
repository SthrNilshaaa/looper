import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/providers.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/search/presentation/search_view.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';

class GlobalSearchBar extends ConsumerStatefulWidget {
  const GlobalSearchBar({super.key});

  @override
  ConsumerState<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends ConsumerState<GlobalSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    // Unfocus the search bar to return to music control mode
    FocusManager.instance.primaryFocus?.unfocus();

    // If we are currently in the search view, exit to home
    if (ref.read(appNavigationProvider).activeItem == NavItem.search) {
      ref.read(appNavigationProvider.notifier).setItem(NavItem.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDynamic = settings.enableDynamicTheming;
    final nav = ref.watch(appNavigationProvider);
    final query = ref.watch(searchQueryProvider);

    // Sync controller if provider changes from elsewhere (though unlikely)
    if (_controller.text != query) {
      _controller.text = query;
    }

    if (nav.activeItem == NavItem.lyrics) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 55,

        //width: MediaQuery.of(context).size.width*0.1,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color.fromARGB(
            255,
            53,
            53,
            53,
          ).withOpacity(isDynamic ? 0.3 : 0.1),
          border: Border.all(color: Colors.white10.withOpacity(0.1), width: 1),
          boxShadow: [
            if (!isDynamic)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: isDynamic ? 10 : 0,
              sigmaY: isDynamic ? 10 : 0,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: TextField(
                focusNode: ref.watch(searchFocusNodeProvider),
                controller: _controller,
                onChanged: (val) {
                  ref.read(searchQueryProvider.notifier).state = val;
                  if (val.isNotEmpty && nav.activeItem != NavItem.search) {
                    ref
                        .read(appNavigationProvider.notifier)
                        .setItem(NavItem.search);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search songs',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  prefixIcon: SizedBox(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.search,
                          size: 20,
                          color: Colors.white,
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          color: Colors.white10,
                        ),
                      ],
                    ),
                  ),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            LucideIcons.x,
                            size: 18,
                            color: Colors.white70,
                          ),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
