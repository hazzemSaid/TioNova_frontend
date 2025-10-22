import 'package:flutter/material.dart';
import 'package:tionova/features/challenges/presentation/view/screens/challange_screen.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/GradientButton.dart';

class OptionCard extends StatelessWidget {
  final List<Color> gradientColors;
  final Color backgroundColor;
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
    required this.backgroundColor,
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
    final borderRadius = BorderRadius.circular(20);
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: outlined
            ? null
            : LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: outlined ? Colors.transparent : backgroundColor,
        border: outlined
            ? Border.all(width: 1.4, color: gradientColors.last)
            : null,
      ),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
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
                  child: Icon(icon, color: gradientColors.last, size: 24),
                ),
              const SizedBox(width: 16),
              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
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
