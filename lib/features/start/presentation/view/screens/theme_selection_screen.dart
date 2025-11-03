import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/theme/presentation/bloc/theme_cubit.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  ThemeMode _selectedTheme = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    // Get the current theme from the cubit
    final currentTheme = context.read<ThemeCubit>().state;
    setState(() {
      _selectedTheme = currentTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, currentThemeMode) {
        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),

                  // Logo
                  Center(
                    child: Text(
                      'Tionova',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Title
                  const Text(
                    'Choose Your Theme',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  const Text(
                    'Select your preferred appearance',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.white70),
                  ),

                  const SizedBox(height: 48),

                  // Light Theme Option
                  _ThemeOption(
                    icon: Icons.light_mode_rounded,
                    label: 'Light',
                    isSelected: _selectedTheme == ThemeMode.light,
                    onTap: () {
                      setState(() {
                        _selectedTheme = ThemeMode.light;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Dark Theme Option
                  _ThemeOption(
                    icon: Icons.dark_mode_rounded,
                    label: 'Dark',
                    isSelected: _selectedTheme == ThemeMode.dark,
                    onTap: () {
                      setState(() {
                        _selectedTheme = ThemeMode.dark;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // System Theme Option
                  _ThemeOption(
                    icon: Icons.settings_suggest_rounded,
                    label: 'System',
                    isSelected: _selectedTheme == ThemeMode.system,
                    onTap: () {
                      setState(() {
                        _selectedTheme = ThemeMode.system;
                      });
                    },
                  ),

                  const Spacer(),

                  // Continue Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<ThemeCubit>().setTheme(_selectedTheme);
                        context.go('/onboarding');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Back Button
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text(
                      'Back',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
