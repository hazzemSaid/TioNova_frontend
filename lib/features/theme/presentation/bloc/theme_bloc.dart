import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tionova/features/theme/presentation/bloc/theme_event.dart';
import 'package:tionova/features/theme/presentation/bloc/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences prefs;
  static const String _themeKey = 'isDarkMode';

  ThemeBloc({required this.prefs}) : super(ThemeState.initial()) {
    on<ThemeEvent>((event, emit) async {
      await _onThemeChanged(event, emit);
    });
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDarkMode = prefs.getBool(_themeKey) ?? false;
    add(ThemeEvent(isDarkMode: isDarkMode));
  }

  Future<void> _onThemeChanged(
    ThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await prefs.setBool(_themeKey, event.isDarkMode);
    emit(state.copyWith(isDarkMode: event.isDarkMode));
  }
}
