import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotel_management/models/hotels.dart';
import 'package:hotel_management/models/tables.dart';
import 'package:hotel_management/themes/colors.dart';
import 'package:hotel_management/services/add_booking.dart';

class SeatSelectionWidget extends StatefulWidget {
  final Hotels hotel;
  final Tables table;
  const SeatSelectionWidget(
      {super.key, required this.hotel, required this.table});

  @override
  SeatSelectionWidgetState createState() => SeatSelectionWidgetState();
}

class SeatSelectionWidgetState extends State<SeatSelectionWidget> {
  List<Seat> seats = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Initialize seats with the hotel's price
    seats = List.generate(
      15,
      (index) => Seat(price: widget.hotel.price), // Use hotel's price
    );
    fetchTableStatus();
  }

  Future<void> fetchTableStatus() async {
    DocumentSnapshot documentSnapshot = await _firestore
        .collection('Table')
        .doc(widget.hotel.uid)
        .collection(widget.table.date)
        .doc('table_status')
        .get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      print(data);
      updateSeats(data);
    }
  }

  void updateSeats(Map<String, dynamic> tableStatus) {
    setState(() {
      tableStatus.forEach((key, value) {
        int index = int.parse(key) - 1;
        if (index >= 0 && index < seats.length) {
          seats[index].isReserved = value;
        }
      });
    });
  }

  void toggleSeatSelection(int index) {
    setState(() {
      seats[index].isSelected = !seats[index].isSelected;
    });
  }

  int getSelectedSeatsCount() {
    return seats.where((seat) => seat.isSelected).length;
  }

  double getTotalPrice() {
    return seats
        .where((seat) => seat.isSelected)
        .fold(0.0, (sum, seat) => sum + seat.price);
  }

  Future<void> updateTableStatus() async {
    Map<String, bool> updatedStatus = {};
    for (int i = 0; i < seats.length; i++) {
      updatedStatus['${i + 1}'] = seats[i].isSelected || seats[i].isReserved;
    }
    await _firestore
        .collection('Table')
        .doc(widget.hotel.uid)
        .collection(widget.table.date)
        .doc('table_status')
        .set(updatedStatus, SetOptions(merge: true));
  }

  List<int> getSelectedSeatNumbers() {
    List<int> selectedSeatNumbers = [];
    for (int i = 0; i < seats.length; i++) {
      if (seats[i].isSelected) {
        selectedSeatNumbers.add(i + 1); // Seat numbers are 1-based, so add 1
      }
    }
    return selectedSeatNumbers;
  }

  @override
  Widget build(BuildContext context) {
    final bookingAdd Booking = bookingAdd();
    final User? currentUser = FirebaseAuth.instance.currentUser;
    int selectedSeatsCount = getSelectedSeatsCount();
    double totalPrice = getTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seat Selection'),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 600 ? 8 : 4;
          return SingleChildScrollView(
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: seats.length,
                  itemBuilder: (context, index) {
                    return SeatWidget(
                      isSelected: seats[index].isSelected,
                      isReserved: seats[index].isReserved,
                      isAvailable: seats[index].isAvailable,
                      onTap: () => toggleSeatSelection(index),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      BookingInfoWidget(
                          color: Color.fromARGB(255, 129, 199, 132),
                          label: 'Available'),
                      BookingInfoWidget(color: Colors.red, label: 'Reserved'),
                      BookingInfoWidget(
                          color: Colors.yellow, label: 'Selected'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: '\$${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          children: [
                            TextSpan(
                              text:
                                  '\n$selectedSeatsCount seat${selectedSeatsCount == 1 ? '' : 's'}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedSeatsCount > 0) {
                            updateTableStatus();
                            Booking.addBooking(
                                context,
                                widget.hotel,
                                widget.table,
                                currentUser!.uid,
                                getSelectedSeatNumbers());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 40,
                          ),
                        ),
                        child: const Text(
                          'BOOK NOW',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Supporting Widgets and Models

class BookingInfoWidget extends StatelessWidget {
  final Color color;
  final String label;

  const BookingInfoWidget({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}

class Seat {
  bool isAvailable;
  bool isSelected;
  bool isReserved;
  int price;

  Seat(
      {this.isAvailable = true,
      this.isSelected = false,
      this.isReserved = false,
      required this.price});
}

class SeatWidget extends StatelessWidget {
  final bool isSelected;
  final bool isReserved;
  final bool isAvailable;
  final VoidCallback onTap;

  const SeatWidget({
    super.key,
    required this.isSelected,
    required this.isReserved,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color seatColor;
    if (isSelected) {
      seatColor = Colors.yellow;
    } else if (isReserved) {
      seatColor = Colors.red;
    } else if (isAvailable) {
      seatColor = primaryColor; // Use primary color
    } else {
      seatColor = Colors.grey;
    }

    return GestureDetector(
      onTap: isAvailable && !isReserved ? onTap : null,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
        ),
        child: const Icon(
          Icons.dining,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
}
