import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:one_player/l10n/app_localizations.dart';
import 'package:one_player/features/settings/presentation/settings_notifier.dart';

import 'core/db_service.dart';
import 'ui/screens/home_screen.dart';

import 'package:metadata_god/metadata_god.dart';
import 'package:one_player/core/theme_provider.dart';
import 'package:one_player/ui/widgets/keyboard_handler.dart';
import 'package:one_player/core/providers.dart';

void main(List<String> args) async {
  final String? initialFile = args.isNotEmpty ? args.first : null;
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize MetadataGod
  MetadataGod.initialize();
  
  // Initialize MediaKit
  MediaKit.ensureInitialized();
  
  // Initialize Database
  await DbService.init();
  
  // Initialize Window Manager
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Aspen',
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    ProviderScope(
      overrides: [
        startupFileProvider.overrideWithValue(initialFile),
      ],
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aspen',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: themeState.colorScheme,
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      locale: Locale(settings.language),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
      ],
      home: const KeyboardHandler(child: HomeScreen()),
    );
  }
}
