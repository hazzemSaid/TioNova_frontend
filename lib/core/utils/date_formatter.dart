// Utility: Format DateTime to 'time ago' string
String formatTimeAgo(dynamic date) {
  if (date == null) return 'Recently';
  DateTime? dateTime;
  if (date is DateTime) {
    dateTime = date;
  } else if (date is String) {
    try {
      dateTime = DateTime.tryParse(date);
    } catch (_) {
      return 'Recently';
    }
  }
  if (dateTime == null) return 'Recently';
  final now = DateTime.now();
  final diff = now.difference(dateTime);
  if (diff.inSeconds < 60) {
    return '${diff.inSeconds}s ago';
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  } else if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  } else if (diff.inDays < 7) {
    return '${diff.inDays}d ago';
  } else if (diff.inDays < 30) {
    return '${(diff.inDays / 7).floor()}w ago';
  } else if (diff.inDays < 365) {
    return '${(diff.inDays / 30).floor()}mo ago';
  } else {
    return '${(diff.inDays / 365).floor()}y ago';
  }
}
