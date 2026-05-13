import 'dart:io';
import 'package:looper_player/core/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../l10n/app_localizations.dart';
import '../../features/library/presentation/library_notifier.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF070707),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Area
                  SizedBox(
                    height: 180.s,
                    width: 400.s,
                    child: SvgPicture.asset(
                      'assets/main_logo.svg',
                      fit: BoxFit.contain,
                      placeholderBuilder: (context) => const Icon(
                        Icons.music_note,
                        size: 80,
                        color: Colors.white24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    l10n.appTitle.toUpperCase(),
                    style: TextStyle(
                      fontSize: 48.ts,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 2,
                    width: 60,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      l10n.scanLibrary,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.ts,
                        color: Colors.white.withOpacity(0.5),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 56),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (Platform.isAndroid) {
                        // Request permissions first
                        final status = await _requestPermissions();
                        if (!status) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Storage permissions are required to scan your library'),
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
                    icon: const Icon(LucideIcons.folder, color: Colors.white),
                    label: Text(
                      l10n.scanLibrary,
                      style: TextStyle(
                        fontSize: 16.ts,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.s,
                        vertical: 16.s,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+)
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
