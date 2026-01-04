import 'package:flutter/material.dart';

class ChallengeWebOptionCard extends StatelessWidget {
  final List<Color> gradientColors;
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;
  final bool outlined;

  const ChallengeWebOptionCard({
    super.key,
    required this.gradientColors,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: outlined
            ? null
            : LinearGradient(
                colors: gradientColors.map((c) => c.withOpacity(0.05)).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: outlined ? colorScheme.surface : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: outlined
              ? colorScheme.outlineVariant.withOpacity(0.5)
              : gradientColors.first.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    gradientColors.first.withOpacity(0.2),
                    gradientColors.last.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: gradientColors.first, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: outlined
                      ? colorScheme.surface
                      : gradientColors.first,
                  foregroundColor: outlined
                      ? gradientColors.first
                      : Colors.white,
                  elevation: 0,
                  side: outlined
                      ? BorderSide(color: gradientColors.first, width: 2)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
