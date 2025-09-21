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
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.045,
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
                size: screenWidth * 0.04,
              ),
              SizedBox(width: screenWidth * 0.015),
            ],
            Text(
              actionText,
              style: TextStyle(
                color: const Color(0xFF8E8E93),
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (actionIcon == Icons.arrow_forward_ios) ...[
              SizedBox(width: screenWidth * 0.01),
              Icon(
                actionIcon,
                color: const Color(0xFF8E8E93),
                size: screenWidth * 0.03,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
