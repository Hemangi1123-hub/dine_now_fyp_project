import 'package:flutter/material.dart';
import 'package:hotel_management/components/bottom_nav_bar.dart';
import 'package:hotel_management/pages/explore.dart';
import 'package:hotel_management/pages/hiddendrawer.dart';
import 'package:hotel_management/pages/menu_page.dart';
import 'package:hotel_management/pages/ongoing_tile.dart';
import 'package:hotel_management/pages/profile.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0; // Track the selected index

  // Pages to display based on the selected index
  final List<Widget> _pages = [
    MenuPage(),
    OngoingTile(),
    ExploreMore(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display the selected page
      bottomNavigationBar: DockingBar(
        activeIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index; // Update the selected index
          });
        },
      ),
    );
  }
}
