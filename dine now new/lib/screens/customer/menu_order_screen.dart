import 'package:dine_now/models/menu_item_model.dart';
import 'package:dine_now/models/restaurant_model.dart';
import 'package:dine_now/providers/restaurant_provider.dart'; // Import provider
import 'package:dine_now/screens/customer/checkout_screen.dart'; // Import Checkout Screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Define a type for the cart item
typedef CartItem = ({MenuItemModel item, int quantity});

// StateNotifier for the cart
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(MenuItemModel item) {
    final existingIndex = state.indexWhere(
      (cartItem) => cartItem.item.id == item.id,
    );
    if (existingIndex != -1) {
      // Item exists, increase quantity
      final updatedItem = (
        item: state[existingIndex].item,
        quantity: state[existingIndex].quantity + 1,
      );
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex) updatedItem else state[i],
      ];
    } else {
      // Item does not exist, add with quantity 1
      state = [...state, (item: item, quantity: 1)];
    }
  }

  void removeItem(String itemId) {
    final existingIndex = state.indexWhere(
      (cartItem) => cartItem.item.id == itemId,
    );
    if (existingIndex != -1) {
      if (state[existingIndex].quantity > 1) {
        // Decrease quantity
        final updatedItem = (
          item: state[existingIndex].item,
          quantity: state[existingIndex].quantity - 1,
        );
        state = [
          for (int i = 0; i < state.length; i++)
            if (i == existingIndex) updatedItem else state[i],
        ];
      } else {
        // Remove item if quantity is 1
        state = state.where((cartItem) => cartItem.item.id != itemId).toList();
      }
    }
  }

  void clearCart() {
    state = [];
  }

  int get totalItems => state.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      state.fold(0.0, (sum, item) => sum + (item.item.price * item.quantity));
}

// Provider for the cart
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class MenuOrderScreen extends ConsumerWidget {
  // Changed to ConsumerWidget
  final RestaurantModel restaurant;

  const MenuOrderScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(restaurantMenuStreamProvider(restaurant.id));
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order from ${restaurant.name}'),
        actions: [
          // Show cart icon with item count
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed:
                    cart.isEmpty
                        ? null
                        : () {
                          // Navigate to Checkout Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      CheckoutScreen(restaurant: restaurant),
                            ),
                          );
                        },
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      cartNotifier.totalItems.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: menuAsync.when(
        data: (menuItems) {
          if (menuItems.isEmpty) {
            return const Center(
              child: Text('No menu items available for this restaurant.'),
            );
          }

          // Filter only available items
          final availableItems =
              menuItems.where((item) => item.isAvailable).toList();

          if (availableItems.isEmpty) {
            return const Center(
              child: Text('No menu items currently available.'),
            );
          }

          // Group by category
          final groupedMenu = <String, List<MenuItemModel>>{};
          for (var item in availableItems) {
            (groupedMenu[item.category] ??= []).add(item);
          }
          final categories = groupedMenu.keys.toList()..sort();

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, categoryIndex) {
              final category = categories[categoryIndex];
              final itemsInCategory = groupedMenu[category]!;

              return ExpansionTile(
                title: Text(
                  category.isNotEmpty ? category : 'Other',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                initiallyExpanded: true, // Keep categories expanded by default
                children:
                    itemsInCategory.map((item) {
                      final cartItem = cart.firstWhere(
                        (ci) => ci.item.id == item.id,
                        orElse:
                            () => (
                              item: item,
                              quantity: 0,
                            ), // Default if not in cart
                      );
                      final quantity = cartItem.quantity;

                      return ListTile(
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
                                ),
                        title: Text(item.name),
                        subtitle: Text('NPR ${item.price.toStringAsFixed(0)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (quantity > 0)
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed:
                                    () => cartNotifier.removeItem(item.id),
                                color: theme.colorScheme.error,
                              ),
                            if (quantity > 0)
                              Text(
                                quantity.toString(),
                                style: theme.textTheme.titleMedium,
                              ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => cartNotifier.addItem(item),
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(child: Text('Error loading menu: $error')),
      ),
      floatingActionButton:
          cart.isEmpty
              ? null
              : FloatingActionButton.extended(
                onPressed: () {
                  // Navigate to Checkout Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CheckoutScreen(restaurant: restaurant),
                    ),
                  );
                },
                label: Text('View Cart (${cartNotifier.totalItems})'),
                icon: const Icon(Icons.shopping_cart_checkout),
              ),
    );
  }
}
