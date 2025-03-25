import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotel_management/pages/Chefs/orders.dart';
import 'package:hotel_management/pages/Chefs/search_page.dart';
import 'package:hotel_management/services/isChefPending.dart';

class RequestNavigator extends StatelessWidget {
  RequestNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // Listen for auth state changes
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Waiting for authentication state
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Handle errors
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No user signed in')); // If no user, show this message
          }

          final User? currentUser = snapshot.data; // Get the current user from the stream

          if (currentUser == null) {
            return Center(child: Text('No user signed in')); // If no user, show message
          }

          String uid = currentUser.uid;

          // Proceed with checking if the chef request is pending
          return FutureBuilder<bool>(
            future: CheckRequest().isChefPending(uid), // Call your future function
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator()); // Show loading while waiting for the result
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}')); // Handle errors
              }

              if (snapshot.hasData) {
                bool isChefPending = snapshot.data ?? false; // Get the result from the snapshot

                if (isChefPending) {
                  return ChefOrders(); // Show ChefOrders if chef is accepted
                } else {
                  return SearchPage(); // Show SearchPage if not accepted
                }
              }

              return Center(child: Text('No data found')); // In case there's no data
            },
          );
        },
      ),
    );
  }
}
