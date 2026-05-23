import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'premium_section.dart';

class EmptyLibraryView extends ConsumerWidget {
  final String title;
  const EmptyLibraryView({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final settings = ref.watch(settingsProvider);
    final isScanning = library.isScanning;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: PremiumSection(
          borderRadius: BorderRadius.circular(24),
          useBlur: true,
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon or scanning animation
              if (isScanning)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(settings.accentColor).withOpacity(0.06),
                  ),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(settings.accentColor)),
                      strokeWidth: 3,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.02),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.04),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    LucideIcons.music,
                    size: 48,
                    color: Color(settings.accentColor).withOpacity(0.8),
                  ),
                ),
              const SizedBox(height: 24),

              // Title
              Text(
                isScanning
                    ? UiUtils.tr(context, "SCANNING STORAGE...", "स्टोरेज स्कैन किया जा रहा है...")
                    : title.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                isScanning
                    ? UiUtils.tr(
                        context,
                        "Traversing directory trees to discover audio tracks. Please hold on...",
                        "ऑडियो ट्रैक्स खोजने के लिए डायरेक्टरी स्कैन की जा रही है। कृपया प्रतीक्षा करें..."
                      )
                    : UiUtils.tr(
                        context,
                        "We couldn't find any supported music files in your library. Add folders or run a search scan.",
                        "हमें आपकी लाइब्रेरी में कोई समर्थित संगीत फ़ाइल नहीं मिली। फ़ोल्डर जोड़ें या स्कैन करें।"
                      ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.4),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),

              // Actions
              if (!isScanning) ...[
                // Primary Action: Scan Storage
                _EmptyActionButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    ref.read(libraryProvider.notifier).scanSavedFolders();
                  },
                  label: UiUtils.tr(context, "SCAN FOR MUSIC", "संगीत के लिए स्कैन करें"),
                  icon: LucideIcons.searchCode,
                  isPrimary: true,
                  accentColor: Color(settings.accentColor),
                ),
                const SizedBox(height: 12),
                // Secondary Action: Select Folder
                _EmptyActionButton(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    final String? path = await FilePicker.platform.getDirectoryPath();
                    if (path != null) {
                      ref.read(libraryProvider.notifier).scanLibrary(path);
                    }
                  },
                  label: UiUtils.tr(context, "SELECT CUSTOM FOLDER", "कस्टम फ़ोल्डर चुनें"),
                  icon: LucideIcons.folderPlus,
                  isPrimary: false,
                  accentColor: Color(settings.accentColor),
                ),
              ] else ...[
                // Loading indicator auxiliary status
                Text(
                  UiUtils.tr(context, "Scanning in background...", "पृष्ठभूमि में स्कैन हो रहा है..."),
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final bool isPrimary;
  final Color accentColor;

  const _EmptyActionButton({
    required this.onPressed,
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: isPrimary
            ? LinearGradient(
                colors: [accentColor, accentColor.withOpacity(0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPrimary ? null : Colors.white.withOpacity(0.03),
        border: isPrimary
            ? null
            : Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.black : Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? Colors.black : Colors.white,
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
