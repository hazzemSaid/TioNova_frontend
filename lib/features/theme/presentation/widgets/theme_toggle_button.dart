import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/theme/presentation/bloc/theme_bloc.dart';
import 'package:tionova/features/theme/presentation/bloc/theme_event.dart';
import 'package:tionova/features/theme/presentation/bloc/theme_state.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return IconButton(
          icon: Icon(
            state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: state.isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            context.read<ThemeBloc>().add(
              ThemeEvent(isDarkMode: !state.isDarkMode),
            );
          },
        );
      },
    );
  }
}
