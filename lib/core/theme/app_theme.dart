import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const ink = Color(0xFF18322E);
  static const muted = Color(0xFF64736F);
  static const canvas = Color(0xFFF6F5F0);
  static const surface = Color(0xFFFFFEFA);
  static const teal = Color(0xFF2C7667);
  static const mint = Color(0xFFDCEDE6);
  static const warm = Color(0xFFECE6D8);

  static ThemeData get light {
    final colors = ColorScheme.fromSeed(
      seedColor: teal,
      brightness: Brightness.light,
      surface: surface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors.copyWith(
        primary: teal,
        onPrimary: Colors.white,
        secondary: const Color(0xFFD9A86C),
        surface: surface,
        onSurface: ink,
      ),
      scaffoldBackgroundColor: canvas,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: ink,
          fontSize: 34,
          height: 1.08,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.1,
        ),
        headlineMedium: TextStyle(
          color: ink,
          fontSize: 27,
          height: 1.15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        titleLarge: TextStyle(
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: ink,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: ink, fontSize: 16, height: 1.45),
        bodyMedium: TextStyle(color: muted, fontSize: 14, height: 1.45),
        labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: teal, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(56, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
    );
  }
}
