import 'package:flutter/material.dart';
import '../widgets/rating_dialog.dart';

Future<bool?> showRatingDialog(
  BuildContext context, {
  required String orderId,
  required String restaurantId,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => RatingDialog(
      orderId: orderId,
      restaurantId: restaurantId,
    ),
  );
} 