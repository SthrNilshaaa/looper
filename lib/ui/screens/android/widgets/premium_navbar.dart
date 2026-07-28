import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/core/app_icons.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'premium_section.dart';
import 'package:looper_player/core/ui_calculations.dart';

class PremiumNavbar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  static final GlobalKey _homeKey = GlobalKey(debugLabel: 'nav_home');
  static final GlobalKey _songsKey = GlobalKey(debugLabel: 'nav_songs');
  static final GlobalKey _libraryKey = GlobalKey(debugLabel: 'nav_library');

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
    final l10n = AppLocalizations.of(context)!;
   
    

    return RepaintBoundary(
      child: Container(
        padding: UiCalculations.getNavbarPadding(bottomPadding),
        child: SizedBox(
          height: 72,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double gapSize = 6.s;

            final home = _NavItem(
              key: _homeKey,
              iconPath: AppIcons.home,
              label: l10n.home,
              isSelected: currentIndex == 0,
              accentColor: accentColor,
            );

            final songs = _NavItem(
              key: _songsKey,
              iconPath: AppIcons.songs,
              label: l10n.songs,
              isSelected: currentIndex == 1,
              accentColor: accentColor,
            );

            final library = _NavItem(
              key: _libraryKey,
              iconPath: AppIcons.library,
              label: l10n.library,
              isSelected: currentIndex == 2,
              accentColor: accentColor,
            );

            List<Widget> children;
            if (currentIndex == 0) {
              children = [
                PremiumSection(
                  flex: 3,
                  heroTag: 'nav_morph_1',
                  //  useblur true,
                  isSelected: true,
                   useBlur: useBlur,
                  keepSurfaceOnDisableBlur: true,
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
                  // useblur true,
                  isSelected: false,
                  showLeftBorder: true,
                  showShadow: false,
                   useBlur: useBlur,
                  keepSurfaceOnDisableBlur: true,
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
                          child: Container(
                            height: double.infinity,
                            alignment: Alignment.center,
                            child: songs,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onTap(2);
                          },
                          child: Container(
                            height: double.infinity,
                            alignment: Alignment.center,
                            child: library,
                          ),
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
                //  useblur true,
                  isSelected: false,
                   useBlur: useBlur,
                  keepSurfaceOnDisableBlur: true,
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
                  // use/////blur true,
                  isSelected: true,
                   useBlur: useBlur,
                  keepSurfaceOnDisableBlur: true,
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
                   //useblur true,
                  isSelected: false,
                   useBlur: useBlur,
                  keepSurfaceOnDisableBlur: true,
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
                 //useblur true,
                  isSelected: false,
                 
                  showRightBorder: true,
                  showShadow: false,
                  useBlur: useBlur,
                  keepSurfaceOnDisableBlur: true,
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
                          child: Container(
                            height: double.infinity,
                            alignment: Alignment.center,
                            child: home,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onTap(1);
                          },
                          child: Container(
                            height: double.infinity,
                            alignment: Alignment.center,
                            child: songs,
                          ),
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

                  // useBlur: true,
                  heroTag: 'nav_morph_2',
                  isSelected: true,
                   useBlur: useBlur,
                  keepSurfaceOnDisableBlur: true,
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
    super.key,
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = Colors.white.withOpacity(0.4);
    final targetColor = isSelected ? accentColor : inactiveColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedScale(
          scale: isSelected ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: targetColor),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (context, color, child) {
              return SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(
                  color ?? inactiveColor,
                  BlendMode.srcIn,
                ),
                width: AppIcons.navbarIcon.s,
                height: AppIcons.navbarIcon.s,
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            style: AppFonts.jostStyle(
              textStyle: const TextStyle(inherit: false),
              color: targetColor,
              fontSize: 18.ts,
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
