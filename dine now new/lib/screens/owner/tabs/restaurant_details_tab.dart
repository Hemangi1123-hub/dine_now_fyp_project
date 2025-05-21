import 'package:dine_now/models/restaurant_model.dart';
import 'package:dine_now/providers/user_provider.dart'; // For firestoreServiceProvider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for loading state during update
final _detailsUpdateLoadingProvider = StateProvider<bool>((ref) => false);

class RestaurantDetailsTab extends ConsumerStatefulWidget {
  final RestaurantModel restaurant;
  const RestaurantDetailsTab({super.key, required this.restaurant});

  @override
  ConsumerState<RestaurantDetailsTab> createState() =>
      _RestaurantDetailsTabState();
}

class _RestaurantDetailsTabState extends ConsumerState<RestaurantDetailsTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cuisineController;
  late TextEditingController _addressController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current restaurant data
    _nameController = TextEditingController(text: widget.restaurant.name);
    _cuisineController = TextEditingController(text: widget.restaurant.cuisine);
    _addressController = TextEditingController(text: widget.restaurant.address);
    _imageUrlController = TextEditingController(
      text: widget.restaurant.imageUrl,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cuisineController.dispose();
    _addressController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _updateDetails() async {
    if (_formKey.currentState!.validate()) {
      ref.read(_detailsUpdateLoadingProvider.notifier).state = true;
      final firestoreService = ref.read(firestoreServiceProvider);

      final success = await firestoreService.updateRestaurantDetails(
        widget.restaurant.id,
        name: _nameController.text.trim(),
        cuisine: _cuisineController.text.trim(),
        address: _addressController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
      );

      ref.read(_detailsUpdateLoadingProvider.notifier).state = false;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Details updated successfully!'
                  : 'Failed to update details. Please try again.',
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
    final isLoading = ref.watch(_detailsUpdateLoadingProvider);

    // Use a ListView to prevent overflow if content grows
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit Restaurant Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Restaurant Name'),
              validator:
                  (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Please enter a name'
                          : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cuisineController,
              decoration: const InputDecoration(labelText: 'Cuisine Type'),
              validator:
                  (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Please enter a cuisine type'
                          : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              maxLines: 3,
              validator:
                  (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Please enter an address'
                          : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                hintText: 'https://...',
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                // Basic URL validation (optional field)
                if (value != null &&
                    value.isNotEmpty &&
                    !value.startsWith('http')) {
                  return 'Please enter a valid URL (starting with http/https)';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isLoading ? null : _updateDetails,
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
                      : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
 