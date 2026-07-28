import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';

class FolderPickerHelper {
  static void showManualPathDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F1F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Enter Folder Path Manually',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'If the system directory picker is not opening, type or paste the full directory path below:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '/home/username/Music',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final path = controller.text.trim();
                if (path.isNotEmpty) {
                  ref.read(libraryProvider.notifier).scanLibrary(path);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> pickFolder(BuildContext context, WidgetRef ref) async {
    try {
      final String? path = await FilePicker.platform.getDirectoryPath();
      if (path != null) {
        ref.read(libraryProvider.notifier).scanLibrary(path);
      } else {
        if (context.mounted) {
          // Clear any current snackbars to avoid queuing them
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1E1E1E),
              duration: const Duration(seconds: 4), // Explicit auto-hide duration
              content: const Text('Folder picker closed', style: TextStyle(color: Colors.white)),
              action: SnackBarAction(
                textColor: Colors.deepPurpleAccent,
                label: 'Enter Manually',
                onPressed: () => showManualPathDialog(context, ref),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error using native directory picker: $e');
      if (context.mounted) {
        showManualPathDialog(context, ref);
      }
    }
  }
}
