import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/rooms.dart';

class RoomTile extends StatelessWidget {
  final Rooms rooms;
  const RoomTile({
    super.key,
    required this.rooms,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define a base color for the monochromatic scheme
    final Color baseColor = Colors.blue;

    return Container(
      decoration: BoxDecoration(
        // Use a lighter shade of the base color for the background
        color:
            baseColor.withOpacity(0.1), // Adjust opacity for a lighter effect
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.only(left: screenWidth * 0.05), // Responsive margin
      padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Network image with responsive height (increased by 50%)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15), // Rounded corners
              child: Image.network(
                rooms.imagePath, // URL of the image
                height: screenHeight * 0.25, // Increased height by 50%
                width: screenWidth * 0.4, // Responsive image width
                fit: BoxFit.cover, // Ensure the image fits the box
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: screenHeight * 0.25, // Increased height by 50%
                    width: screenWidth * 0.4,
                    color: Colors.grey[300], // Placeholder color
                    child: Center(
                      child: CircularProgressIndicator(
                        color: baseColor, // Loading indicator color
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: screenHeight * 0.25, // Increased height by 50%
                    width: screenWidth * 0.4,
                    color: Colors.grey[300], // Error placeholder color
                    child: const Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.red, // Error icon color
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01), // Small spacing
          // Room name with responsive font size
          Text(
            rooms.name,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: screenWidth * 0.045, // Responsive font size
            ),
          ),
          SizedBox(height: screenHeight * 0.01), // Small spacing
          // Price and rating row
          SizedBox(
            width: screenWidth * 0.4, // Responsive width
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price text
                Text(
                  rooms.price,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    fontSize: screenWidth * 0.035, // Responsive font size
                  ),
                ),
                // Rating icon and text
                Row(
                  children: [
                    Icon(
                      Icons.smoke_free,
                      color: Colors.yellow[900],
                      size: screenWidth * 0.04, // Responsive icon size
                    ),
                    SizedBox(width: screenWidth * 0.01), // Small spacing
                    Text(
                      rooms.rating,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035, // Responsive font size
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
