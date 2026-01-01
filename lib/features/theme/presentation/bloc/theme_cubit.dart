import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tionova/core/utils/safe_emit.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences? prefs;
  static const String _themeModeKey = 'theme_mode';

  ThemeCubit({this.prefs}) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    // If prefs is null (Safari private mode), use system theme
    if (prefs == null) {
      safeEmit(ThemeMode.system);
      return;
    }
    try {
      final themeModeString = prefs!.getString(_themeModeKey) ?? 'system';
      final themeMode = _getThemeModeFromString(themeModeString);
      safeEmit(themeMode);
    } catch (e) {
      // Fallback to system theme if reading fails
      print('⚠️ Error loading theme: $e');
      safeEmit(ThemeMode.system);
    }
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    // Emit immediately for instant UI update
    safeEmit(themeMode);
    // Save to preferences in background (don't await to avoid blocking UI)
    // Skip if prefs is null (Safari private mode)
    if (prefs == null) return;
    try {
      prefs!
          .setString(_themeModeKey, _getStringFromThemeMode(themeMode))
          .ignore();
    } catch (e) {
      print('⚠️ Error saving theme: $e');
    }
  }

  ThemeMode _getThemeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _getStringFromThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
