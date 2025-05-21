import 'package:dine_now/models/staff_model.dart';
import 'package:dine_now/services/firestore_service.dart'; // For service
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the staff stream for the current restaurant
final restaurantStaffStreamProvider =
    StreamProvider.family<List<StaffMemberModel>, String>((ref, restaurantId) {
      final firestoreService = ref.watch(firestoreServiceProvider);
      return firestoreService.getStaffStream(restaurantId);
    });

// Provider for the add staff loading state
final _addStaffLoadingProvider = StateProvider<bool>((ref) => false);

class ManageStaffTab extends ConsumerStatefulWidget {
  final String restaurantId;
  const ManageStaffTab({super.key, required this.restaurantId});

  @override
  ConsumerState<ManageStaffTab> createState() => _ManageStaffTabState();
}

class _ManageStaffTabState extends ConsumerState<ManageStaffTab> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showAddStaffDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isLoading = ref.watch(_addStaffLoadingProvider);
        String? dialogError; // Local error state for the dialog

        return StatefulBuilder(
          // Use StatefulBuilder to update dialog state
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Staff Member'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter the email address of the user you want to add as staff. They must already have an account in the app.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Staff Email',
                      errorText: dialogError, // Show error message
                    ),
                    enabled: !isLoading,
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            final email = _emailController.text.trim();
                            if (email.isEmpty || !email.contains('@')) {
                              setDialogState(
                                () =>
                                    dialogError = 'Please enter a valid email',
                              );
                              return;
                            }

                            setDialogState(() => dialogError = null);
                            ref.read(_addStaffLoadingProvider.notifier).state =
                                true;

                            final firestoreService = ref.read(
                              firestoreServiceProvider,
                            );
                            final result = await firestoreService
                                .addStaffByEmail(widget.restaurantId, email);

                            ref.read(_addStaffLoadingProvider.notifier).state =
                                false;

                            if (context.mounted) {
                              if (result == null) {
                                // Success
                                Navigator.of(
                                  context,
                                ).pop(); // Close dialog on success
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$email added successfully!'),
                                  ),
                                );
                                _emailController.clear();
                              } else {
                                // Error message returned
                                setDialogState(() => dialogError = result);
                              }
                            }
                          },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _removeStaff(
    BuildContext context,
    WidgetRef ref,
    StaffMemberModel staff,
  ) async {
    // Show confirmation dialog
    final confirm =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Remove Staff'),
                content: Text(
                  'Are you sure you want to remove ${staff.name} (${staff.email})?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Remove',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
        ) ??
        false; // Default to false if dialog dismissed

    if (confirm) {
      final firestoreService = ref.read(firestoreServiceProvider);
      final success = await firestoreService.removeStaff(
        widget.restaurantId,
        staff.id,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? '${staff.name} removed.' : 'Failed to remove staff.',
            ),
            backgroundColor:
                success ? Colors.green : Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffAsyncValue = ref.watch(
      restaurantStaffStreamProvider(widget.restaurantId),
    );

    return Scaffold(
      // Scaffold is automatically part of the TabBarView
      // Add FloatingActionButton to add staff
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStaffDialog(context, ref),
        tooltip: 'Add Staff',
        child: const Icon(Icons.add),
      ),
      body: staffAsyncValue.when(
        data: (staffList) {
          if (staffList.isEmpty) {
            return const Center(child: Text('No staff members added yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Space for FAB
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(staff.role.substring(0, 1).toUpperCase()),
                ),
                title: Text(staff.name),
                subtitle: Text(staff.email),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  tooltip: 'Remove Staff',
                  onPressed: () => _removeStaff(context, ref, staff),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          print('Error loading staff: $error\n$stack');
          return Center(child: Text('Could not load staff: $error'));
        },
      ),
    );
  }
}
