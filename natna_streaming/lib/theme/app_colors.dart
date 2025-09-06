import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0F172A);
  static const Color primary = Color(0xFF8A2D3B);
  static const Color shades = Color(0xFF1E293B);

  // Optional: You can also define other colors like surface, onSurface, etc.
  static const Color surface = Color(0xFF1E293B);
  static const Color onSurface = Colors.white;
  static const Color onPrimary = Colors.white;
  static const Color borderColor = Color(0XFFC99EA5);
  static const Color textFieldColor = Color(0XFF3F4555);
  static const Color appBarColor = Color(0XFF060A12);
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
}

ThemeData getAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'JetBrainsMono',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      surface: AppColors.background,
      onSurface: AppColors.onSurface,
      background: AppColors.background,
      error: AppColors.errorColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
