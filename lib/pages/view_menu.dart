import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_management/services/get_table_no.dart';
import 'package:hotel_management/services/isHotelBooked.dart';
import '../models/hotels.dart';
import 'package:hotel_management/services/crud.dart';

class RestaurantMenuPage extends StatefulWidget {
  final Hotels hotel;
  RestaurantMenuPage({super.key, required this.hotel});

  @override
  _RestaurantMenuPageState createState() => _RestaurantMenuPageState();
}

class _RestaurantMenuPageState extends State<RestaurantMenuPage> {
  Map<String, int> itemCounts = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String menuCollection = 'menu';
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirestoreService _firestoreService = FirestoreService();

  void _updateItemCount(String itemId, int newCount) {
    setState(() {
      itemCounts[itemId] = newCount;
    });
  }

  // Add Order Function

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Menu'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Owner')
            .doc(widget.hotel.uid)
            .collection('menu')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No menu items available.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var menuItem = snapshot.data!.docs[index];
              String itemId = menuItem.id;
              String foodName = menuItem['foodName'];
              double foodPrice = menuItem['foodPrice'].toDouble();
              String foodDescription = menuItem['foodDescription'];
              if (!itemCounts.containsKey(itemId)) {
                itemCounts[itemId] = 0;
              }
              return Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foodName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              foodDescription,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '\$${foodPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () {
                              _updateItemCount(itemId, itemCounts[itemId]! + 1);
                            },
                          ),
                          Text(
                            '${itemCounts[itemId]}',
                            style: TextStyle(fontSize: 18),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (itemCounts[itemId]! > 0) {
                                _updateItemCount(
                                    itemId, itemCounts[itemId]! - 1);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (currentUser != null) {
            // User is logged in
            bool isBooked = await CheckBooking()
                .isHotelBooked(currentUser!.uid, widget.hotel.uid);

            if (!isBooked) {
              Navigator.pushNamed(context, '/noorder');
              return;
            }

            // Prepare the order map
            Map<String, dynamic> order = {};
            for (var entry in itemCounts.entries) {
              String itemId = entry.key;
              int count = entry.value;

              if (count > 0) {
                // Fetch the food name from Firestore
                var menuItem = await _firestore
                    .collection('Owner')
                    .doc(widget.hotel.uid)
                    .collection('menu')
                    .doc(itemId)
                    .get();

                String foodName = menuItem['foodName'];
                List seats = await GetTableNo()
                    .TableNumber(currentUser!.uid, widget.hotel.uid);
                print('Seats=$seats');

                // Add food name and quantity to the order map
                order = {
                  'tableNo': seats[0],
                  'foodName': foodName,
                  'foodQuantity': count,
                };
              }
            }

            if (order.isEmpty) {
              // No items selected
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select at least one item to order.'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            // Call the addOrder function
            await _firestoreService.addOrder(context, widget.hotel.uid, order);

            // Navigate to booking success page
            Navigator.pushNamed(context, '/bookingsuccess');
          } else {
            // User is not logged in
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Not Logged In'),
                content: Text('Please log in to place an order.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Done'),
                  ),
                ],
              ),
            );
          }
        },
        label: Text('Place Order'),
        icon: Icon(Icons.shopping_cart),
      ),
    );
  }
}
