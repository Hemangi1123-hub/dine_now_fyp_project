import 'package:flutter/material.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use constraints to determine the screen size
          bool isLargeScreen = constraints.maxWidth > 600;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Metrics Section (Horizontal Scrollable for small screens, Grid for large screens)
                  if (isLargeScreen)
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2,
                      children: const [
                        MetricCard(
                          icon: Icons.people,
                          title: "Users",
                          value: "1,250",
                          color: Colors.blue,
                        ),
                        MetricCard(
                          icon: Icons.restaurant,
                          title: "Restaurants",
                          value: "85",
                          color: Colors.green,
                        ),
                        MetricCard(
                          icon: Icons.fastfood,
                          title: "Food Orders",
                          value: "3,450",
                          color: Colors.orange,
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      height: 150, // Fixed height for the scrollable section
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          MetricCard(
                            icon: Icons.people,
                            title: "Users",
                            value: "1,250",
                            color: Colors.blue,
                          ),
                          SizedBox(width: 10),
                          MetricCard(
                            icon: Icons.restaurant,
                            title: "Restaurants",
                            value: "85",
                            color: Colors.green,
                          ),
                          SizedBox(width: 10),
                          MetricCard(
                            icon: Icons.fastfood,
                            title: "Food Orders",
                            value: "3,450",
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Quick Actions Section
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      ActionButton(
                        icon: Icons.add,
                        label: 'Add Restaurant',
                        onPressed: () {
                          // Navigate to add restaurant page
                        },
                      ),
                      ActionButton(
                        icon: Icons.edit,
                        label: 'Edit Menu',
                        onPressed: () {
                          // Navigate to edit menu page
                        },
                      ),
                      ActionButton(
                        icon: Icons.attach_money,
                        label: 'Advertise Fair',
                        onPressed: () {
                          // Navigate to set booking price page
                        },
                      ),
                      ActionButton(
                        icon: Icons.list,
                        label: 'View Orders',
                        onPressed: () {
                          // Navigate to view orders page
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Metric Card Widget
class MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const MetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Action Button Widget
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}
