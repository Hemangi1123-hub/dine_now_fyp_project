import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hotel_management/models/hotels.dart';
import 'package:hotel_management/models/tables.dart';

class bookingAdd {
  final CollectionReference resturant =
      FirebaseFirestore.instance.collection('Owner');
  final CollectionReference tables =
      FirebaseFirestore.instance.collection('User');
  Future<void> addBooking(BuildContext context, Hotels hotel, Tables table,
      String user, List seat) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while loading
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await resturant.doc(hotel.uid).collection('Booking').add({
        'date': table.date,
        'user': user,
        'seats': seat,
      });
      await tables.doc(user).collection('Booking').add({
        'user': hotel.uid,
        'imageurl': hotel.imagePath,
        'hotel': hotel.name,
        'date': table.date,
        'seats': seat,
      });

      Navigator.pushNamed(context, '/bookingsuccess');
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add booking: $e'),
      ));
    }
  }
}
