/// Utility class for date and time operations.
///
/// Provides methods for formatting timestamps, calculating relative time,
/// and handling date/time conversions for the caching system.
class DateTimeUtils {
  DateTimeUtils._();

  /// Formats a DateTime to ISO 8601 string for storage.
  ///
  /// Example: "2024-01-15T10:30:00Z"
  static String toIso8601(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  /// Parses an ISO 8601 string to DateTime.
  ///
  /// Returns null if parsing fails.
  static DateTime? fromIso8601(String? iso8601String) {
    if (iso8601String == null || iso8601String.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(iso8601String).toUtc();
    } catch (e) {
      return null;
    }
  }

  /// Formats a DateTime to human-readable string without external packages.
  ///
  /// Example: "Jan 15, 2024 10:30 AM"
  static String toHumanReadable(DateTime dateTime) {
    final local = dateTime.toLocal();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[local.month - 1];
    final day = local.day;
    final year = local.year;
    final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $year $hour:$minute $period';
  }

  /// Returns a human-readable relative time string.
  ///
  /// Examples:
  /// - "Just now"
  /// - "5 minutes ago"
  /// - "2 hours ago"
  /// - "Yesterday"
  /// - "Jan 15, 2024 10:30 AM"
  static String toRelativeTime(DateTime dateTime) {
    final now = DateTime.now().toUtc();
    final target = dateTime.toUtc();
    final difference = now.difference(target);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'} ago';
    }

    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }

    if (difference.inDays < 2) {
      return 'Yesterday';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    // Fall back to full date for older dates
    return toHumanReadable(dateTime);
  }

  /// Checks if a cache entry is stale based on expiration time.
  ///
  /// Returns true if the current time is after the expiration time.
  static bool isStale(DateTime expiresAt) {
    return DateTime.now().toUtc().isAfter(expiresAt.toUtc());
  }

  /// Calculates the expiration time from a given cached time and validity duration.
  ///
  /// [cachedAt] - The time the data was cached.
  /// [validityHours] - Number of hours the cache should be valid.
  static DateTime calculateExpiration(DateTime cachedAt, int validityHours) {
    return cachedAt.toUtc().add(Duration(hours: validityHours));
  }

  /// Returns a timestamp suitable for display in the UI.
  ///
  /// Shows "Last updated: X" with relative time.
  static String lastUpdatedText(DateTime cachedAt) {
    return 'Last updated: ${toRelativeTime(cachedAt)}';
  }
}

/// Extension on DateTime for convenient access to utility methods.
extension DateTimeExtensions on DateTime {
  /// Returns true if this DateTime is stale (past expiration).
  bool isStale() => DateTimeUtils.isStale(this);

  /// Returns the expiration time for this cached time.
  DateTime expiresAfter(int validityHours) =>
      DateTimeUtils.calculateExpiration(this, validityHours);

  /// Returns a human-readable relative time string.
  String toRelativeTime() => DateTimeUtils.toRelativeTime(this);

  /// Returns a human-readable formatted string.
  String toHumanReadable() => DateTimeUtils.toHumanReadable(this);
}

/// Extension on String for parsing ISO 8601 dates.
extension StringDateExtensions on String {
  /// Attempts to parse this string as an ISO 8601 DateTime.
  DateTime? toDateTime() => DateTimeUtils.fromIso8601(this);
}