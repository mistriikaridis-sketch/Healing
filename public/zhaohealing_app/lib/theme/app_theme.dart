import 'package:flutter/material.dart';

class AppTheme {
  static const Color bgWarm = Color(0xFFF9F7F2);
  static const Color ink = Color(0xFF2C2C2C);
  static const Color sub = Color(0xFF666666);
  static const Color accent = Color(0xFFC5A059);
  static const Color paper = Color(0xFFF0EFE9);
  static const Color medicalBlue = Color(0xFF2563EB);
  static const Color soulLight = Color(0xFFFFFCF5);
  static const Color soulShadow = Color(0xFFE6D5C8);

  // 灵犀主题色
  static const Color bgWarmDark = Color(0xFFE2D1C3);
  static const Color textBrown = Color(0xFF5A4A42);
  static const Color textLight = Color(0xFF8D7B72);
  static const Color accentGreen = Color(0xFFA7C4BC);
  static const Color accentOrange = Color(0xFFF3B07C);
  static const Color accentPink = Color(0xFFD4A5B3);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        primary: accent,
        secondary: ink,
        tertiary: medicalBlue,
        surface: bgWarm,
        background: bgWarm,
      ),
      scaffoldBackgroundColor: bgWarm,
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, color: ink, fontFamily: 'serif'),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, color: ink, fontFamily: 'serif'),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: ink, fontFamily: 'serif'),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: ink, fontFamily: 'serif'),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: ink, fontFamily: 'serif'),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: ink, fontFamily: 'serif'),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: ink, fontFamily: 'serif'),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: ink),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: sub),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: ink),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: sub),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: sub),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: sub),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: sub),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: sub),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        surfaceTintColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: ink),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        primary: accent,
        secondary: Colors.white,
        tertiary: medicalBlue,
        surface: const Color(0xFF1A1A1A),
        background: const Color(0xFF1A1A1A),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, color: Colors.white, fontFamily: 'serif'),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, color: Colors.white, fontFamily: 'serif'),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: Colors.white, fontFamily: 'serif'),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'serif'),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'serif'),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'serif'),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white, fontFamily: 'serif'),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Colors.white70),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2A2A2A),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        surfaceTintColor: const Color(0xFF2A2A2A),
      ),
    );
  }
}
