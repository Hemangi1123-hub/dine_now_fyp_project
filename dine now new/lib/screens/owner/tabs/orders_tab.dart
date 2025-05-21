import 'package:dine_now/services/firestore_service.dart'; // Import Firestore service
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:dine_now/models/order_model.dart'
    as app_order; // Import with prefix

// Provider to stream restaurant's orders
final restaurantOrdersStreamProvider =
    StreamProvider.family<List<app_order.Order>, String>((ref, restaurantId) {
      if (restaurantId.isEmpty) {
        return Stream.value([]); // Return empty stream if no restaurant ID
      }
      final firestoreService = ref.watch(firestoreServiceProvider);
      return firestoreService.getOrdersForRestaurantStream(restaurantId);
    });

class OrdersTab extends ConsumerWidget {
  final String restaurantId;
  const OrdersTab({super.key, required this.restaurantId});

  // Function to handle refresh logic
  Future<void> _refreshOrders(WidgetRef ref) async {
    // Invalidate the provider to refetch the orders
    ref.invalidate(restaurantOrdersStreamProvider(restaurantId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsyncValue = ref.watch(
      restaurantOrdersStreamProvider(restaurantId),
    );
    final theme = Theme.of(context);

    return Scaffold(
      // No AppBar needed as it's a tab
      body: ordersAsyncValue.when(
        // Wrap the content with RefreshIndicator
        data:
            (orders) => RefreshIndicator(
              onRefresh: () => _refreshOrders(ref),
              child:
                  orders.isEmpty
                      ? LayoutBuilder(
                        // Ensure Center takes full height for RefreshIndicator
                        builder:
                            (context, constraints) => SingleChildScrollView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(), // Allow refresh even when empty
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: const Center(
                                  child: Text(
                                    'No orders received yet.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                      )
                      : ListView.builder(
                        // Ensure ListView is always scrollable for RefreshIndicator
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final app_order.Order order = orders[index];
                          final formattedDate = DateFormat(
                            'yyyy-MM-dd HH:mm',
                          ).format(order.orderTimestamp);

                          // Determine status and color
                          final bool isPaid =
                              order.status.toLowerCase() == 'success';
                          final statusText =
                              isPaid
                                  ? 'Paid'
                                  : order.status; // Or 'Pending'/'Not Paid'
                          final statusColor =
                              isPaid ? Colors.green : Colors.orange;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6, // Slightly reduce vertical margin
                            ),
                            child: ListTile(
                              dense: true, // Make items a bit more compact
                              leading: Icon(Icons.receipt, color: statusColor),
                              title: Text(
                                'Order on $formattedDate',
                                style: theme.textTheme.bodyMedium,
                              ),
                              subtitle: Text(
                                'Txn: ${order.transactionId.substring(0, 8)}...',
                                style: theme.textTheme.bodySmall,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'NPR ${order.totalAmount.toStringAsFixed(0)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    statusText,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                _showOrderDetails(context, order);
                              },
                              // isThreeLine: true, // Remove this, layout handles it
                            ),
                          );
                        },
                      ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          print("Error loading restaurant orders: $error\n$stack");
          // Also allow refresh on error state
          return RefreshIndicator(
            onRefresh: () => _refreshOrders(ref),
            child: LayoutBuilder(
              // Ensure Center takes full height
              builder:
                  (context, constraints) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Error loading orders: ${error.toString()}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
            ),
          );
        },
      ),
    );
  }

  // Helper function to show order details (Adapted from MyOrdersScreen)
  void _showOrderDetails(BuildContext context, app_order.Order order) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final formattedDate = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(order.orderTimestamp);

        // TODO: Fetch customer details based on order.userId if needed for display

        return AlertDialog(
          title: Text('Order Details (Txn: ${order.transactionId})'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Text('Customer: ${customerName}'), // Add customer name if fetched
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
            // TODO: Add actions like 'Update Status' if needed
          ],
        );
      },
    );
  }
}
