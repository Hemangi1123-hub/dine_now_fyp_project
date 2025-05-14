import 'package:dine_now/models/menu_item_model.dart';
import 'package:dine_now/models/restaurant_model.dart';
import 'package:dine_now/providers/restaurant_provider.dart'; // For menu stream & opening hours provider
// For firestore service
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dine_now/models/timing_model.dart'; // For DailyOpeningHours
// For date formatting
import 'package:dine_now/screens/customer/booking_screen.dart';
import 'package:dine_now/screens/customer/menu_order_screen.dart';

// Provider to fetch a single restaurant's details
// This assumes the basic RestaurantModel might already be available or fetched efficiently elsewhere
// For simplicity, let's assume we pass the ID and rely on other providers for details
final restaurantDetailsProvider =
    FutureProvider.family<RestaurantModel?, String>((ref, restaurantId) async {
      // Re-fetch basic details (could be optimized)
      final restaurants = await ref.watch(
        activeRestaurantsStreamProvider.future,
      );
      try {
        return restaurants.firstWhere((r) => r.id == restaurantId);
      } catch (e) {
        print("Error finding restaurant $restaurantId in provider: $e");
        return null; // Not found
      }
    });

// Note: detailsOpeningHoursProvider is already defined in restaurant_provider.dart
// We will use that directly in the build method.

class RestaurantDetailsScreen extends ConsumerWidget {
  final String restaurantId;
  const RestaurantDetailsScreen({super.key, required this.restaurantId});

  String _formatTime(BuildContext context, TimeOfDay? time) {
    if (time == null) return 'N/A';
    return time.format(context);
  }

  Widget _buildOpeningHours(
    BuildContext context,
    List<DailyOpeningHours> hoursList, // Changed from Map to List
  ) {
    final theme = Theme.of(context);
    if (hoursList.isEmpty) {
      return Text(
        'Opening hours not available.',
        style: theme.textTheme.bodyMedium,
      );
    }
    // Ensure sorted 0-6 (Mon-Sun)
    hoursList.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

    final todayWeekdayIndex = DateTime.now().weekday - 1; // 0=Mon, 6=Sun

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Opening Hours', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        for (var entry in hoursList)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.dayName, // Use dayName getter from DailyOpeningHours
                  style: TextStyle(
                    fontWeight:
                        entry.dayOfWeek == todayWeekdayIndex
                            ? FontWeight.bold
                            : FontWeight.normal,
                    color:
                        entry.dayOfWeek == todayWeekdayIndex
                            ? theme.colorScheme.primary
                            : null,
                  ),
                ),
                Text(
                  entry.isOpen &&
                          entry.openTime != null &&
                          entry.closeTime != null
                      ? '${_formatTime(context, entry.openTime)} - ${_formatTime(context, entry.closeTime)}'
                      : 'Closed',
                  style: TextStyle(
                    fontWeight:
                        entry.dayOfWeek == todayWeekdayIndex
                            ? FontWeight.bold
                            : FontWeight.normal,
                    color:
                        entry.isOpen
                            ? (entry.dayOfWeek == todayWeekdayIndex
                                ? theme.colorScheme.primary
                                : null)
                            : Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    WidgetRef ref,
    List<MenuItemModel> menuItems,
  ) {
    final theme = Theme.of(context);
    if (menuItems.isEmpty) {
      return const Text('Menu not available yet.');
    }
    final groupedMenu = <String, List<MenuItemModel>>{};
    for (var item in menuItems) {
      if (item.isAvailable) {
        // Only show available items to customer
        (groupedMenu[item.category] ??= []).add(item);
      }
    }
    final categories =
        groupedMenu.keys.toList()..sort(); // Sort categories alphabetically

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Menu Highlights', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        if (categories.isEmpty) const Text('No available menu items found.'),
        for (var category in categories)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.isNotEmpty
                      ? category
                      : 'Other', // Handle empty category name
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                for (var item in groupedMenu[category]!)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading:
                        item.imageUrl.isNotEmpty
                            ? CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                item.imageUrl,
                              ),
                              radius: 25,
                              backgroundColor: Colors.grey[200],
                            )
                            : CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey[200],
                              child: Icon(Icons.restaurant_menu),
                            ), // Placeholder icon
                    title: Text(item.name),
                    subtitle:
                        item.description.isNotEmpty
                            ? Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                            : null,
                    trailing: Text(
                      'NPR ${item.price.toStringAsFixed(0)}', // Format price
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(restaurantDetailsProvider(restaurantId));
    final menuAsync = ref.watch(restaurantMenuStreamProvider(restaurantId));
    // Use the correct opening hours provider from restaurant_provider.dart
    final hoursAsync = ref.watch(detailsOpeningHoursProvider(restaurantId));
    final theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: restaurantAsync.whenOrNull(
        data:
            (restaurant) =>
                restaurant == null
                    ? null
                    : BottomAppBar(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => BookingScreen(
                                          restaurant: restaurant,
                                        ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.calendar_month),
                              label: const Text('Book Table'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ), // Spacing between buttons
                            ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to MenuOrderScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => MenuOrderScreen(
                                          restaurant: restaurant,
                                        ), // Pass restaurant
                                  ),
                                );
                              },
                              icon: const Icon(Icons.fastfood),
                              label: const Text('Order Food'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
      ),
      body: restaurantAsync.when(
        data: (restaurant) {
          if (restaurant == null) {
            return const Center(child: Text('Restaurant not found.'));
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220.0,
                pinned: true,
                stretch: true,
                backgroundColor: theme.colorScheme.primary,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.zero,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: restaurant.imageUrl,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) =>
                                Container(color: Colors.grey[300]),
                        errorWidget:
                            (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.restaurant,
                                color: Colors.grey[600],
                                size: 60,
                              ),
                            ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.7, 1.0],
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.2),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16.0,
                        left: 16.0,
                        right: 16.0,
                        child: Text(
                          restaurant.name,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 6.0,
                                color: Colors.black.withOpacity(0.7),
                                offset: const Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  stretchModes: const [StretchMode.zoomBackground],
                ),
              ),
              // Body content using SliverList
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Basic Info Section
                    Text(
                      restaurant.cuisine,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(restaurant.address, style: theme.textTheme.bodyMedium),
                    // Add rating later if available
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Opening Hours Section
                    hoursAsync.when(
                      data:
                          (hoursList) => _buildOpeningHours(context, hoursList),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error loading hours: $err'),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Menu Section
                    menuAsync.when(
                      data:
                          (menuItems) =>
                              _buildMenuSection(context, ref, menuItems),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error loading menu: $err'),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading restaurant details: $err\n$stack',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
      ),
    );
  }
}
