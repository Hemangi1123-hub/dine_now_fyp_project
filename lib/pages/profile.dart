import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotel_management/pages/login_page.dart';
import 'package:hotel_management/pages/signIn_page.dart';

class ProfileScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: FutureBuilder<User?>(
          future: _getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasData && snapshot.data != null) {
              User user = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('User ID: ${user.uid}'),
                  SizedBox(height: 10),
                  Text('Username: ${user.displayName ?? 'No username'}'),
                  SizedBox(height: 10),
                  Text('Email: ${user.email ?? 'No email'}'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await _auth.signOut();
                      // Refresh the page after signing out
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()),
                      );
                    },
                    child: Text('Sign Out'),
                  ),
                ],
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Not Signed In'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the Sign-In Screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text('Sign In'),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<User?> _getCurrentUser() async {
    return _auth.currentUser;
  }
}

// Example SignInScreen widget
