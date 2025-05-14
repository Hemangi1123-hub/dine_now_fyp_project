import 'package:dine_now/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChefDashboardScreen extends ConsumerWidget {
  const ChefDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Fetch data relevant to the chef (e.g., assigned restaurant, orders)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chef Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome, Chef! - [Restaurant Name Placeholder]'),
        // TODO: Display relevant chef information (orders, schedule)
      ),
    );
  }
}
