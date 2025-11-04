import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'passed':
        bgColor = colorScheme.tertiary;
        textColor = colorScheme.onTertiary;
        break;
      case 'failed':
        bgColor = colorScheme.error;
        textColor = colorScheme.onError;
        break;
      case 'in progress':
        bgColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        break;
      default:
        bgColor = colorScheme.surfaceVariant;
        textColor = colorScheme.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
