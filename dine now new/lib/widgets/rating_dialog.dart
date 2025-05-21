import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingDialog extends StatefulWidget {
  final String? orderId;
  final String restaurantId;

  const RatingDialog({
    Key? key,
    required this.orderId,
    required this.restaurantId,
  }) : super(key: key);

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _foodRating = 0;
  int _serviceRating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  // Review aspects
  bool _wasDeliveredOnTime = true;
  bool _wasPackagedWell = true;
  bool _wouldRecommend = true;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_foodRating == 0 || _serviceRating == 0) {
      setState(() {
        _errorMessage = 'Please rate both food and service before submitting';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Calculate average rating
      final averageRating = (_foodRating + _serviceRating) / 2.0;

      // Add the rating document
      final ratingRef = await FirebaseFirestore.instance.collection('ratings').add({
        'orderId': widget.orderId ?? 'unknown',
        'restaurantId': widget.restaurantId,
        'userId': user.uid,
        'foodRating': _foodRating,
        'serviceRating': _serviceRating,
        'averageRating': averageRating,
        'feedback': _feedbackController.text.trim(),
        'wasDeliveredOnTime': _wasDeliveredOnTime,
        'wasPackagedWell': _wasPackagedWell,
        'wouldRecommend': _wouldRecommend,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Rating document created with ID: ${ratingRef.id}');

      // Update restaurant's average rating
      final restaurantRef = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final restaurantDoc = await transaction.get(restaurantRef);
        
        if (!restaurantDoc.exists) {
          throw Exception('Restaurant not found');
        }

        final data = restaurantDoc.data()!;
        final currentRating = (data['rating'] as num?)?.toDouble() ?? 0.0;
        final totalRatings = (data['totalRatings'] as num?)?.toInt() ?? 0;

        final newTotalRatings = totalRatings + 1;
        final newRating = ((currentRating * totalRatings) + averageRating) / newTotalRatings;

        transaction.update(restaurantRef, {
          'rating': newRating,
          'totalRatings': newTotalRatings,
          'lastRatedAt': FieldValue.serverTimestamp(),
        });

        debugPrint('Restaurant rating updated: $newRating ($newTotalRatings total ratings)');
      });

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      debugPrint('Error submitting rating: $e\n$stackTrace');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to submit rating. Please try again.';
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildRatingSection(String title, int rating, Function(int) onRatingChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              iconSize: 36,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              icon: Icon(
                index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: index < rating ? Colors.amber : Colors.grey,
              ),
              onPressed: _isSubmitting
                  ? null
                  : () {
                      onRatingChanged(index + 1);
                      setState(() => _errorMessage = null);
                    },
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isSubmitting,
      child: AlertDialog(
        title: const Text(
          'Rate Your Experience',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Rating
              _buildRatingSection(
                'How was the food?',
                _foodRating,
                (rating) => setState(() => _foodRating = rating),
              ),
              const SizedBox(height: 24),

              // Service Rating
              _buildRatingSection(
                'How was the service?',
                _serviceRating,
                (rating) => setState(() => _serviceRating = rating),
              ),
              const SizedBox(height: 24),

              // Additional Feedback Options
              const Text(
                'Additional Feedback',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              
              // Delivery Time
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Order was delivered on time'),
                value: _wasDeliveredOnTime,
                onChanged: _isSubmitting ? null : (value) {
                  setState(() => _wasDeliveredOnTime = value);
                },
              ),

              // Packaging
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Food was packaged well'),
                value: _wasPackagedWell,
                onChanged: _isSubmitting ? null : (value) {
                  setState(() => _wasPackagedWell = value);
                },
              ),

              // Recommendation
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Would recommend to others'),
                value: _wouldRecommend,
                onChanged: _isSubmitting ? null : (value) {
                  setState(() => _wouldRecommend = value);
                },
              ),

              const SizedBox(height: 16),

              // Detailed Feedback
              TextField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Share your detailed feedback (optional)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                enabled: !_isSubmitting,
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    Navigator.of(context).pop(false);
                  },
            child: const Text('SKIP'),
          ),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitRating,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('SUBMIT'),
          ),
        ],
      ),
    );
  }
} 