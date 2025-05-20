import 'package:dine_now/screens/owner/tabs/reports_tab.dart'; // Reuse earnings provider
import 'package:dine_now/screens/owner/tabs/orders_tab.dart'; // Reuse orders provider
import 'package:dine_now/models/order_model.dart' as app_order;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For number formatting
import '../restaurant_management_screen.dart'; // Import for provider

// TODO: Add providers for recent orders, pending bookings etc.

class DashboardTab extends ConsumerWidget {
  final String restaurantId;
  const DashboardTab({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsAsyncValue = ref.watch(totalEarningsProvider(restaurantId));
    // Watch the orders stream for recent orders
    final ordersAsyncValue = ref.watch(
      restaurantOrdersStreamProvider(restaurantId),
    );
    final theme = Theme.of(context);
    final numberFormat = NumberFormat.currency(
      locale: 'en_NP',
      symbol: 'NPR ',
      decimalDigits: 0, // Show whole numbers for dashboard summary
    );
    final dateFormat = DateFormat('MMM d, HH:mm'); // Format for recent orders

    return Scaffold(
      // No AppBar needed, part of TabBarView
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate relevant providers
          ref.invalidate(totalEarningsProvider(restaurantId));
          ref.invalidate(
            restaurantOrdersStreamProvider(restaurantId),
          ); // Invalidate orders too
          // Add invalidation for other dashboard items here
          await Future.wait([
            ref.read(totalEarningsProvider(restaurantId).future),
            ref.read(restaurantOrdersStreamProvider(restaurantId).future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Earnings Card ---
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Earnings', // Simpler title for dashboard
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    earningsAsyncValue.when(
                      data:
                          (earnings) => Text(
                            numberFormat.format(earnings),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      loading:
                          () => const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      error:
                          (err, _) => Text(
                            'Error loading earnings',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '(All time successful orders)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Recent Orders Card ---
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Orders', style: theme.textTheme.titleLarge),
                    const Divider(height: 16),
                    ordersAsyncValue.when(
                      data: (orders) {
                        if (orders.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Center(child: Text('No orders yet.')),
                          );
                        }
                        // Take the first 3 orders (or fewer if less than 3 exist)
                        final recentOrders = orders.take(3).toList();
                        return Column(
                          children:
                              recentOrders.map((order) {
                                final bool isPaid =
                                    order.status.toLowerCase() == 'success';
                                final statusText =
                                    isPaid
                                        ? 'Paid'
                                        : order
                                            .status; // Or 'Pending'/'Not Paid'
                                final statusColor =
                                    isPaid ? Colors.green : Colors.orange;
                                return ListTile(
                                  dense: true,
                                  leading: Icon(
                                    Icons.receipt,
                                    color: statusColor,
                                  ),
                                  title: Text(
                                    'Order on ${dateFormat.format(order.orderTimestamp)}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  subtitle: Text(
                                    'Txn: ${order.transactionId.substring(0, 8)}...',
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'NPR ${order.totalAmount.toStringAsFixed(0)}',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        statusText,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: statusColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  // Optional: Add onTap to navigate to full order details
                                  onTap:
                                      () => _showOrderDetails(context, order),
                                );
                              }).toList(),
                        );
                      },
                      loading:
                          () => const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      error:
                          (err, _) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Error loading orders',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                    ),
                    // Optional: Add a 'View All' button
                    if (ordersAsyncValue.hasValue &&
                        (ordersAsyncValue.value?.isNotEmpty ?? false))
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          child: const Text('View All Orders'),
                          onPressed: () {
                            // Find the index of the 'orders' tab for the owner
                            // Note: This assumes the order of _allTabs in RestaurantManagementScreen
                            // WARNING: This index is hardcoded and fragile. If the order of tabs in
                            // RestaurantManagementScreen._allTabs changes, this index MUST be updated.
                            // Current order: Dashboard[0], Details[1], Timings[2], Staff[3], Menu[4], Bookings[5], Orders[6], Reports[7]
                            const ordersTabIndex = 6;

                            // Update the provider to request navigation
                            ref.read(requestedTabIndexProvider.notifier).state =
                                ordersTabIndex;
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Placeholder for Pending Bookings ---
            Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(
                  Icons.event_available,
                  color: theme.colorScheme.tertiary ?? Colors.blue,
                ),
                title: const Text('Pending Bookings'),
                subtitle: const Text('Check new requests'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // TODO: Navigate to Bookings tab or show pending bookings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pending Bookings view coming soon!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),

            // Add more dashboard widgets (e.g., quick links, stats) here
          ],
        ),
      ),
    );
  }

  // Helper function to show order details (Copied/Adapted from OrdersTab)
  // Consider moving this to a shared utility if used in multiple places
  void _showOrderDetails(BuildContext context, app_order.Order order) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final formattedDate = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(order.orderTimestamp);

        return AlertDialog(
          title: Text('Order Details (Txn: ${order.transactionId})'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Date: $formattedDate'),
                Text('Status: ${order.status}'),
                Text(
                  'Total Paid: NPR ${order.totalAmount.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                const Divider(),
                Text('Items Ordered:', style: theme.textTheme.titleMedium),
                if (order.items.isEmpty)
                  const Text('No items found in this order data.'),
                ...order.items.map((item) {
                  final itemName = item['name'] ?? 'Unknown Item';
                  final itemQty = item['quantity'] ?? 0;
                  final itemPrice = (item['price'] ?? 0.0).toDouble();
                  return ListTile(
                    dense: true,
                    title: Text('$itemQty x $itemName'),
                    trailing: Text(
                      'NPR ${(itemPrice * itemQty).toStringAsFixed(0)}',
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
