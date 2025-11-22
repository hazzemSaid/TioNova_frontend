import 'package:intl/intl.dart';

/// Utility class for formatting dates across the application
class DateFormatters {
  /// Format a date string to a human-readable format (e.g., "Jan 15, 2024")
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Format a date string to a short format (e.g., "15 Jan")
  static String formatDateShort(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Format a date string to relative time (e.g., "2 days ago")
  static String formatRelativeDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return years == 1 ? '1 year ago' : '$years years ago';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return months == 1 ? '1 month ago' : '$months months ago';
      } else if (difference.inDays > 0) {
        return difference.inDays == 1
            ? '1 day ago'
            : '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return difference.inHours == 1
            ? '1 hour ago'
            : '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return difference.inMinutes == 1
            ? '1 minute ago'
            : '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Format a date string to a full format (e.g., "Monday, January 15, 2024")
  static String formatDateFull(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, MMMM dd, yyyy').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Format a date string to time only (e.g., "3:45 PM")
  static String formatTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('h:mm a').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Format a date string to date and time (e.g., "Jan 15, 2024 at 3:45 PM")
  static String formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy \'at\' h:mm a').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }
}
