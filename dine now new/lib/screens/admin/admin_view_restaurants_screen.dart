import 'package:dine_now/providers/restaurant_provider.dart';
import 'package:dine_now/providers/user_provider.dart'; // For firestoreServiceProvider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminViewRestaurantsScreen extends ConsumerWidget {
  const AdminViewRestaurantsScreen({super.key});

  Future<void> _toggleRestaurantStatus(
    WidgetRef ref,
    BuildContext context,
    String restaurantId,
    bool currentStatus,
  ) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    final success = await firestoreService.updateRestaurantStatus(
      restaurantId,
      !currentStatus,
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status for restaurant $restaurantId'),
        ),
      );
      // Optionally, refresh the list provider if the UI doesn't update automatically
      // ref.refresh(restaurantsStreamProvider);
    }
    // No success message needed, switch reflects change
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the stream provider for restaurants
    final restaurantsAsyncValue = ref.watch(restaurantsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Restaurants')),
      body: restaurantsAsyncValue.when(
        data: (restaurants) {
          if (restaurants.isEmpty) {
            return const Center(child: Text('No restaurants added yet.'));
          }
          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              return ListTile(
                // leading: CircleAvatar( // Optional: Display image thumbnail
                //   backgroundImage: NetworkImage(restaurant.imageUrl),
                //   onBackgroundImageError: (_, __) => {}, // Handle error
                //   child: restaurant.imageUrl.isEmpty ? const Icon(Icons.business) : null,
                // ),
                title: Text(restaurant.name),
                subtitle: Text('Owner: ${restaurant.ownerEmail}'),
                trailing: Switch(
                  value: restaurant.isActive,
                  onChanged: (newValue) {
                    _toggleRestaurantStatus(
                      ref,
                      context,
                      restaurant.id,
                      restaurant.isActive,
                    );
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                // TODO: Add onTap to navigate to a detailed restaurant view/edit screen
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          print('Error loading restaurants for admin: $error\n$stack');
          return Center(child: Text('Could not load restaurants: $error'));
        },
      ),
    );
  }
}
 