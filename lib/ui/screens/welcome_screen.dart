import 'dart:io';
import 'dart:ui';
import 'package:looper_player/core/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import '../../../l10n/app_localizations.dart';
import '../../features/library/presentation/library_notifier.dart';
import '../../features/settings/presentation/settings_notifier.dart';

enum WelcomeState { initial, scanning, noSongs }

// Provider to track if the user has manually pressed "GO START" to bypass the welcome screen.
// We only check the initial song list state to avoid automatically closing the screen while scanning!
final welcomeBypassedProvider = StateProvider<bool>((ref) {
  final initialSongsEmpty = ref.read(libraryProvider).songs.isEmpty;
  return !initialSongsEmpty;
});

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> with WidgetsBindingObserver {
  WelcomeState _currentState = WelcomeState.initial;
  String _scanStatusMessage = "Initializing scanner...";
  
  bool _permissionGranted = false; // true if standard audio/storage OR all files is granted
  bool _notificationGranted = false;
  bool _audioGranted = false;
  bool _allFilesGranted = false;
  bool _autoScanTriggered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionStatus();
    }
  }

  Future<void> _checkPermissionStatus() async {
    bool notif = false;
    bool aud = false;
    bool all = false;

    if (Platform.isAndroid) {
      notif = await Permission.notification.isGranted;
      all = await Permission.manageExternalStorage.isGranted;
      aud = (await Permission.audio.isGranted) || (await Permission.storage.isGranted);
    } else {
      notif = true;
      aud = true;
      all = true;
    }

    if (mounted) {
      setState(() {
        _notificationGranted = notif;
        _audioGranted = aud;
        _allFilesGranted = all;
        _permissionGranted = aud || all; // Sufficient to scan
      });
    }
  }

  Future<void> _requestNotificationPermission() async {
    HapticFeedback.lightImpact();
    await Permission.notification.request();
    await _checkPermissionStatus();
  }

  Future<void> _requestAudioPermission() async {
    HapticFeedback.lightImpact();
    await Permission.audio.request();
    await Permission.storage.request();
    await _checkPermissionStatus();
  }

  Future<void> _requestAllFilesPermission() async {
    HapticFeedback.lightImpact();
    await Permission.manageExternalStorage.request();
    await _checkPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Elegant animated-like glowing backgrounds
          Positioned(
            top: -100,
            right: -100,
            child: _GlowOrb(color: colorScheme.primary.withOpacity(0.12)),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: _GlowOrb(color: colorScheme.primary.withOpacity(0.08)),
          ),
          
          // Subtle vignette overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.white.withOpacity(0.001),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Layout Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeInOutCubic,
                    switchOutCurve: Curves.easeInOutCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.05),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildStateContent(colorScheme, l10n),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateContent(ColorScheme colorScheme, AppLocalizations l10n) {
    switch (_currentState) {
      case WelcomeState.scanning:
        return _buildScanningState(colorScheme);
      case WelcomeState.noSongs:
        return _buildNoSongsState(colorScheme);
      case WelcomeState.initial:
      default:
        return _buildInitialState(colorScheme, l10n);
    }
  }

  // State 1: Initial Premium Welcome State
  Widget _buildInitialState(ColorScheme colorScheme, AppLocalizations l10n) {
    final librarySongs = ref.watch(libraryProvider).songs;
    final settings = ref.watch(settingsProvider);

    return Column(
      key: const ValueKey('initial_state'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Brand logo container with glowing borders
        Container(
          padding: const EdgeInsets.all(28.0),
          child: SizedBox(
            height: 100.s,
            width: 200.s,
            child: SvgPicture.asset(
              'assets/main_logo.svg',
              fit: BoxFit.contain,
              placeholderBuilder: (context) => Icon(
                LucideIcons.music,
                size: 50.s,
                color: colorScheme.primary.withOpacity(0.4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Clean & Modern Title Typography
        Text(
          l10n.appTitle.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28.ts,
            fontWeight: FontWeight.w200,
            letterSpacing: 10,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "LOOPER PLAYER",
          style: TextStyle(
            fontSize: 11.ts,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary.withOpacity(0.6),
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 32),

        // Premium About Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 16.s,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    UiUtils.tr(context, "ABOUT LOOPER PLAYER", "लूपर प्लेयर के बारे में"),
                    style: TextStyle(
                      fontSize: 12.ts,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                UiUtils.tr(
                  context,
                  "Looper Player is a next-generation Music-OS built for premium offline audio playback. Features real-time dynamic lyrics generation, advanced audio session management with call mute handling, adaptive background theming, and multi-format music library support. Fully optimized for maximum battery efficiency.",
                  "लूपर प्लेयर एक अगली पीढ़ी का म्यूजिक-ओएस है जिसे प्रीमियम ऑफ़लाइन ऑडियो प्लेबैक के लिए बनाया गया है। इसमें रियल-टाइम डायनामिक बोल, कॉल म्यूट हैंडलिंग के साथ उन्नत ऑडियो सेशन प्रबंधन, एडेप्टिव बैकग्राउंड थीमिंग और मल्टी-फॉर्मेट म्यूजिक लाइब्रेरी शामिल है। इसे बैटरी दक्षता के लिए अनुकूलित किया गया है।"
                ),
                style: TextStyle(
                  fontSize: 13.ts,
                  height: 1.6,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Interactive Permission Checklist (Sequential Setup)
        if (Platform.isAndroid) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.shieldCheck,
                      size: 16.s,
                      color: Color(settings.accentColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      UiUtils.tr(context, "SYSTEM PERMISSION CHECKLIST", "सिस्टम अनुमति चेकलिस्ट"),
                      style: TextStyle(
                        fontSize: 12.ts,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 1. Notification Permission Row
                _buildPermissionRow(
                  title: UiUtils.tr(context, "NOTIFICATION ACCESS", "नोटिफिकेशन एक्सेस"),
                  description: UiUtils.tr(
                    context, 
                    "Required to show playback controls and active notification widgets in your system bar.",
                    "आपके सिस्टम बार में प्लेबैक कंट्रोल और एक्टिव नोटिफिकेशन विजेट दिखाने के लिए आवश्यक है।"
                  ),
                  isGranted: _notificationGranted,
                  onGrant: _requestNotificationPermission,
                  colorScheme: colorScheme,
                  accentColor: Color(settings.accentColor),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1, color: Colors.white10),
                ),
                
                // 2. Music & Audio Permission Row
                _buildPermissionRow(
                  title: UiUtils.tr(context, "MUSIC & AUDIO ACCESS", "म्यूजिक और ऑडियो एक्सेस"),
                  description: UiUtils.tr(
                    context,
                    "Required to discover and play standard offline audio tracks on your device memory.",
                    "आपके डिवाइस की मेमोरी में ऑफ़लाइन ऑडियो ट्रैक्स को खोजने और चलाने के लिए आवश्यक है।"
                  ),
                  isGranted: _audioGranted,
                  onGrant: _requestAudioPermission,
                  colorScheme: colorScheme,
                  accentColor: Color(settings.accentColor),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1, color: Colors.white10),
                ),
                
                // 3. All Files Permission Row (Highly recommended)
                _buildPermissionRow(
                  title: UiUtils.tr(context, "ALL FILES ACCESS (RECOMMENDED)", "सभी फाइलों का एक्सेस (अनुशंसित)"),
                  description: UiUtils.tr(
                    context,
                    "Highly recommended for professional scanning to locate songs in non-standard directories (Downloads, Telegram, custom folders).",
                    "डाउनलोड, टेलीग्राम और कस्टम फ़ोल्डर जैसी गैर-मानक निर्देशिकाओं में गाने खोजने के लिए अत्यधिक अनुशंसित है।"
                  ),
                  isGranted: _allFilesGranted,
                  onGrant: _requestAllFilesPermission,
                  colorScheme: colorScheme,
                  accentColor: Color(settings.accentColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],

        // Modern Action Button area
        Column(
          children: [
            // GO START Button (Colored when standard permission is granted, otherwise greyed)
            _PremiumButton(
              onPressed: _permissionGranted
                  ? () async {
                      if (ref.read(libraryProvider).songs.isNotEmpty) {
                        // Enter dashboard!
                        ref.read(welcomeBypassedProvider.notifier).state = true;
                      } else {
                        // Automatically scan first if database is empty
                        await _startStorageScanFlow();
                        if (ref.read(libraryProvider).songs.isNotEmpty) {
                          ref.read(welcomeBypassedProvider.notifier).state = true;
                        }
                      }
                    }
                  : null,
              label: UiUtils.tr(context, "GO START", "शुरू करें"),
              icon: LucideIcons.playCircle,
              gradientColors: _permissionGranted
                  ? [
                      Color(settings.accentColor),
                      Color(settings.accentColor).withOpacity(0.75),
                    ]
                  : [
                      Colors.grey.withOpacity(0.3),
                      Colors.grey.withOpacity(0.2),
                    ],
            ),
            const SizedBox(height: 24),

            // Scan Completion Status feedback
            if (_permissionGranted && librarySongs.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(settings.accentColor).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(settings.accentColor).withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.checkCircle2, color: Color(settings.accentColor), size: 18.s),
                    const SizedBox(width: 10),
                    Text(
                      UiUtils.tr(
                        context,
                        "SCAN COMPLETE: ${librarySongs.length} SONGS DETECTED!",
                        "स्कैन पूर्ण: ${librarySongs.length} गाने मिले!"
                      ),
                      style: TextStyle(
                        fontSize: 12.ts,
                        fontWeight: FontWeight.bold,
                        color: Color(settings.accentColor),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            TextButton.icon(
              onPressed: _permissionGranted ? _selectCustomFolder : null,
              icon: Icon(
                LucideIcons.folderSearch,
                size: 16.s,
                color: _permissionGranted ? Colors.white60 : Colors.white24,
              ),
              label: Text(
                UiUtils.tr(context, "SELECT SPECIFIC FOLDER", "विशिष्ट फ़ोल्डर चुनें"),
                style: TextStyle(
                  fontSize: 12.ts,
                  color: _permissionGranted ? Colors.white70 : Colors.white24,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPermissionRow({
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onGrant,
    required ColorScheme colorScheme,
    required Color accentColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2.0),
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: isGranted ? accentColor.withOpacity(0.12) : Colors.white.withOpacity(0.03),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isGranted ? LucideIcons.check : LucideIcons.shieldAlert,
            size: 16.s,
            color: isGranted ? accentColor : Colors.white60,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11.ts,
                  height: 1.4,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if (!isGranted)
          SizedBox(
            height: 30.s,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: accentColor.withOpacity(0.15),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 0.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: onGrant,
              child: Text(
                UiUtils.tr(context, "GRANT", "स्वीकृत करें"),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.ts,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              UiUtils.tr(context, "GRANTED", "स्वीकृत"),
              style: TextStyle(
                color: accentColor,
                fontSize: 11.ts,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  // State 2: Deep Scanning State
  Widget _buildScanningState(ColorScheme colorScheme) {
    final settings = ref.watch(settingsProvider);
    return Column(
      key: const ValueKey('scanning_state'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Custom interactive glowing spinner
        SizedBox(
          width: 250.s,
          height: 320.s,
          child: Lottie.asset(
            'assets/loading.json',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 48),
        Text(
          UiUtils.tr(context, "DEEP STORAGE SCAN IN PROGRESS...", "गहरा स्टोरेज स्कैन चल रहा है..."),
          style: TextStyle(
            fontSize: 16.ts,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            UiUtils.tr(
              context,
              "Scanning all folders and subfolders for audio files.",
              "ऑडियो फाइलों के लिए सभी फ़ोल्डर और सब-फ़ोल्डर को स्कैन किया जा रहा है।"
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.ts,
              color: Colors.white.withOpacity(0.4),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // State 3: User Information / Instructions State when No Songs are Found
  Widget _buildNoSongsState(ColorScheme colorScheme) {
    final settings = ref.watch(settingsProvider);
    return Column(
      key: const ValueKey('no_songs_state'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Informational Alert Icon
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amber.withOpacity(0.05),
            border: Border.all(
              color: Colors.amber.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Icon(
            LucideIcons.searchCode,
            size: 48.s,
            color: Colors.amber,
          ),
        ),
        const SizedBox(height: 24),

        Text(
          UiUtils.tr(context, "NO MUSIC DETECTED", "कोई संगीत फ़ाइल नहीं मिली"),
          style: TextStyle(
            fontSize: 18.ts,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          UiUtils.tr(
            context,
            "We couldn't find any supported audio files (MP3, FLAC, WAV, M4A, OGG) on your device storage.",
            "हमें आपके डिवाइस स्टोरेज पर कोई समर्थित ऑडियो फाइलें (MP3, FLAC, WAV, M4A, OGG) नहीं मिलीं।"
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.ts,
            color: Colors.white.withOpacity(0.4),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),

        // Custom Step-by-Step Instruction Cards
        _buildInstructionStep(
          stepNumber: "1",
          title: UiUtils.tr(context, "CONNECT DEVICE", "डिवाइस कनेक्ट करें"),
          description: UiUtils.tr(
            context,
            "Plug your phone or device into a personal computer using a standard USB data cable.",
            "यूएसबी डेटा केबल का उपयोग करके अपने फोन को कंप्यूटर से कनेक्ट करें।"
          ),
          icon: LucideIcons.usb,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 16),
        _buildInstructionStep(
          stepNumber: "2",
          title: UiUtils.tr(context, "TRANSFER MUSIC FILES", "संगीत फाइलें ट्रांसफर करें"),
          description: UiUtils.tr(
            context,
            "Copy your offline music files (supports .mp3, .flac, .m4a, .wav) directly into the standard 'Music' or 'Download' folder of your device.",
            "अपने गानों को फोन के 'Music' या 'Download' फोल्डर में कॉपी करें।"
          ),
          icon: LucideIcons.arrowDownToLine,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 16),
        _buildInstructionStep(
          stepNumber: "3",
          title: UiUtils.tr(context, "DOWNLOAD AUDIO DIRECTLY", "संगीत सीधे डाउनलोड करें"),
          description: UiUtils.tr(
            context,
            "Alternatively, download files directly using a web browser or other downloader utility on the device itself.",
            "या फिर वेब ब्राउज़र का उपयोग करके सीधे फोन में संगीत डाउनलोड करें।"
          ),
          icon: LucideIcons.chrome,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 48),

        // Quick Retry/Actions
        _PremiumButton(
          onPressed: _startStorageScanFlow,
          label: UiUtils.tr(context, "RESCAN STORAGE", "स्टोरेज दोबारा स्कैन करें"),
          icon: LucideIcons.refreshCw,
          gradientColors: [
            Color(settings.accentColor),
            Color(settings.accentColor).withOpacity(0.75),
          ],
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _currentState = WelcomeState.initial;
            });
          },
          child: Text(
            UiUtils.tr(context, "BACK TO MAIN VIEW", "मुख्य स्क्रीन पर जाएं"),
            style: TextStyle(
              fontSize: 12.ts,
              color: Colors.white60,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.015),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.03),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36.s,
            width: 36.s,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: 16.s,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "STEP $stepNumber: $title",
                  style: TextStyle(
                    fontSize: 11.ts,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.ts,
                    color: Colors.white.withOpacity(0.45),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Scan & Permission Flow Functions
  Future<void> _startStorageScanFlow() async {
    _autoScanTriggered = true;
    setState(() {
      _currentState = WelcomeState.scanning;
      _scanStatusMessage = "Checking system permissions...";
    });

    // Check again
    await _checkPermissionStatus();

    if (Platform.isAndroid && !_permissionGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(UiUtils.tr(context, 'Storage permissions are required to scan device memory.', 'डिवाइस मेमोरी को स्कैन करने के लिए स्टोरेज अनुमतियों की आवश्यकता है।')),
          ),
        );
        setState(() {
          _currentState = WelcomeState.initial;
        });
      }
      return;
    }

    setState(() {
      _scanStatusMessage = "Traversing standard device directories recursively...";
    });

    // Determine scan roots including all popular directories for maximum coverage
    final List<String> scanRoots = [];
    if (Platform.isLinux) {
      String defaultPath = '${Platform.environment['HOME']}/Music';
      try {
        final result = await Process.run('xdg-user-dir', ['MUSIC']);
        if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
          defaultPath = result.stdout.toString().trim();
        }
      } catch (_) {}
      scanRoots.add(defaultPath);
    } else if (Platform.isAndroid) {
      final List<String> commonPaths = [
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Documents',
        '/storage/emulated/0/Audiobooks',
        '/storage/emulated/0/Podcasts',
        '/storage/emulated/0/Recordings',
        '/storage/emulated/0/Ringtones',
        '/storage/emulated/0/Alarms',
        '/storage/emulated/0/Notifications',
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Pictures',
        '/storage/emulated/0/Movies',
      ];
      if (await Permission.manageExternalStorage.isGranted) {
        scanRoots.add('/storage/emulated/0');
      } else {
        scanRoots.addAll(commonPaths);
      }
      // Check for SD Card mount points
      try {
        final storageDir = Directory('/storage');
        if (await storageDir.exists()) {
          final List<FileSystemEntity> entities = await storageDir.list().toList();
          for (final entity in entities) {
            final name = p.context.basename(entity.path);
            if (name != 'emulated' && name != 'self' && name != 'knox-emulated' && !name.contains('-')) {
              if (await Permission.manageExternalStorage.isGranted) {
                scanRoots.add(entity.path);
              } else {
                scanRoots.add('${entity.path}/Music');
                scanRoots.add('${entity.path}/Download');
              }
            }
          }
        }
      } catch (_) {}
    }

    int totalSongsDiscovered = 0;

    // Run scans
    for (final path in scanRoots) {
      if (Directory(path).existsSync()) {
        setState(() {
          _scanStatusMessage = "Analyzing path: ${p.context.basename(path)}...";
        });
        final count = await ref.read(libraryProvider.notifier).scanLibrary(path);
        totalSongsDiscovered += count;
      }
    }

    if (totalSongsDiscovered == 0) {
      setState(() {
        _currentState = WelcomeState.noSongs;
      });
    } else {
      setState(() {
        _currentState = WelcomeState.initial;
      });
    }
  }

  // Choose Custom Folder Backup Function
  Future<void> _selectCustomFolder() async {
    await _checkPermissionStatus();
    if (Platform.isAndroid && !_permissionGranted) return;

    final String? path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      setState(() {
        _currentState = WelcomeState.scanning;
        _scanStatusMessage = "Scanning selected path: $path...";
      });

      final count = await ref.read(libraryProvider.notifier).scanLibrary(path);
      if (count == 0) {
        setState(() {
          _currentState = WelcomeState.noSongs;
        });
      } else {
        setState(() {
          _currentState = WelcomeState.initial;
        });
      }
    }
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  const _GlowOrb({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320.s,
      height: 320.s,
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
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final List<Color> gradientColors;

  const _PremiumButton({
    required this.onPressed,
    required this.label,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    return Container(
      width: double.infinity,
      height: 56.s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isEnabled 
              ? gradientColors 
              : [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isEnabled ? Colors.white : Colors.white30,
                size: 20.s,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15.ts,
                  fontWeight: FontWeight.bold,
                  color: isEnabled ? Colors.white : Colors.white30,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
