import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Core Colors - محسّنة لتكون أكثر راحة
  static const Color softBlack = Color(0xFF1A1A1A); // بدلاً من الأسود النقي
  static const Color softWhite = Color(0xFFF8F8F8); // بدلاً من الأبيض النقي

  // Grayscale Palette - مسافات أقل بين الدرجات
  static const Color gray900 = Color(0xFF1A1A1A);
  static const Color gray850 = Color(0xFF222222);
  static const Color gray800 = Color(0xFF2A2A2A);
  static const Color gray700 = Color(0xFF383838);
  static const Color gray600 = Color(0xFF4F4F4F);
  static const Color gray500 = Color(0xFF757575);
  static const Color gray400 = Color(0xFF9E9E9E);
  static const Color gray300 = Color(0xFFBDBDBD);
  static const Color gray200 = Color(0xFFD4D4D4);
  static const Color gray100 = Color(0xFFEEEEEE);

  // Accent Color - أقل حدة
  static const Color accentGreen = Color(0xFF66BB6A);

  // ===== DARK THEME =====
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: gray900,
    primaryColor: softWhite,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: softWhite,
      onPrimary: softBlack,
      primaryContainer: gray700,
      onPrimaryContainer: gray100,
      secondary: gray400,
      onSecondary: gray900,
      surface: gray850,
      onSurface: gray100,
      background: gray900,
      onBackground: gray100,
      error: Color(0xFFEF5350),
      onError: gray900,
      outline: gray600,
      outlineVariant: gray700,
      surfaceVariant: gray800,
      onSurfaceVariant: gray400,
      inverseSurface: gray100,
      inversePrimary: gray900,
      shadow: Color(0xFF000000),
      surfaceTint: Colors.transparent,
      scrim: Color(0xFF000000),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: gray900,
      foregroundColor: softWhite,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        color: softWhite,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: gray800,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: gray700, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gray100,
        foregroundColor: gray900,
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
        foregroundColor: gray300,
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
      fillColor: gray800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gray600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gray300, width: 1.5),
      ),
      hintStyle: const TextStyle(color: gray500, fontFamily: 'Inter'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(color: gray700, thickness: 1),
    iconTheme: const IconThemeData(color: gray100, size: 24),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: gray850,
      selectedItemColor: gray100,
      unselectedItemColor: gray500,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: gray100, fontSize: 16, fontFamily: 'Inter'),
      bodyMedium: TextStyle(color: gray300, fontSize: 14, fontFamily: 'Inter'),
      bodySmall: TextStyle(color: gray500, fontSize: 12, fontFamily: 'Inter'),
      titleMedium: TextStyle(
        color: gray100,
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
    scaffoldBackgroundColor: softWhite,
    primaryColor: softBlack,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: softBlack,
      onPrimary: softWhite,
      primaryContainer: gray200,
      onPrimaryContainer: gray900,
      secondary: gray700,
      onSecondary: softWhite,
      surface: softWhite,
      onSurface: gray900,
      background: softWhite,
      onBackground: gray900,
      error: Color(0xFFE53935),
      onError: softWhite,
      outline: gray300,
      outlineVariant: gray400,
      surfaceVariant: gray100,
      onSurfaceVariant: gray600,
      inverseSurface: gray900,
      inversePrimary: gray100,
      shadow: gray700,
      surfaceTint: Colors.transparent,
      scrim: gray900,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: softWhite,
      foregroundColor: softBlack,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        color: softBlack,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: softWhite,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: gray200, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gray900,
        foregroundColor: gray100,
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
        foregroundColor: gray700,
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
      fillColor: gray100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gray300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gray700, width: 1.5),
      ),
      hintStyle: const TextStyle(color: gray500, fontFamily: 'Inter'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(color: gray200, thickness: 1),
    iconTheme: const IconThemeData(color: gray900, size: 24),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: softWhite,
      selectedItemColor: gray900,
      unselectedItemColor: gray500,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: gray900, fontSize: 16, fontFamily: 'Inter'),
      bodyMedium: TextStyle(color: gray700, fontSize: 14, fontFamily: 'Inter'),
      bodySmall: TextStyle(color: gray500, fontSize: 12, fontFamily: 'Inter'),
      titleMedium: TextStyle(
        color: gray900,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    ),
  );
}
