import 'package:dine_now/providers/auth_provider.dart';
import 'package:dine_now/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // Function to handle refresh logic
  Future<void> _refreshProfile(WidgetRef ref) async {
    // Invalidate the provider to refetch user data
    ref.invalidate(currentUserDataProvider);
    // Optionally wait for the future if needed
    // await ref.read(currentUserDataProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: userAsync.when(
        // Wrap ListView with RefreshIndicator
        data:
            (user) => RefreshIndicator(
              onRefresh: () => _refreshProfile(ref),
              child:
                  user == null
                      ? LayoutBuilder(
                        // Handle null user case within RefreshIndicator
                        builder:
                            (context, constraints) => SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: const Center(
                                  child: Text('Could not load profile data.'),
                                ),
                              ),
                            ),
                      )
                      : ListView(
                        // Ensure ListView is always scrollable for RefreshIndicator
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text('Name'),
                            subtitle: Text(
                              user.name.isNotEmpty ? user.name : 'N/A',
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: const Text('Email'),
                            subtitle: Text(
                              user.email.isNotEmpty ? user.email : 'N/A',
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.work),
                            title: const Text('Role'),
                            subtitle: Text(user.role.toUpperCase()),
                          ),
                          const Divider(),
                          if (user.assignedRestaurantId != null)
                            ListTile(
                              leading: const Icon(Icons.storefront),
                              title: const Text('Assigned Restaurant ID'),
                              subtitle: Text(user.assignedRestaurantId!),
                            ),
                          if (user.assignedRestaurantId != null)
                            const Divider(),
                          const SizedBox(height: 30),
                          Center(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.logout),
                              label: const Text('Logout'),
                              onPressed: () async {
                                // Consider showing a confirmation dialog before logout
                                // Pop all routes up to the first one AFTER logout is complete
                                await ref.read(authServiceProvider).signOut();
                                if (context.mounted) {
                                  Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                                foregroundColor: theme.colorScheme.onError,
                              ),
                            ),
                          ),
                        ],
                      ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        // Wrap error state with RefreshIndicator
        error:
            (err, stack) => RefreshIndicator(
              onRefresh: () => _refreshProfile(ref),
              child: LayoutBuilder(
                // Ensure Center takes full height
                builder:
                    (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Error loading profile: ${err.toString()}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
              ),
            ),
      ),
    );
  }
}
