import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';

class LanguageTile extends ConsumerWidget {
  const LanguageTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(LucideIcons.languages, color: Colors.white70),
      title: Text(
        l10n.language,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: DropdownButton<String>(
        value: settings.language,
        dropdownColor: const Color(0xFF1A1A1A),
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(
            value: '',
            child: Text(
              'System Default',
              style: TextStyle(color: Colors.white),
            ),
          ),
          DropdownMenuItem(
            value: 'en',
            child: Text('English', style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: 'es',
            child: Text('Español', style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: 'fr',
            child: Text('Français', style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: 'de',
            child: Text('Deutsch', style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: 'pt',
            child: Text('Português', style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: 'ru',
            child: Text('Русский', style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: 'it',
            child: Text('Italiano', style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: 'zh',
            child: Text('中文', style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: 'ja',
            child: Text('日本語', style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: 'ko',
            child: Text('한국어', style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: 'ar',
            child: Text('العربية', style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: 'tr',
            child: Text('Türkçe', style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: 'nl',
            child: Text(
              'Nederlands',
              style: TextStyle(color: Colors.white),
            ),
          ),
          DropdownMenuItem(
            value: 'hi',
            child: Text('हिन्दी', style: TextStyle(color: Colors.white)),
          ),
        ],
        onChanged: (lang) {
          if (lang != null) {
            ref.read(settingsProvider.notifier).updateLanguage(lang);
          }
        },
      ),
    );
  }
}

class VerticalMotionEffectTile extends ConsumerWidget {
  const VerticalMotionEffectTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return SwitchListTile(
      secondary: const Icon(LucideIcons.move, color: Colors.white70),
      title: const Text(
        'Vertical Motion Effect Player',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: const Text(
        'Swipe down on the expanded player to dismiss it',
        style: TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
      value: settings.enableSlideGesture,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateEnableSlideGesture(value);
      },
    );
  }
}

class StopServiceTile extends ConsumerWidget {
  const StopServiceTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return SwitchListTile(
      secondary: const Icon(LucideIcons.power, color: Colors.white70),
      title: const Text(
        'Stop Service on App Dismissal',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: const Text(
        'Stop playback and close the app when swiped away from recent panel',
        style: TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
      value: settings.stopOnTaskRemoved,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateStopOnTaskRemoved(value);
      },
    );
  }
}

class InternetModeTile extends ConsumerWidget {
  const InternetModeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.globe, color: Colors.white70),
      title: Text(
        l10n.internetMode,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.enableNetworkLyricsArt,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
      value: settings.enableInternet,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateEnableInternet(value);
      },
    );
  }
}

class DownloadMissingArtworkTile extends ConsumerWidget {
  const DownloadMissingArtworkTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.image, color: Colors.white70),
      title: Text(
        l10n.downloadMissingArtwork,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.downloadMissingArtworkDesc,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
      value: settings.downloadArtwork,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateDownloadArtwork(value);
      },
    );
  }
}
