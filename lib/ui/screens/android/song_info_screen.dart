import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/data/audio_analyzer.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:intl/intl.dart';
import 'package:looper_player/core/ui_utils.dart';

class SongInfoScreen extends ConsumerStatefulWidget {
  final Song song;

  const SongInfoScreen({super.key, required this.song});

  @override
  ConsumerState<SongInfoScreen> createState() => _SongInfoScreenState();
}

class _SongInfoScreenState extends ConsumerState<SongInfoScreen> {
  late Future<AudioAnalysis?> _analysisFuture;

  @override
  void initState() {
    super.initState();
    _analysisFuture = AudioAnalyzer.analyze(widget.song.path);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blurred Background
          if (settings.enableDynamicTheming && widget.song.artPath != null)
            Positioned.fill(
              child: Stack(
                children: [
                  Image.file(
                    File(widget.song.artPath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    cacheWidth: 100,
                    cacheHeight: 100,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                    child: Container(
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(color: Theme.of(context).colorScheme.surface),

          SafeArea(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(context),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroSection(primaryColor),
                        const SizedBox(height: 32),
                        
                        FutureBuilder<AudioAnalysis?>(
                          future: _analysisFuture,
                          builder: (context, snapshot) {
                            final analysis = snapshot.data;
                            final isLoading = snapshot.connectionState == ConnectionState.waiting;

                            return Column(
                              children: [
                                _buildInfoSection(
                                  title: 'Audio Quality',
                                  icon: LucideIcons.activity,
                                  isLoading: isLoading,
                                  items: [
                                    _InfoItem('Codec', analysis?.codec ?? '...'),
                                    _InfoItem('Format', analysis?.container ?? '...'),
                                    _InfoItem('Sample Rate', analysis?.sampleRateKhz ?? '...'),
                                    _InfoItem('Bit Depth', analysis?.bitDepth ?? '...'),
                                    _InfoItem('Bitrate', analysis?.bitrateKbps ?? '...'),
                                    _InfoItem('Channels', analysis?.channels.toString() ?? '...'),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _buildInfoSection(
                                  title: 'File Information',
                                  icon: LucideIcons.fileText,
                                  isLoading: false,
                                  items: [
                                    _InfoItem('Size', _formatFileSize(widget.song.path)),
                                    _InfoItem('Path', widget.song.path, isLong: true),
                                    _InfoItem('Date Added', DateFormat('MMM dd, yyyy').format(widget.song.dateAdded)),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _buildInfoSection(
                                  title: 'Metadata Details',
                                  icon: LucideIcons.tags,
                                  isLoading: isLoading,
                                  items: [
                                    _InfoItem('ISRC', analysis?.isrc ?? 'N/A'),
                                    _InfoItem('Label', analysis?.label ?? 'N/A'),
                                    _InfoItem('Composer', analysis?.composer ?? 'N/A'),
                                    _InfoItem('Copyright', analysis?.copyright ?? 'N/A', isLong: true),
                                    _InfoItem('Encoder', analysis?.encoder ?? 'N/A'),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Song Details',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Color primaryColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: OptimizedImage(
              imagePath: widget.song.artPath,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.song.title,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                widget.song.artist ?? 'Unknown Artist',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.song.album ?? 'Unknown Album',
                style: GoogleFonts.plusJakartaSans(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<_InfoItem> items,
    bool isLoading = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.02),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
              children: [
                Icon(icon, color: Colors.white.withOpacity(0.5), size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.value,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    maxLines: item.isLong ? 3 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )),
            ],
          ),
        ),
      ),
    ),
  );
}

  String _formatFileSize(String path) {
    try {
      final file = File(path);
      final bytes = file.lengthSync();
      if (bytes <= 0) return "0 B";
      const suffixes = ["B", "KB", "MB", "GB", "TB"];
      var i = (math.log(bytes) / math.log(1024)).floor();
      return ((bytes / math.pow(1024, i)).toStringAsFixed(1)) + ' ' + suffixes[i];
    } catch (_) {
      return "N/A";
    }
  }
}

class _InfoItem {
  final String label;
  final String value;
  final bool isLong;

  _InfoItem(this.label, this.value, {this.isLong = false});
}
