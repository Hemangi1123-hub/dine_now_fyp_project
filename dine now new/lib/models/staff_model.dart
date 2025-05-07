import 'package:cloud_firestore/cloud_firestore.dart';

class StaffMemberModel {
  final String id; // Document ID (same as user UID)
  final String name;
  final String email;
  final String role; // Usually 'staff' or 'chef'
  final Timestamp addedAt;

  StaffMemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.addedAt,
  });

  factory StaffMemberModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StaffMemberModel(
      id: doc.id, // Assuming document ID is the staff member's UID
      name: data['name'] ?? 'N/A',
      email: data['email'] ?? 'N/A',
      role: data['role'] ?? 'staff',
      addedAt: data['addedAt'] ?? Timestamp.now(), // Provide default
    );
  }

  // We might not need to write back from this model often,
  // as adding is based on existing user data.
  Map<String, dynamic> toFirestore() {
    return {'name': name, 'email': email, 'role': role, 'addedAt': addedAt};
  }
}
