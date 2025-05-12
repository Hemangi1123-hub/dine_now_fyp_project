import 'package:dine_now/models/user_model.dart';
import 'package:dine_now/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to fetch users with the 'owner' role
final ownerUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  return await firestoreService.getUsersByRole('owner');
});

// Provider to manage the loading state of the form
final _addRestaurantLoadingProvider = StateProvider<bool>((ref) => false);

class AdminAddRestaurantScreen extends ConsumerStatefulWidget {
  const AdminAddRestaurantScreen({super.key});

  @override
  ConsumerState<AdminAddRestaurantScreen> createState() =>
      _AdminAddRestaurantScreenState();
}

class _AdminAddRestaurantScreenState
    extends ConsumerState<AdminAddRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _addressController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _selectedOwnerId; // State variable for selected owner UID

  @override
  void dispose() {
    _nameController.dispose();
    _cuisineController.dispose();
    _addressController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedOwnerId == null) {
        // Show error if no owner is selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a restaurant owner.')),
        );
        return;
      }

      ref.read(_addRestaurantLoadingProvider.notifier).state = true;
      final firestoreService = ref.read(firestoreServiceProvider);

      final restaurantId = await firestoreService.addRestaurant(
        name: _nameController.text.trim(),
        cuisine: _cuisineController.text.trim(),
        address: _addressController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        ownerId: _selectedOwnerId!, // Pass selected owner ID
      );

      ref.read(_addRestaurantLoadingProvider.notifier).state = false;

      if (mounted) {
        if (restaurantId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restaurant added successfully!')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add restaurant. Please try again.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(_addRestaurantLoadingProvider);
    final ownerUsersAsync = ref.watch(
      ownerUsersProvider,
    ); // Watch the owners provider

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Restaurant')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField(_nameController, 'Restaurant Name'),
              const SizedBox(height: 16),
              _buildTextFormField(_cuisineController, 'Cuisine Type'),
              const SizedBox(height: 16),
              _buildTextFormField(
                _addressController,
                'Full Address',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                _imageUrlController,
                'Image URL (optional)',
                isRequired: false,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              // Owner Selection Dropdown
              ownerUsersAsync.when(
                data: (owners) {
                  if (owners.isEmpty) {
                    return const Text(
                      'No users with the \'owner\' role found. Please create an owner user first.',
                      style: TextStyle(
                        color: Colors.red,
                      ), // Or some other indicator
                    );
                  }
                  // Ensure there's a valid selection if only one owner exists
                  // or reset if current selection is no longer valid
                  if (_selectedOwnerId != null &&
                      !owners.any((o) => o.uid == _selectedOwnerId)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _selectedOwnerId = null;
                      });
                    });
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedOwnerId,
                    hint: const Text('Select Owner'),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Assign Owner',
                    ),
                    items:
                        owners.map((UserModel owner) {
                          return DropdownMenuItem<String>(
                            value: owner.uid,
                            child: Text('${owner.name} (${owner.email})'),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOwnerId = newValue;
                      });
                    },
                    validator:
                        (value) =>
                            value == null ? 'Please select an owner' : null,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (err, stack) =>
                        Center(child: Text('Error loading owners: $err')),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                child:
                    isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Add Restaurant'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator:
          isRequired
              ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the $label';
                }
                if (keyboardType == TextInputType.url &&
                    value.isNotEmpty &&
                    !value.startsWith('http')) {
                  return 'Please enter a valid URL (starting with http/https)';
                }
                return null;
              }
              : null, // No validator if not required (like image URL)
    );
  }
}
