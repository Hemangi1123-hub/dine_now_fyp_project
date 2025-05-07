import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String cuisine;
  final String address;
  final double rating;
  final String imageUrl;
  final String ownerEmail; // Email of the assigned owner
  final String? ownerId; // UID of the owner (set after owner claims/is linked)
  final bool isActive; // To control visibility for customers
  // Add other relevant fields like opening hours, price range etc. as needed

  RestaurantModel({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.address,
    required this.rating,
    required this.imageUrl,
    required this.ownerEmail,
    this.ownerId,
    this.isActive = true, // Default to active
  });

  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RestaurantModel(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Restaurant',
      cuisine: data['cuisine'] ?? 'Various',
      address: data['address'] ?? 'Address unavailable',
      // Ensure rating is treated as a number, default to 0.0
      rating: (data['rating'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '', // Provide default empty string
      ownerEmail: data['ownerEmail'] ?? '',
      ownerId: data['ownerId'], // Can be null initially
      isActive: data['isActive'] ?? true, // Default to true if missing
    );
  }

  // toFirestore method (optional, useful if customers can add restaurants - not in MVP)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'cuisine': cuisine,
      'address': address,
      'rating': rating,
      'imageUrl': imageUrl,
      'ownerEmail': ownerEmail,
      'ownerId': ownerId,
      'isActive': isActive,
      // Add server timestamp for creation/update if needed
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  // Add copyWith method for easier updates
  RestaurantModel copyWith({
    String? id,
    String? name,
    String? cuisine,
    String? address,
    double? rating,
    String? imageUrl,
    String? ownerEmail,
    String? ownerId,
    bool? isActive,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cuisine: cuisine ?? this.cuisine,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerId: ownerId ?? this.ownerId,
      isActive: isActive ?? this.isActive,
    );
  }
}
