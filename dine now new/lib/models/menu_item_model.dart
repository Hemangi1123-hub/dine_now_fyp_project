import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItemModel {
  final String id; // Document ID
  final String name;
  final String description;
  final double price;
  final String category; // e.g., Appetizer, Main Course, Dessert
  final String imageUrl; // Optional image URL
  bool isAvailable;

  MenuItemModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    this.category = 'Uncategorized',
    this.imageUrl = '',
    this.isAvailable = true,
  });

  factory MenuItemModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MenuItemModel(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Item',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? 'Uncategorized',
      imageUrl: data['imageUrl'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      // Consider adding lastUpdated timestamp if needed
    };
  }
}
