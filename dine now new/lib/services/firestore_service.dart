import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dine_now/models/user_model.dart';
import 'package:dine_now/models/restaurant_model.dart';
import 'package:dine_now/models/staff_model.dart';
import 'package:dine_now/models/menu_item_model.dart';
import 'package:dine_now/models/timing_model.dart';
import 'package:dine_now/models/booking_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Assuming Order model is here
import 'package:dine_now/models/order_model.dart' as app_order;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _usersCollection = 'users';
  final String _restaurantsCollection = 'restaurants';
  final String _bookingsCollection = 'bookings';
  final String _ordersCollection = 'orders';

  // --- User Methods --- //

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _db.collection(_usersCollection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        print('User document does not exist for uid: $uid');
        return null; // User document not found
      }
    } catch (e) {
      print('Error getting user data: $e');
      return null; // Return null or throw an error
    }
  }

  // Stream of all users (for Admin)
  Stream<List<UserModel>> getAllUsersStream() {
    return _db.collection(_usersCollection).snapshots().asyncMap((
      snapshot,
    ) async {
      try {
        // Use await here if mapping involves async operations, otherwise keep as is
        return snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList();
      } catch (e, stackTrace) {
        print("Error mapping users snapshot: $e\n$stackTrace");
        return <UserModel>[]; // Return typed empty list on mapping error
      }
    });
  }

  // Get users by a specific role
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      QuerySnapshot snapshot =
          await _db
              .collection(_usersCollection)
              .where('role', isEqualTo: role)
              .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e, stackTrace) {
      print("Error fetching users by role '$role': $e\n$stackTrace");
      return []; // Return empty list on error
    }
  }

  // --- Restaurant Methods --- //

  // Stream of all restaurants
  Stream<List<RestaurantModel>> getRestaurantsStream({
    bool includeInactive = false,
  }) {
    Query query = _db.collection(_restaurantsCollection);
    if (!includeInactive) {
      query = query.where('isActive', isEqualTo: true);
    }
    return query.snapshots().asyncMap((snapshot) async {
      try {
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => RestaurantModel.fromFirestore(doc))
              .toList();
        }
        return <RestaurantModel>[];
      } catch (e, stackTrace) {
        print("Error mapping restaurants snapshot: $e\n$stackTrace");
        return <RestaurantModel>[];
      }
    });
  }

  // Add a new restaurant
  Future<String?> addRestaurant({
    required String name,
    required String cuisine,
    required String address,
    required String imageUrl,
    required String ownerId,
  }) async {
    try {
      if (name.isEmpty ||
          cuisine.isEmpty ||
          address.isEmpty ||
          ownerId.isEmpty) {
        print("Validation failed: Missing required fields for new restaurant.");
        return null;
      }

      String? ownerEmail = await getUserData(
        ownerId,
      ).then((user) => user?.email);

      DocumentReference docRef = await _db
          .collection(_restaurantsCollection)
          .add({
            'name': name,
            'cuisine': cuisine,
            'address': address,
            'rating': 0.0,
            'imageUrl': imageUrl,
            'ownerEmail': ownerEmail ?? '',
            'ownerId': ownerId,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
            // Initialize openingHours map field with default closed values
            'openingHours': {
              for (int i = 0; i < 7; i++)
                i.toString():
                    DailyOpeningHours(dayOfWeek: i, isOpen: false).toMap(),
            },
          });
      print(
        "Restaurant added successfully with ID: ${docRef.id}, OwnerID: $ownerId",
      );
      return docRef.id;
    } catch (e) {
      print("Error adding restaurant: $e");
      return null;
    }
  }

  // Update restaurant active status (Admin)
  Future<bool> updateRestaurantStatus(
    String restaurantId,
    bool isActive,
  ) async {
    try {
      await _db.collection(_restaurantsCollection).doc(restaurantId).update({
        'isActive': isActive,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print("Restaurant $restaurantId status updated to: $isActive");
      return true;
    } catch (e) {
      print("Error updating restaurant status for $restaurantId: $e");
      return false;
    }
  }

  // Get restaurants assigned to a specific owner ID
  Stream<List<RestaurantModel>> getRestaurantsForOwner(String ownerId) {
    print(
      '[getRestaurantsForOwner] Querying restaurants where ownerId == $ownerId',
    );
    return _db
        .collection(_restaurantsCollection)
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .asyncMap((snapshot) async {
          print(
            '[getRestaurantsForOwner] Snapshot received. Docs count: ${snapshot.docs.length}',
          );
          try {
            final restaurants =
                snapshot.docs
                    .map((doc) => RestaurantModel.fromFirestore(doc))
                    .toList();
            print(
              '[getRestaurantsForOwner] Mapped ${restaurants.length} restaurants.',
            );
            return restaurants;
          } catch (e, stackTrace) {
            print("Error mapping owner restaurants snapshot: $e\n$stackTrace");
            return <RestaurantModel>[];
          }
        });
  }

  // Update Restaurant Details (Owner)
  Future<bool> updateRestaurantDetails(
    String restaurantId, {
    required String name,
    required String cuisine,
    required String address,
    required String imageUrl,
  }) async {
    try {
      if (name.isEmpty || cuisine.isEmpty || address.isEmpty) {
        print(
          "Validation failed: Missing required fields for updating restaurant.",
        );
        return false;
      }

      await _db.collection(_restaurantsCollection).doc(restaurantId).update({
        'name': name,
        'cuisine': cuisine,
        'address': address,
        'imageUrl': imageUrl, // Allow empty string
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print("Restaurant $restaurantId details updated successfully.");
      return true;
    } catch (e) {
      print("Error updating restaurant details for $restaurantId: $e");
      return false;
    }
  }

  // --- Staff Management Methods (Owner) ---

  // Get stream of staff for a specific restaurant
  Stream<List<StaffMemberModel>> getStaffStream(String restaurantId) {
    return _db
        .collection(_restaurantsCollection)
        .doc(restaurantId)
        .collection('staff')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          try {
            return snapshot.docs
                .map((doc) => StaffMemberModel.fromFirestore(doc))
                .toList();
          } catch (e, stackTrace) {
            print(
              "Error mapping staff snapshot for $restaurantId: $e\n$stackTrace",
            );
            return <StaffMemberModel>[];
          }
        });
  }

  // Add staff member to a restaurant by email
  Future<String?> addStaffByEmail(
    String restaurantId,
    String staffEmail,
  ) async {
    if (staffEmail.isEmpty || !staffEmail.contains('@')) {
      return 'Please enter a valid email address.';
    }

    try {
      // 1. Find the user with the given email
      QuerySnapshot userQuery =
          await _db
              .collection(_usersCollection)
              .where('email', isEqualTo: staffEmail)
              .limit(1)
              .get();

      if (userQuery.docs.isEmpty) {
        return 'No user found with email: $staffEmail. Ask them to sign up first.';
      }

      UserModel staffUser = UserModel.fromFirestore(userQuery.docs.first);

      // Allow adding users with customer/staff/chef roles
      if (staffUser.role != 'customer' &&
          staffUser.role != 'staff' &&
          staffUser.role != 'chef') {
        return 'User with email $staffEmail has an incompatible role (${staffUser.role}).';
      }

      // Check if staff is already assigned *somewhere else*
      if (staffUser.assignedRestaurantId != null &&
          staffUser.assignedRestaurantId != restaurantId) {
        return '${staffUser.name} is already assigned to another restaurant.';
      }

      // Check if staff member already exists in the subcollection (redundant if assignedRestaurantId is used correctly, but safe)
      DocumentSnapshot existingStaffSubcollectionEntry =
          await _db
              .collection(_restaurantsCollection)
              .doc(restaurantId)
              .collection('staff')
              .doc(staffUser.uid)
              .get();

      if (existingStaffSubcollectionEntry.exists) {
        // Ensure user doc is also updated if somehow inconsistent
        await _db.collection(_usersCollection).doc(staffUser.uid).update({
          'assignedRestaurantId': restaurantId,
          'role':
              (staffUser.role == 'chef' || staffUser.role == 'staff')
                  ? staffUser.role
                  : 'staff',
        });
        return '${staffUser.name} is already a staff member at this restaurant.';
      }

      // 3. Add the user to the staff subcollection (optional, could rely solely on user field)
      // Keeping it for potential direct queries on restaurant staff
      await _db
          .collection(_restaurantsCollection)
          .doc(restaurantId)
          .collection('staff')
          .doc(staffUser.uid)
          .set({
            'name': staffUser.name,
            'email': staffUser.email,
            // Use the user's existing role if staff/chef, otherwise default to staff
            'role':
                (staffUser.role == 'chef' || staffUser.role == 'staff')
                    ? staffUser.role
                    : 'staff',
            'addedAt': FieldValue.serverTimestamp(),
          });

      // 4. Update the user document with assignedRestaurantId and ensure role is at least 'staff'
      await _db.collection(_usersCollection).doc(staffUser.uid).update({
        'assignedRestaurantId': restaurantId,
        // Promote role to 'staff' if they were just a 'customer'
        'role':
            (staffUser.role == 'chef' || staffUser.role == 'staff')
                ? staffUser.role
                : 'staff',
      });

      print(
        'Staff ${staffUser.name} added to restaurant $restaurantId and user doc updated.',
      );
      return null; // Success
    } catch (e) {
      print("Error adding staff by email: $e");
      return 'An unexpected error occurred while adding staff.';
    }
  }

  // Remove staff member from a restaurant
  Future<bool> removeStaff(String restaurantId, String staffUid) async {
    try {
      // 1. Remove from staff subcollection
      await _db
          .collection(_restaurantsCollection)
          .doc(restaurantId)
          .collection('staff')
          .doc(staffUid)
          .delete();

      // 2. Clear assignedRestaurantId and potentially downgrade role (e.g., back to customer? TBD)
      // For now, just clear the assignment.
      await _db.collection(_usersCollection).doc(staffUid).update({
        'assignedRestaurantId': FieldValue.delete(), // Remove the field
        // Consider if role should change, e.g.:
        // 'role': 'customer' // if they should revert to customer
      });

      print(
        'Staff $staffUid removed from restaurant $restaurantId and user doc updated.',
      );
      return true;
    } catch (e) {
      print("Error removing staff $staffUid: $e");
      return false;
    }
  }

  // --- Menu Management Methods (Owner) ---

  // Get stream of menu items for a specific restaurant
  Stream<List<MenuItemModel>> getMenuStream(String restaurantId) {
    return _db
        .collection(_restaurantsCollection)
        .doc(restaurantId)
        .collection('menu')
        .orderBy('category')
        .orderBy('name')
        .snapshots()
        .asyncMap((snapshot) async {
          try {
            return snapshot.docs
                .map((doc) => MenuItemModel.fromFirestore(doc))
                .toList();
          } catch (e, stackTrace) {
            print(
              "Error mapping menu items snapshot for $restaurantId: $e\n$stackTrace",
            );
            return <MenuItemModel>[];
          }
        });
  }

  // Add or Update a menu item
  Future<bool> upsertMenuItem(String restaurantId, MenuItemModel item) async {
    try {
      await _db
          .collection(_restaurantsCollection)
          .doc(restaurantId)
          .collection('menu')
          .doc(
            item.id.isNotEmpty ? item.id : null,
          ) // Use ID or let Firestore generate
          .set(
            item.toFirestore(),
            SetOptions(merge: item.id.isNotEmpty),
          ); // Merge if updating
      print(
        'Menu item ${item.name} upserted successfully for restaurant $restaurantId',
      );
      return true;
    } catch (e) {
      print("Error upserting menu item ${item.name}: $e");
      return false;
    }
  }

  // Delete a menu item
  Future<bool> deleteMenuItem(String restaurantId, String itemId) async {
    try {
      await _db
          .collection(_restaurantsCollection)
          .doc(restaurantId)
          .collection('menu')
          .doc(itemId)
          .delete();
      print(
        'Menu item $itemId deleted successfully from restaurant $restaurantId',
      );
      return true;
    } catch (e) {
      print("Error deleting menu item $itemId: $e");
      return false;
    }
  }

  // --- Timings Management Methods (Owner) ---

  // Get the stream for a specific restaurant document (to read openingHours map)
  Stream<DocumentSnapshot> getRestaurantDocStream(String restaurantId) {
    return _db
        .collection(_restaurantsCollection)
        .doc(restaurantId)
        .snapshots()
        .handleError((error) {
          print("Error in getRestaurantDocStream for $restaurantId: $error");
          // Depending on how you want to handle errors, you might rethrow,
          // or return an empty/error snapshot indicator if the provider handles it.
          // For now, just print. The provider's map function will handle non-existent docs.
        });
  }

  // Update the opening hours map field for a restaurant
  Future<bool> updateRestaurantTimings(
    String restaurantId,
    List<DailyOpeningHours> timings,
  ) async {
    try {
      // Convert the list back to a map suitable for Firestore field
      final Map<String, Map<String, dynamic>> hoursData = {
        for (var timing in timings) timing.dayOfWeek.toString(): timing.toMap(),
      };

      await _db.collection(_restaurantsCollection).doc(restaurantId).update({
        'openingHours': hoursData, // Update the map field directly
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print("Timings updated successfully for restaurant $restaurantId");
      return true;
    } catch (e, stackTrace) {
      print("Error updating timings map for $restaurantId: $e\n$stackTrace");
      return false;
    }
  }

  // --- Booking Management Methods ---

  // Create a new booking
  Future<String?> createBooking(BookingModel booking) async {
    try {
      final bookingData =
          booking.toFirestore()..['createdAt'] = FieldValue.serverTimestamp();
      DocumentReference docRef = await _db
          .collection(_bookingsCollection)
          .add(bookingData);
      print(
        'Booking created successfully with ID: ${docRef.id} for restaurant ${booking.restaurantId}',
      );
      return docRef.id;
    } catch (e, stackTrace) {
      print("Error creating booking: $e\n$stackTrace");
      return null;
    }
  }

  // Get stream of bookings for a specific restaurant
  Stream<List<BookingModel>> getBookingsForRestaurantStream(
    String restaurantId,
  ) {
    return _db
        .collection(_bookingsCollection)
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('bookingDateTime', descending: false)
        .snapshots()
        .asyncMap((snapshot) async {
          try {
            return snapshot.docs
                .map((doc) => BookingModel.fromFirestore(doc))
                .toList();
          } catch (e, stackTrace) {
            print(
              "Error mapping restaurant bookings snapshot for $restaurantId: $e\n$stackTrace",
            );
            return <BookingModel>[];
          }
        });
  }

  // Get stream of bookings for a specific user
  Stream<List<BookingModel>> getBookingsForUserStream(String userId) {
    return _db
        .collection(_bookingsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('bookingDateTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          try {
            return snapshot.docs
                .map((doc) => BookingModel.fromFirestore(doc))
                .toList();
          } catch (e, stackTrace) {
            print(
              "Error mapping user bookings snapshot for $userId: $e\n$stackTrace",
            );
            return <BookingModel>[];
          }
        });
  }

  // Update the status of a specific booking
  Future<bool> updateBookingStatus(
    String bookingId,
    String newStatus, // e.g., 'confirmed', 'rejected', 'completed'
  ) async {
    // Optional: Add validation for allowed status transitions here
    // if (!['confirmed', 'rejected', 'completed', 'pending'].contains(newStatus)) {
    //   print("Invalid booking status: $newStatus");
    //   return false;
    // }
    try {
      await _db.collection(_bookingsCollection).doc(bookingId).update({
        'status': newStatus,
      });
      print("Booking $bookingId status updated to: $newStatus");
      return true;
    } catch (e) {
      print("Error updating booking status for $bookingId: $e");
      return false;
    }
  }

  // --- Order Methods --- //

  // Add a new order document
  Future<DocumentReference?> addOrder(Map<String, dynamic> orderData) async {
    try {
      // Basic validation (can be expanded)
      if (orderData['userId'] == null ||
          orderData['restaurantId'] == null ||
          (orderData['items'] as List?)?.isEmpty == true ||
          orderData['transactionId'] == null) {
        print("Error: Missing required fields in order data.");
        return null;
      }
      DocumentReference docRef = await _db.collection(_ordersCollection).add({
        ...orderData, // Spread the provided data
        // Ensure server timestamp if not already provided
        'orderTimestamp':
            orderData['orderTimestamp'] ?? FieldValue.serverTimestamp(),
      });
      print("Order added successfully with ID: ${docRef.id}");
      return docRef;
    } catch (e) {
      print("Error adding order: $e");
      return null;
    }
  }

  // Get stream of orders for a specific user
  // Return type uses the prefixed model
  Stream<List<app_order.Order>> getOrdersForUserStream(String userId) {
    print("[getOrdersForUserStream] Querying orders where userId == $userId");
    return _db
        .collection(_ordersCollection) // Use the correct collection name
        .where('userId', isEqualTo: userId)
        .orderBy('orderTimestamp', descending: true) // Show newest orders first
        .snapshots()
        .map((snapshot) {
          // Use map instead of asyncMap if Order.fromFirestore is synchronous
          print(
            "[getOrdersForUserStream] Snapshot received. Docs count: ${snapshot.docs.length}",
          );
          try {
            return snapshot.docs
                // Use the prefixed model factory here
                .map((doc) => app_order.Order.fromFirestore(doc))
                .toList();
          } catch (e, stackTrace) {
            print("Error mapping user orders snapshot: $e\n$stackTrace");
            // Return type uses the prefixed model
            return <app_order.Order>[]; // Return empty list on error
          }
        })
        .handleError((error) {
          // Handle stream errors
          print("Error in getOrdersForUserStream for $userId: $error");
          // Return type uses the prefixed model
          return <app_order.Order>[]; // Return empty list on stream error
        });
  }

  // Get stream of orders for a specific restaurant
  Stream<List<app_order.Order>> getOrdersForRestaurantStream(
    String restaurantId,
  ) {
    print(
      "[getOrdersForRestaurantStream] Querying orders where restaurantId == $restaurantId",
    );
    return _db
        .collection(_ordersCollection)
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('orderTimestamp', descending: true) // Show newest orders first
        .snapshots()
        .map((snapshot) {
          print(
            "[getOrdersForRestaurantStream] Snapshot received. Docs count: ${snapshot.docs.length}",
          );
          try {
            return snapshot.docs
                .map((doc) => app_order.Order.fromFirestore(doc))
                .toList();
          } catch (e, stackTrace) {
            print("Error mapping restaurant orders snapshot: $e\n$stackTrace");
            return <app_order.Order>[];
          }
        })
        .handleError((error) {
          print(
            "Error in getOrdersForRestaurantStream for $restaurantId: $error",
          );
          return <app_order.Order>[];
        });
  }

  // Calculate total earnings for a restaurant (sum of successful orders)
  Future<double> calculateTotalEarnings(String restaurantId) async {
    print(
      "[calculateTotalEarnings] Calculating earnings for restaurant: $restaurantId",
    );
    try {
      // Query successful orders for the restaurant
      QuerySnapshot snapshot =
          await _db
              .collection(_ordersCollection)
              .where('restaurantId', isEqualTo: restaurantId)
              .where(
                'status',
                isEqualTo: 'success',
              ) // Assuming 'success' marks a completed/paid order
              .get();

      // Sum the totalAmount field
      double totalEarnings = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?; // Safe cast
        // Use cartTotalAmount as it seems to be the primary amount used
        final amount = (data?['cartTotalAmount'] ?? 0.0).toDouble();
        totalEarnings += amount;
      }

      print(
        "[calculateTotalEarnings] Total earnings for $restaurantId: $totalEarnings",
      );
      return totalEarnings;
    } catch (e, stackTrace) {
      print(
        "Error calculating total earnings for $restaurantId: $e\n$stackTrace",
      );
      return 0.0; // Return 0 on error
    }
  }

  // TODO: Add methods to get orders (e.g., getOrdersForUser, getOrdersForRestaurant)
}

// --- Riverpod Provider --- //
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
