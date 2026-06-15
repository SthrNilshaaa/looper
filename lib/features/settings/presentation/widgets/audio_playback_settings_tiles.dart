import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'settings_widgets.dart';

class FadePlayPauseStopTile extends ConsumerWidget {
  const FadePlayPauseStopTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.music, color: Colors.white70),
      title: Text(
        l10n.fadePlayPauseStop,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        l10n.fadePlayPauseStopDesc,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
      value: settings.fadePlayPauseStop,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateFadePlayPauseStop(value);
      },
    );
  }
}

class FadeDurationSlider extends ConsumerWidget {
  const FadeDurationSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SettingsSliderTile(
      icon: LucideIcons.sliders,
      title: l10n.fadeDuration,
      subtitle: l10n.fadeDurationDesc,
      value: settings.playPauseStopFadeLength.toDouble(),
      min: 10,
      max: 1000,
      divisions: 99,
      suffix: 'ms',
      onChanged: (value) {
        ref
            .read(settingsProvider.notifier)
            .updatePlayPauseStopFadeLength(value.round());
      },
    );
  }
}

class FadeOnSeekTile extends ConsumerWidget {
  const FadeOnSeekTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.sliders, color: Colors.white70),
      title: Text(
        l10n.fadeOnSeek,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        l10n.fadeOnSeekDesc,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
      value: settings.fadeOnSeek,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateFadeOnSeek(value);
      },
    );
  }
}

class SeekFadeDurationSlider extends ConsumerWidget {
  const SeekFadeDurationSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SettingsSliderTile(
      icon: LucideIcons.sliders,
      title: l10n.seekFadeDuration,
      subtitle: l10n.seekFadeDurationDesc,
      value: settings.seekFadeLength.toDouble(),
      min: 10,
      max: 500,
      divisions: 49,
      suffix: 'ms',
      onChanged: (value) {
        ref
            .read(settingsProvider.notifier)
            .updateSeekFadeLength(value.round());
      },
    );
  }
}

class AudioCrossfadeTile extends ConsumerWidget {
  const AudioCrossfadeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.gitCompare, color: Colors.white70),
      title: Text(
        l10n.audioCrossfade,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        l10n.audioCrossfadeDesc,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
      value: settings.enableCrossfade,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateEnableCrossfade(value);
      },
    );
  }
}

class AutoCrossfadeDurationSlider extends ConsumerWidget {
  const AutoCrossfadeDurationSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SettingsSliderTile(
      icon: LucideIcons.sliders,
      title: l10n.autoCrossfadeDuration,
      subtitle: l10n.autoCrossfadeDurationDesc,
      value: settings.crossfadeLength.toDouble(),
      min: 100,
      max: 15000,
      divisions: 149,
      suffix: 'ms',
      onChanged: (value) {
        ref
            .read(settingsProvider.notifier)
            .updateCrossfadeLength(value.round());
      },
    );
  }
}

class ManualCrossfadeDurationSlider extends ConsumerWidget {
  const ManualCrossfadeDurationSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SettingsSliderTile(
      icon: LucideIcons.sliders,
      title: l10n.manualCrossfadeDuration,
      subtitle: l10n.manualCrossfadeDurationDesc,
      value: settings.shortManualCrossfadeLength.toDouble(),
      min: 10,
      max: 1000,
      divisions: 99,
      suffix: 'ms',
      onChanged: (value) {
        ref
            .read(settingsProvider.notifier)
            .updateShortManualCrossfadeLength(value.round());
      },
    );
  }
}

class SilenceBetweenTracksSlider extends ConsumerWidget {
  const SilenceBetweenTracksSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SettingsSliderTile(
      icon: LucideIcons.clock,
      title: l10n.silenceBetweenTracksTitle,
      subtitle: l10n.silenceBetweenTracksDesc,
      value: settings.silenceBetweenTracks.toDouble(),
      min: 0,
      max: 5000,
      divisions: 50,
      suffix: 'ms',
      onChanged: (value) {
        ref
            .read(settingsProvider.notifier)
            .updateSilenceBetweenTracks(value.round());
      },
    );
  }
}

class ManageAudioFocusTile extends ConsumerWidget {
  const ManageAudioFocusTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.phoneCall, color: Colors.white70),
      title: Text(
        l10n.manageAudioFocusTitle,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        l10n.manageAudioFocusDesc,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
      value: settings.audioFocus,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateAudioFocus(value);
      },
    );
  }
}

class ResumeAfterCallTile extends ConsumerWidget {
  const ResumeAfterCallTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.phoneCall, color: Colors.white70),
      title: Text(
        l10n.resumeAfterCallTitle,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.resumeAfterCallDesc,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
      value: settings.resumeAfterCall,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateResumeAfterCall(value);
      },
    );
  }
}

class ResumeOnStartTile extends ConsumerWidget {
  const ResumeOnStartTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.power, color: Colors.white70),
      title: Text(
        l10n.resumeOnStartTitle,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.resumeOnStartDesc,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
      value: settings.resumeOnStart,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateResumeOnStart(value);
      },
    );
  }
}

class PermanentAudioFocusChangeTile extends ConsumerWidget {
  const PermanentAudioFocusChangeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      secondary: const Icon(LucideIcons.alertCircle, color: Colors.white70),
      title: Text(
        l10n.permanentFocusChangePause,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        l10n.permanentFocusChangePauseDesc,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Color(settings.accentColor),
      value: settings.permanentAudioFocusChange,
      onChanged: (value) {
        ref
            .read(settingsProvider.notifier)
            .updatePermanentAudioFocusChange(value);
      },
    );
  }
}
