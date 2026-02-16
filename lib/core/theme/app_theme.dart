import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // New Color Palette
  static const Color spaceDark = Color(0xFF222831);
  static const Color slateGray = Color(0xFF393E46);
  static const Color cyanBrand = Color(0xFF00ADB5);
  static const Color cloudWhite = Color(0xFFEEEEEE);

  // Aliases for retro-compatibility
  static const Color accentGreen = cyanBrand;
  static const Color softBlack = spaceDark;
  static const Color softWhite = cloudWhite;

  // Grayscale Palette (Legacy/Support)
  static const Color gray900 = Color(0xFF222831);
  static const Color gray850 = Color(0xFF2A2E35);
  static const Color gray800 = Color(0xFF393E46);
  static const Color gray700 = Color(0xFF4B535B);
  static const Color gray600 = Color(0xFF5C656F);
  static const Color gray500 = Color(0xFF717D8A);
  static const Color gray400 = Color(0xFF9EABB8);
  static const Color gray300 = Color(0xFFBDC8D3);
  static const Color gray200 = Color(0xFFDDE6ED);
  static const Color gray100 = Color(0xFFEEEEEE);

  // ===== DARK THEME =====
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: spaceDark,
    primaryColor: cyanBrand,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: cyanBrand,
      onPrimary: spaceDark,
      primaryContainer: slateGray,
      onPrimaryContainer: cloudWhite,
      secondary: gray400,
      onSecondary: spaceDark,
      surface: gray850,
      onSurface: cloudWhite,
      background: spaceDark,
      onBackground: cloudWhite,
      error: Color(0xFFEF5350),
      onError: spaceDark,
      outline: gray600,
      outlineVariant: gray700,
      surfaceVariant: gray800,
      onSurfaceVariant: gray300,
      inverseSurface: cloudWhite,
      inversePrimary: spaceDark,
      shadow: Color(0xFF000000),
      surfaceTint: Colors.transparent,
      scrim: Color(0xFF000000),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: spaceDark,
      foregroundColor: cloudWhite,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        color: cloudWhite,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: gray850,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: slateGray, width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cyanBrand,
        foregroundColor: spaceDark,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: cyanBrand,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: gray850,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: slateGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: cyanBrand, width: 1.5),
      ),
      hintStyle: const TextStyle(color: gray500, fontFamily: 'Inter'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: slateGray,
      thickness: 1.2,
      space: 1,
    ),
    iconTheme: const IconThemeData(color: cloudWhite, size: 26),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: spaceDark,
      selectedItemColor: cyanBrand,
      unselectedItemColor: gray500,
      selectedIconTheme: IconThemeData(size: 28),
      unselectedIconTheme: IconThemeData(size: 24),
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      elevation: 8,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: slateGray,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentTextStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: cloudWhite,
      ),
      actionTextColor: cyanBrand,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: cloudWhite,
        fontSize: 16,
        fontFamily: 'Inter',
      ),
      bodyMedium: TextStyle(color: gray300, fontSize: 14, fontFamily: 'Inter'),
      bodySmall: TextStyle(color: gray500, fontSize: 12, fontFamily: 'Inter'),
      titleMedium: TextStyle(
        color: cloudWhite,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    ),
  );

  // ===== LIGHT THEME =====
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.light,
    scaffoldBackgroundColor: cloudWhite,
    primaryColor: spaceDark,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: cyanBrand,
      onPrimary: cloudWhite,
      primaryContainer: gray200,
      onPrimaryContainer: spaceDark,
      secondary: slateGray,
      onSecondary: cloudWhite,
      surface: Color(0xFFF5F5F5), // Softer surface color
      onSurface: spaceDark,
      background: cloudWhite,
      onBackground: spaceDark,
      error: Color(0xFFE53935),
      onError: cloudWhite,
      outline: gray300,
      outlineVariant: gray400,
      surfaceVariant: gray100,
      onSurfaceVariant: gray600,
      inverseSurface: spaceDark,
      inversePrimary: gray100,
      shadow: gray700,
      surfaceTint: Colors.transparent,
      scrim: spaceDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: cloudWhite,
      foregroundColor: spaceDark,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        color: spaceDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFF8F8F8), // Softer card color
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: gray200, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cyanBrand,
        foregroundColor: cloudWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: cyanBrand,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5), // Softer input background
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gray300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: cyanBrand, width: 1.5),
      ),
      hintStyle: const TextStyle(color: gray500, fontFamily: 'Inter'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(color: gray200, thickness: 1),
    iconTheme: const IconThemeData(color: spaceDark, size: 24),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cloudWhite,
      selectedItemColor: cyanBrand,
      unselectedItemColor: gray500,
      type: BottomNavigationBarType.fixed,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: spaceDark,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentTextStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: cloudWhite,
      ),
      actionTextColor: cyanBrand,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: spaceDark, fontSize: 16, fontFamily: 'Inter'),
      bodyMedium: TextStyle(
        color: slateGray,
        fontSize: 14,
        fontFamily: 'Inter',
      ),
      bodySmall: TextStyle(color: gray500, fontSize: 12, fontFamily: 'Inter'),
      titleMedium: TextStyle(
        color: spaceDark,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    ),
  );
}
