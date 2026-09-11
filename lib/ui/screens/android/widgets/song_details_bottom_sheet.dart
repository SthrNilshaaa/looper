import 'package:flutter/material.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:intl/intl.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/l10n/app_localizations.dart';

class SongDetailsBottomSheet extends StatelessWidget {
  final Song song;

  const SongDetailsBottomSheet({super.key, required this.song});

  String _formatDuration(int? ms) {
    if (ms == null) return 'Unknown';
    final d = Duration(milliseconds: ms);
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration:  BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.songDetails,
            style: AppFonts.jostStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _detailItem('Title', song.title),
          _detailItem('Artist', song.artist ?? 'Unknown'),
          _detailItem('Album', song.album ?? 'Unknown'),
          _detailItem('Duration', _formatDuration(song.duration)),
          _detailItem('Play Count', '${song.playCount} times'),
          if (song.lastPlayed != null)
            _detailItem(
              'Last Played',
              DateFormat('MMM dd, yyyy HH:mm').format(song.lastPlayed!),
            ),
          _detailItem('File Path', song.path),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.jostStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppFonts.jostStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
