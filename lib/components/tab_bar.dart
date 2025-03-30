import 'package:flutter/material.dart';
import 'package:hotel_management/pages/Owner/chart_page.dart';
import 'package:hotel_management/pages/Owner/owner_homepage.dart';
import 'package:hotel_management/pages/Owner/resturant_page.dart';
import 'package:hotel_management/pages/Owner/table_setting.dart';

class SecondaryTabbar extends StatefulWidget {
  final double radius;
  const SecondaryTabbar({super.key, this.radius = 0});

  @override
  _SecondaryTabbarState createState() => _SecondaryTabbarState();
}

class _SecondaryTabbarState extends State<SecondaryTabbar> {
  int _selectedIndex = 0;

  // Define the body content for each tab
  final List<Widget> _tabBodies = [
    const ChartPage(), // Widget for Home
     ResturantPage(), // Widget for Restaurant
     TableSetting(), // Widget for Table
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFF292929),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    child: Container(
                      color: _selectedIndex == 0
                          ? Colors.amber
                          : Colors.transparent,
                      child: Center(
                        child: Text(
                          'Home',
                          style: TextStyle(
                            color: _selectedIndex == 0
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    child: Container(
                      color: _selectedIndex == 1
                          ? const Color(0xFF00BAAB)
                          : Colors.transparent,
                      child: Center(
                        child: Text(
                          'Restaurant',
                          style: TextStyle(
                            color: _selectedIndex == 1
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                    child: Container(
                      color: _selectedIndex == 2
                          ? const Color(0xFF00BAAB)
                          : Colors.transparent,
                      child: Center(
                        child: Text(
                          'Table',
                          style: TextStyle(
                            color: _selectedIndex == 2
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Body based on selected tab
        Expanded(
          child: _tabBodies[_selectedIndex],
        ),
      ],
    );
  }
}
