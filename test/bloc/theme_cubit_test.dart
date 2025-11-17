import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tionova/features/theme/presentation/bloc/theme_cubit.dart';

void main() {
  group('ThemeCubit', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state reads from prefs (default system)', () async {
      final prefs = await SharedPreferences.getInstance();
      final cubit = ThemeCubit(prefs: prefs);
      expect(cubit.state, ThemeMode.system);
    });

    test('setTheme persists and emits new mode', () async {
      final prefs = await SharedPreferences.getInstance();
      final cubit = ThemeCubit(prefs: prefs);

      await cubit.setTheme(ThemeMode.dark);
      expect(cubit.state, ThemeMode.dark);
      expect(prefs.getString('theme_mode'), 'dark');

      await cubit.setTheme(ThemeMode.light);
      expect(cubit.state, ThemeMode.light);
      expect(prefs.getString('theme_mode'), 'light');
    });
  });
}
