import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors from the Swift app
  static const Color deepRed = Color(0xFFB31A1A);
  static const Color cream = Color(0xFFFAF5E6);
  static const Color lightRed = Color(0xFFE6B3B3);
  static const Color white = Colors.white;

  // Status colors
  static const Color approved = Color(0xFF4CAF50);
  static const Color pending = Color(0xFFFFA726);
  static const Color rejected = Color(0xFFEF5350);
  static const Color used = Color(0xFF42A5F5);

  // Gradients
  static final LinearGradient headerGradient = LinearGradient(
    colors: [deepRed, const Color(0xFF8B1414)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: deepRed,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: deepRed,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  // Card decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 5,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Input decoration
  static InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: deepRed),
      labelStyle: const TextStyle(color: deepRed),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: deepRed.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: deepRed),
      ),
      filled: true,
      fillColor: white,
    );
  }

  // Status badge color
  static Color statusColor(String status) {
    switch (status) {
      case 'approved':
        return approved;
      case 'pending':
        return pending;
      case 'rejected':
        return rejected;
      case 'used':
        return used;
      default:
        return Colors.grey;
    }
  }

  // ThemeData
  static ThemeData get themeData => ThemeData(
        primaryColor: deepRed,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: deepRed,
          primary: deepRed,
          surface: cream,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: deepRed,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: deepRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        fontFamily: 'Roboto',
      );
}
