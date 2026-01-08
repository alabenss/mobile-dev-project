// lib/utils/timezone_helper.dart

class TimezoneHelper {
  /// Format date for API - always use local date components as date string
  /// This ensures consistent date handling across timezones
  static String formatDateForApi(DateTime localDate) {
    // Take the LOCAL date components and format as date string
    // This preserves the user's calendar date regardless of timezone
    return '${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}';
  }
  
  /// Format datetime for API - sends full ISO8601 UTC with Z suffix
  /// Use this for timestamps that include time (not just date)
  static String formatDateTimeForApi(DateTime localDateTime) {
    final utc = localDateTime.toUtc();
    return utc.toIso8601String();
  }
  
  /// Parse date from API response (date-only strings like "2026-01-08")
  /// Returns a local DateTime with time set to midnight
  static DateTime parseDateFromApi(String dateString) {
    // If it's just a date "2026-01-08", parse as local date
    if (dateString.length == 10) {
      final parts = dateString.split('-');
      return DateTime(
        int.parse(parts[0]), // year
        int.parse(parts[1]), // month
        int.parse(parts[2]), // day
      );
    }
    // If it's a full datetime, parse and convert to local
    return DateTime.parse(dateString).toLocal();
  }
  
  /// Parse timestamp from API (full ISO8601 with time)
  /// Returns a local DateTime with the correct time
  static DateTime parseTimestamp(String timestamp) {
    // DateTime.parse handles both "2026-01-08T16:47:18.214761Z" and without Z
    return DateTime.parse(timestamp).toLocal();
  }
  
  /// Get today's date as a string in YYYY-MM-DD format
  /// This is what you should use for API calls with "today"
  static String getTodayString() {
    final now = DateTime.now();
    return formatDateForApi(now);
  }
  
  /// Get today's date in local timezone (date only, no time)
  static DateTime getTodayLocal() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  
  /// Check if two dates are the same day (ignoring time)
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  /// Check if a date string is today
  static bool isToday(String dateString) {
    return dateString == getTodayString();
  }
  
  /// Format time only (HH:mm)
  static String formatTimeOnly(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  /// Get current timestamp for database records
  /// Use this for created_at, updated_at, lastCompletedDate, etc.
  static String getCurrentTimestamp() {
    return DateTime.now().toUtc().toIso8601String();
  }
  
  /// Format a DateTime for display in user's local time
  static String formatForDisplay(DateTime dateTime, {bool includeTime = true}) {
    if (includeTime) {
      return '${formatDateForApi(dateTime)} ${formatTimeOnly(dateTime)}';
    }
    return formatDateForApi(dateTime);
  }
}