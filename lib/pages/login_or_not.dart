import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hotel_management/pages/login_page.dart';
import 'package:hotel_management/pages/table_booking_page.dart';
import '../models/hotels.dart';


class LoginOrNot extends StatelessWidget {
  final Hotels hotel;
  LoginOrNot({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return TableBookingPage(hotel: hotel);
              } else {
                return LoginPage();
              }
            }));
  }
}
