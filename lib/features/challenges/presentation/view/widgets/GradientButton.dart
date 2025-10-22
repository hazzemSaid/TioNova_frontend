import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final bool outlined;

  const GradientButton({
    super.key,
    required this.label,
    required this.gradientColors,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(40);
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: outlined
              ? null
              : LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          border: outlined
              ? Border.all(width: 1, color: gradientColors.last)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: outlined ? gradientColors.last : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
