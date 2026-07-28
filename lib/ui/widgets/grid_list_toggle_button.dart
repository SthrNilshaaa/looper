import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final isGridViewProvider = StateProvider<bool>((ref) => true);

class GridListToggleButton extends ConsumerWidget {
  const GridListToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGrid = ref.watch(isGridViewProvider);

    return IconButton(
      icon: Icon(
        isGrid ? LucideIcons.layoutGrid : LucideIcons.list,
        color: Colors.white70,
        size: 20,
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        ref.read(isGridViewProvider.notifier).state = !isGrid;
      },
    );
  }
}
