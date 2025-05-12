import 'package:dine_now/models/coupon_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Sample coupons for MVP (in a real app, these would come from Firestore)
final List<CouponModel> _sampleCoupons = [
  CouponModel(
    id: 'WELCOME50',
    code: 'WELCOME50',
    description: '50% off on your first order (up to NPR 200)',
    discountPercentage: 50.0,
    maxDiscountAmount: 200.0,
    minOrderValue: 300.0,
    expiryDate: DateTime.now().add(const Duration(days: 90)),
    usageLimit: 1,
  ),
  CouponModel(
    id: 'FLAT100',
    code: 'FLAT100',
    description: 'NPR 100 off on orders above NPR 500',
    discountAmount: 100.0,
    minOrderValue: 500.0,
    expiryDate: DateTime.now().add(const Duration(days: 30)),
    usageLimit: 2,
  ),
  CouponModel(
    id: 'DINELUNCH',
    code: 'DINELUNCH',
    description: '15% off on lunch orders (11 AM - 3 PM)',
    discountPercentage: 15.0,
    maxDiscountAmount: 150.0,
    minOrderValue: 200.0,
    expiryDate: DateTime.now().add(const Duration(days: 60)),
    usageLimit: 5,
  ),
];

// Provider for available coupons
final availableCouponsProvider = Provider<List<CouponModel>>((ref) {
  // In a real app, you'd fetch these from Firestore
  return _sampleCoupons;
});

// State provider for selected coupon
final selectedCouponProvider = StateProvider<CouponModel?>((ref) => null);

// Provider to check if a coupon is valid for the current order
final couponValidityProvider =
    Provider.family<bool, ({String restaurantId, double orderTotal})>((
      ref,
      params,
    ) {
      final selectedCoupon = ref.watch(selectedCouponProvider);

      if (selectedCoupon == null) {
        return false;
      }

      // Check if the coupon is valid for this restaurant and order value
      return selectedCoupon.isValidForRestaurant(params.restaurantId) &&
          params.orderTotal >= selectedCoupon.minOrderValue;
    });

// Provider to calculate discount amount
final discountAmountProvider = Provider.family<double, double>((
  ref,
  orderTotal,
) {
  final selectedCoupon = ref.watch(selectedCouponProvider);

  if (selectedCoupon == null) {
    return 0.0;
  }

  return selectedCoupon.calculateDiscount(orderTotal);
});

// Provider to calculate final order amount after applying coupon
final finalOrderAmountProvider = Provider.family<double, double>((
  ref,
  orderTotal,
) {
  final discount = ref.watch(discountAmountProvider(orderTotal));
  return orderTotal - discount;
});
