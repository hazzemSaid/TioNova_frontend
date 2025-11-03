import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Monochrome Base
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Grayscale Levels
  static const Color gray900 = Color(0xFF0A0A0A);
  static const Color gray800 = Color(0xFF121212);
  static const Color gray700 = Color(0xFF1E1E1E);
  static const Color gray600 = Color(0xFF2C2C2C);
  static const Color gray500 = Color(0xFF555555);
  static const Color gray400 = Color(0xFF8A8A8A);
  static const Color gray300 = Color(0xFFBDBDBD);
  static const Color gray200 = Color(0xFFD6D6D6);
  static const Color gray100 = Color(0xFFF3F3F3);

  static const Color accentGreen = Color(0xFF4CAF50);
  // DARK THEME
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: gray900,
    primaryColor: white,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: white,
      onPrimary: black,
      secondary: gray300,
      onSecondary: black,
      surface: gray800,
      onSurface: white,
      background: gray900,
      onBackground: white,
      error: Color(0xFFFF3B30),
      onError: white,
      outline: gray700,
      outlineVariant: gray600,
      surfaceVariant: gray700,
      onSurfaceVariant: gray400,
      inverseSurface: gray100,
      inversePrimary: gray900,
      shadow: black,
      surfaceTint: Colors.transparent,
      scrim: black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: gray900,
      foregroundColor: white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: gray800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: gray700, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: gray300,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: gray800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gray700, width: 1),
      ),
      hintStyle: const TextStyle(color: gray400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: gray700,
      thickness: 1,
      space: 1,
    ),
    iconTheme: const IconThemeData(color: white, size: 24),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: gray800,
      selectedItemColor: white,
      unselectedItemColor: gray500,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: white, fontSize: 16),
      bodyMedium: TextStyle(color: gray300, fontSize: 14),
      bodySmall: TextStyle(color: gray500, fontSize: 12),
      titleMedium: TextStyle(
        color: white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // LIGHT THEME
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: white,
    primaryColor: black,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: black,
      onPrimary: white,
      secondary: gray700,
      onSecondary: white,
      surface: white,
      onSurface: black,
      background: white,
      onBackground: black,
      error: Color(0xFFD32F2F),
      onError: white,
      outline: gray200,
      outlineVariant: gray300,
      surfaceVariant: gray100,
      onSurfaceVariant: gray500,
      inverseSurface: gray900,
      inversePrimary: gray100,
      shadow: gray700,
      surfaceTint: Colors.transparent,
      scrim: gray900,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      foregroundColor: black,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        color: black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: gray200, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: black,
        foregroundColor: white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: gray700,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: gray100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gray200, width: 1),
      ),
      hintStyle: const TextStyle(color: gray500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: gray200,
      thickness: 1,
      space: 1,
    ),
    iconTheme: const IconThemeData(color: black, size: 24),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: black,
      unselectedItemColor: gray500,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: black, fontSize: 16),
      bodyMedium: TextStyle(color: gray700, fontSize: 14),
      bodySmall: TextStyle(color: gray500, fontSize: 12),
      titleMedium: TextStyle(
        color: black,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
