import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetHotelInfo extends StatelessWidget {
  final String hotelId;
  GetHotelInfo({required this.hotelId});

  @override
  Widget build(BuildContext context) {
    CollectionReference hotels = FirebaseFirestore.instance.collection('Owner');
    return FutureBuilder<DocumentSnapshot>(
      future: hotels.doc(hotelId).get(),
      builder: ((context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
        return Text(data['resturant']);
      }
      return Text(
        'loading....',
      );
    }));
  }
}
