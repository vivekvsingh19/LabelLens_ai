import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF121212); // Material Dark
  static const Color darkCard = Color(0xFF1E1E1E); // Lighter Dark Gray
  static const Color darkText = Color(0xFFF1F5F9);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkDivider = Color(0xFF1E293B);

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightTextMuted = Color(0xFF475569);
  static const Color lightDivider = Color(0xFFE2E8F0);

  // AI-Centric Accent Colors
  static const Color accentPrimary = Color(0xFFFFFFFF); // White
  static const Color accentSecondary = Color(0xFFE0E0E0); // Light Gray
  static const Color accentSpark = Color(0xFFBDBDBD); // Silver

  // Status Colors
  static const Color safeColor = Color(0xFF22C55E); // Green
  static const Color cautionColor = Color(0xFFF59E0B); // Amber
  static const Color avoidColor = Color(0xFFEF4444); // Red

  // Design Tokens
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusSmall = 16.0;

  // Shadow Tokens
  static List<BoxShadow> softShadow(bool isDark) => [
        BoxShadow(
          color: isDark
              ? const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.04),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> premiumShadow(bool isDark) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.7)
              : Colors.black.withValues(alpha: 0.08),
          blurRadius: 48,
          offset: const Offset(0, 16),
        ),
      ];

  // Glass Effect Decoration
  static BoxDecoration glassDecoration(bool isDark) => BoxDecoration(
        color: isDark
            ? const Color(0xFF0D1117).withValues(alpha: 0.4)
            : Colors.black.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(borderRadiusLarge),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
        ),
      );

  // Typography
  static TextStyle h1(bool isDark) => GoogleFonts.outfit(
        fontSize: 42,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
        height: 1.05,
        color: isDark ? darkText : lightText,
      );

  static TextStyle h2(bool isDark) => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: isDark ? darkText : lightText,
      );

  static TextStyle h3(bool isDark) => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: isDark ? darkText : lightText,
      );

  static TextStyle bodyLarge(bool isDark) => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.6,
        color: isDark ? darkText : lightText,
      );

  static TextStyle body(bool isDark) => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.6,
        color: isDark
            ? (isDark ? darkText : lightText).withValues(alpha: 0.8)
            : lightText,
      );

  static TextStyle bodySmall(bool isDark) => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: isDark ? darkTextMuted : lightTextMuted,
      );

  static TextStyle caption(bool isDark) => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.0,
        color: (isDark ? darkText : lightText).withValues(alpha: 0.4),
      );

  static TextStyle score(bool isDark) => GoogleFonts.outfit(
        fontSize: 88,
        fontWeight: FontWeight.w900,
        letterSpacing: -4,
        color: isDark ? darkText : lightText,
      );

  // Legacy Mappings
  static Color get lightTextPrimary => lightText;
  static Color get darkTextPrimary => darkText;
  static Color get lightTextSecondary => lightTextMuted;
  static Color get darkTextSecondary => darkTextMuted;
  static Color get safe => safeColor;
  static Color get caution => cautionColor;
  static Color get avoid => avoidColor;

  static ThemeData get lightTheme => _createTheme(Brightness.light);
  static ThemeData get darkTheme => _createTheme(Brightness.dark);

  static ThemeData _createTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final backgroundColor = isDark ? darkBackground : lightBackground;
    final cardColor = isDark ? darkCard : lightCard;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      primaryColor: accentPrimary,
      dividerColor: isDark ? darkDivider : lightDivider,
      textTheme:
          (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.copyWith(
                displayLarge: h1(isDark),
                displayMedium: h2(isDark),
                displaySmall: h3(isDark),
                bodyLarge: bodyLarge(isDark),
                bodyMedium: body(isDark),
                bodySmall: bodySmall(isDark),
                labelSmall: caption(isDark),
              ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: h2(isDark),
        iconTheme: IconThemeData(color: isDark ? darkText : lightText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : Colors.black,
          foregroundColor: isDark ? Colors.black : Colors.white,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  static ThemeData get mainTheme => darkTheme;
}
