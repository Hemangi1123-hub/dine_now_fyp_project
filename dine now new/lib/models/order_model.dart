import 'package:cloud_firestore/cloud_firestore.dart';

// Define the Order model
class Order {
  final String id;
  final String restaurantName;
  final double totalAmount; // Assuming cartTotalAmount
  final String status;
  final DateTime orderTimestamp;
  final List<Map<String, dynamic>> items; // List of item maps
  final String transactionId;

  Order({
    required this.id,
    required this.restaurantName,
    required this.totalAmount,
    required this.status,
    required this.orderTimestamp,
    required this.items,
    required this.transactionId,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    return Order(
      id: doc.id,
      restaurantName: data['restaurantName'] ?? 'N/A',
      // Use cartTotalAmount as the primary display amount
      totalAmount: (data['cartTotalAmount'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'Unknown',
      orderTimestamp:
          (data['orderTimestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // Ensure items is parsed correctly as a List of Maps
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      transactionId: data['transactionId'] ?? 'N/A',
    );
  }

  // Optional: Add a toFirestore method if needed later
  Map<String, dynamic> toFirestore() {
    return {
      // Only include fields you might want to *write* back
      // Often, reading is sufficient, so this might not be needed now
      'restaurantName': restaurantName,
      'totalAmount': totalAmount,
      'status': status,
      'orderTimestamp': Timestamp.fromDate(orderTimestamp),
      'items': items,
      'transactionId': transactionId,
      // Exclude fields like id (document ID) and potentially userId if set elsewhere
    };
  }
}
