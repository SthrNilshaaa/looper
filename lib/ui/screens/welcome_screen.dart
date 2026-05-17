import 'dart:io';
import 'dart:ui';
import 'package:looper_player/core/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:animate_gradient/animate_gradient.dart';
import '../../../l10n/app_localizations.dart';
import '../../features/library/presentation/library_notifier.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, // Eboney background
      body: Stack(
        children: [
          // Subtle vignette effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.white.withOpacity(0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minimalist Logo Container
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                            width: 1,
                          ),
                        ),
                        child: SizedBox(
                          height: 100.s,
                          width: 100.s,
                          child: SvgPicture.asset(
                            'assets/main_logo.svg',
                            fit: BoxFit.contain,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                            placeholderBuilder: (context) => const Icon(
                              Icons.music_note,
                              size: 50,
                              color: Colors.white10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),

                      // App Title - Ultra clean
                      Text(
                        l10n.appTitle.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32.ts,
                          fontWeight: FontWeight.w200, // Thinner for premium feel
                          letterSpacing: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Subtitle - Muted
                      Text(
                        "LOOPER PLAYER",
                        style: TextStyle(
                          fontSize: 12.ts,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.2),
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 80),

                      // Refined Glass Action Area
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white.withOpacity(0.05)),
                            bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.scanLibrary.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.ts,
                                color: Colors.white.withOpacity(0.5),
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 32),
                            _PremiumButton(
                              onPressed: () async {
                                if (Platform.isAndroid) {
                                  final status = await _requestPermissions();
                                  if (!status) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Storage permissions are required to scan your library',
                                          ),
                                        ),
                                      );
                                    }
                                    return;
                                  }
                                }

                                final String? path = await FilePicker.platform
                                    .getDirectoryPath();
                                if (path != null) {
                                  ref.read(libraryProvider.notifier).scanLibrary(path);
                                }
                              },
                              label: "INITIALIZE LIBRARY",
                              icon: LucideIcons.scan,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
      bool isGranted = await Permission.manageExternalStorage.request().isGranted;
      if (isGranted) return true;

      if (await _isAndroid13OrHigher()) {
        final status = await Permission.audio.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }

  Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    final audioStatus = await Permission.audio.status;
    if (audioStatus.isGranted || audioStatus.isLimited) return true;

    final request = await Permission.audio.request();
    return !request.isRestricted;
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  const _GlowOrb({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }
}

class _PremiumButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const _PremiumButton({
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 56.s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20.s),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.ts,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
