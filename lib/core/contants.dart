import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF4B5563);
  static const Color backgroundColor = Color(0xFFF3F4F6);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);

  // Durations
  static const int defaultTimerDuration = 60; // seconds
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Points
  static const int defaultPoints = 400;

  // Spacing
  static const double defaultPadding = 16.0;
  static const double cardElevation = 4.0;

  // Typography
  static const TextStyle titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: secondaryColor,
  );
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: secondaryColor,
  );
}