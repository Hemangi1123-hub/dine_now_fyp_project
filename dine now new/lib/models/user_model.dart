import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final Timestamp? createdAt;
  final String?
  assignedRestaurantId; // Optional ID of restaurant staff is assigned to

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
    this.assignedRestaurantId, // Added to constructor
  });

  // Factory constructor to create a UserModel from a Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id, // Use document ID as UID
      name: data['name'] ?? '', // Provide default value
      email: data['email'] ?? '', // Provide default value
      role: data['role'] ?? 'customer', // Default to customer if missing
      createdAt: data['createdAt'] as Timestamp?, // Handle potential null
      assignedRestaurantId:
          data['assignedRestaurantId'] as String?, // Read the new field
    );
  }

  // Method to convert UserModel instance to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'createdAt':
          createdAt ??
          FieldValue.serverTimestamp(), // Use server timestamp if null
      // Only include assignedRestaurantId if it's not null
      if (assignedRestaurantId != null)
        'assignedRestaurantId': assignedRestaurantId,
    };
  }

  // Optional: copyWith method for easier updates
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    Timestamp? createdAt,
    String? assignedRestaurantId,
    bool clearAssignedRestaurantId =
        false, // Flag to explicitly clear the field
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      assignedRestaurantId:
          clearAssignedRestaurantId
              ? null
              : (assignedRestaurantId ?? this.assignedRestaurantId),
    );
  }
}
