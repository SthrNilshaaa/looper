import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';

class AppBottomSheetContainer extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final bool showDragHandle;

  const AppBottomSheetContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    this.height,
    this.showDragHandle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final useBlur = settings.enableDynamicTheming && !settings.disableBlur;

    Widget body = Container(
      height: height,
      decoration: BoxDecoration(
        color: useBlur
            ? const Color.fromARGB(50, 0, 0, 0)
            : settings.darkTheme
                ? const Color.fromARGB(255, 0, 0, 0)
                : const Color(0xFF161613),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: padding,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDragHandle) ...[
              const SizedBox(height: 5),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (height != null)
              Expanded(child: child)
            else
              child,
          ],
        ),
      ),
    );

    if (useBlur) {
      return PremiumSection(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        useBlur: true,
        forceBlur: true,
        useExpanded: false,
        useCenter: false,
        child: body,
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: body,
    );
  }
}
