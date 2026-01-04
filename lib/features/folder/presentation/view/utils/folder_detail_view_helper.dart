import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FolderDetailViewHelper {
  static String formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  static Color getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'passed':
        return Colors.green;
      case 'failed':
        return colorScheme.error;
      case 'in progress':
        return Colors.orange;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'passed':
        return Icons.check_circle_outline;
      case 'failed':
        return Icons.cancel_outlined;
      case 'in progress':
        return Icons.pending_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
}
