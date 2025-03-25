import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_management/components/button.dart';
import 'package:hotel_management/components/lineChart.dart';

class ChartPage extends StatelessWidget {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for the carousel
    final List<Map<String, String>> reviews = [
      {
        'image':
            'https://img.freepik.com/free-photo/medium-shot-man-with-afro-hairstyle_23-2150677136.jpg',
        'text':
            'Great experience! The staff was very friendly and the room was clean.',
      },
      {
        'image':
            'https://img.freepik.com/free-psd/portrait-man-teenager-isolated_23-2151745771.jpg',
        'text':
            'Amazing service and the food was delicious. Highly recommended!',
      },
      {
        'image':
            'https://img.freepik.com/free-vector/simple-shadow-profile-picture-template_742173-8847.jpg',
        'text':
            'The view from the room was breathtaking. Will definitely come!',
      },
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),
              Text('Users Overview',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: screenWidth * 0.06,
                    color: Colors.black,
                  )),
              LineChartGraphWidget(),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Customer Reviews',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: screenWidth * 0.06,
                  color: Colors.black,
                ),
              ),
              CarouselSlider(
                options: CarouselOptions(
                  height: isPortrait ? screenHeight * 0.3 : screenHeight * 0.5,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: isPortrait ? 0.8 : 0.6,
                ),
                items: reviews.map((review) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                            style: BorderStyle.solid,
                          ),
                          color: Colors.blue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.green, // Border color
                                  width: 3.0, // Border width
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  review['image']!,
                                  width: isPortrait
                                      ? screenWidth * 0.2
                                      : screenWidth * 0.15,
                                  height: isPortrait
                                      ? screenWidth * 0.2
                                      : screenWidth * 0.15,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    return const Icon(Icons.error,
                                        color: Colors.red);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                review['text']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isPortrait
                                      ? screenWidth * 0.04
                                      : screenWidth * 0.03,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2E3A59), // Soft Navy Blue
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Get 32% Promo.',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: screenWidth * 0.05,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          MyButton(text: 'Redeem Now', onTap: () {}),
                        ],
                      ),
                    ),
                    Image.asset(
                      'lib/images/balcony.png',
                      height: screenHeight * 0.15,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
