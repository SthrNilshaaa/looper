import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../lyrics_notifier.dart';
import '../playback_notifier.dart';
import '../overlay_service.dart';

class OverlayLyricsWidget extends ConsumerStatefulWidget {
  const OverlayLyricsWidget({super.key});

  @override
  ConsumerState<OverlayLyricsWidget> createState() =>
      _OverlayLyricsWidgetState();
}

class _OverlayLyricsWidgetState extends ConsumerState<OverlayLyricsWidget> {
  @override
  Widget build(BuildContext context) {
    // Only rebuild when the parsed lines change
    final lines = ref.watch(
      lyricsProvider.select((state) => state.parsedLines),
    );

    return GestureDetector(
      onPanStart: (details) {
        windowManager.startDragging();
      },
      onDoubleTap: () {
        ref.read(overlayServiceProvider).toggleOverlay();
      },
      child: Container(
        color: Colors.black.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Stack(
          children: [
            Center(
              child: Consumer(
                builder: (context, ref, child) {
                  // Optimization: only rebuild when the current line index changes
                  final lineIndex = ref.watch(
                    playbackProvider.select((s) {
                      if (lines.isEmpty) return -1;
                      return lines.indexWhere(
                        (line) =>
                            s.position >= line.startTime &&
                            s.position < line.endTime,
                      );
                    }),
                  );

                  String currentLine = "Looper Player";
                  String nextLine = "";

                  if (lineIndex != -1) {
                    currentLine = lines[lineIndex].text;
                    if (lineIndex + 1 < lines.length) {
                      nextLine = lines[lineIndex + 1].text;
                    }
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentLine,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (nextLine.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          nextLine,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      LucideIcons.x,
                      color: Colors.white54,
                      size: 20,
                    ),
                    onPressed: () {
                      ref.read(overlayServiceProvider).toggleOverlay();
                    },
                    hoverColor: Colors.white10,
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            // Resize handle on the bottom right
            Positioned(
              bottom: -5,
              right: -5,
              child: GestureDetector(
                onPanStart: (details) {
                  windowManager.startResizing(ResizeEdge.bottomRight);
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeDownRight,
                  child: Container(
                    width: 20,
                    height: 20,
                    color: Colors.transparent,
                    child: const Icon(
                      Icons.keyboard_arrow_right,
                      size: 14,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
