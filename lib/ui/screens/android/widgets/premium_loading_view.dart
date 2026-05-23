import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PremiumLoadingView extends ConsumerStatefulWidget {
  final String? message;
  const PremiumLoadingView({super.key, this.message});

  @override
  ConsumerState<PremiumLoadingView> createState() => _PremiumLoadingViewState();
}

class _PremiumLoadingViewState extends ConsumerState<PremiumLoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _loadingPhase = 0;

  final List<String> _loadingMessages = [
    "INTERROGATING AUDIO STORAGE...",
    "REFRESHING MUSIC ENGINE...",
    "EXTRACTING COUSTIC DATA...",
    "OPTIMIZING PLAYBACK MEMORY...",
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Rotate messages for interactive high-fidelity feedback
    _rotatePhase();
  }

  void _rotatePhase() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        setState(() {
          _loadingPhase = (_loadingPhase + 1) % _loadingMessages.length;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final accentColor = Color(settings.accentColor);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sonic Wave / Rotating Ring visualizer
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulse Ring 1
                          Container(
                            width: 100 + (30 * math.sin(_controller.value * 2 * math.pi)),
                            height: 100 + (30 * math.sin(_controller.value * 2 * math.pi)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accentColor.withOpacity(0.12 * (1 - _controller.value)),
                                width: 2,
                              ),
                            ),
                          ),
                          // Pulse Ring 2
                          Container(
                            width: 80 + (40 * math.cos(_controller.value * 2 * math.pi)),
                            height: 80 + (40 * math.cos(_controller.value * 2 * math.pi)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accentColor.withOpacity(0.18 * _controller.value),
                                width: 1.5,
                              ),
                            ),
                          ),
                          // Main Rotating Segment Ring
                          Transform.rotate(
                            angle: _controller.value * 2 * math.pi,
                            child: SizedBox(
                              width: 86,
                              height: 86,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                value: 0.38,
                                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                              ),
                            ),
                          ),
                          // Center Rotating Core Icon
                          Transform.rotate(
                            angle: -_controller.value * 2 * math.pi,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.08),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: accentColor.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  LucideIcons.loader,
                                  color: accentColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 36),

                // Main Loading Text
                Text(
                  widget.message ?? UiUtils.tr(context, "LOADING MUSIC LIBRARY", "संगीत लाइब्रेरी लोड हो रही है"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Dynamic Status Text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    UiUtils.tr(
                      context,
                      _loadingMessages[_loadingPhase],
                      "कृपया प्रतीक्षा करें...",
                    ),
                    key: ValueKey<int>(_loadingPhase),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.35),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
