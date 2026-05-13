import 'package:flutter/material.dart';
import 'package:looper_player/ui/widgets/global_search_bar.dart';

class AndroidSearchTab extends StatelessWidget {
  const AndroidSearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child:
                    GlobalSearchBar(), // Reusing the global search bar widget
              ),
            ],
          ),
        ),
      ),
    );
  }
}
