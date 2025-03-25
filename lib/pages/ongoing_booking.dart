import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OngoingBooking extends StatefulWidget {
  const OngoingBooking({super.key});

  @override
  State<OngoingBooking> createState() => _OngoingBookingState();
}

class _OngoingBookingState extends State<OngoingBooking> {
  List<Cart> demoCarts = [
    Cart(product: demoProducts[0], numOfItem: 2),
    Cart(product: demoProducts[1], numOfItem: 1),
    Cart(product: demoProducts[2], numOfItem: 1),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Column(
          children: [
            const Text(
              "Your Bookings",
              style: TextStyle(color: Colors.black),
            ),
            Text(
              "${demoCarts.length} resturaunts",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          itemCount: demoCarts.length,
          itemBuilder: (context, index) {
            final cart = demoCarts[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Dismissible(
                key: Key(cart.product.id.toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  setState(() {
                    demoCarts.removeAt(index);
                  });
                },
                background: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE6E6),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      SvgPicture.string(trashIcon),
                    ],
                  ),
                ),
                child: CartCard(cart: cart),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const CheckoutCard(),
    );
  }
}

class CartCard extends StatelessWidget {
  const CartCard({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: AspectRatio(
            aspectRatio: 0.88,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Image.network(
                cart.product.images[0],
                fit: BoxFit.cover, // Ensure the image fits properly
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child:
                        CircularProgressIndicator(), // Show a loader while the image is loading
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons
                      .error); // Show an error icon if the image fails to load
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cart.product.title,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis, // Handle overflow
              ),
              const SizedBox(height: 8),
              // Replace the price with a person icon and number of items
              Row(
                children: [
                  const Icon(
                    Icons.person, // Person icon
                    size: 16,
                    color: Color(0xFFFF7643),
                  ),
                  const SizedBox(width: 4), // Add some spacing
                  Text(
                    "x ${cart.numOfItem}", // Number of items
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFFF7643),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CheckoutCard extends StatelessWidget {
  const CheckoutCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -15),
            blurRadius: 20,
            color: const Color(0xFFDADADA).withOpacity(0.15),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.string(receiptIcon),
                ),
                const Spacer(),
                const Text("Add voucher code"),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.black,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: "Swipe Left to Cancel",
                      children: [],
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFFF7643),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    child: const Text("Book More"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Cart {
  final Product product;
  final int numOfItem;

  Cart({required this.product, required this.numOfItem});
}

class Product {
  final int id;
  final String title, description;
  final List<String> images;
  final List<Color> colors;
  final double rating, price;
  final bool isFavourite, isPopular;

  Product({
    required this.id,
    required this.images,
    required this.colors,
    this.rating = 0.0,
    this.isFavourite = false,
    this.isPopular = false,
    required this.title,
    required this.price,
    required this.description,
  });
}

// Demo data for our products
List<Product> demoProducts = [
  Product(
    id: 1,
    images: [
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ9KijEcmT7qLwslzlt6NDM1K6jitrl9g6obA&s"
    ],
    colors: [
      const Color(0xFFF6625E),
      const Color(0xFF836DB8),
      const Color(0xFFDECB9C),
      Colors.white,
    ],
    title: "The Bakery Cafe",
    price: 64.99,
    description: description,
    rating: 4.8,
    isFavourite: true,
    isPopular: true,
  ),
  Product(
    id: 2,
    images: [
      "https://images.squarespace-cdn.com/content/v1/612e249cb8d4931963f712e5/923f2421-b1fa-4154-994e-11aa021f0d69/75d03719-e372-4e7c-8f19-5e0e6fec7d8e.JPG",
    ],
    colors: [
      const Color(0xFFF6625E),
      const Color(0xFF836DB8),
      const Color(0xFFDECB9C),
      Colors.white,
    ],
    title: "Fire And Ice Pizza",
    price: 50.5,
    description: description,
    rating: 4.1,
    isPopular: true,
  ),
  Product(
    id: 3,
    images: [
      "https://res.cloudinary.com/dpqvbxdpf/image/upload/w_720,h_720,c_thumb,f_auto/v1612946559/uploads/ProfileImage/d2mpew9yfixccsq7xefn.jpg",
    ],
    colors: [
      const Color(0xFFF6625E),
      const Color(0xFF836DB8),
      const Color(0xFFDECB9C),
      Colors.white,
    ],
    title: "The Burger House",
    price: 36.55,
    description: description,
    rating: 4.1,
    isFavourite: true,
    isPopular: true,
  ),
];

const String description =
    "Wireless Controller for PS4™ gives you what you want in your gaming from over precision control your games to sharing …";

const receiptIcon =
    '''<svg width="16" height="20" viewBox="0 0 16 20" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M2.18 19.85C2.27028 19.9471 2.3974 20.0016 2.53 20H2.82C2.9526 20.0016 3.07972 19.9471 3.17 19.85L5 18C5.19781 17.8082 5.51219 17.8082 5.71 18L7.52 19.81C7.61028 19.9071 7.7374 19.9616 7.87 19.96H8.16C8.2926 19.9616 8.41972 19.9071 8.51 19.81L10.32 18C10.5136 17.8268 10.8064 17.8268 11 18L12.81 19.81C12.9003 19.9071 13.0274 19.9616 13.16 19.96H13.45C13.5826 19.9616 13.7097 19.9071 13.8 19.81L15.71 18C15.8947 17.8137 15.9989 17.5623 16 17.3V1C16 0.447715 15.5523 0 15 0H1C0.447715 0 0 0.447715 0 1V17.26C0.00368349 17.5248 0.107266 17.7784 0.29 17.97L2.18 19.85ZM9 11.5C9 11.7761 8.77614 12 8.5 12H4.5C4.22386 12 4 11.7761 4 11.5V10.5C4 10.2239 4.22386 10 4.5 10H8.5C8.77614 10 9 10.2239 9 10.5V11.5ZM11.5 8C11.7761 8 12 7.77614 12 7.5V6.5C12 6.22386 11.7761 6 11.5 6H4.5C4.22386 6 4 6.22386 4 6.5V7.5C4 7.77614 4.22386 8 4.5 8H11.5Z" fill="#FF7643"/>
</svg>
''';

const trashIcon =
    '''<svg width="18" height="20" viewBox="0 0 18 20" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M10.7812 15.6604V7.16981C10.7812 6.8566 11.0334 6.60377 11.3438 6.60377C11.655 6.60377 11.9062 6.8566 11.9062 7.16981V15.6604C11.9062 15.9736 11.655 16.2264 11.3438 16.2264C11.0334 16.2264 10.7812 15.9736 10.7812 15.6604ZM6.09375 15.6604V7.16981C6.09375 6.8566 6.34594 6.60377 6.65625 6.60377C6.9675 6.60377 7.21875 6.8566 7.21875 7.16981V15.6604C7.21875 15.9736 6.9675 16.2264 6.65625 16.2264C6.34594 16.2264 6.09375 15.9736 6.09375 15.6604ZM15 16.6038C15 17.8519 13.9903 18.8679 12.75 18.8679H5.25C4.00969 18.8679 3 17.8519 3 16.6038V3.96226H15V16.6038ZM7.21875 1.50943C7.21875 1.30094 7.38656 1.13208 7.59375 1.13208H10.4062C10.6134 1.13208 10.7812 1.30094 10.7812 1.50943V2.83019H7.21875V1.50943ZM17.4375 2.83019H11.9062V1.50943C11.9062 0.677359 11.2331 0 10.4062 0H7.59375C6.76688 0 6.09375 0.677359 6.09375 1.50943V2.83019H0.5625C0.252187 2.83019 0 3.08302 0 3.39623C0 3.70943 0.252187 3.96226 0.5625 3.96226H1.875V16.6038C1.875 18.4764 3.38906 20 5.25 20H12.75C14.6109 20 16.125 18.4764 16.125 16.6038V3.96226H17.4375C17.7488 3.96226 18 3.70943 18 3.39623C18 3.08302 17.7488 2.83019 17.4375 2.83019Z" fill="#FF4848"/>
</svg>
''';
