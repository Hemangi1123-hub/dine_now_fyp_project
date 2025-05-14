// Import UserModel
import 'package:dine_now/providers/user_provider.dart'; // Import user provider
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
// Import REAL screens
import '../customer/customer_main_screen.dart'; // Import the new main screen
import '../owner/owner_home_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../chef/chef_dashboard_screen.dart';
import '../staff/staff_home_screen.dart';
import '../placeholder/unknown_role_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    // Directly use .when() without AnimatedSwitcher for debugging
    return authState.when(
      data: (firebaseUser) {
        // Directly call _buildContent without KeyedSubtree
        return _buildContent(context, ref, firebaseUser);
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) {
        print('Error in auth state stream: $error\n$stackTrace');
        return Scaffold(
          body: Center(child: Text('Authentication error! $error')),
        );
      },
    );
  }

  // Helper function to build the main content based on auth state
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    User? firebaseUser,
  ) {
    if (firebaseUser != null) {
      // User is signed in, now fetch their user data/role
      final userDataAsyncValue = ref.watch(currentUserDataProvider);

      return userDataAsyncValue.when(
        data: (userModel) {
          if (userModel != null) {
            // Route based on role
            switch (userModel.role) {
              case 'customer':
                // Navigate to the new wrapper screen with bottom navigation
                return const CustomerMainScreen();
              case 'chef':
                return const ChefDashboardScreen();
              case 'owner':
                return const OwnerHomeScreen();
              case 'admin':
                return const AdminDashboardScreen();
              case 'staff':
                return const StaffHomeScreen();
              default: // Handle unexpected role or error
                return const UnknownRoleScreen();
            }
          } else {
            // User authenticated but no Firestore document
            print(
              'Error: User authenticated but Firestore document missing for UID: ${firebaseUser.uid}',
            );
            return Scaffold(
              appBar: AppBar(title: const Text("Error")),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Could not load user profile. Please contact support.',
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => ref.read(authServiceProvider).signOut(),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
        loading:
            () => const Scaffold(
              body: Center(child: Text('Loading user data...')),
            ),
        error: (error, stack) {
          print('Error loading user data: $error\n$stack');
          return Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Error loading user profile. Please try again later.',
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => ref.read(authServiceProvider).signOut(),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // User is signed out
      print(
        "[AuthWrapper] Firebase user is null. Showing LoginScreen.",
      ); // Keep this log
      return const LoginScreen(); // Show login screen
    }
  }
}
