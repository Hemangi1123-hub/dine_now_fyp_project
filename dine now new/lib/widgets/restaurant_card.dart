import 'package:dine_now/models/restaurant_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart'; // For rating icon

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      // Uses CardTheme defined in app_theme.dart
      clipBehavior: Clip.antiAlias, // Ensures image respects card shape
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Image
          SizedBox(
            // Constrain the image size
            height: 150,
            width: double.infinity,
            child: Image.network(
              restaurant.imageUrl.isNotEmpty
                  ? restaurant.imageUrl
                  : 'https://via.placeholder.com/300x150.png?text=No+Image', // Basic fallback URL
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                // Log the error for debugging if needed
                // print('Error loading image: $error');
                return Container(
                  color: Colors.grey.shade300,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined, // More specific error icon
                      color: Colors.grey.shade500,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Name
                Text(
                  restaurant.name,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface, // Use onSurface for contrast
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Cuisine Type
                Text(
                  restaurant.cuisine,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Rating
                Row(
                  children: [
                    Icon(
                      MaterialCommunityIcons.star, // Using flutter_vector_icons
                      color: Colors.amber, // Standard star color
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.rating.toStringAsFixed(1),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(Rating)', // Placeholder for review count later
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                // Add Address or other info if needed
                // const SizedBox(height: 4),
                // Text(restaurant.address, style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
