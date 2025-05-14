import 'package:dine_now/screens/customer/menu_order_screen.dart'; // For CartItem type
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khalti_checkout_flutter/khalti_checkout_flutter.dart'; // For PaymentPayload, PaymentStatus
import 'package:intl/intl.dart'; // For date formatting
import 'package:dine_now/models/coupon_model.dart'; // Import coupon model
import '../../utils/rating_utils.dart';
import '../../../widgets/rating_dialog.dart';  // Direct import

class OrderConfirmationScreen extends ConsumerStatefulWidget {
  final PaymentPayload paymentPayload;
  final String restaurantName;
  final String restaurantId;
  final List<CartItem> items;
  final CouponModel? appliedCoupon;

  const OrderConfirmationScreen({
    super.key,
    required this.paymentPayload,
    required this.restaurantName,
    required this.restaurantId,
    required this.items,
    this.appliedCoupon,
  });

  @override
  ConsumerState<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends ConsumerState<OrderConfirmationScreen> {
  bool _hasShownRating = false;
  bool _isShowingRating = false;

  @override
  void initState() {
    super.initState();
    // Schedule the rating dialog to be shown after the screen is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isShowingRating = true);
        _showRatingDialogWithDelay();
      }
    });
  }

  @override
  void dispose() {
    _isShowingRating = false;
    super.dispose();
  }

  Future<void> _showRatingDialogWithDelay() async {
    try {
      // Wait for 2 seconds to ensure the screen is stable
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted || !_isShowingRating) {
        debugPrint('Screen not mounted or rating cancelled');
        return;
      }

      debugPrint('Preparing to show rating dialog for restaurant: ${widget.restaurantId}');
      
      if (_hasShownRating) {
        debugPrint('Rating dialog already shown');
        return;
      }

      setState(() => _hasShownRating = true);

      // Use a microtask to ensure dialog shows after any pending frame updates
      Future.microtask(() async {
        if (!mounted || !_isShowingRating) return;

        try {
          debugPrint('Showing rating dialog');
          final transactionId = widget.paymentPayload.transactionId ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}';
          
          await showDialog(
            context: context,
            barrierDismissible: false,
            useRootNavigator: false, // Use the local navigator
            builder: (BuildContext context) => RatingDialog(
              orderId: transactionId,
              restaurantId: widget.restaurantId,
            ),
          );
          debugPrint('Rating dialog closed normally');
        } catch (dialogError, dialogStack) {
          debugPrint('Error showing rating dialog: $dialogError\n$dialogStack');
          if (mounted) {
            setState(() => _hasShownRating = false);
          }
        }
      });
    } catch (e, stack) {
      debugPrint('Error in _showRatingDialogWithDelay: $e\n$stack');
      if (mounted) {
        setState(() => _hasShownRating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalAmount = widget.items.fold(
      0.0,
      (sum, item) => sum + (item.item.price * item.quantity),
    );

    // Calculate discount if coupon was applied
    final discountAmount = widget.appliedCoupon?.calculateDiscount(totalAmount) ?? 0.0;
    final finalAmount = totalAmount - discountAmount;

    final transactionTime = DateTime.now();
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(transactionTime);

    return WillPopScope(
      onWillPop: () async {
        // Prevent back button while rating dialog is showing
        if (_hasShownRating) {
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Confirmed'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.check_circle_outline,
                  size: 100,
                  color: Colors.green,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Your order from ${widget.restaurantName} has been placed.',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 30),
                // Order items
                ...widget.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.quantity} x ${item.item.name}'),
                      Text(
                        'NPR ${(item.item.price * item.quantity).toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
                const Divider(height: 30),
                // Order total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'NPR ${(widget.paymentPayload.totalAmount / 100.0).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Transaction details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transaction ID: ${widget.paymentPayload.transactionId}'),
                      Text('Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}'),
                      Text('Status: ${widget.paymentPayload.status ?? 'Success'}'),
                      Text('Khalti pidx: ${widget.paymentPayload.pidx}'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
