import 'package:flutter/material.dart';

class ParkingColors {
  static const navy = Color(0xFF0F172A);
  static const navySoft = Color(0xFF1E293B);
  static const cyan = Color(0xFF06B6D4);
  static const blue = Color(0xFF2563EB);
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
}

class ParkingTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: ParkingColors.cyan,
      brightness: Brightness.light,
      primary: ParkingColors.navy,
      secondary: ParkingColors.cyan,
      surface: ParkingColors.surface,
      error: ParkingColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ParkingColors.background,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: ParkingColors.navy,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: ParkingColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: ParkingColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ParkingColors.cyan,
          foregroundColor: ParkingColors.navy,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ParkingColors.navy,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: ParkingColors.border),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ParkingColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ParkingColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ParkingColors.cyan, width: 1.8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.white,
        indicatorColor: ParkingColors.cyan.withOpacity(.14),
      ),
    );
  }
}
