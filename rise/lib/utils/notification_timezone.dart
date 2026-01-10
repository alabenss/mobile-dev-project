import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationTimezone {
  static Future<void> init() async {
    tz.initializeTimeZones();

    // Returns a TimezoneInfo object
    final tzInfo = await FlutterTimezone.getLocalTimezone();

    // Use identifier property for timezone
    final String timezoneName = tzInfo.identifier;

    tz.setLocalLocation(tz.getLocation(timezoneName));
  }
}
