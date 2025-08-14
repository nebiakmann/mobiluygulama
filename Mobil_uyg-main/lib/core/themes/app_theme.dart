import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF4285F4);
  static const Color accentColor = Color(0xFF34A853);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Colors.white;
  static const Color lightOnSurface = Color(0xFF202124);
  static const Color lightTextPrimary = Color(0xFF202124);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightDivider = Color(0xFFDADCE0);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF202124);
  static const Color darkSurface = Color(0xFF303134);
  static const Color darkOnSurface = Color(0xFFE8EAED);
  static const Color darkTextPrimary = Color(0xFFE8EAED);
  static const Color darkTextSecondary = Color(0xFFBDC1C6);
  static const Color darkDivider = Color(0xFF5F6368);
  
  // Status Colors
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC05);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF4285F4);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      useMaterial3: true,
    );
  }
}