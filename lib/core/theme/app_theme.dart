import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Strict Black & White Color Palette
  // Light Mode
  static const Color lightBackground = Color(0xFFFFFFFF); // Pure white
  static const Color lightTextPrimary = Color(0xFF000000); // Pure black
  static const Color lightTextSecondary = Color(0xFF6B6B6B); // Medium grey
  static const Color lightTextTertiary = Color(0xFF9B9B9B); // Light grey
  static const Color lightDivider = Color(0xFFE5E5E5); // Very light grey

  // Dark Mode
  static const Color darkBackground = Color(0xFF000000); // Pure black
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // Pure white
  static const Color darkTextSecondary = Color(0xFF9B9B9B); // Medium grey
  static const Color darkTextTertiary = Color(0xFF6B6B6B); // Dark grey
  static const Color darkDivider = Color(0xFF1A1A1A); // Very dark grey

  // Muted Status Colors (20% opacity on text)
  // Light Mode
  static const Color lightSafe = Color(0xFF4A5D4A); // Muted grey-green
  static const Color lightCaution = Color(0xFF6B5D4A); // Muted amber-grey
  static const Color lightAvoid = Color(0xFF6B4A4A); // Muted grey-red

  // Dark Mode
  static const Color darkSafe = Color(0xFF5A6B5A); // Muted grey-green
  static const Color darkCaution = Color(0xFF7B6B5A); // Muted amber-grey
  static const Color darkAvoid = Color(0xFF7B5A5A); // Muted grey-red

  // Legacy support (mapped to new colors)
  static Color get safe => lightSafe;
  static Color get caution => lightCaution;
  static Color get avoid => lightAvoid;

  // Design Tokens
  static const double spacingUnit = 4.0; // 4px base

  // Typography
  static TextStyle h1(bool isDark) => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: isDark ? darkTextPrimary : lightTextPrimary,
      );

  static TextStyle h2(bool isDark) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: isDark ? darkTextPrimary : lightTextPrimary,
      );

  static TextStyle h3(bool isDark) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: isDark ? darkTextPrimary : lightTextPrimary,
      );

  static TextStyle bodyLarge(bool isDark) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: isDark ? darkTextPrimary : lightTextPrimary,
      );

  static TextStyle body(bool isDark) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        color: isDark ? darkTextPrimary : lightTextPrimary,
      );

  static TextStyle bodySmall(bool isDark) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        color: isDark ? darkTextSecondary : lightTextSecondary,
      );

  static TextStyle caption(bool isDark) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: isDark ? darkTextSecondary : lightTextSecondary,
      );

  static TextStyle score(bool isDark) => TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: isDark ? darkTextPrimary : lightTextPrimary,
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: lightTextPrimary,
          primary: lightTextPrimary,
          surface: lightBackground,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: lightBackground,
        textTheme: GoogleFonts.interTextTheme().copyWith(
          displayLarge: h1(false),
          displayMedium: h2(false),
          displaySmall: h3(false),
          bodyLarge: bodyLarge(false),
          bodyMedium: body(false),
          bodySmall: bodySmall(false),
          labelSmall: caption(false),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.transparent,
            fontSize: 0,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightTextPrimary,
            foregroundColor: lightBackground,
            minimumSize: const Size(double.infinity, 64),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            elevation: 0,
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkTextPrimary,
          primary: darkTextPrimary,
          surface: darkBackground,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: darkBackground,
        textTheme:
            GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge: h1(true),
          displayMedium: h2(true),
          displaySmall: h3(true),
          bodyLarge: bodyLarge(true),
          bodyMedium: body(true),
          bodySmall: bodySmall(true),
          labelSmall: caption(true),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.transparent,
            fontSize: 0,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkTextPrimary,
            foregroundColor: darkBackground,
            minimumSize: const Size(double.infinity, 64),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            elevation: 0,
          ),
        ),
      );
}
