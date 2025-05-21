import 'package:dine_now/models/timing_model.dart';
import 'package:dine_now/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dine_now/providers/restaurant_provider.dart'; // Import detailsOpeningHoursProvider

// Use a simple StateProvider to hold the local list of hours being edited
final manageHoursStateProvider =
    StateProvider.family<List<DailyOpeningHours>?, String>((ref, restaurantId) {
      // Initialize with null, data will be loaded from the stream provider
      return null;
    });

class ManageTimingsTab extends ConsumerStatefulWidget {
  final String restaurantId;
  const ManageTimingsTab({super.key, required this.restaurantId});

  @override
  ConsumerState<ManageTimingsTab> createState() => _ManageTimingsTabState();
}

class _ManageTimingsTabState extends ConsumerState<ManageTimingsTab> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Load initial data when the widget is first built
    // We watch the stream provider and update our local state provider
    ref.listenManual(detailsOpeningHoursProvider(widget.restaurantId), (
      previous,
      next,
    ) {
      if (next is AsyncData<List<DailyOpeningHours>>) {
        // Only update local state if it hasn't been initialized yet
        // or if the fetched data is different (optional, depends on desired behavior)
        final currentState = ref.read(
          manageHoursStateProvider(widget.restaurantId),
        );
        if (currentState == null) {
          ref
              .read(manageHoursStateProvider(widget.restaurantId).notifier)
              .state = List.from(next.value); // Create a mutable copy
        }
      }
    }, fireImmediately: true);
  }

  void _updateLocalHours(
    List<DailyOpeningHours> Function(List<DailyOpeningHours>) updateFn,
  ) {
    ref.read(manageHoursStateProvider(widget.restaurantId).notifier).update((
      state,
    ) {
      if (state == null) {
        return state; // Return current state (null) if not initialized
      }

      // Create a new list (immutable update pattern)
      final newState = List<DailyOpeningHours>.from(state);
      // Apply the update function which modifies the copy
      return updateFn(newState);
    });
  }

  void _toggleDayOpen(int dayIndex, bool isOpen) {
    _updateLocalHours((currentHours) {
      // Use copyWith to create a modified object
      currentHours[dayIndex] = currentHours[dayIndex].copyWith(isOpen: isOpen);
      // If closing, clear the times (optional, depends on desired behavior)
      if (!isOpen) {
        currentHours[dayIndex] = currentHours[dayIndex].copyWith(
          openTime: null,
          closeTime: null,
        );
      }
      return currentHours;
    });
  }

  void _updateTime(int dayIndex, TimeOfDay time, bool isOpeningTime) {
    _updateLocalHours((currentHours) {
      final currentDay = currentHours[dayIndex];
      // Use copyWith for updates
      currentHours[dayIndex] =
          isOpeningTime
              ? currentDay.copyWith(
                openTime: time,
                isOpen: true,
              ) // Auto-open if setting time
              : currentDay.copyWith(closeTime: time, isOpen: true);
      return currentHours;
    });
  }

  Future<void> _selectTime(
    BuildContext context,
    int dayIndex,
    bool isOpeningTime,
  ) async {
    final currentHours = ref.read(
      manageHoursStateProvider(widget.restaurantId),
    );
    if (currentHours == null) return;

    final initialTime =
        isOpeningTime
            ? currentHours[dayIndex].openTime
            : currentHours[dayIndex].closeTime;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          initialTime ?? const TimeOfDay(hour: 9, minute: 0), // Default to 9 AM
    );

    if (picked != null) {
      _updateTime(dayIndex, picked, isOpeningTime);
    }
  }

  Future<void> _saveTimings() async {
    final currentHours = ref.read(
      manageHoursStateProvider(widget.restaurantId),
    );
    if (currentHours == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Hours data not loaded.')),
      );
      return;
    }
    // Basic validation: Check if close time is after open time for open days
    for (final day in currentHours) {
      if (day.isOpen) {
        if (day.openTime == null || day.closeTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please set both Open and Close times for ${day.dayName}.',
              ),
            ),
          );
          return;
        }
        // Convert to minutes for comparison
        final openMinutes = day.openTime!.hour * 60 + day.openTime!.minute;
        final closeMinutes = day.closeTime!.hour * 60 + day.closeTime!.minute;
        // Allow close time to be 00:00 (midnight) but not equal to open time
        if (closeMinutes != 0 && closeMinutes <= openMinutes) {
          // Allow overnight (close time < open time is handled by logic, but not equal)
          if (!(closeMinutes < openMinutes)) {
            // If not overnight case, check <=
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Close time must be after Open time for ${day.dayName}.',
                ),
              ),
            );
            return;
          }
        }
      }
    }

    setState(() => _isSaving = true);
    final firestoreService = ref.read(firestoreServiceProvider);
    final success = await firestoreService.updateRestaurantTimings(
      widget.restaurantId,
      currentHours,
    );
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Opening hours saved!' : 'Failed to save hours.',
          ),
          backgroundColor:
              success ? Colors.green : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the stream provider to trigger rebuilds on data load/error
    final asyncHours = ref.watch(
      detailsOpeningHoursProvider(widget.restaurantId),
    );
    // Get the local state for editing
    final localHoursState = ref.watch(
      manageHoursStateProvider(widget.restaurantId),
    );

    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving || localHoursState == null ? null : _saveTimings,
        icon:
            _isSaving
                ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : const Icon(Icons.save),
        label: const Text('Save Timings'),
        backgroundColor:
            localHoursState == null
                ? Colors.grey
                : null, // Disable visually if no data
      ),
      body: asyncHours.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Error loading timings: $error"),
              ),
            ),
        data: (loadedHours) {
          // Use the local state for the UI once it's loaded
          if (localHoursState == null) {
            // Show loading indicator until local state is initialized by the listener
            return const Center(
              child: CircularProgressIndicator(
                key: ValueKey("init_local_hours"),
              ),
            );
          }

          // Build the list using the local state
          return ListView.builder(
            padding: const EdgeInsets.all(16.0).copyWith(bottom: 80),
            itemCount: localHoursState.length, // Should always be 7
            itemBuilder: (context, index) {
              final dayHours = localHoursState[index]; // Use index directly

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dayHours.dayName,
                            style: theme.textTheme.titleLarge,
                          ),
                          Switch(
                            value: dayHours.isOpen,
                            onChanged: (value) => _toggleDayOpen(index, value),
                            activeColor: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      if (dayHours.isOpen) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.access_time, size: 18),
                                label: Text(
                                  dayHours.openTime?.format(context) ??
                                      'Set Open',
                                ),
                                onPressed:
                                    () => _selectTime(context, index, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      theme.colorScheme.secondaryContainer,
                                  foregroundColor:
                                      theme.colorScheme.onSecondaryContainer,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  textStyle: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.access_time_filled,
                                  size: 18,
                                ),
                                label: Text(
                                  dayHours.closeTime?.format(context) ??
                                      'Set Close',
                                ),
                                onPressed:
                                    () => _selectTime(context, index, false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      theme.colorScheme.secondaryContainer,
                                  foregroundColor:
                                      theme.colorScheme.onSecondaryContainer,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  textStyle: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
