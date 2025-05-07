import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String? id; // Firestore document ID
  final String restaurantId;
  final String restaurantName; // Denormalized for easy display
  final String userId;
  final String userName; // Denormalized
  final String userEmail; // Denormalized
  final DateTime bookingDateTime; // Combined date and time
  final int partySize;
  final String status; // e.g., 'pending', 'confirmed', 'cancelled', 'completed'
  final Timestamp createdAt;
  // Add other fields like special requests, assigned table ID later

  BookingModel({
    this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.bookingDateTime,
    required this.partySize,
    this.status = 'pending', // Default status
    required this.createdAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      bookingDateTime:
          (data['bookingDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      partySize: (data['partySize'] ?? 1).toInt(),
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'bookingDateTime': Timestamp.fromDate(bookingDateTime),
      'partySize': partySize,
      'status': status,
      'createdAt': createdAt,
      // Add server timestamp for createdAt on initial write if preferred
    };
  }
}
