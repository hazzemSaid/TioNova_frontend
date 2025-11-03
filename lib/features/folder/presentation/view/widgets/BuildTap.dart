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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = widget.isActive;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primaryContainer.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : colorScheme.outlineVariant.withOpacity(0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? colorScheme.primary.withOpacity(0.25)
                  : theme.shadowColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isActive ? 1.1 : 1.0,
              child: Icon(
                widget.icon,
                color: isActive ? colorScheme.onPrimary : colorScheme.onSurface,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isActive ? colorScheme.onPrimary : colorScheme.onSurface,
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
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
