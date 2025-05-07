import 'package:flutter/material.dart'; // For TimeOfDay

class DailyOpeningHours {
  // Store day names or numbers (0=Mon, 6=Sun)
  // Using int for easier sorting/storage
  final int dayOfWeek; // 0=Mon, 1=Tue, ..., 6=Sun
  final TimeOfDay? openTime;
  final TimeOfDay? closeTime;
  final bool isOpen;

  static const List<String> dayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  // Make properties final and use a const constructor
  const DailyOpeningHours({
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    this.isOpen = false,
  });

  String get dayName => dayNames[dayOfWeek];

  // Convert TimeOfDay to minutes since midnight for Firestore storage
  int? _timeOfDayToMinutes(TimeOfDay? time) {
    if (time == null) return null;
    return time.hour * 60 + time.minute;
  }

  // Convert minutes since midnight back to TimeOfDay
  static TimeOfDay? _minutesToTimeOfDay(int? minutes) {
    if (minutes == null || minutes < 0 || minutes >= 24 * 60) return null;
    final int hours = minutes ~/ 60;
    final int mins = minutes % 60;
    return TimeOfDay(hour: hours, minute: mins);
  }

  // Convert from Firestore data (Map)
  factory DailyOpeningHours.fromMap(int day, Map<String, dynamic> data) {
    return DailyOpeningHours(
      dayOfWeek: day,
      openTime: _minutesToTimeOfDay(data['open'] as int?),
      closeTime: _minutesToTimeOfDay(data['close'] as int?),
      isOpen: data['isOpen'] as bool? ?? false, // Explicit cast and null check
    );
  }

  // Convert to Firestore representation (Map)
  Map<String, dynamic> toMap() {
    return {
      'open': _timeOfDayToMinutes(openTime),
      'close': _timeOfDayToMinutes(closeTime),
      'isOpen': isOpen,
    };
  }

  // copyWith method
  DailyOpeningHours copyWith({
    int? dayOfWeek,
    TimeOfDay? openTime,
    TimeOfDay? closeTime,
    bool? isOpen,
  }) {
    return DailyOpeningHours(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      // Handle potential null assignment if needed, though constructor allows nulls
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  // Optional: Add equality and hashCode for better state comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyOpeningHours &&
          runtimeType == other.runtimeType &&
          dayOfWeek == other.dayOfWeek &&
          openTime == other.openTime &&
          closeTime == other.closeTime &&
          isOpen == other.isOpen;

  @override
  int get hashCode =>
      dayOfWeek.hashCode ^
      openTime.hashCode ^
      closeTime.hashCode ^
      isOpen.hashCode;
}
