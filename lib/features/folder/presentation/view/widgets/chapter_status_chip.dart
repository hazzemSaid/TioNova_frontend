import 'package:flutter/material.dart';

/// Status chip widget for showing chapter quiz status
class ChapterStatusChip extends StatelessWidget {
  final String status;

  const ChapterStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color chipColor;
    IconData chipIcon;

    switch (status.toLowerCase()) {
      case 'passed':
        chipColor = Colors.green;
        chipIcon = Icons.check_circle_outline;
        break;
      case 'failed':
        chipColor = colorScheme.error;
        chipIcon = Icons.cancel_outlined;
        break;
      case 'in progress':
        chipColor = Colors.orange;
        chipIcon = Icons.pending_outlined;
        break;
      default:
        chipColor = colorScheme.onSurfaceVariant;
        chipIcon = Icons.circle_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chipIcon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: chipColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
