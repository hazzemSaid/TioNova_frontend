import 'package:flutter/material.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/GradientButton.dart';

class OptionCard extends StatelessWidget {
  final List<Color> gradientColors;
  final IconData? icon;
  final List<Color>? iconGradient;
  final Widget? leading;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;
  final bool outlined;

  const OptionCard({
    super.key,
    required this.gradientColors,
    this.icon,
    this.iconGradient,
    this.leading,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
    this.outlined = false,
  }) : assert(
         icon != null || leading != null,
         'Either icon or leading must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOutlined = outlined;
    final borderRadius = BorderRadius.circular(20);
    final overlayOpacity = theme.brightness == Brightness.dark ? 0.25 : 0.12;
    final gradientOverlay = isOutlined
        ? null
        : LinearGradient(
            colors: gradientColors
                .map((color) => color.withOpacity(overlayOpacity))
                .toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: colorScheme.surface,
        border: Border.all(
          width: isOutlined ? 1.4 : 1,
          color: isOutlined
              ? gradientColors.last
              : colorScheme.outlineVariant.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: gradientOverlay,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              // Leading Icon or custom widget
              if (leading != null)
                leading!
              else
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: iconGradient ?? gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(icon, color: colorScheme.onSurface, size: 24),
                ),
              const SizedBox(width: 16),
              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Action button
              GradientButton(
                label: actionLabel,
                gradientColors: gradientColors,
                outlined: outlined,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
