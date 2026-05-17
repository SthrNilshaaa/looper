import 'package:flutter/material.dart';
import 'package:looper_player/features/search/presentation/search_view.dart';
import 'package:looper_player/ui/widgets/global_search_bar.dart';

class AndroidSearchTab extends StatelessWidget {
  const AndroidSearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 16, bottom: 8),
                child: Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GlobalSearchBar(),
              Expanded(
                child: SearchView(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
