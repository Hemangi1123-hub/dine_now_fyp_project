import 'package:dine_now/models/restaurant_model.dart';
import 'package:dine_now/screens/customer/menu_order_screen.dart'; // Import CartItem type and cartProvider
import 'package:dine_now/screens/customer/order_confirmation_screen.dart'; // Import confirmation screen
import 'package:dine_now/services/firestore_service.dart'; // Import Firestore service AND provider
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khalti_checkout_flutter/khalti_checkout_flutter.dart';
import 'package:dine_now/main.dart'; // Import global khaltiInstance and navigatorKey
import 'package:firebase_auth/firebase_auth.dart'; // To get current user ID
import 'dart:developer'; // For logging
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for FieldValue
import 'package:dine_now/providers/coupon_provider.dart'; // Import coupon providers
import 'package:dine_now/models/coupon_model.dart'; // Import coupon model

class CheckoutScreen extends ConsumerStatefulWidget {
  final RestaurantModel restaurant;

  const CheckoutScreen({super.key, required this.restaurant});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isProcessing = false;
  final TextEditingController _couponController = TextEditingController();
  bool _isApplyingCoupon = false;
  String? _couponError;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final availableCoupons = ref.read(availableCouponsProvider);
    final couponCode = _couponController.text.trim().toUpperCase();
    final cart = ref.read(cartProvider);
    final orderTotal = ref.read(cartProvider.notifier).totalPrice;

    setState(() {
      _isApplyingCoupon = true;
      _couponError = null;
    });

    // Find coupon by code
    final coupon = availableCoupons.firstWhere(
      (c) => c.code == couponCode,
      orElse:
          () => CouponModel(
            id: '',
            code: '',
            description: '',
            expiryDate: DateTime.now(),
            isActive: false,
          ),
    );

    // Check if coupon exists and is valid
    if (coupon.id.isEmpty) {
      setState(() {
        _couponError = 'Invalid coupon code';
        _isApplyingCoupon = false;
      });
      return;
    }

    // Check if coupon is valid for this restaurant and order
    final isValid =
        coupon.isValidForRestaurant(widget.restaurant.id) &&
        orderTotal >= coupon.minOrderValue;

    if (!isValid) {
      setState(() {
        _couponError = 'Coupon not applicable for this order';
        _isApplyingCoupon = false;
      });
      return;
    }

    // Apply the coupon
    ref.read(selectedCouponProvider.notifier).state = coupon;

    setState(() {
      _isApplyingCoupon = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coupon "${coupon.code}" applied successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeCoupon() {
    ref.read(selectedCouponProvider.notifier).state = null;
    _couponController.clear();
    setState(() {
      _couponError = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Coupon removed')));
  }

  Future<void> _showAvailableCoupons() async {
    final availableCoupons = ref.read(availableCouponsProvider);
    final orderTotal = ref.read(cartProvider.notifier).totalPrice;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Coupons',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Order Total: NPR ${orderTotal.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: availableCoupons.length,
                      itemBuilder: (context, index) {
                        final coupon = availableCoupons[index];
                        final isValid =
                            coupon.isValidForRestaurant(widget.restaurant.id) &&
                            orderTotal >= coupon.minOrderValue;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color:
                                  isValid
                                      ? Colors.green.shade300
                                      : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap:
                                isValid
                                    ? () {
                                      _couponController.text = coupon.code;
                                      ref
                                          .read(selectedCouponProvider.notifier)
                                          .state = coupon;
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Coupon "${coupon.code}" applied successfully!',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                    : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isValid
                                                  ? Colors.green.shade50
                                                  : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color:
                                                isValid
                                                    ? Colors.green.shade300
                                                    : Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          coupon.code,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isValid
                                                    ? Colors.green.shade800
                                                    : Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (isValid)
                                        TextButton(
                                          onPressed: () {
                                            _couponController.text =
                                                coupon.code;
                                            ref
                                                .read(
                                                  selectedCouponProvider
                                                      .notifier,
                                                )
                                                .state = coupon;
                                            Navigator.pop(context);
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(50, 30),
                                            tapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                          child: const Text('APPLY'),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    coupon.description,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Min Order: NPR ${coupon.minOrderValue.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Valid until: ${coupon.expiryDate.day}/${coupon.expiryDate.month}/${coupon.expiryDate.year}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (!isValid &&
                                      orderTotal < coupon.minOrderValue)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Add NPR ${(coupon.minOrderValue - orderTotal).toStringAsFixed(0)} more to use this coupon',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _initiatePayment() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    final cartNotifier = ref.read(cartProvider.notifier);
    final cart = ref.read(cartProvider);
    final user = FirebaseAuth.instance.currentUser;
    final selectedCoupon = ref.read(selectedCouponProvider);
    final orderTotal = cartNotifier.totalPrice;

    // Calculate final amount after discount
    final discount = selectedCoupon?.calculateDiscount(orderTotal) ?? 0.0;
    final finalAmount = orderTotal - discount;

    final bool isMounted = context.mounted;

    if (khaltiInstance == null) {
      if (!isMounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khalti initialization failed.')),
      );
      setState(() => _isProcessing = false);
      return;
    }

    if (user == null) {
      if (!isMounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in.')));
      setState(() => _isProcessing = false);
      return;
    }

    const pidx = 'ZyzCEMLFz2QYFYfERGh8LE';
    log("Using Khalti test pidx: $pidx");

    final payConfig = KhaltiPayConfig(
      publicKey: 'test_public_key_dc74e0fd57cb46cd93832aee0a507256',
      pidx: pidx,
      environment: Environment.test,
    );

    try {
      log("Attempting Khalti.init...");
      final khaltiPaymentInstance = await Khalti.init(
        enableDebugging: true,
        payConfig: payConfig,
        onPaymentResult: (paymentResult, khalti) {
          log(
            '>>> Sandbox onPaymentResult (Ignored): ${paymentResult.toString()}',
          );
          if (navigatorKey.currentContext != null) {
            khalti.close(navigatorKey.currentContext!);
          }
        },
        onMessage: (
          khalti, {
          description,
          statusCode,
          event,
          needsPaymentConfirmation,
        }) {
          log(
            '>>> Sandbox onMessage (Ignored): Desc: ${description?.toString()}, Code: $statusCode, Event: $event, NeedsConfirm: $needsPaymentConfirmation',
          );
          if (navigatorKey.currentContext != null) {
            khalti.close(navigatorKey.currentContext!);
          }
        },
        onReturn: () => log('>>> Sandbox onReturn (Ignored).'),
      );
      log("Khalti.init successful. Instance: $khaltiPaymentInstance");

      log("Attempting khalti.open()...");
      if (!context.mounted) {
        log("Context became unmounted before khalti.open()");
        setState(() => _isProcessing = false);
        return;
      }

      khaltiPaymentInstance.open(context);
      log("khalti.open() called. Now showing simulated OTP dialog...");

      // Create a transaction ID that includes restaurant ID
      final transactionId = 'sandbox_${widget.restaurant.id}_${DateTime.now().millisecondsSinceEpoch}';
      
      final dummyPayload = PaymentPayload(
        pidx: pidx,
        transactionId: transactionId,
        totalAmount: (finalAmount * 100).toInt(),
        status: 'success',
      );

      if (context.mounted) {
        _showOtpDialog(
          context,
          ref,
          dummyPayload,
          user.uid,
          cart,
          selectedCoupon,
        );
      } else {
        log("Context became unmounted before showing OTP dialog");
      }
    } catch (error, stackTrace) {
      log("*** ERROR during Khalti.init or khalti.open ***");
      log(
        "Error initializing Khalti for payment: ${error.toString()}\n${stackTrace.toString()}",
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not initiate Khalti payment: ${error.toString()}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _showOtpDialog(
    BuildContext dialogContext,
    WidgetRef ref,
    PaymentPayload dummyPayload,
    String userId,
    List<CartItem> cart,
    CouponModel? appliedCoupon,
  ) async {
    final otpController = TextEditingController();
    const String testOtp = '987654';
    bool isVerifying = false;

    await showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (BuildContext alertContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              title: const Text('Enter Test OTP'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Enter the Khalti sandbox OTP: $testOtp'),
                  const SizedBox(height: 15),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'OTP Code',
                      counterText: "",
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(alertContext).pop();
                    if (mounted) setState(() => _isProcessing = false);
                  },
                ),
                ElevatedButton(
                  onPressed:
                      isVerifying
                          ? null
                          : () async {
                            final enteredOtp = otpController.text;
                            if (enteredOtp == testOtp) {
                              stfSetState(() => isVerifying = true);
                              log("Simulated OTP Correct. Saving order...");

                              final success = await _saveOrderToFirestore(
                                ref,
                                dummyPayload,
                                userId,
                                cart,
                                alertContext,
                                appliedCoupon,
                              );

                              if (alertContext.mounted) {
                                Navigator.of(alertContext).pop();
                              }

                              if (success) {
                                log("Firestore save successful after OTP. Navigating...");

                                // Clear the selected coupon after successful payment
                                ref.read(selectedCouponProvider.notifier).state = null;
                                ref.read(cartProvider.notifier).clearCart();

                                // Use a microtask to ensure proper navigation timing
                                Future.microtask(() {
                                  if (!mounted) return;
                                  
                                  // Use the local context for navigation
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (ctx) {
                                        debugPrint('Building OrderConfirmationScreen with restaurantId: ${widget.restaurant.id}');
                                        return OrderConfirmationScreen(
                                          paymentPayload: dummyPayload,
                                          restaurantName: widget.restaurant.name,
                                          restaurantId: widget.restaurant.id,
                                          items: List.unmodifiable(cart),
                                          appliedCoupon: appliedCoupon,
                                        );
                                      },
                                    ),
                                    (route) => false, // Remove all previous routes
                                  );
                                });
                              } else {
                                log("Firestore save FAILED after OTP.");
                                final navContext = navigatorKey.currentContext;
                                if (navContext != null && navContext.mounted) {
                                  ScaffoldMessenger.of(navContext).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'OTP Verified, but failed to save order.',
                                      ),
                                    ),
                                  );
                                }
                                if (mounted) {
                                  setState(() => _isProcessing = false);
                                }
                              }
                            } else {
                              stfSetState(() {
                                otpController.text = "";
                                ScaffoldMessenger.of(stfContext).showSnackBar(
                                  const SnackBar(
                                    content: Text('Wrong OTP Code. Try again.'),
                                  ),
                                );
                              });
                            }
                          },
                  child: const Text('Verify'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _saveOrderToFirestore(
    WidgetRef ref,
    PaymentPayload payload,
    String userId,
    List<CartItem> cartItems,
    BuildContext saveContext,
    CouponModel? appliedCoupon,
  ) async {
    log("_saveOrderToFirestore called with txn: ${payload.transactionId}");
    final firestoreService = ref.read(firestoreServiceProvider);
    final orderTotal = ref.read(cartProvider.notifier).totalPrice;

    // Calculate discount amount if coupon was applied
    final discount = appliedCoupon?.calculateDiscount(orderTotal) ?? 0.0;
    final finalAmount = orderTotal - discount;

    try {
      // Prepare order data
      final orderData = {
        'restaurantId': widget.restaurant.id,
        'restaurantName': widget.restaurant.name,
        'userId': userId,
        'transactionId': payload.transactionId,
        'status': payload.status ?? 'success',
        'orderTimestamp': FieldValue.serverTimestamp(),
        'cartTotalAmount':
            finalAmount, // Store the final amount after discount (keeping original key for compatibility)
        'totalAmount': finalAmount, // Store the final amount after discount
        'originalAmount':
            orderTotal, // Store the original amount before discount
        'discountAmount': discount, // Store the discount amount
        'items':
            cartItems.map((item) {
              return {
                'itemId': item.item.id,
                'name': item.item.name,
                'price': item.item.price,
                'quantity': item.quantity,
              };
            }).toList(),
        'khaltiPaidAmount': payload.totalAmount / 100.0,
        'pidx': payload.pidx,
        'isSandbox': true,
      };

      // Add coupon information if applied
      if (appliedCoupon != null) {
        orderData['coupon'] = {
          'id': appliedCoupon.id,
          'code': appliedCoupon.code,
          'discountAmount': discount,
        };
      }

      log("Saving order to Firestore: $orderData");

      // Add to the 'orders' collection
      final docRef = await firestoreService.addOrder(orderData);

      if (docRef != null) {
        log("Order saved successfully to Firestore with ID: ${docRef.id}");
        return true;
      } else {
        log("Firestore addOrder returned null, indicating potential failure.");
        return false;
      }
    } catch (error, stackTrace) {
      log(
        "Error saving order to Firestore: ${error.toString()}\n${stackTrace.toString()}",
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final selectedCoupon = ref.watch(selectedCouponProvider);
    final orderTotal = cartNotifier.totalPrice;

    // Calculate discount and final amount
    final discount = selectedCoupon?.calculateDiscount(orderTotal) ?? 0.0;
    final finalAmount = orderTotal - discount;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body:
          cart.isEmpty
              ? const Center(
                child: Text('Your cart is empty. Add items to checkout.'),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Information
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              widget.restaurant.imageUrl.isNotEmpty
                                  ? NetworkImage(widget.restaurant.imageUrl)
                                  : null,
                          child:
                              widget.restaurant.imageUrl.isEmpty
                                  ? const Icon(Icons.restaurant)
                                  : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.restaurant.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.restaurant.address,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Order Items
                    const Text(
                      'Your Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...cart.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Text('${item.quantity}x'),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item.item.name)),
                            Text(
                              'NPR ${(item.item.price * item.quantity).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 32),

                    // Coupon Section
                    const Text(
                      'Apply Coupon',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (selectedCoupon == null)
                      // Coupon Input Field
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _couponController,
                              decoration: InputDecoration(
                                labelText: 'Coupon Code',
                                hintText: 'Enter coupon code',
                                errorText: _couponError,
                                border: const OutlineInputBorder(),
                                suffixIcon:
                                    _isApplyingCoupon
                                        ? Container(
                                          width: 24,
                                          height: 24,
                                          padding: const EdgeInsets.all(6),
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                        )
                                        : IconButton(
                                          icon: const Icon(Icons.search),
                                          onPressed: _showAvailableCoupons,
                                          tooltip: 'Browse coupons',
                                        ),
                              ),
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _isApplyingCoupon ? null : _applyCoupon,
                            child: const Text('Apply'),
                          ),
                        ],
                      )
                    else
                      // Applied Coupon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Coupon Applied: ${selectedCoupon.code}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _removeCoupon,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('REMOVE'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedCoupon.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'You saved NPR ${discount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Order Summary
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal'),
                        Text('NPR ${orderTotal.toStringAsFixed(0)}'),
                      ],
                    ),
                    if (selectedCoupon != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Discount (${selectedCoupon.code})',
                            style: const TextStyle(color: Colors.green),
                          ),
                          Text(
                            '- NPR ${discount.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery Fee'),
                        Text('NPR 0'), // Free delivery for MVP
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'NPR ${finalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (selectedCoupon != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'You saved NPR ${discount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade700,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    const SizedBox(height: 32),

                    // Payment Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _initiatePayment,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child:
                            _isProcessing
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Text(
                                  'Pay NPR ${finalAmount.toStringAsFixed(0)}',
                                ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
