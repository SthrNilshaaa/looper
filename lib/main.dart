import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_performance_optimizer/flutter_performance_optimizer.dart';

import 'core/db_service.dart';
import 'core/app_fonts.dart';
import 'ui/screens/home_screen.dart';

import 'package:metadata_god/metadata_god.dart';
import 'package:looper_player/core/theme_provider.dart';
import 'package:looper_player/ui/widgets/keyboard_handler.dart';
import 'package:looper_player/core/providers.dart';
import 'package:local_notifier/local_notifier.dart';

final dbInitializerProvider = FutureProvider<void>((ref) async {
  await DbService.init();
  await ref.read(settingsProvider.notifier).initialization;
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

  // Initialize MpvAudioKit
  MpvAudioKit.ensureInitialized();

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
    final isInitialized = dbInit.asData != null;

    final themeState = isInitialized ? ref.watch(themeProvider) : null;
    final settings = isInitialized ? ref.watch(settingsProvider) : null;

    Widget buildHome() {
      return dbInit.when(
        data: (_) => KeyboardHandler(
          key: ValueKey('${settings!.useNewFont}_${settings.customFontFamily}_${settings.customFontWeightDelta}_${settings.useNewFontLyrics}_${settings.customFontFamilyLyrics}_${settings.customFontWeightLyricsDelta}'),
          child: const HomeScreen(),
        ),
        loading: () => const PreAppLoadingScreenContent(),
        error: (err, stack) => Scaffold(
          body: Center(
            child: Text('Error initializing database: $err'),
          ),
        ),
      );
    }

    // Build the MaterialApp using either dynamic/loaded settings or fallback values.
    final ColorScheme colorScheme = (themeState != null)
        ? themeState.colorScheme
        : ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark);

    final bool useNewFont = settings?.useNewFont ?? false;
    final String customFontFamily = settings?.customFontFamily ?? '';
    final int customFontWeightDelta = settings?.customFontWeightDelta ?? 0;
    final String language = settings?.language ?? '';

    final String fontFamily = useNewFont ? (customFontFamily.isEmpty ? 'Jost' : customFontFamily) : 'DM Sans';

    final textTheme = AppFonts.adjustTextTheme(
      ThemeData.dark().textTheme.apply(
        fontFamily: fontFamily,
        displayColor: Colors.white,
        bodyColor: Colors.white70,
      ),
      useNewFont ? customFontWeightDelta : 0,
    );

    Widget buildMaterialApp(ColorScheme colorScheme) {
      return MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'Looper Player',
        color: Colors.transparent,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          fontFamily: fontFamily,
          textTheme: textTheme,
        ),
        themeAnimationDuration: const Duration(milliseconds: 1000),
        themeAnimationCurve: Curves.easeInOut,
        locale: language.isEmpty || language == 'system' ? null : Locale(language),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          final showPerformanceOptimizer = settings?.showPerformanceOptimizer ?? false;
          return PerformanceOptimizer(
            enabled: showPerformanceOptimizer,
            showDashboard: showPerformanceOptimizer,
            enableInReleaseMode: true,
            child: child!,
          );
        },
        home: buildHome(),
      );
    }

    if (settings == null || !settings.enableDynamicTheming) {
      return buildMaterialApp(colorScheme);
    }

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return buildMaterialApp(colorScheme);
      },
    );
  }
}

class PreAppLoadingScreenContent extends StatelessWidget {
  const PreAppLoadingScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F0F0C),
      body: SizedBox.shrink(),
    );
  }
}
