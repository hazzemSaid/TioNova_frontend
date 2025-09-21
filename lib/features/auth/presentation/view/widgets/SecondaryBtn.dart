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
        icon: icon ?? const Icon(Icons.person_add_rounded),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          foregroundColor: isDark ? Colors.white : Colors.black,
          backgroundColor: isDark ? Colors.black12 : Colors.white10,
        ),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
