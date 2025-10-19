import 'package:flutter/material.dart';

class SecondaryBtn extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback onPressed;
  final bool isDark;
  const SecondaryBtn({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon ?? const Icon(Icons.person_add_rounded, size: 20),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? Colors.white24 : Colors.black26,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: isDark ? Colors.white : Colors.black,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }
}
