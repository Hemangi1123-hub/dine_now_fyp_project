import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_management/components/button.dart';
import 'package:hotel_management/components/hotel_tile.dart';
import 'package:hotel_management/models/hotels.dart';
import 'package:hotel_management/pages/customer_resturant_search.dart';
import 'package:hotel_management/pages/hotel_details_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false; // To track loading state

  void _searchHotels(BuildContext context, String hotelName) async {
    if (hotelName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a hotel name')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Query Firestore for hotels matching the name
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Owner')
          .where('resturant', isEqualTo: hotelName)
          .get();

      List<Map<String, dynamic>> restaurants = querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      // Navigate to the results page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CHotelResultsPage(restaurants: restaurants),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  void navigateToHotelDetails(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelDetailsPage(hotel: stays[index]),
      ),
    );
  }

  List stays = [
    Hotels(
        uid: '1',
        name: 'Soaltee',
        location: 'Bhaktapur',
        imagePath:
            'https://q-xx.bstatic.com/xdata/images/hotel/max500/252046750.jpg?k=1c956f6528232f65d2b1b3f948032a3e9f86e9b2e808c122709617c88860b474&o=',
        rating: '3.9',
        price: 10),
    Hotels(
        uid: '1',
        name: 'Everest',
        location: 'Naxal',
        imagePath:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS0MOycgRpuxxyenVkeogIzjPuEu55bCHY-BQ&s',
        rating: '4.1',
        price: 20),
    Hotels(
        uid: '1',
        name: 'Mariot',
        location: 'Baneshwor',
        imagePath:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSy_naAiqB4RTb_YAuJZFUVB-QH5ZVrrQmYfg&s',
        rating: '3.9',
        price: 30),
  ];

  Future _logout() async {
    // Show confirmation dialog
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel logout
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm logout
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      try {
        final User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseAuth.instance.signOut();
          Navigator.of(context).pop(); // Close the loading dialog

          // Show success dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Success'),
                content: Text('Successfully Logged Out!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          Navigator.of(context).pop(); // Close the loading dialog

          // Show error dialog for not logged in
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('User not logged in!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // Close the loading dialog

        // Show error dialog for exception
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('An error occurred. Please try again: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white, // Light Beige
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight:
            MediaQuery.of(context).size.height * 0.05, // 7% of screen height
        leading: GestureDetector(
            onTap: _logout,
            child: Icon(Icons.logout,
                color: const Color(0xFF333333))), // Charcoal Gray
        title: Text(
          'Dine Now',
          style: TextStyle(
            color: const Color(0xFF333333), // Charcoal Gray
            fontSize: MediaQuery.of(context).size.height *
                0.025, // 2.5% of screen height
          ),
        ),
        centerTitle: true, // This centers the title
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0), // Add right padding
            child: IconButton(
              icon: Icon(Icons.business,
                  color: const Color(0xFF333333)), // Hotel owner icon
              onPressed: () {
                // Add functionality for the hotel owner icon
                Navigator.pushNamed(context, '/hiddendrawer');
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Promo Section
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2E3A59), // Soft Navy Blue
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Get 32% Promo.',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: screenWidth * 0.05,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          MyButton(text: 'Redeem Now', onTap: () {}),
                        ],
                      ),
                    ),
                    Image.asset(
                      'lib/images/bathrobe.png',
                      height: screenHeight * 0.15,
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              // Search Bar
              Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Enter Hotel Name',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          _searchHotels(context, _searchController.text.trim());
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Add some spacing
                  if (_isLoading) // Show CircularProgressIndicator when loading
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              // Popular Stays Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Restaurants',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333), // Charcoal Gray
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                  GestureDetector(
                    child: Text(
                      'See more->',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333333), // Charcoal Gray
                        fontSize: screenWidth * 0.040,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/resturanttilepage');
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                height: screenHeight * 0.3,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: stays.length,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.04),
                    child: HotelTile(
                      onTap: () => navigateToHotelDetails(index),
                      hotels: stays[index],
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              // Footer Card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF777777)
                      .withOpacity(0.1), // Soft Gray with opacity
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Row(
                  children: [
                    Image.asset('lib/images/nepal.png',
                        height: screenHeight * 0.08),
                    SizedBox(width: screenWidth * 0.04),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Location',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: screenWidth * 0.045,
                            color: const Color(0xFF333333), // Charcoal Gray
                          ),
                        ),
                        Text(
                          'Nepal',
                          style: TextStyle(
                              color: const Color(0xFF777777)), // Soft Gray
                        ),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.favorite_outline,
                        color: const Color(0xFF777777), size: 28), // Soft Gray
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
