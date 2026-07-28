import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/account/data/youtube_account_service.dart';
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final accountServiceProvider = Provider((ref) => YouTubeAccountService());

class AccountView extends ConsumerStatefulWidget {
  const AccountView({super.key});

  @override
  ConsumerState<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends ConsumerState<AccountView> {
  final TextEditingController _cookieController = TextEditingController();

  @override
  void dispose() {
    _cookieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountService = ref.watch(accountServiceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'YouTube Music Account Sync',
          style: AppFonts.jostStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PremiumSection(
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.all(16),
              useExpanded: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        accountService.isLoggedIn ? LucideIcons.userCheck : LucideIcons.userX,
                        color: accountService.isLoggedIn ? Colors.greenAccent : Colors.orangeAccent,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        accountService.isLoggedIn ? 'Account Connected' : 'Not Connected',
                        style: AppFonts.jostStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Paste your YouTube Music session cookie below to import your online playlists and liked tracks seamlessly.',
                    style: AppFonts.jostStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _cookieController,
                    maxLines: 3,
                    style: AppFonts.jostStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Paste Session Cookie (SAPISIDHAS=...)...',
                      hintStyle: AppFonts.jostStyle(color: Colors.white38, fontSize: 12),
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          accountService.setSessionCookie(_cookieController.text);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('YouTube Music Account connected successfully!')),
                          );
                        },
                        icon: const Icon(LucideIcons.check, size: 18),
                        label: const Text('Save & Sync'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (accountService.isLoggedIn)
                        OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            accountService.logout();
                            _cookieController.clear();
                            setState(() {});
                          },
                          icon: const Icon(LucideIcons.logOut, size: 18, color: Colors.redAccent),
                          label: const Text('Disconnect', style: TextStyle(color: Colors.redAccent)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
