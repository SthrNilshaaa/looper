import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';

import 'core/db_service.dart';
import 'ui/screens/home_screen.dart';

import 'package:metadata_god/metadata_god.dart';
import 'package:looper_player/core/theme_provider.dart';
import 'package:looper_player/ui/widgets/keyboard_handler.dart';
import 'package:looper_player/core/providers.dart';
import 'package:local_notifier/local_notifier.dart';

void main(List<String> args) async {
  final String? initialFile = args.isNotEmpty ? args.first : null;
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize LocalNotifier
  await localNotifier.setup(appName: 'Looper Player');

  // Initialize MetadataGod
  MetadataGod.initialize();

  // Initialize MediaKit
  MediaKit.ensureInitialized();

  // Initialize Database
  await DbService.init();

  // Initialize Window Manager
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1300, 700),
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Looper Player',
    // fullScreen: true,


  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

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
    final themeState = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);

    Widget buildMaterialApp(ColorScheme colorScheme) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Looper Player',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
        ),
        themeAnimationDuration: const Duration(milliseconds: 1000),
        themeAnimationCurve: Curves.easeInOut,
        locale: Locale(settings.language.isEmpty ? 'en' : settings.language),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('hi')],
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
