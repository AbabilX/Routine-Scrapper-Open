import 'model/routine_day.dart';
import 'routine_queries.dart';

class ReminderRules {
  static const presets = [5, 10, 15, 20, 30];
  static const defaultMinutes = 20;

  static bool isPreset(int minutes) => presets.contains(minutes);

  static int fireMinutes(String start, int minutesBefore) {
    final value = RoutineQueries.minutes(start) - minutesBefore;
    return value < 0 ? 0 : value;
  }

  static ({int hour, int minute}) fireClock(String start, int minutesBefore) {
    final total = fireMinutes(start, minutesBefore);
    return (hour: total ~/ 60, minute: total % 60);
  }

  /// Same 12-hour `HH:MM` shape as routine slots (`09:40`, `12:40`).
  static String formatFireTime(String start, int minutesBefore) {
    final clock = fireClock(start, minutesBefore);
    final hour = clock.hour == 0
        ? 12
        : clock.hour > 12
        ? clock.hour - 12
        : clock.hour;
    final hh = hour.toString().padLeft(2, '0');
    final mm = clock.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static int dateTimeWeekday(RoutineDay day) {
    return switch (day) {
      RoutineDay.saturday => DateTime.saturday,
      RoutineDay.sunday => DateTime.sunday,
      RoutineDay.monday => DateTime.monday,
      RoutineDay.tuesday => DateTime.tuesday,
      RoutineDay.wednesday => DateTime.wednesday,
      RoutineDay.thursday => DateTime.thursday,
    };
  }

  static int notificationId(String reminderId) =>
      reminderId.hashCode & 0x7fffffff;
}
