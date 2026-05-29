import 'package:flutter/material.dart';
import 'package:looper_player/features/search/presentation/search_view.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/widgets/global_search_bar.dart';
import 'package:looper_player/core/ui_utils.dart';

class AndroidSearchTab extends StatelessWidget {
  const AndroidSearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.search,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GlobalSearchBar(autofocus: true),
            ),
            const Expanded(
              child: SearchView(),
            ),
          ],
        ),
      ),
    );
  }
}
