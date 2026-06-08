import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_performance_optimizer/flutter_performance_optimizer.dart';

import 'core/db_service.dart';
import 'ui/screens/home_screen.dart';

import 'package:metadata_god/metadata_god.dart';
import 'package:looper_player/core/theme_provider.dart';
import 'package:looper_player/ui/widgets/keyboard_handler.dart';
import 'package:looper_player/core/providers.dart';
import 'package:local_notifier/local_notifier.dart';
import 'core/ui_utils.dart';

final dbInitializerProvider = FutureProvider<void>((ref) async {
  await DbService.init();
});

void main(List<String> args) async {
  final String? initialFile = args.isNotEmpty ? args.first : null;
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize LocalNotifier
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await localNotifier.setup(appName: 'Looper Player');
  }

  // Initialize MetadataGod
  MetadataGod.initialize();

  // Initialize MediaKit
  MediaKit.ensureInitialized();

  // Initialize Window Manager
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1150, 700),
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      title: 'Looper Player',
      backgroundColor: Colors.transparent,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (e) {
    debugPrint('Error setting high refresh rate: $e');
  }

  runApp(
    ProviderScope(
      overrides: [startupFileProvider.overrideWithValue(initialFile)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbInit = ref.watch(dbInitializerProvider);

    return dbInit.when(
      data: (_) => const MainApp(),
      loading: () => const PreAppLoadingScreen(),
      error: (err, stack) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Center(
            child: Text('Error initializing database: $err'),
          ),
        ),
      ),
    );
  }
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);

    Widget buildMaterialApp(ColorScheme colorScheme) {
      return MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'Looper Player',
        color: Colors.transparent,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          textTheme: GoogleFonts.dmSansTextTheme(
            ThemeData.dark().textTheme.apply(
              displayColor: Colors.white,
              bodyColor: Colors.white70,
            ),
          ),
        ),
        themeAnimationDuration: const Duration(milliseconds: 1000),
        themeAnimationCurve: Curves.easeInOut,
        locale: settings.language.isEmpty || settings.language == 'system' ? null : Locale(settings.language),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          return PerformanceOptimizer(
            enabled: settings.showPerformanceOptimizer,
            showDashboard: settings.showPerformanceOptimizer,
            enableInReleaseMode: true,
            child: child!,
          );
        },
        home: const KeyboardHandler(child: HomeScreen()),
      );
    }

    if (!settings.enableDynamicTheming) {
      return buildMaterialApp(themeState.colorScheme);
    }

    // When dynamic theming is enabled, we use the extracted album colors
    // We can also wrap in DynamicColorBuilder if we want system fallback
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        // If themeState.isDynamic is false (no song playing), we could fallback to system
        return buildMaterialApp(themeState.colorScheme);
      },
    );
  }
}

class PreAppLoadingScreen extends StatelessWidget {
  const PreAppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: const Color(0xFF0F0F0C),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 300,
                    height: 250,
                    child: Lottie.asset(
                      'assets/loading.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'LOOPER PLAYER',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Initializing System...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.35),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
