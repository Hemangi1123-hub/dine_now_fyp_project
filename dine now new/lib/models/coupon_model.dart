import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String id;
  final String code;
  final String description;
  final double discountAmount; // Fixed amount discount in NPR
  final double discountPercentage; // Percentage discount (0-100)
  final double minOrderValue; // Minimum order value for coupon to be applicable
  final double
  maxDiscountAmount; // Maximum discount amount for percentage discounts
  final DateTime expiryDate;
  final bool isActive;
  final int usageLimit; // How many times this coupon can be used per user
  final List<String>
  applicableRestaurants; // Restaurant IDs where this coupon can be used, empty means all restaurants

  CouponModel({
    required this.id,
    required this.code,
    required this.description,
    this.discountAmount = 0.0,
    this.discountPercentage = 0.0,
    this.minOrderValue = 0.0,
    this.maxDiscountAmount = double.infinity,
    required this.expiryDate,
    this.isActive = true,
    this.usageLimit = 1,
    this.applicableRestaurants = const [],
  });

  // Calculate discount for a given order total
  double calculateDiscount(double orderTotal) {
    if (!isActive ||
        orderTotal < minOrderValue ||
        DateTime.now().isAfter(expiryDate)) {
      return 0.0;
    }

    if (discountAmount > 0) {
      // Fixed amount discount
      return discountAmount;
    } else if (discountPercentage > 0) {
      // Percentage discount
      double calculatedDiscount = orderTotal * (discountPercentage / 100);
      return calculatedDiscount > maxDiscountAmount
          ? maxDiscountAmount
          : calculatedDiscount;
    }

    return 0.0;
  }

  // Check if the coupon is valid for a specific restaurant
  bool isValidForRestaurant(String restaurantId) {
    if (!isActive || DateTime.now().isAfter(expiryDate)) {
      return false;
    }

    // If applicableRestaurants is empty, coupon is valid for all restaurants
    return applicableRestaurants.isEmpty ||
        applicableRestaurants.contains(restaurantId);
  }

  // Factory method to create from Firestore document
  factory CouponModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return CouponModel(
      id: doc.id,
      code: data['code'] ?? '',
      description: data['description'] ?? '',
      discountAmount: (data['discountAmount'] ?? 0.0).toDouble(),
      discountPercentage: (data['discountPercentage'] ?? 0.0).toDouble(),
      minOrderValue: (data['minOrderValue'] ?? 0.0).toDouble(),
      maxDiscountAmount:
          (data['maxDiscountAmount'] ?? double.infinity).toDouble(),
      expiryDate:
          (data['expiryDate'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 365)),
      isActive: data['isActive'] ?? true,
      usageLimit: data['usageLimit'] ?? 1,
      applicableRestaurants: List<String>.from(
        data['applicableRestaurants'] ?? [],
      ),
    );
  }

  // Method to convert to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'description': description,
      'discountAmount': discountAmount,
      'discountPercentage': discountPercentage,
      'minOrderValue': minOrderValue,
      'maxDiscountAmount':
          maxDiscountAmount == double.infinity ? null : maxDiscountAmount,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'isActive': isActive,
      'usageLimit': usageLimit,
      'applicableRestaurants': applicableRestaurants,
    };
  }
}
