import 'dart:developer' as developer;

import 'package:dine_now/screens/customer/customer_home_screen.dart';
import 'package:dine_now/screens/customer/my_orders_screen.dart';
import 'package:dine_now/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerMainScreen extends ConsumerStatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  ConsumerState<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends ConsumerState<CustomerMainScreen> {
  int _selectedIndex = 0;

  // List of the main screens accessible via the bottom bar
  static const List<Widget> _widgetOptions = <Widget>[
    CustomerHomeScreen(),
    MyOrdersScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    // If the 'My Orders' tab (index 1) is tapped, invalidate its provider
    if (index == 1) {
      developer.log(
        "Invalidating userOrdersStreamProvider on tab tap.",
      ); // Debug log
      ref.invalidate(userOrdersStreamProvider);
    }
    // Also invalidate profile provider if profile tab (index 2) is tapped (optional, but good practice)
    // Requires importing currentUserDataProvider from user_provider.dart
    // if (index == 2) {
    //   ref.invalidate(currentUserDataProvider);
    // }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the selected screen
      // Each screen might have its own AppBar, or we could add a central one here
      body: IndexedStack(
        // Use IndexedStack to keep state of screens
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'My Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels:
            false, // Optional: Hide labels for unselected items
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
      ),
    );
  }
}
