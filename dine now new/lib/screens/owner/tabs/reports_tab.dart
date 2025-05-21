import 'package:dine_now/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For number formatting

// FutureProvider to fetch total earnings
final totalEarningsProvider = FutureProvider.family<double, String>((
  ref,
  restaurantId,
) async {
  if (restaurantId.isEmpty) {
    return 0.0;
  }
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.calculateTotalEarnings(restaurantId);
});

class ReportsTab extends ConsumerWidget {
  final String restaurantId;
  const ReportsTab({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsAsyncValue = ref.watch(totalEarningsProvider(restaurantId));
    final theme = Theme.of(context);
    final numberFormat = NumberFormat.currency(
      locale: 'en_NP', // Nepalese locale
      symbol: 'NPR ', // Currency symbol
      decimalDigits: 2,
    );

    return Scaffold(
      // No AppBar needed as it's a tab
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate the provider to refetch
          ref.invalidate(totalEarningsProvider(restaurantId));
          // Wait for the future to complete if needed, often invalidate is enough
          await ref.read(totalEarningsProvider(restaurantId).future);
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: earningsAsyncValue.when(
              data:
                  (totalEarnings) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total Earnings (All Time)',
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        numberFormat.format(totalEarnings),
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // Placeholder for future filters/charts
                      const Text(
                        '(More reporting features coming soon)',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) {
                print("Error loading earnings: $error\n$stack");
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Could not load earnings.',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: () {
                        ref.invalidate(totalEarningsProvider(restaurantId));
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
