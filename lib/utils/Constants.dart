import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const primaryColor = Color(0xFF673AB7);
  static const accentColor = Color(0xFF9C27B0);
  static const backgroundColor = Color(0xFFF5F7FA);
  static const cardColor = Colors.white;

  // Gradients
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
  );

  // Text Styles
  static const heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const bodyText = TextStyle(
    fontSize: 14,
  );

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
}