import 'package:dine_now/models/booking_model.dart';
import 'package:dine_now/providers/user_provider.dart'; // For firestoreServiceProvider
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for getting bookings for a specific restaurant
final restaurantBookingsProvider =
    StreamProvider.family<List<BookingModel>, String>((ref, restaurantId) {
      final firestoreService = ref.watch(firestoreServiceProvider);
      return firestoreService.getBookingsForRestaurantStream(restaurantId);
    });

// Provider for getting bookings for a specific user
final userBookingsProvider = StreamProvider.family<List<BookingModel>, String>((
  ref,
  userId,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getBookingsForUserStream(userId);
});
