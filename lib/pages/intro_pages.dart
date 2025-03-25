import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_management/components/button.dart';

class IntroPages extends StatelessWidget {
  const IntroPages({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch screen dimensions for responsive scaling
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 138, 60, 55),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.03),
              Text(
                "Dine Now",
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: screenWidth *
                      0.08, // Adjust font size based on screen width
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Image.asset(
                    'lib/images/food.png',
                    width: screenWidth * 0.7, // Adjust image width
                    height: screenHeight * 0.3, // Adjust image height
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                "THE BEST DINNING EXPERIENCE",
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: screenWidth * 0.1, // Adjust font size
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "Reserve your table with us and indulge in a dining experience like no other. Whether it's a casual meal or a special occasion, we have the perfect setting and the best culinary delights waiting for you.",
                style: TextStyle(
                  fontSize: screenWidth * 0.04, // Adjust font size
                  height: 1.5,
                  color: Colors.grey[200],
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Center(
                child: MyButton(
                  text: 'Get Started',
                  onTap: () {
                    Navigator.pushNamed(context, '/homepage');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
