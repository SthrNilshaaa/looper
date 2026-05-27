import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

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
      duration: const Duration(seconds: 4),
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
                // Sonic Wave / Rotating SVG loader animation
                SizedBox(
                  width: 250.s,
                  height: 320.s,
                  child: Lottie.asset(
                    'assets/loading.json',
                    fit: BoxFit.contain,
                  ),
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
