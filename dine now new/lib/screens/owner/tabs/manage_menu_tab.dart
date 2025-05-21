// ignore_for_file: unnecessary_string_escapes

import 'package:dine_now/models/menu_item_model.dart';
import 'package:dine_now/providers/restaurant_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For images
import 'package:dine_now/services/firestore_service.dart'; // Ensure this is the only import for the provider

class ManageMenuTab extends ConsumerWidget {
  final String restaurantId;
  const ManageMenuTab({super.key, required this.restaurantId});

  // Function to show Add/Edit Menu Item Dialog
  void _showUpsertMenuItemDialog(
    BuildContext context,
    WidgetRef ref, {
    MenuItemModel? existingItem,
  }) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: existingItem?.name ?? '',
    );
    final descController = TextEditingController(
      text: existingItem?.description ?? '',
    );
    final priceController = TextEditingController(
      text: existingItem?.price.toString() ?? '',
    );
    final categoryController = TextEditingController(
      text: existingItem?.category ?? '',
    );
    final imageUrlController = TextEditingController(
      text: existingItem?.imageUrl ?? '',
    );
    bool isAvailable = existingItem?.isAvailable ?? true;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existingItem == null ? 'Add Menu Item' : 'Edit Menu Item',
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator:
                            (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                        enabled: !isLoading,
                      ),
                      TextFormField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                        ),
                        maxLines: 2,
                        enabled: !isLoading,
                      ),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          prefixText: 'NPR ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$'),
                          ),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (double.tryParse(v) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                        enabled: !isLoading,
                      ),
                      TextFormField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category (e.g., Appetizer)',
                        ),
                        validator:
                            (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                        enabled: !isLoading,
                      ),
                      TextFormField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL (optional)',
                        ),
                        keyboardType: TextInputType.url,
                        enabled: !isLoading,
                      ),
                      SwitchListTile(
                        title: const Text('Is Available'),
                        value: isAvailable,
                        onChanged:
                            isLoading
                                ? null
                                : (value) =>
                                    setDialogState(() => isAvailable = value),
                      ),
                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
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
                            if (formKey.currentState!.validate()) {
                              setDialogState(() => isLoading = true);
                              final firestoreService = ref.read(
                                firestoreServiceProvider,
                              );
                              final item = MenuItemModel(
                                id:
                                    existingItem?.id ??
                                    '', // Use existing ID or empty for new
                                name: nameController.text.trim(),
                                description: descController.text.trim(),
                                price:
                                    double.tryParse(priceController.text) ??
                                    0.0,
                                category: categoryController.text.trim(),
                                imageUrl: imageUrlController.text.trim(),
                                isAvailable: isAvailable,
                              );
                              final success = await firestoreService
                                  .upsertMenuItem(restaurantId, item);
                              setDialogState(() => isLoading = false);
                              if (context.mounted) {
                                if (success) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Menu item ${existingItem == null ? "added" : "updated"}!',
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Operation failed. Please try again.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                  child: Text(existingItem == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteItem(
    BuildContext context,
    WidgetRef ref,
    MenuItemModel item,
  ) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Delete Item'),
                content: Text('Are you sure you want to delete ${item.name}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirm) {
      final firestoreService = ref.read(firestoreServiceProvider);
      final success = await firestoreService.deleteMenuItem(
        restaurantId,
        item.id,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? '${item.name} deleted.' : 'Failed to delete item.',
            ),
            backgroundColor:
                success ? Colors.green : Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsyncValue = ref.watch(
      restaurantMenuStreamProvider(restaurantId),
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUpsertMenuItemDialog(context, ref),
        tooltip: 'Add Menu Item',
        child: const Icon(Icons.add),
      ),
      body: menuAsyncValue.when(
        data: (menuItems) {
          if (menuItems.isEmpty) {
            return const Center(child: Text('No menu items added yet.'));
          }
          // Group items by category for better display (optional but nice)
          final groupedMenu = <String, List<MenuItemModel>>{};
          for (var item in menuItems) {
            (groupedMenu[item.category] ??= []).add(item);
          }
          final categories = groupedMenu.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Space for FAB
            itemCount: categories.length,
            itemBuilder: (context, catIndex) {
              final category = categories[catIndex];
              final itemsInCategory = groupedMenu[category]!;
              return ExpansionTile(
                title: Text(
                  category,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                initiallyExpanded: true, // Keep categories expanded by default
                children:
                    itemsInCategory
                        .map(
                          (item) => ListTile(
                            leading:
                                item.imageUrl.isNotEmpty
                                    ? CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                            item.imageUrl,
                                          ),
                                      onBackgroundImageError: (_, __) {},
                                    )
                                    : CircleAvatar(
                                      child: Icon(Icons.fastfood, size: 20),
                                    ), // Placeholder icon
                            title: Text(item.name),
                            subtitle: Text(
                              '\NPR ${item.price.toStringAsFixed(2)}${item.description.isNotEmpty ? '\n${item.description}' : ''}',
                            ),
                            isThreeLine: item.description.isNotEmpty,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: item.isAvailable,
                                  onChanged: (value) async {
                                    // Optimistic UI update + DB update
                                    final updatedItem = MenuItemModel(
                                      id: item.id,
                                      name: item.name,
                                      description: item.description,
                                      price: item.price,
                                      category: item.category,
                                      imageUrl: item.imageUrl,
                                      isAvailable: value,
                                    );
                                    final firestoreService = ref.read(
                                      firestoreServiceProvider,
                                    );
                                    await firestoreService.upsertMenuItem(
                                      restaurantId,
                                      updatedItem,
                                    );
                                    // Stream will update the UI eventually
                                  },
                                  activeColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  tooltip: 'Edit Item',
                                  onPressed:
                                      () => _showUpsertMenuItemDialog(
                                        context,
                                        ref,
                                        existingItem: item,
                                      ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  tooltip: 'Delete Item',
                                  onPressed:
                                      () => _deleteItem(context, ref, item),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          print('Error loading menu: $error\n$stack');
          return Center(child: Text('Could not load menu: $error'));
        },
      ),
    );
  }
}
