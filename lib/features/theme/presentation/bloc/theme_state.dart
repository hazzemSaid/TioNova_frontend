class ThemeState {
  final bool isDarkMode;

  const ThemeState({required this.isDarkMode});

  factory ThemeState.initial() {
    return const ThemeState(isDarkMode: false);
  }

  ThemeState copyWith({bool? isDarkMode}) {
    return ThemeState(isDarkMode: isDarkMode ?? this.isDarkMode);
  }
}
