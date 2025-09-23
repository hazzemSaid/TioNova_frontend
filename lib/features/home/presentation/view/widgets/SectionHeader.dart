import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final IconData actionIcon;

  const SectionHeader({
    super.key,
    required this.title,
    required this.actionText,
    required this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.width > 600;
    final double titleSize = isTablet ? 20.0 : screenSize.width * 0.045;
    final double actionTextSize = isTablet ? 16.0 : screenSize.width * 0.035;
    final double iconSize = isTablet ? 20.0 : screenSize.width * 0.04;
    final double spacing = isTablet ? 12.0 : screenSize.width * 0.015;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Row(
          children: [
            if (actionIcon == Icons.access_time) ...[
              Icon(
                actionIcon,
                color: const Color(0xFF8E8E93),
                size: iconSize,
              ),
              SizedBox(width: spacing / 2),
            ],
            Text(
              actionText,
              style: TextStyle(
                color: const Color(0xFF8E8E93),
                fontSize: actionTextSize,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (actionIcon == Icons.arrow_forward_ios) ...[
              SizedBox(width: spacing / 2),
              Icon(
                actionIcon,
                color: const Color(0xFF8E8E93),
                size: isTablet ? 16.0 : screenSize.width * 0.03,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
