import 'package:dine_now/providers/auth_provider.dart';
import 'package:dine_now/providers/restaurant_provider.dart';
import 'package:dine_now/widgets/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'restaurant_details_screen.dart'; // Import details screen
import 'my_bookings_screen.dart'; // Import My Bookings screen

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    final cuisines = ref.read(availableCuisinesProvider);
    final currentCuisine = ref.read(selectedCuisineProvider);
    final currentRating = ref.read(ratingFilterProvider);
    final currentSortOption = ref.read(sortOptionProvider);

    String? selectedCuisine = currentCuisine;
    double selectedRating = currentRating;
    SortOption selectedSort = currentSortOption;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter & Sort'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cuisine Filter
                    const Text(
                      'Cuisine Type',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: selectedCuisine == null,
                          onSelected: (selected) {
                            setState(() => selectedCuisine = null);
                          },
                        ),
                        ...cuisines.map((cuisine) {
                          return FilterChip(
                            label: Text(cuisine),
                            selected: selectedCuisine == cuisine,
                            onSelected: (selected) {
                              setState(
                                () =>
                                    selectedCuisine = selected ? cuisine : null,
                              );
                            },
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // Minimum Rating
                    const Text(
                      'Minimum Rating',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: selectedRating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label:
                          selectedRating == 0
                              ? 'Any'
                              : selectedRating.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() => selectedRating = value);
                      },
                    ),

                    const SizedBox(height: 16),
                    // Sort Options
                    const Text(
                      'Sort By',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildSortOption(
                      selectedSort,
                      SortOption.nameAsc,
                      'Name (A-Z)',
                      Icons.sort_by_alpha,
                      setState,
                    ),
                    _buildSortOption(
                      selectedSort,
                      SortOption.nameDesc,
                      'Name (Z-A)',
                      Icons.sort_by_alpha,
                      setState,
                    ),
                    _buildSortOption(
                      selectedSort,
                      SortOption.ratingHighToLow,
                      'Rating (High to Low)',
                      Icons.star,
                      setState,
                    ),
                    _buildSortOption(
                      selectedSort,
                      SortOption.ratingLowToHigh,
                      'Rating (Low to High)',
                      Icons.star_outline,
                      setState,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Reset filters
                    ref.read(selectedCuisineProvider.notifier).state = null;
                    ref.read(ratingFilterProvider.notifier).state = 0.0;
                    ref.read(sortOptionProvider.notifier).state =
                        SortOption.nameAsc;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Reset'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    // Apply filters
                    ref.read(selectedCuisineProvider.notifier).state =
                        selectedCuisine;
                    ref.read(ratingFilterProvider.notifier).state =
                        selectedRating;
                    ref.read(sortOptionProvider.notifier).state = selectedSort;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption(
    SortOption currentOption,
    SortOption option,
    String label,
    IconData icon,
    StateSetter setState,
  ) {
    return RadioListTile<SortOption>(
      title: Row(
        children: [Icon(icon, size: 16), const SizedBox(width: 8), Text(label)],
      ),
      value: option,
      groupValue: currentOption,
      onChanged: (SortOption? value) {
        if (value != null) {
          setState(() => currentOption = value);
        }
      },
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRestaurants = ref.watch(filteredRestaurantsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedCuisine = ref.watch(selectedCuisineProvider);
    final minRating = ref.watch(ratingFilterProvider);

    // Check if any filters are active
    final hasActiveFilters = selectedCuisine != null || minRating > 0;

    return Scaffold(
      appBar: AppBar(
        title:
            _showSearchBar
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search restaurants...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                )
                : const Text('Find Restaurants'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        actions: [
          // Search icon
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search),
            tooltip: _showSearchBar ? 'Close Search' : 'Search',
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
                if (!_showSearchBar) {
                  // Clear search when closing
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                }
              });
            },
          ),
          // Filter icon with indicator badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter',
                onPressed: _showFilterDialog,
              ),
              if (hasActiveFilters)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'My Bookings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active filters display
          if (hasActiveFilters || searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[200],
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (searchQuery.isNotEmpty)
                          Chip(
                            label: Text('Search: $searchQuery'),
                            onDeleted: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                            visualDensity: VisualDensity.compact,
                          ),
                        if (selectedCuisine != null)
                          Chip(
                            label: Text('Cuisine: $selectedCuisine'),
                            onDeleted: () {
                              ref.read(selectedCuisineProvider.notifier).state =
                                  null;
                            },
                            visualDensity: VisualDensity.compact,
                          ),
                        if (minRating > 0)
                          Chip(
                            label: Text(
                              'Min Rating: ${minRating.toStringAsFixed(1)}',
                            ),
                            onDeleted: () {
                              ref.read(ratingFilterProvider.notifier).state = 0;
                            },
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
                  if (hasActiveFilters || searchQuery.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // Clear all filters
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                        ref.read(selectedCuisineProvider.notifier).state = null;
                        ref.read(ratingFilterProvider.notifier).state = 0;
                      },
                      child: const Text('Clear All'),
                    ),
                ],
              ),
            ),

          // Restaurant list
          Expanded(
            child: RefreshIndicator(
              onRefresh:
                  () => ref.refresh(activeRestaurantsStreamProvider.future),
              child:
                  filteredRestaurants.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No restaurants found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: filteredRestaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = filteredRestaurants[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => RestaurantDetailsScreen(
                                        restaurantId: restaurant.id,
                                      ),
                                ),
                              );
                            },
                            child: RestaurantCard(restaurant: restaurant),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
