import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    switch (status.toLowerCase()) {
      case 'passed':
        bgColor = const Color(0xFF28A745);
        break;
      case 'failed':
        bgColor = const Color(0xFFDC3545);
        break;
      case 'in progress':
        bgColor = const Color(0xFFFFC107);
        break;
      default:
        bgColor = const Color(0xFF6C757D);
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
          color: status.toLowerCase() == 'in progress'
              ? Colors.black
              : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
