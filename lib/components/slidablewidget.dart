import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Order {
  final String id; // Unique ID for each order (from Firestore)
  final String tableNumber;
  final String foodName;
  final int quantity;

  Order({
    required this.id,
    required this.tableNumber,
    required this.foodName,
    required this.quantity,
  });
}

class ChefOrderPage extends StatefulWidget {
  const ChefOrderPage({super.key});

  @override
  State<ChefOrderPage> createState() => _ChefOrderPageState();
}

class _ChefOrderPageState extends State<ChefOrderPage> {
  final CollectionReference orderCollection =
      FirebaseFirestore.instance.collection('Order');
  final CollectionReference restaurantChef =
      FirebaseFirestore.instance.collection('Chef');
  final User? currentUser = FirebaseAuth.instance.currentUser;
  List<Order> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      // Fetch chef data
      DocumentSnapshot chefData =
          await restaurantChef.doc(currentUser!.uid).get();
      if (!chefData.exists) {
        throw Exception("Chef data not found");
      }

      Map<String, dynamic> chefInfo = chefData.data() as Map<String, dynamic>;
      String hotelUid = chefInfo['hotel'];

      // Fetch orders for the hotel
      QuerySnapshot querySnapshot =
          await orderCollection.doc(hotelUid).collection('orders').get();

      List<Order> fetchedOrders = [];
      for (var doc in querySnapshot.docs) {
        fetchedOrders.add(Order(
          id: doc.id, // Use Firestore document ID as unique identifier
          tableNumber: doc['tableNo'].toString(),
          foodName: doc['foodName'],
          quantity: doc['foodQuantity'],
        ));
      }

      setState(() {
        orders = fetchedOrders;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching orders: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteOrder(String orderId, String hotelUid) async {
    try {
      await orderCollection
          .doc(hotelUid)
          .collection('orders')
          .doc(orderId)
          .delete();
      print("Order deleted successfully: $orderId");
    } catch (e) {
      print("Error deleting order: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.red.withOpacity(0.3),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: orders.length,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Dismissible(
                    key: ValueKey<String>(order.id), // Use unique Firestore ID
                    onDismissed: (direction) async {
                      // Delete the order from Firestore
                      DocumentSnapshot chefData =
                          await restaurantChef.doc(currentUser!.uid).get();
                      Map<String, dynamic> chefInfo =
                          chefData.data() as Map<String, dynamic>;
                      String hotelUid = chefInfo['hotel'];

                      await deleteOrder(order.id, hotelUid);

                      // Remove the order from the local list
                      setState(() {
                        orders.removeAt(index);
                      });
                    },
                    confirmDismiss: (DismissDirection direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Delete Order"),
                            content: Text(
                                "Are you sure you want to delete this order?"),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text("Yes"),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("No"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(top: screenHeight * 0.01),
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left side: Table Number
                          Row(
                            children: [
                              Icon(Icons.table_restaurant,
                                  size: screenWidth * 0.06),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                "Table ${order.tableNumber}",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          // Right side: Food Name and Quantity
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${order.foodName} x ${order.quantity}",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
