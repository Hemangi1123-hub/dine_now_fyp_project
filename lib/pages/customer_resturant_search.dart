import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotel_management/models/hotels.dart';
import 'package:hotel_management/pages/hotel_details_page.dart';
import 'package:hotel_management/services/crud.dart';

class CHotelResultsPage extends StatelessWidget {
  final List<Map<String, dynamic>> restaurants;

  CHotelResultsPage({required this.restaurants});
  final FirestoreService _firestoreService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Search Results'),
        ),
        body: restaurants.isEmpty
            ? Center(
                child: Text('No hotels found'),
              )
            : ListView.builder(
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];
                  final uid = restaurant['uid'] ?? 'Unknown UID';
                  final restaurantName =
                      restaurant['resturant'] ?? 'Unknown Restaurant';
                  final restaurantLocation =
                      restaurant['location'] ?? 'Unknown Location';
                  final imageUrl =
                      'https://fwhponoldzlbxzkxpowv.supabase.co/storage/v1/object/public/image/uploads/' +
                          (uid);
                  final price = restaurant['price'] ??
                      0; // Assuming you have an image URL field

                  return GestureDetector(
                    onTap: () {
                      final Hotels __hotel = Hotels(
                          uid: uid,
                          name: restaurantName,
                          location: restaurantLocation,
                          imagePath: imageUrl,
                          rating: '4.1',
                          price: price);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  HotelDetailsPage(hotel: __hotel)));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(
                            0.1), // Set the background color of the tile
                        borderRadius: BorderRadius.circular(
                            14.0), // Add border radius here
                      ),
                      // Set the background color of the tile
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0), // Add spacing between tiles
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0), // Add padding inside the tile
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Vertically center the content
                        children: [
                          // Left Side: Restaurant Name and Location
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurantName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  restaurantLocation,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Right Side: Image from Network
                          if (imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    // Image has finished loading
                                    return child;
                                  } else {
                                    // Show a circular progress indicator while the image is loading
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  }
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback icon if the image fails to load
                                  return const Icon(Icons.image_not_supported,
                                      size: 50, color: Colors.grey);
                                },
                              ),
                            )
                          else
                            const Icon(Icons.image_not_supported,
                                size: 50, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ));
    ;
  }
}
