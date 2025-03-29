import 'package:flutter/material.dart';
import 'package:hotel_management/themes/colors.dart';

class DockingBar extends StatefulWidget {
  final int activeIndex; // Added: Current active index
  final Function(int) onIndexChanged; // Added: Callback for index changes

  const DockingBar({
    super.key,
    required this.activeIndex, // Added: Required parameter
    required this.onIndexChanged, // Added: Required parameter
  });

  @override
  State<DockingBar> createState() => _DockingBarState();
}

class _DockingBarState extends State<DockingBar> {
  List<IconData> icons = [
    Icons.home,
    Icons.table_bar,
    Icons.travel_explore,
    Icons.person,
  ];

  Tween<double> tween = Tween<double>(begin: 1.0, end: 1.2);
  bool animationCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.none,
      width: MediaQuery.sizeOf(context).width * 0.8, // Responsive width
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1DE),
        borderRadius: BorderRadius.circular(32),
        // Original color
        // Original border radius
      ),
      child: TweenAnimationBuilder(
        key: ValueKey(widget.activeIndex), // Updated: Use widget.activeIndex
        tween: tween,
        duration: Duration(milliseconds: animationCompleted ? 2000 : 200),
        curve: animationCompleted ? Curves.elasticOut : Curves.easeOut,
        onEnd: () {
          setState(() {
            animationCompleted = true;
            tween = Tween(begin: 1.5, end: 1.0);
          });
        },
        builder: (context, value, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(icons.length, (i) {
              return Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..scale(i == widget.activeIndex
                      ? value
                      : 1.0) // Updated: Use widget.activeIndex
                  ..translate(
                      0.0,
                      i == widget.activeIndex
                          ? 80.0 * (1 - value)
                          : 0.0), // Updated: Use widget.activeIndex
                child: InkWell(
                  onTap: () {
                    setState(() {
                      animationCompleted = false;
                      tween = Tween(begin: 1.0, end: 1.2);
                      widget.onIndexChanged(
                          i); // Updated: Notify parent of index change
                    });
                  },
                  onHover: (pointer) {
                    setState(() {
                      animationCompleted = false;
                      tween = Tween(begin: 1.0, end: 1.2);
                      widget.onIndexChanged(
                          i); // Updated: Notify parent of index change
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7), // Original color
                      borderRadius:
                          BorderRadius.circular(10), // Original border radius
                    ),
                    child: Icon(
                      icons[i],
                      size: 24, // Original icon size
                      color: Colors.black, // Original icon color
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
