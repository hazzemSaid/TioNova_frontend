import 'package:flutter/material.dart';

class BuildTab extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const BuildTab({
    super.key,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<BuildTab> createState() => _BuildTabState();
}

class _BuildTabState extends State<BuildTab> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: widget.isActive ? const Color(0xFF2C2C2E) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: widget.isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: widget.isActive ? 1.1 : 1.0,
              child: Icon(
                widget.icon,
                color: widget.isActive
                    ? Colors.white
                    : Colors.white.withOpacity(0.6),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: widget.isActive
                    ? Colors.white
                    : Colors.white.withOpacity(0.6),
                fontSize: 15,
                fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
              child: Text(widget.label),
            ),
          ],
        ),
      ),
    );
  }
}
