import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart'; // Ensure this package is added to your pubspec.yaml
import 'package:hotel_management/components/slidablewidget.dart'; // Ensure this import is correct
import 'package:hotel_management/components/slide_to_act widget.dart'; // Ensure this import is correct

class ChefOrders extends StatelessWidget {
  const ChefOrders({super.key});
  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _performLogout(context); // Perform logout
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Function to perform logout
  Future<void> _performLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      // Navigate to the homepage and remove all previous routes
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/hiddendrawer',
        (route) => false,
      );
    } catch (e) {
      // Show an error message if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chef Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmationDialog(context),
          ),
        ],
      ),
      body: const ChefOrderPage(),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Ensure the column takes minimal space
          children: [
            const Text(
              'Swipe to End your shift',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: screenHeight * 0.01), // 1% of screen height
            SizedBox(
              height: screenHeight * 0.08, // 8% of screen height
              child: const SlideToActWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
