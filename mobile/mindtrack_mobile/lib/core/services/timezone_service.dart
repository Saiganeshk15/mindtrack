import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TimezoneService {
  static void init() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(tz.local.name));
  }
}
