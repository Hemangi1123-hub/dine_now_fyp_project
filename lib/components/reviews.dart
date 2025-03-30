import 'package:flutter/material.dart';

class CustomCarouselFB2 extends StatefulWidget {
  const CustomCarouselFB2({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CustomCarouselFB2State createState() => _CustomCarouselFB2State();
}

class _CustomCarouselFB2State extends State<CustomCarouselFB2> {
  List<Widget> cards = [
    CardFb1(
        text: "John McLovin",
        imageUrl:
            "https://img.freepik.com/free-photo/medium-shot-man-with-afro-hairstyle_23-2150677136.jpg",
        subtitle: "Loved the app, helped me a lot",
        onPressed: () {}),
    CardFb1(
        text: "Vanilla Sky",
        imageUrl:
            "https://img.freepik.com/free-photo/medium-shot-man-with-afro-hairstyle_23-2150677136.jpg",
        subtitle: "Great app, easy to use",
        onPressed: () {}),
    CardFb1(
        text: "Sara Johnson",
        imageUrl:
            "https://img.freepik.com/free-photo/medium-shot-man-with-afro-hairstyle_23-2150677136.jpg",
        subtitle: "Saved me a lot of time",
        onPressed: () {})
  ];

  final double carouselItemMargin = 16;

  late PageController _pageController;
  int _position = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: .7);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        controller: _pageController,
        itemCount: cards.length,
        onPageChanged: (int position) {
          setState(() {
            _position = position;
          });
        },
        itemBuilder: (BuildContext context, int position) {
          return imageSlider(position);
        });
  }

  Widget imageSlider(int position) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (BuildContext context, widget) {
        return Container(
          margin: EdgeInsets.all(carouselItemMargin),
          child: Center(child: widget),
        );
      },
      child: Container(
        child: cards[position],
      ),
    );
  }
}

class CardFb1 extends StatelessWidget {
  final String text;
  final String imageUrl;
  final String subtitle;
  final Function() onPressed;

  const CardFb1(
      {required this.text,
      required this.imageUrl,
      required this.subtitle,
      required this.onPressed,
      super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 250,
        height: 230,
        padding: const EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.5),
          boxShadow: [
            BoxShadow(
                offset: const Offset(10, 20),
                blurRadius: 10,
                spreadRadius: 0,
                color: Colors.grey.withOpacity(.05)),
          ],
        ),
        child: Column(
          children: [
            Image.network(
              imageUrl,
              height: 90,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child; // Image is fully loaded, return the child (the image).
                }
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                // Display a fallback widget if the image fails to load.
                return const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 50,
                );
              },
            ),
            const Spacer(),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
            const SizedBox(
              height: 5,
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                  fontSize: 12),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}