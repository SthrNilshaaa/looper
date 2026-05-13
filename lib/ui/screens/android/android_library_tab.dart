import 'package:flutter/material.dart';
import 'package:looper_player/features/library/presentation/smart_views.dart';

class AndroidLibraryTab extends StatelessWidget {
  const AndroidLibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'Library',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: RecentlyPlayedView()),
          ],
        ),
      ),
    );
  }
}
