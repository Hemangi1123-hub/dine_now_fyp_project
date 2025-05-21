import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception (Sign In): ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Sign up with email and password
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // User created successfully in Auth, now add details to Firestore
      if (userCredential.user != null) {
        await _createUserDocument(userCredential.user!, name, email, role);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception (Sign Up): ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Helper method to create user document in Firestore
  Future<void> _createUserDocument(
    User user,
    String name,
    String email,
    String role,
  ) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(), // Record creation time
      });
    } catch (e) {
      // Handle potential Firestore errors during user document creation
      print('Firestore Error creating user document: $e');
      // Optional: Decide if you need to delete the Auth user if Firestore fails
      // await user.delete();
      // Rethrow or handle appropriately based on desired app behavior
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Forgot password - sends password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://dinenow.page.link/reset-password', // Replace with your actual dynamic link domain
          handleCodeInApp: true,
          androidPackageName: 'com.example.dine_now',
          androidInstallApp: true,
          androidMinimumVersion: '1',
          iOSBundleId: 'com.example.dineNow'
        ),
      );
      print('Password reset email sent successfully to: $email');
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception (Password Reset): ${e.code} - ${e.message}');
      if (e.code == 'invalid-email') {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'The email address is not valid.',
        );
      } else if (e.code == 'user-not-found') {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found with this email address.',
        );
      } else if (e.code == 'missing-android-pkg-name') {
        print('Error: Android package name configuration is missing');
        throw FirebaseAuthException(
          code: 'configuration-error',
          message: 'There was an error in the app configuration. Please contact support.',
        );
      } else if (e.code == 'missing-continue-uri') {
        print('Error: Continue URL configuration is missing');
        throw FirebaseAuthException(
          code: 'configuration-error',
          message: 'There was an error in the app configuration. Please contact support.',
        );
      } else if (e.code == 'invalid-continue-uri') {
        print('Error: Continue URL is invalid');
        throw FirebaseAuthException(
          code: 'configuration-error',
          message: 'There was an error in the app configuration. Please contact support.',
        );
      } else {
        print('Unexpected error during password reset: ${e.code}');
        throw FirebaseAuthException(
          code: 'unknown-error',
          message: 'An unexpected error occurred. Please try again.',
        );
      }
    } catch (e) {
      print('Unexpected error during password reset: $e');
      rethrow;
    }
  }

  // TODO: Add methods for Google Sign-In, Apple Sign-In (as per requirements)
  // TODO: Add logic to store user roles/additional info in Firestore after signup/signin
  // TODO: Add method to fetch user role/profile from Firestore
}
