import 'package:flutter/material.dart';

// Define the new primary color
const _primaryColor = Color.fromARGB(255, 138, 60, 55);

// Define New Light Theme Colors using the new primary color
const _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: _primaryColor, // Use the defined primary color
  onPrimary: Color(0xFFFFFFFF), // White for good contrast on dark red/brown
  secondary: Color(0xFFD2B48C), // Keep Tan as secondary
  onSecondary: Color(0xFF5D4037), // Dark Brown on Tan
  error: Color(0xFFB00020), // Standard Material error red
  onError: Color(0xFFFFFFFF), // Near-black for text
  surface: Color(0xFFFFFFFF), // White surface for cards, dialogs
  onSurface: Color(0xFF1C1B1F), // Near-black for text on surfaces
);

// Define New Dark Theme Colors using the new primary color
const _darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: _primaryColor, // Use the defined primary color
  onPrimary: Color(0xFFFFFFFF), // White for good contrast
  secondary: Color(0xFFD2B48C), // Keep Tan as secondary
  onSecondary: Color(0xFF5D4037), // Dark Brown on Tan
  error: Color(0xFFCF6679), // Material dark error color
  onError: Color(0xFF141210), // Light grey text
  surface: Color(0xFF2C2A2E), // Slightly lighter dark surface
  onSurface: Color(0xFFE6E1E5), // Light grey text on surface
);

// Define Text Theme (Can be shared or customized)
const _textTheme = TextTheme(
  // Define specific styles if needed, e.g.:
  // headlineSmall: TextStyle(fontWeight: FontWeight.bold),
  // titleLarge: TextStyle(fontWeight: FontWeight.bold),
);

// Create ThemeData objects
final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _lightColorScheme,
  textTheme: _textTheme.apply(
    bodyColor: _lightColorScheme.onSurface,
    displayColor: _lightColorScheme.onSurface,
  ),
  scaffoldBackgroundColor: _lightColorScheme.surface,
  appBarTheme: AppBarTheme(
    backgroundColor: _lightColorScheme.primary, // Use primary color
    foregroundColor: _lightColorScheme.onPrimary, // Use onPrimary color
    elevation: 1.0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightColorScheme.primary, // Use primary color
      foregroundColor: _lightColorScheme.onPrimary, // Use onPrimary color
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _lightColorScheme.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: _lightColorScheme.primary, // Use primary color for focus
        width: 2.0,
      ),
    ),
    labelStyle: TextStyle(color: _lightColorScheme.onSurface.withOpacity(0.6)),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _lightColorScheme.primary, // Use primary color
    ),
  ),
  cardTheme: CardTheme(
    color: _lightColorScheme.surface,
    elevation: 1.0,
    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  ),
  tabBarTheme: TabBarTheme(
    indicatorColor:
        _lightColorScheme.secondary, // Example: Use secondary for indicator
    labelColor: _lightColorScheme.onPrimary, // Color for selected tab text/icon
    unselectedLabelColor: _lightColorScheme.onPrimary.withOpacity(0.8),
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _darkColorScheme,
  textTheme: _textTheme.apply(
    bodyColor: _darkColorScheme.onSurface,
    displayColor: _darkColorScheme.onSurface,
  ),
  scaffoldBackgroundColor: _darkColorScheme.surface,
  appBarTheme: AppBarTheme(
    backgroundColor: _darkColorScheme.surface, // Use dark surface for AppBar
    foregroundColor: _darkColorScheme.onSurface,
    elevation: 1.0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _darkColorScheme.primary, // Use primary color
      foregroundColor: _darkColorScheme.onPrimary, // Use onPrimary color
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _darkColorScheme.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: _darkColorScheme.onSurface.withOpacity(0.3),
        width: 1.0,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: _darkColorScheme.onSurface.withOpacity(0.3),
        width: 1.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: _darkColorScheme.primary, // Use primary color for focus
        width: 2.0,
      ),
    ),
    labelStyle: TextStyle(color: _darkColorScheme.onSurface.withOpacity(0.6)),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _darkColorScheme.primary, // Use primary color
    ),
  ),
  cardTheme: CardTheme(
    color: _darkColorScheme.surface,
    elevation: 1.0,
    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  ),
  tabBarTheme: TabBarTheme(
    indicatorColor:
        _darkColorScheme.secondary, // Example: Use secondary for indicator
    labelColor: _darkColorScheme.onPrimary, // Color for selected tab text/icon
    unselectedLabelColor: _darkColorScheme.onPrimary.withOpacity(0.8),
  ),
);
