import 'package:flutter/material.dart';

/// A reusable background widget for all authentication screens
/// Features a decorative background image with overlay
class AuthBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const AuthBackground({super.key, required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/auth_background.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            isDark
                ? Colors.black.withOpacity(0.7)
                : Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    Colors.black.withOpacity(0.06),
                    Colors.black.withOpacity(0.04),
                    Colors.black.withOpacity(0.07),
                  ]
                : [
                    Colors.white.withOpacity(0.06),
                    Colors.white.withOpacity(0.04),
                    Colors.white.withOpacity(0.07),
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}
