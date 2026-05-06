import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/search/presentation/search_view.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';

class GlobalSearchBar extends ConsumerWidget {
  const GlobalSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDynamic = settings.enableDynamicTheming;
    final nav = ref.watch(appNavigationProvider);

    if (nav.activeItem == NavItem.lyrics) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        height: 52,
        width:MediaQuery.of(context).size.width/2.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: const Color.fromARGB(255, 53, 53, 53).withOpacity(isDynamic ? 0.3 : 0.1),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
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
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: isDynamic ? 10 : 0,
              sigmaY: isDynamic ? 10 : 0,
            ),
            child: TextField(
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).state = val;
                if (val.isNotEmpty) {
                  ref.read(appNavigationProvider.notifier).setItem(NavItem.search);
                }
              },
              decoration: InputDecoration(
                hintText: 'Search songs',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              
         prefixIcon: SizedBox(
  width: 60, // give enough space
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        LucideIcons.search,
        size: 20,
        color: Colors.white.withOpacity(0.7),
      ),
      SizedBox(width: 8),
      Container(
        width: 1,
        height: 20,
        color: Colors.white.withOpacity(0.3),
      ),
    ],
  ),
),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}
