import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/core/app_icons.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'premium_section.dart';

class PremiumNavbar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PremiumNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accentColor = Color(settings.accentColor);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final useBlur = settings.enableDynamicTheming;
    // final useBlur = true;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 2, 16, 16 + bottomPadding),
      child: SizedBox(
        height: 72,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double gapSize = 6.s;

            final home = _NavItem(
              iconPath: AppIcons.home,
              label: 'Home',
              isSelected: currentIndex == 0,
              accentColor: accentColor,
            );

            final songs = _NavItem(
              iconPath: AppIcons.songs,
              label: 'Songs',
              isSelected: currentIndex == 1,
              accentColor: accentColor,
            );

            final library = _NavItem(
              iconPath: AppIcons.library,
              label: 'Library',
              isSelected: currentIndex == 2,
              accentColor: accentColor,
            );

            List<Widget> children;
            if (currentIndex == 0) {
              children = [
                PremiumSection(
                  flex: 3,
                  heroTag: 'nav_morph_1',
                  isSelected: true,
                  useBlur: useBlur,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap(0);
                  },
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36),
                    bottomLeft: Radius.circular(36),
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: home,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  width: gapSize,
                ),
                PremiumSection(
                  flex: 6,
                  heroTag: 'nav_morph_2',
                  isSelected: false,
                  showLeftBorder: true,
                  showShadow: false,
                  useBlur: useBlur,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    topRight: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onTap(1);
                          },
                          child: songs,
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onTap(2);
                          },
                          child: library,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            } else if (currentIndex == 1) {
              children = [
                PremiumSection(
                  flex: 3,
                  heroTag: 'nav_morph_1',
                  isSelected: false,
                  useBlur: useBlur,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap(0);
                  },
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36),
                    bottomLeft: Radius.circular(36),
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: home,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  width: gapSize,
                ),
                PremiumSection(
                  flex: 3,
                  heroTag: 'nav_morph_2',
                  isSelected: true,
                  useBlur: useBlur,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap(1);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: songs,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  width: gapSize,
                ),
                PremiumSection(
                  flex: 3,
                  heroTag: 'nav_morph_3',
                  isSelected: false,
                  useBlur: useBlur,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap(2);
                  },
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    topRight: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                  child: library,
                ),
              ];
            } else {
              children = [
                PremiumSection(
                  flex: 6,
                  heroTag: 'nav_morph_1',
                  isSelected: false,
                  showRightBorder: true,
                  showShadow: false,
                  useBlur: useBlur,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36),
                    bottomLeft: Radius.circular(36),
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onTap(0);
                          },
                          child: home,
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onTap(1);
                          },
                          child: songs,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  width: gapSize,
                ),
                PremiumSection(
                  flex: 3,
                  heroTag: 'nav_morph_2',
                  isSelected: true,
                  useBlur: useBlur,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap(2);
                  },
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    topRight: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                  child: library,
                ),
              ];
            }

            return Row(children: children);
          },
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isSelected;
  final Color accentColor;

  const _NavItem({
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
          transformAlignment: Alignment.center,
          child: SvgPicture.asset(
            iconPath,
            colorFilter: ColorFilter.mode(
              isSelected ? accentColor : Colors.white.withOpacity(0.4),
              BlendMode.srcIn,
            ),
            width: AppIcons.navbarIcon.s,
            height: AppIcons.navbarIcon.s,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              inherit: false,
              color: isSelected ? accentColor : Colors.white.withOpacity(0.4),
              fontSize: 13.ts,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.2,
            ),
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }
}
