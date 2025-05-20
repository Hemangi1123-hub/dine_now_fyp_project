import 'package:dine_now/providers/booking_provider.dart';
import 'package:dine_now/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ManageBookingsTab extends ConsumerWidget {
  final String restaurantId;
  const ManageBookingsTab({super.key, required this.restaurantId});

  // Helper to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'completed': // Optional future status
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  // Function to update booking status
  Future<void> _updateStatus(
    WidgetRef ref,
    BuildContext context,
    String bookingId,
    String newStatus,
  ) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    final success = await firestoreService.updateBookingStatus(
      bookingId,
      newStatus,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Booking status updated to $newStatus.'
                : 'Failed to update booking status.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(restaurantBookingsProvider(restaurantId));
    final theme = Theme.of(context);

    return Scaffold(
      // No AppBar needed as it's a tab
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(
              child: Text('No bookings found for this restaurant.'),
            );
          }

          // Separate pending bookings from others
          final pendingBookings =
              bookings
                  .where((b) => b.status.toLowerCase() == 'pending')
                  .toList();
          final otherBookings =
              bookings
                  .where((b) => b.status.toLowerCase() != 'pending')
                  .toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (pendingBookings.isNotEmpty)
                Text('Pending Requests', style: theme.textTheme.headlineSmall),
              if (pendingBookings.isNotEmpty) const Divider(),
              ...pendingBookings.map(
                (booking) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      '${booking.userName} - ${booking.partySize} person(s)',
                    ),
                    subtitle: Text(
                      '${DateFormat.yMMMEd().add_jm().format(booking.bookingDateTime)}\nEmail: ${booking.userEmail}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          tooltip: 'Confirm Booking',
                          onPressed:
                              () => _updateStatus(
                                ref,
                                context,
                                booking.id!,
                                'confirmed',
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          tooltip: 'Reject Booking',
                          onPressed:
                              () => _updateStatus(
                                ref,
                                context,
                                booking.id!,
                                'rejected',
                              ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
              if (pendingBookings.isNotEmpty && otherBookings.isNotEmpty)
                const SizedBox(height: 24),
              if (otherBookings.isNotEmpty)
                Text('Other Bookings', style: theme.textTheme.headlineSmall),
              if (otherBookings.isNotEmpty) const Divider(),
              ...otherBookings.map(
                (booking) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      '${booking.userName} - ${booking.partySize} person(s)',
                    ),
                    subtitle: Text(
                      DateFormat.yMMMEd().add_jm().format(
                        booking.bookingDateTime,
                      ),
                    ),
                    trailing: Chip(
                      label: Text(
                        booking.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: _getStatusColor(booking.status),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error loading bookings: $error'),
              ),
            ),
      ),
    );
  }
}
