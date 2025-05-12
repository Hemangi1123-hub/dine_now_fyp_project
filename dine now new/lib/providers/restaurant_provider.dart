import 'package:dine_now/models/menu_item_model.dart'; // Import MenuItemModel
import 'package:dine_now/models/restaurant_model.dart';
import 'package:dine_now/providers/user_provider.dart'; // Needs firestoreServiceProvider
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Needed for QuerySnapshot
import 'package:dine_now/models/timing_model.dart'; // Import DailyOpeningHours

// State provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// State provider for selected cuisine filter (null means all cuisines)
final selectedCuisineProvider = StateProvider<String?>((ref) => null);

// State provider for rating filter (min rating, 0 means all ratings)
final ratingFilterProvider = StateProvider<double>((ref) => 0.0);

// State provider for sorting option
final sortOptionProvider = StateProvider<SortOption>(
  (ref) => SortOption.nameAsc,
);

// Enum for sorting options
enum SortOption { nameAsc, nameDesc, ratingHighToLow, ratingLowToHigh }

// StreamProvider for ALL restaurants (Admin view)
final restaurantsStreamProvider = StreamProvider<List<RestaurantModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  // Pass includeInactive: true for admin view
  return firestoreService.getRestaurantsStream(includeInactive: true);
});

// StreamProvider for ACTIVE restaurants (Customer view)
final activeRestaurantsStreamProvider = StreamProvider<List<RestaurantModel>>((
  ref,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  // Default behavior (includeInactive: false)
  return firestoreService.getRestaurantsStream();
});

// Provider for filtered and searchable restaurants
final filteredRestaurantsProvider = Provider<List<RestaurantModel>>((ref) {
  final restaurantsAsyncValue = ref.watch(activeRestaurantsStreamProvider);

  return restaurantsAsyncValue.when(
    data: (restaurants) {
      final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
      final selectedCuisine = ref.watch(selectedCuisineProvider);
      final minRating = ref.watch(ratingFilterProvider);
      final sortOption = ref.watch(sortOptionProvider);

      // Apply filters
      var filteredList =
          restaurants.where((restaurant) {
            // Filter by search query (name or cuisine)
            final matchesSearch =
                searchQuery.isEmpty ||
                restaurant.name.toLowerCase().contains(searchQuery) ||
                restaurant.cuisine.toLowerCase().contains(searchQuery) ||
                restaurant.address.toLowerCase().contains(searchQuery);

            // Filter by cuisine
            final matchesCuisine =
                selectedCuisine == null ||
                restaurant.cuisine == selectedCuisine;

            // Filter by rating
            final matchesRating = restaurant.rating >= minRating;

            return matchesSearch && matchesCuisine && matchesRating;
          }).toList();

      // Apply sorting
      switch (sortOption) {
        case SortOption.nameAsc:
          filteredList.sort((a, b) => a.name.compareTo(b.name));
          break;
        case SortOption.nameDesc:
          filteredList.sort((a, b) => b.name.compareTo(a.name));
          break;
        case SortOption.ratingHighToLow:
          filteredList.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case SortOption.ratingLowToHigh:
          filteredList.sort((a, b) => a.rating.compareTo(b.rating));
          break;
      }

      return filteredList;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider to get unique cuisine types from available restaurants
final availableCuisinesProvider = Provider<List<String>>((ref) {
  final restaurantsAsyncValue = ref.watch(activeRestaurantsStreamProvider);

  return restaurantsAsyncValue.when(
    data: (restaurants) {
      final cuisines =
          restaurants
              .map((restaurant) => restaurant.cuisine)
              .toSet() // Remove duplicates
              .toList();
      cuisines.sort(); // Sort alphabetically
      return cuisines;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// StreamProvider for a specific restaurant's MENU (Owner & Customer view)
final restaurantMenuStreamProvider =
    StreamProvider.family<List<MenuItemModel>, String>((ref, restaurantId) {
      final firestoreService = ref.watch(firestoreServiceProvider);
      return firestoreService.getMenuStream(restaurantId);
    });

// StreamProvider for a specific restaurant's OPENING HOURS
final detailsOpeningHoursProvider = StreamProvider.family<
  List<DailyOpeningHours>,
  String
>((ref, restaurantId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  print(
    '[TimingProvider] Subscribing to document for $restaurantId',
  ); // Log subscription

  // Use the new service method to get the document stream
  return firestoreService
      .getRestaurantDocStream(restaurantId)
      .map((docSnapshot) {
        print(
          '[TimingProvider] Received document snapshot for $restaurantId. Exists: ${docSnapshot.exists}',
        ); // Log snapshot

        final hours = <DailyOpeningHours>[];
        Map<String, dynamic>? data;
        Map<String, dynamic> openingHoursMap = {};

        if (docSnapshot.exists && docSnapshot.data() != null) {
          data = docSnapshot.data() as Map<String, dynamic>;
          // Attempt to get the openingHours field, default to empty map if null or wrong type
          openingHoursMap =
              data['openingHours'] is Map<String, dynamic>
                  ? data['openingHours'] as Map<String, dynamic>
                  : {};
          print(
            '[TimingProvider] Raw openingHours map from doc: $openingHoursMap',
          );
        } else {
          print(
            '[TimingProvider] Document $restaurantId does not exist or has no data.',
          );
        }

        // Map the openingHoursMap field to List<DailyOpeningHours>
        for (int i = 0; i < 7; i++) {
          final dayKey = i.toString(); // Keys in the map are '0', '1', etc.
          print(
            '[TimingProvider] Processing day $i (key: $dayKey) for $restaurantId',
          );

          if (openingHoursMap.containsKey(dayKey) &&
              openingHoursMap[dayKey] is Map<String, dynamic>) {
            final dayData = openingHoursMap[dayKey] as Map<String, dynamic>;
            print('[TimingProvider] Day $i Data from Map Field: $dayData');
            try {
              final mappedHour = DailyOpeningHours.fromMap(i, dayData);
              print(
                '[TimingProvider] Day $i Mapped: isOpen=${mappedHour.isOpen}, Open=${mappedHour.openTime}, Close=${mappedHour.closeTime}',
              );
              hours.add(mappedHour);
            } catch (e) {
              print(
                '[TimingProvider] Error mapping Day $i data from map: $e. Adding default closed.',
              );
              hours.add(DailyOpeningHours(dayOfWeek: i, isOpen: false));
            }
          } else {
            print(
              '[TimingProvider] Day $i (key: $dayKey) missing or invalid in openingHours map. Adding default closed.',
            );
            hours.add(DailyOpeningHours(dayOfWeek: i, isOpen: false));
          }
        }

        print(
          '[TimingProvider] Returning mapped hours list for $restaurantId: ${hours.map((h) => h.toMap()).toList()}',
        );
        return hours;
      })
      .handleError((error, stackTrace) {
        print("Error in timings stream for $restaurantId: $error\n$stackTrace");
        return <DailyOpeningHours>[]; // Return empty list on error
      });
});

// You might add other providers here later, e.g.:
// - Filtered restaurants based on user search/cuisine selection
// - Provider for a single restaurant's details (if needed differently)
