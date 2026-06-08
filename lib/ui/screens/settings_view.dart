import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Text(
                  l10n.settings,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            // Appearance Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _Section(
                  title: l10n.appearance,
                  children: [
                    _PremiumSwitchRow(
                      icon: LucideIcons.palette,
                      title: l10n.dynamicTheming,
                      subtitle: l10n.adaptColorsArtwork,
                      value: settings.enableDynamicTheming,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref
                            .read(settingsProvider.notifier)
                            .updateDynamicTheming(value);
                      },
                      isLast: false,
                    ),
                    if (settings.enableDynamicTheming)
                      _PremiumSwitchRow(
                        icon: LucideIcons.eyeOff,
                        title: l10n.disableBlurEffects,
                        subtitle: l10n.turnOffBlursOptimize,
                        value: settings.disableBlur,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          ref
                              .read(settingsProvider.notifier)
                              .updateDisableBlur(value);
                        },
                        isLast: false,
                      ),
                    if (!settings.enableDynamicTheming) ...[
                      _PremiumSwitchRow(
                        icon: LucideIcons.paintBucket,
                        title: l10n.dynamicAccentColor,
                        subtitle: l10n.dynamicAccentColorDesc,
                        value: settings.dynamicAccentColor,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          ref
                              .read(settingsProvider.notifier)
                              .updateDynamicAccentColor(value);
                        },
                        isLast: false,
                      ),
                      _PremiumAccentColorRow(
                        icon: LucideIcons.droplet,
                        title: l10n.accentColor,
                        subtitle: l10n.accentColorDesc,
                        selectedColor: settings.accentColor,
                        onColorChanged: (color) {
                          ref
                              .read(settingsProvider.notifier)
                              .updateAccentColor(color);
                        },
                        isLast: false,
                      ),
                    ],
                    _PremiumSwitchRow(
                      icon: LucideIcons.moon,
                      title: l10n.pureBlackOled,
                      subtitle: l10n.pureBlackOledDesc,
                      value: settings.darkTheme,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref
                            .read(settingsProvider.notifier)
                            .updateDarkTheme(value);
                      },
                      isLast: false,
                    ),
                    _PremiumSwitchRow(
                      icon: LucideIcons.music,
                      title: l10n.dynamicLyricsBg,
                      subtitle: l10n.dynamicLyricsBgDesc,
                      value: settings.dynamicLyrics,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref
                            .read(settingsProvider.notifier)
                            .updateDynamicLyrics(value);
                      },
                      isLast: false,
                    ),
                    if (settings.enableDynamicTheming || settings.dynamicLyrics)
                      _PremiumSwitchRow(
                        icon: LucideIcons.palette,
                        title: l10n.dynamicColorActiveLyrics,
                        subtitle: l10n.dynamicColorActiveLyricsDesc,
                        value: settings.dynamicColorActiveLyrics,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          ref
                              .read(settingsProvider.notifier)
                              .updateDynamicColorActiveLyrics(value);
                        },
                        isLast: false,
                      ),
                    _PremiumDropdownRow<String>(
                      icon: LucideIcons.alignCenter,
                      title: l10n.lyricsAlignment,
                      value: settings.lyricsAlignment,
                      items: [
                        DropdownMenuItem(value: 'left', child: Text(l10n.left)),
                        DropdownMenuItem(
                          value: 'center',
                          child: Text(l10n.center),
                        ),
                        DropdownMenuItem(value: 'right', child: Text(l10n.right)),
                      ],
                      onChanged: (align) {
                        if (align != null) {
                          HapticFeedback.lightImpact();
                          ref
                              .read(settingsProvider.notifier)
                              .updateLyricsAlignment(align);
                        }
                      },
                      isLast: false,
                    ),
                    _PremiumSwitchRow(
                      icon: LucideIcons.sliders,
                      title: l10n.flatProgressBar,
                      subtitle: l10n.disableSquigglyProgressBar,
                      value: settings.disableSquiggle,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref
                            .read(settingsProvider.notifier)
                            .updateDisableSquiggle(value);
                      },
                      isLast: false,
                    ),
                    _PremiumSwitchRow(
                      icon: LucideIcons.clock,
                      title: l10n.plainTimestamps,
                      subtitle: l10n.useStaticTextTimestamps,
                      value: settings.disableAnimatedDuration,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref
                            .read(settingsProvider.notifier)
                            .updateDisableAnimatedDuration(value);
                      },
                      isLast: false,
                    ),
                    _PremiumSwitchRow(
                      icon: LucideIcons.move,
                      title: l10n.verticalMotionEffectPlayer,
                      subtitle: l10n.verticalMotionEffectPlayerDesc,
                      value: settings.enableSlideGesture,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref
                            .read(settingsProvider.notifier)
                            .updateEnableSlideGesture(value);
                      },
                      isLast: false,
                    ),
                    _PremiumSwitchRow(
                      icon: LucideIcons.power,
                      title: l10n.stopServiceOnAppDismissal,
                      subtitle: l10n.stopServiceOnAppDismissalDesc,
                      value: settings.stopOnTaskRemoved,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref
                            .read(settingsProvider.notifier)
                            .updateStopOnTaskRemoved(value);
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            // Language Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _Section(
                  title: l10n.language,
                  children: [
                    _PremiumDropdownRow<String>(
                      icon: LucideIcons.languages,
                      title: l10n.language,
                      value: settings.language,
                      items: [
                        DropdownMenuItem(
                          value: '',
                          child: Text(l10n.systemDefault),
                        ),
                        ...AppLocalizations.supportedLocales.map((locale) {
                          final code = locale.languageCode;
                          final name = {
                            'en': 'English',
                            'es': 'Español',
                            'fr': 'Français',
                            'de': 'Deutsch',
                            'pt': 'Português',
                            'ru': 'Русский',
                            'it': 'Italiano',
                            'zh': '中文',
                            'ja': '日本語',
                            'ko': '한국어',
                            'ar': 'العربية',
                            'tr': 'Türkçe',
                            'nl': 'Nederlands',
                            'hi': 'हिन्दी',
                          }[code] ?? code;
                          return DropdownMenuItem(
                            value: code,
                            child: Text(name),
                          );
                        }),
                      ],
                      onChanged: (lang) {
                        if (lang != null) {
                          HapticFeedback.lightImpact();
                          ref
                              .read(settingsProvider.notifier)
                              .updateLanguage(lang);
                        }
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            // Audio & Playback Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _Section(
                  title: l10n.audioPlayback,
                  children: [
                    _PremiumSwitchRow(
                      icon: LucideIcons.music,
                      title: l10n.fadePlayPauseStop,
                      subtitle: l10n.fadePlayPauseStopDesc,
                      value: settings.fadePlayPauseStop,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref
                            .read(settingsProvider.notifier)
                            .updateFadePlayPauseStop(value);
                      },
                      isLast: false,
                    ),
                    if (settings.fadePlayPauseStop)
                      _PremiumSliderRow(
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
                        isLast: false,
                      ),
                    _PremiumSwitchRow(
                      icon: LucideIcons.sliders,
                      title: l10n.fadeOnSeek,
                      subtitle: l10n.fadeOnSeekDesc,
                      value: settings.fadeOnSeek,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref
                            .read(settingsProvider.notifier)
                            .updateFadeOnSeek(value);
                      },
                      isLast: false,
                    ),
                    if (settings.fadeOnSeek)
                      _PremiumSliderRow(
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
                        isLast: false,
                      ),
                    _PremiumSwitchRow(
                      icon: LucideIcons.gitCompare,
                      title: l10n.audioCrossfade,
                      subtitle: l10n.audioCrossfadeDesc,
                      value: settings.enableCrossfade,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref
                            .read(settingsProvider.notifier)
                            .updateEnableCrossfade(value);
                      },
                      isLast: false,
                    ),
                    if (settings.enableCrossfade) ...[
                      _PremiumSliderRow(
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
                        isLast: false,
                      ),
                      _PremiumSliderRow(
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
                        isLast: false,
                      ),
                    ],
                    _PremiumSliderRow(
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
                      isLast: false,
                    ),
                    _PremiumSwitchRow(
                      icon: LucideIcons.phoneCall,
                      title: l10n.manageAudioFocusTitle,
                      subtitle: l10n.manageAudioFocusDesc,
                      value: settings.audioFocus,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref
                            .read(settingsProvider.notifier)
                            .updateAudioFocus(value);
                      },
                      isLast: !settings.audioFocus,
                    ),
                    if (settings.audioFocus) ...[
                      _PremiumSwitchRow(
                        icon: LucideIcons.phoneCall,
                        title: l10n.resumeAfterCallTitle,
                        subtitle: l10n.resumeAfterCallDesc,
                        value: settings.resumeAfterCall,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          ref
                              .read(settingsProvider.notifier)
                              .updateResumeAfterCall(value);
                        },
                        isLast: false,
                      ),
                      _PremiumSwitchRow(
                        icon: LucideIcons.power,
                        title: l10n.resumeOnStartTitle,
                        subtitle: l10n.resumeOnStartDesc,
                        value: settings.resumeOnStart,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          ref
                              .read(settingsProvider.notifier)
                              .updateResumeOnStart(value);
                        },
                        isLast: false,
                      ),
                      _PremiumSwitchRow(
                        icon: LucideIcons.alertCircle,
                        title: l10n.permanentFocusChangePause,
                        subtitle: l10n.permanentFocusChangePauseDesc,
                        value: settings.permanentAudioFocusChange,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          ref
                              .read(settingsProvider.notifier)
                              .updatePermanentAudioFocusChange(value);
                        },
                        isLast: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Library Section
             SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _Section(
                  title: l10n.librarySettings,
                  children: [
                    const _PremiumLibraryFoldersList(),
                    _PremiumActionRow(
                      icon: LucideIcons.plus,
                      title: l10n.addFolder,
                      subtitle: l10n.selectFolderIndex,
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final String? path = await FilePicker.platform
                            .getDirectoryPath();
                        if (path != null) {
                          ref.read(libraryProvider.notifier).scanLibrary(path);
                        }
                      },
                      isLast: false,
                    ),
                    _PremiumActionRow(
                      icon: LucideIcons.refreshCcw,
                      title: l10n.rescanLibrary,
                      subtitle: l10n.updateLibraryIndexing,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(libraryProvider.notifier).scanSavedFolders();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.scanningLibrary)),
                        );
                      },
                      isLast: false,
                    ),
                    _PremiumSwitchRow(
                      icon: LucideIcons.globe,
                      title: l10n.internetMode,
                      subtitle: l10n.enableNetworkLyricsArt,
                      value: settings.enableInternet,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref
                            .read(settingsProvider.notifier)
                            .updateEnableInternet(value);
                      },
                      isLast: false,
                    ),
                    _PremiumActionRow(
                      icon: LucideIcons.trash2,
                      title: l10n.resetLibrary,
                      textColor: Colors.redAccent,
                      subtitle: l10n.resetLibraryDesc,
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        _showClearDialog(context, l10n);
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            // About Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _Section(
                  title: l10n.aboutApp,
                  children: [
                    _PremiumActionRow(
                      icon: LucideIcons.info,
                      title: l10n.appTitle,
                      subtitle: 'Version 2.0.0',
                      onTap: () {},
                      trailing: const Text(
                        'v2.0.0',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                      isLast: false,
                    ),
                    _PremiumActionRow(
                      icon: LucideIcons.music,
                      title: l10n.lyricsProvider,
                      subtitle: l10n.lyricsProviderDesc,
                      onTap: () async {
                        final url = Uri.parse('https://lrclib.net');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      isLast: false,
                    ),
                    _PremiumActionRow(
                      icon: LucideIcons.gitFork,
                      title: l10n.sourceCode,
                      subtitle: l10n.visitOfficialRepository,
                      onTap: () async {
                        final url = Uri.parse(
                          'https://github.com/SthrNilshaaa/looper',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            // Maintainers Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: const _PremiumMaintainerSection(),
              ),
            ),

            // Extra padding to breathe
            const SliverToBoxAdapter(child: SizedBox(height: 180)),
          ],
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.resetLibrary,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.resetLibraryConfirmNew,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              await DbService.isar.writeTxn(() async {
                await DbService.isar.songs.clear();
                await DbService.isar.albums.clear();
                await DbService.isar.artists.clear();
              });
              Navigator.pop(context);
            },
            child: Text(
              l10n.clear,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PremiumSection(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                bottomLeft: Radius.circular(32),
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              useExpanded: false,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PremiumSection(
          borderRadius: BorderRadius.circular(20),
          padding: EdgeInsets.zero,
          useExpanded: false,
          child: Column(children: children),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _PremiumSwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _PremiumSwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.8,
            color: Colors.white.withValues(alpha: 0.04),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}

class _PremiumDropdownRow<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool isLast;

  const _PremiumDropdownRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(canvasColor: const Color(0xFF1E1E1E)),
                child: DropdownButton<T>(
                  value: value,
                  underline: const SizedBox(),
                  icon: const Icon(
                    LucideIcons.chevronDown,
                    color: Colors.white70,
                    size: 16,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  items: items,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.8,
            color: Colors.white.withValues(alpha: 0.04),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}

class _PremiumActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? textColor;
  final Widget? trailing;
  final bool isLast;

  const _PremiumActionRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.textColor,
    this.trailing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: textColor ?? Colors.white.withValues(alpha: 0.9),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor ?? Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing ??
                    Icon(
                      LucideIcons.chevronRight,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 18,
                    ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.8,
            color: Colors.white.withValues(alpha: 0.04),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}

class _PremiumLibraryFoldersList extends ConsumerWidget {
  const _PremiumLibraryFoldersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(settingsProvider).libraryFolders;

    if (folders.isEmpty) return const SizedBox.shrink();

    return Column(
      children: folders
          .map(
            (path) => _PremiumActionRow(
              icon: LucideIcons.folder,
              title: path.split('/').last,
              subtitle: path,
              isLast: false,
              onTap: () {},
              trailing: IconButton(
                icon: const Icon(
                  LucideIcons.x,
                  size: 18,
                  color: Colors.white60,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  final newFolders = List<String>.from(folders)..remove(path);
                  ref
                      .read(settingsProvider.notifier)
                      .updateLibraryFolders(newFolders);
                },
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PremiumMaintainerSection extends StatelessWidget {
  const _PremiumMaintainerSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _Section(
      title: l10n.maintainersAndDesigners,
      children: [
        _PremiumMaintainerRow(
          name: 'Nilesh Suthar',
          role: l10n.creatorAndMaintainer,
          avatar: 'assets/about/maintainer_avatar.png',
          github: 'https://github.com/SthrNilshaaa',
          telegram: 'https://t.me/neelshy',
          isLast: false,
        ),
        _PremiumMaintainerRow(
          name: 'Karan Suthar',
          role: l10n.designerAndMaintainer,
          avatar: 'assets/about/designer_avatar.png',
          github: 'https://github.com/sthrkaran',
          telegram: 'https://t.me/karanwhy',
          isLast: true,
        ),
      ],
    );
  }
}

class _PremiumMaintainerRow extends StatelessWidget {
  final String name;
  final String role;
  final String avatar;
  final String github;
  final String telegram;
  final bool isLast;

  const _PremiumMaintainerRow({
    required this.name,
    required this.role,
    required this.avatar,
    required this.github,
    required this.telegram,
    this.isLast = false,
  });

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10, width: 1),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white10,
                  backgroundImage: AssetImage(avatar),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/about/github_icon.svg',
                      width: 18,
                      height: 18,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _launchUrl(github);
                    },
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/about/telegram_icon.svg',
                      width: 18,
                      height: 18,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _launchUrl(telegram);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.8,
            color: Colors.white.withValues(alpha: 0.04),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}

class _PremiumAccentColorRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int selectedColor;
  final ValueChanged<int> onColorChanged;
  final bool isLast;

  const _PremiumAccentColorRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selectedColor,
    required this.onColorChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PremiumColorCircle(
                    color: const Color(0xFF41C25E),
                    isSelected: selectedColor == 0xFF41C25E,
                    onTap: () => onColorChanged(0xFF41C25E),
                  ),
                  const SizedBox(width: 8),
                  _PremiumColorCircle(
                    color: const Color(0xFFF7EAA6),
                    isSelected: selectedColor == 0xFFF7EAA6,
                    onTap: () => onColorChanged(0xFFF7EAA6),
                  ),
                  const SizedBox(width: 8),
                  _PremiumColorCircle(
                    color: Colors.blueAccent,
                    isSelected: selectedColor == Colors.blueAccent.value,
                    onTap: () => onColorChanged(Colors.blueAccent.value),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.8,
            color: Colors.white.withValues(alpha: 0.04),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}

class _PremiumColorCircle extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PremiumColorCircle({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : Border.all(color: Colors.white24, width: 1),
        ),
      ),
    );
  }
}

class _PremiumSliderRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String suffix;
  final ValueChanged<double> onChanged;
  final bool isLast;

  const _PremiumSliderRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    this.divisions = 100,
    required this.suffix,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 22),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${value.round()} $suffix',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Colors.white12,
                  thumbColor: Theme.of(context).colorScheme.primary,
                  overlayColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                  valueIndicatorColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainer,
                  valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                ),
                child: Slider(
                  value: value.clamp(min, max),
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.8,
            color: Colors.white.withValues(alpha: 0.04),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}
