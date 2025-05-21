import 'package:dine_now/models/restaurant_model.dart';
import 'package:dine_now/providers/auth_provider.dart';
import 'package:dine_now/providers/user_provider.dart';
import 'package:dine_now/providers/restaurant_provider.dart'; // Import needed provider
import 'package:dine_now/screens/owner/restaurant_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to fetch the details of the restaurant assigned to the staff
final assignedRestaurantProvider = FutureProvider<RestaurantModel?>((
  ref,
) async {
  final user = ref.watch(currentUserDataProvider).valueOrNull;
  if (user == null || user.assignedRestaurantId == null) {
    return null; // No assignment or user not loaded
  }

  // Fetch all restaurants (using active stream for now)
  // TODO: Consider using a direct document fetch or the non-active stream if staff need to manage inactive restaurants.
  final allRestaurants = await ref.watch(
    activeRestaurantsStreamProvider.future,
  );

  // Ensure the list isn't null before searching
  if (allRestaurants.isEmpty) {
    return null;
  }

  try {
    // Find the assigned restaurant in the list
    final restaurant = allRestaurants.firstWhere(
      (r) => r.id == user.assignedRestaurantId,
    );
    return restaurant;
  } catch (e) {
    // Handle the case where firstWhere finds no element
    return null; // Restaurant not found or inactive
  }
});

// --- Staff Home Screen Widget ---

class StaffHomeScreen extends ConsumerWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);
    final assignedRestaurantAsync = ref.watch(assignedRestaurantProvider);

    // Watch user data
    return userAsync.when(
      data: (user) {
        // Handle user null case
        if (user == null) {
          return _buildErrorScaffold(
            context,
            ref,
            'Error: User data not found.',
          );
        }

        // Handle no assignment case
        if (user.assignedRestaurantId == null) {
          return _buildInfoScaffold(
            context,
            ref,
            'You are not currently assigned to manage a restaurant. Please contact your owner/admin.',
          );
        }

        // User exists and has assignment ID, watch restaurant data
        return assignedRestaurantAsync.when(
          data: (restaurant) {
            if (restaurant != null) {
              // --- SUCCESS CASE ---
              // Return ONLY the management screen (it provides its own Scaffold/AppBar)
              return RestaurantManagementScreen(
                restaurant: restaurant,
                userRole: user.role, // Pass user role
              );
            } else {
              // --- RESTAURANT NOT FOUND/INACTIVE CASE ---
              return _buildInfoScaffold(
                context,
                ref,
                'Assigned restaurant not found or is inactive. Please contact admin.',
              );
            }
          },
          // --- RESTAURANT LOADING CASE ---
          loading: () {
            return _buildLoadingScaffold(
              context,
              ref,
              'Loading restaurant data...',
            );
          },
          // --- RESTAURANT ERROR CASE ---
          error: (err, stack) {
            return _buildErrorScaffold(
              context,
              ref,
              'Error loading assigned restaurant: $err',
            );
          },
        );
      },
      // --- USER LOADING CASE ---
      loading: () {
        return _buildLoadingScaffold(context, ref, 'Loading user data...');
      },
      // --- USER ERROR CASE ---
      error: (err, stack) {
        return _buildErrorScaffold(
          context,
          ref,
          'Error loading your user data: $err',
        );
      },
    );
  }

  // --- Helper methods to build Scaffolds with AppBar ---

  // Base Scaffold builder
  Widget _buildScaffoldWithAppBar(
    BuildContext context,
    WidgetRef ref,
    Widget bodyContent,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            // Simple sign out, AuthWrapper handles redirection
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: bodyContent,
    );
  }

  // Helper for Loading states
  Widget _buildLoadingScaffold(
    BuildContext context,
    WidgetRef ref,
    String message,
  ) {
    return _buildScaffoldWithAppBar(
      context,
      ref,
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  // Helper for Error states
  Widget _buildErrorScaffold(
    BuildContext context,
    WidgetRef ref,
    String message,
  ) {
    return _buildScaffoldWithAppBar(
      context,
      ref,
      Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  // Helper for Informational states (like no assignment)
  Widget _buildInfoScaffold(
    BuildContext context,
    WidgetRef ref,
    String message,
  ) {
    return _buildScaffoldWithAppBar(
      context,
      ref,
      Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
