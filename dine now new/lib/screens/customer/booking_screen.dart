import 'package:dine_now/models/booking_model.dart';
import 'package:dine_now/models/restaurant_model.dart';
import 'package:dine_now/providers/user_provider.dart'; // For current user & service
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:dine_now/models/timing_model.dart'; // Import DailyOpeningHours
import 'package:dine_now/providers/restaurant_provider.dart'; // Import opening hours provider

// Provider for loading state
final _bookingLoadingProvider = StateProvider<bool>((ref) => false);

// Helper to create a default (closed) DailyOpeningHours instance
DailyOpeningHours _defaultTimingModel(int day) => DailyOpeningHours(
  dayOfWeek: day,
  isOpen: false,
  // No need for default times if closed
);

class BookingScreen extends ConsumerStatefulWidget {
  final RestaurantModel restaurant;
  const BookingScreen({super.key, required this.restaurant});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _partySize = 1; // Default party size
  final int _maxPartySize = 10; // Example max size

  // Store fetched opening hours locally
  List<DailyOpeningHours>? _openingHours;
  bool _hoursProcessed = false; // Track if post-frame callback has run

  @override
  void initState() {
    super.initState();
    // Initial date/time set after hours load
  }

  // --- Helper Methods for Opening Hours ---

  // Get the DailyOpeningHours for a specific date
  DailyOpeningHours _getTimingForDate(
    DateTime date,
    List<DailyOpeningHours> hours,
  ) {
    if (hours.isEmpty) {
      // If hours list is empty, return default closed for the specific weekday
      int weekday = date.weekday; // DateTime.weekday: Mon=1, Tue=2, ..., Sun=7
      return _defaultTimingModel(weekday - 1); // Adjust to 0-6 index
    }
    // DateTime.weekday: Mon=1, Tue=2, ..., Sun=7
    // DailyOpeningHours.dayOfWeek: Mon=0, Tue=1, ..., Sun=6
    int targetDayIndex = date.weekday - 1;
    try {
      return hours.firstWhere((timing) => timing.dayOfWeek == targetDayIndex);
    } catch (e) {
      // Should not happen if provider returns full 7 days, but handle defensively
      return _defaultTimingModel(targetDayIndex);
    }
  }

  // Check if the restaurant is open on a specific date
  bool _isRestaurantOpenOnDate(DateTime date, List<DailyOpeningHours> hours) {
    DateTime dateOnly = DateTime(date.year, date.month, date.day);
    DateTime today = DateTime.now();
    DateTime todayOnly = DateTime(today.year, today.month, today.day);

    if (dateOnly.isBefore(todayOnly)) return false;

    return _getTimingForDate(dateOnly, hours).isOpen;
  }

  // Predicate for Date Picker
  bool _selectableDayPredicate(DateTime date) {
    if (_openingHours == null) return false; // Hours not loaded
    return _isRestaurantOpenOnDate(date, _openingHours!);
  }

  // Find first available date from today onwards
  DateTime? _findFirstAvailableDate(List<DailyOpeningHours> hours) {
    DateTime checkDate = DateTime.now();
    DateTime endDate = checkDate.add(const Duration(days: 90));

    while (checkDate.isBefore(endDate)) {
      DateTime currentDateOnly = DateTime(
        checkDate.year,
        checkDate.month,
        checkDate.day,
      );
      if (_isRestaurantOpenOnDate(currentDateOnly, hours)) {
        return currentDateOnly;
      }
      checkDate = checkDate.add(const Duration(days: 1));
    }
    return null;
  }

  int _timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  // Validate selected time against opening hours
  bool _isTimeSelectionValid(
    TimeOfDay selectedTime,
    DateTime selectedDate,
    List<DailyOpeningHours> hours,
  ) {
    final timingForDay = _getTimingForDate(selectedDate, hours);
    // Check if open and if times are defined (should be if isOpen is true)
    if (!timingForDay.isOpen ||
        timingForDay.openTime == null ||
        timingForDay.closeTime == null) {
      return false;
    }

    final int selectedMinutes = _timeOfDayToMinutes(selectedTime);
    final int openMinutes = _timeOfDayToMinutes(
      timingForDay.openTime!,
    ); // Use ! because we checked null
    final int closeMinutes = _timeOfDayToMinutes(
      timingForDay.closeTime!,
    ); // Use ! because we checked null

    final int effectiveCloseMinutes =
        (closeMinutes == 0 && openMinutes != 0) ? 24 * 60 : closeMinutes;

    if (effectiveCloseMinutes < openMinutes) {
      // Overnight case
      return selectedMinutes >= openMinutes ||
          selectedMinutes < effectiveCloseMinutes;
    } else {
      // Same day case
      return selectedMinutes >= openMinutes &&
          selectedMinutes < effectiveCloseMinutes;
    }
  }

  // --- UI Interaction Methods ---

  Future<void> _selectDate(BuildContext context) async {
    if (_openingHours == null || _openingHours!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening hours not available or still loading.'),
        ),
      );
      return;
    }

    DateTime firstDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    DateTime firstValidAvailableDate =
        _findFirstAvailableDate(_openingHours!) ?? firstDate;
    DateTime initialPickerDate = _selectedDate ?? firstValidAvailableDate;

    if (initialPickerDate.isBefore(firstDate) ||
        !_selectableDayPredicate(initialPickerDate)) {
      initialPickerDate = firstValidAvailableDate;
    }
    if (initialPickerDate.isBefore(firstDate)) {
      initialPickerDate = firstDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialPickerDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 90)),
      selectableDayPredicate: _selectableDayPredicate,
    );

    if (picked != null) {
      DateTime pickedDateOnly = DateTime(picked.year, picked.month, picked.day);
      if (_selectedDate != pickedDateOnly) {
        setState(() {
          _selectedDate = pickedDateOnly;
          _selectedTime = null;
        });
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    if (_selectedDate == null ||
        _openingHours == null ||
        _openingHours!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date first.')),
      );
      return;
    }

    final timingForDay = _getTimingForDate(_selectedDate!, _openingHours!);
    if (!timingForDay.isOpen ||
        timingForDay.openTime == null ||
        timingForDay.closeTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Restaurant is closed or hours undefined for the selected date.',
          ),
        ),
      );
      return;
    }

    TimeOfDay initialTimeSuggestion = timingForDay.openTime!;
    if (_selectedTime != null &&
        _isTimeSelectionValid(_selectedTime!, _selectedDate!, _openingHours!)) {
      initialTimeSuggestion = _selectedTime!;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTimeSuggestion,
    );

    if (picked != null) {
      if (_isTimeSelectionValid(picked, _selectedDate!, _openingHours!)) {
        setState(() {
          _selectedTime = picked;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select a time between ${timingForDay.openTime!.format(context)} and ${timingForDay.closeTime!.format(context)}.',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both date and time.')),
      );
      return;
    }

    if (_openingHours == null ||
        _openingHours!.isEmpty ||
        !_isTimeSelectionValid(
          _selectedTime!,
          _selectedDate!,
          _openingHours!,
        )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected time is outside opening hours.'),
        ),
      );
      return;
    }

    final currentUserData = await ref.read(currentUserDataProvider.future);
    if (!mounted) return;
    if (currentUserData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Could not identify user.')),
      );
      return;
    }

    ref.read(_bookingLoadingProvider.notifier).state = true;

    final firestoreService = ref.read(firestoreServiceProvider);
    final bookingDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final userName =
        currentUserData.name.isNotEmpty ? currentUserData.name : 'App User';
    final userEmail = currentUserData.email;

    final newBooking = BookingModel(
      restaurantId: widget.restaurant.id,
      restaurantName: widget.restaurant.name,
      userId: currentUserData.uid,
      userName: userName,
      userEmail: userEmail,
      bookingDateTime: bookingDateTime,
      partySize: _partySize,
      createdAt: Timestamp.now(),
      status: 'pending',
    );

    final bookingId = await firestoreService.createBooking(newBooking);

    if (!mounted) return;
    ref.read(_bookingLoadingProvider.notifier).state = false;

    if (bookingId != null) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: const Text('Booking Requested'),
              content: Text(
                'Your booking for ${widget.restaurant.name} on ${DateFormat.yMMMd().add_jm().format(bookingDateTime)} for $_partySize people is pending. You will be notified upon confirmation.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create booking. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(_bookingLoadingProvider);
    final theme = Theme.of(context);

    // Watch the opening hours provider (returns List<DailyOpeningHours>)
    final openingHoursAsync = ref.watch(
      detailsOpeningHoursProvider(widget.restaurant.id),
    );

    // Use WidgetsBinding to safely update state after the build cycle completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Use AsyncValue.guard to handle potential errors during data processing
      AsyncValue.guard(() async {
        if (openingHoursAsync is AsyncData<List<DailyOpeningHours>>) {
          final hours = openingHoursAsync.asData!.value;
          if (!_hoursProcessed || _openingHours != hours) {
            setState(() {
              _openingHours = hours;
              _hoursProcessed = true;
              if (_selectedDate == null && hours.isNotEmpty) {
                _selectedDate = _findFirstAvailableDate(hours);
              } else if (_selectedDate != null &&
                  hours.isNotEmpty &&
                  !_isRestaurantOpenOnDate(_selectedDate!, hours)) {
                _selectedDate = _findFirstAvailableDate(hours);
                _selectedTime = null;
              }
            });
          }
        } else if (openingHoursAsync is AsyncError && !_hoursProcessed) {
          setState(() {
            _openingHours = [];
            _hoursProcessed = true;
          });
        }
      }); // End of AsyncValue.guard
    });

    return Scaffold(
      appBar: AppBar(title: Text('Book at ${widget.restaurant.name}')),
      body: openingHoursAsync.when(
        loading:
            () => const Center(
              child: CircularProgressIndicator(key: ValueKey('loading_hours')),
            ),
        error:
            (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading opening hours: $error.\nPlease try again later.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        data: (hours) {
          if (!_hoursProcessed) {
            return const Center(
              child: CircularProgressIndicator(
                key: ValueKey('processing_hours'),
              ),
            );
          }

          if (_openingHours == null || _openingHours!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Opening hours are not available for this restaurant.\nBooking is not possible.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // -- Main Booking Form --
          bool canInteract =
              _hoursProcessed &&
              _openingHours != null &&
              _openingHours!.isNotEmpty;
          bool canSubmit =
              canInteract &&
              _selectedDate != null &&
              _selectedTime != null &&
              !isSubmitting;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Date & Time', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  // Date Picker ListTile
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      _selectedDate == null
                          ? 'Select Date'
                          : DateFormat.yMMMEd().format(_selectedDate!),
                    ),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: canInteract ? () => _selectDate(context) : null,
                    enabled: canInteract,
                    contentPadding: EdgeInsets.zero,
                  ),
                  // Time Picker ListTile
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      _selectedTime == null
                          ? 'Select Time'
                          : _selectedTime!.format(context),
                    ),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap:
                        canInteract && _selectedDate != null
                            ? () => _selectTime(context)
                            : null,
                    enabled: canInteract && _selectedDate != null,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(height: 32),
                  // Party Size Selector
                  Text('Party Size', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed:
                            _partySize > 1
                                ? () => setState(() => _partySize--)
                                : null,
                      ),
                      Text(
                        '$_partySize',
                        style: theme.textTheme.headlineMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed:
                            _partySize < _maxPartySize
                                ? () => setState(() => _partySize++)
                                : null,
                      ),
                    ],
                  ),
                  Text(
                    'Person(s)',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 40),
                  // Submit Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: canSubmit ? _submitBooking : null,
                      icon:
                          isSubmitting
                              ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Icon(Icons.check_circle_outline),
                      label: const Text('Request Booking'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        foregroundColor: theme.colorScheme.onPrimary,
                        backgroundColor: theme.colorScheme.primary,
                        disabledForegroundColor: Colors.white70,
                        disabledBackgroundColor: Colors.grey,
                      ),
                    ),
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
