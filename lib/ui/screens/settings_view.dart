import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
                  title: 'Appearance',
                  children: [
                    _PremiumSwitchRow(
                      icon: LucideIcons.palette,
                      title: 'Dynamic Theming',
                      subtitle: 'Enable album-based colors and dynamic effects',
                      value: settings.enableDynamicTheming,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref.read(settingsProvider.notifier).updateDynamicTheming(value);
                      },
                      isLast: false,
                    ),
                    _PremiumSwitchRow(
                      icon: LucideIcons.moon,
                      title: 'Pure Black (OLED)',
                      subtitle: 'Use absolute black backgrounds',
                      value: settings.darkTheme,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref.read(settingsProvider.notifier).updateDarkTheme(value);
                      },
                      isLast: false,
                    ),
                    _PremiumSwitchRow(
                      icon: LucideIcons.music,
                      title: 'Dynamic Lyrics Background',
                      subtitle: 'Apply album-art blur to lyrics screen',
                      value: settings.dynamicLyrics,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref.read(settingsProvider.notifier).updateDynamicLyrics(value);
                      },
                      isLast: false,
                    ),
                    _PremiumSwitchRow(
                      icon: LucideIcons.sliders,
                      title: 'Flat Progress Bar',
                      subtitle: 'Disable squiggly wave progress bar animation',
                      value: settings.disableSquiggle,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref.read(settingsProvider.notifier).updateDisableSquiggle(value);
                      },
                      isLast: false,
                    ),
                    _PremiumSwitchRow(
                      icon: LucideIcons.clock,
                      title: 'Plain Timestamps',
                      subtitle: 'Use static text instead of rolling animation for progress duration',
                      value: settings.disableAnimatedDuration,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref.read(settingsProvider.notifier).updateDisableAnimatedDuration(value);
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
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                      ],
                      onChanged: (lang) {
                        if (lang != null) {
                          HapticFeedback.lightImpact();
                          ref.read(settingsProvider.notifier).updateLanguage(lang);
                        }
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            // Library Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _Section(
                  title: 'Library Settings',
                  children: [
                    const _PremiumLibraryFoldersList(),
                    _PremiumActionRow(
                      icon: LucideIcons.plus,
                      title: l10n.addFolder,
                      subtitle: 'Select folder to index music files',
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final String? path = await FilePicker.platform.getDirectoryPath();
                        if (path != null) {
                          ref.read(libraryProvider.notifier).scanLibrary(path);
                        }
                      },
                      isLast: false,
                    ),
                    _PremiumActionRow(
                      icon: LucideIcons.refreshCcw,
                      title: 'Rescan Library',
                      subtitle: 'Update library files indexing',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(libraryProvider.notifier).scanSavedFolders();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Scanning library...')),
                        );
                      },
                      isLast: false,
                    ),
                    _PremiumActionRow(
                      icon: LucideIcons.trash2,
                      title: l10n.resetLibrary,
                      textColor: Colors.redAccent,
                      subtitle: 'Remove all songs from your indexed library',
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
                  title: 'About App',
                  children: [
                    _PremiumActionRow(
                      icon: LucideIcons.info,
                      title: 'Looper Player',
                      subtitle: 'Version 1.0.0 (Premium OS Edition)',
                      onTap: () {},
                      trailing: const Text(
                        'v1.0.0',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                      isLast: false,
                    ),
                    _PremiumActionRow(
                      icon: LucideIcons.music,
                      title: 'Lyrics Provider',
                      subtitle: 'Online lyrics fetched from lrclib.net (LRCLIB)',
                      onTap: () async {
                        final url = Uri.parse('https://lrclib.net');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      isLast: false,
                    ),
                    _PremiumActionRow(
                      icon: LucideIcons.github,
                      title: 'Source Code',
                      subtitle: 'Visit official repository on GitHub',
                      onTap: () async {
                        final url = Uri.parse('https://github.com/SthrNilshaaa/looper');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
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
        title: Text(l10n.resetLibrary, style: const TextStyle(color: Colors.white)),
        content: const Text(
          'This will remove all songs from your library. Your music files will not be deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
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
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
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
          child: Column(
            children: children,
          ),
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
                Icon(
                  icon,
                  color: Colors.white.withOpacity(0.9),
                  size: 22,
                ),
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
                          color: Colors.white.withOpacity(0.4),
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
            color: Colors.white.withOpacity(0.04),
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
              Icon(
                icon,
                color: Colors.white.withOpacity(0.9),
                size: 22,
              ),
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
                data: Theme.of(context).copyWith(
                  canvasColor: const Color(0xFF1E1E1E),
                ),
                child: DropdownButton<T>(
                  value: value,
                  underline: const SizedBox(),
                  icon: const Icon(LucideIcons.chevronDown, color: Colors.white70, size: 16),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
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
            color: Colors.white.withOpacity(0.04),
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
                  color: textColor ?? Colors.white.withOpacity(0.9),
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
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing ?? Icon(
                  LucideIcons.chevronRight,
                  color: Colors.white.withOpacity(0.6),
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
            color: Colors.white.withOpacity(0.04),
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
                icon: const Icon(LucideIcons.x, size: 18, color: Colors.white60),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  final newFolders = List<String>.from(folders)..remove(path);
                  ref.read(settingsProvider.notifier).updateLibraryFolders(newFolders);
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
    return _Section(
      title: 'Maintainer & Designer',
      children: [
        _PremiumMaintainerRow(
          name: 'Nilesh Suthar',
          role: 'Creator and maintainer',
          avatar: 'assets/about/maintainer_avatar.png',
          github: 'https://github.com/SthrNilshaaa',
          telegram: 'https://t.me/neelshy',
          isLast: false,
        ),
        _PremiumMaintainerRow(
          name: 'Karan Suthar',
          role: 'Designer and maintainer',
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
                        color: Colors.white.withOpacity(0.4),
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
            color: Colors.white.withOpacity(0.04),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}
