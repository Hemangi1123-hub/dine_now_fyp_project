import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hotel_management/pages/Chefs/search_results.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
          builder: (context) => HotelResultsPage(restaurants: restaurants),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotel Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
      ),
    );
  }
}
