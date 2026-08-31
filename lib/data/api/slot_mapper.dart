import '../../domain/model/class_slot.dart';
import '../../domain/model/routine_day.dart';
import 'schedule_item_dto.dart';

class SlotMapper {
  const SlotMapper._();

  static const slotStarts = [
    '08:30',
    '10:00',
    '11:30',
    '01:00',
    '02:30',
    '04:00',
  ];

  static final _courseCode = RegExp(r'^([A-Za-z]{2,5}\d{3})\((.+)\)$');

  static List<ClassSlot> mapItems(
    List<ScheduleItemDto> items, {
    String fallbackGroup = '',
  }) {
    return items
        .map((item) => mapItem(item, fallbackGroup: fallbackGroup))
        .whereType<ClassSlot>()
        .toList();
  }

  static ClassSlot? mapItem(
    ScheduleItemDto item, {
    String fallbackGroup = '',
  }) {
    final times = _splitTime(item.timeSlot);
    if (times == null) return null;
    final day = _dayFromApi(item.day);
    if (day == null) return null;
    final parsed = _courseCode.firstMatch(item.courseCode);
    final course = parsed?.group(1) ?? item.courseCode;
    final group = parsed?.group(2) ?? fallbackGroup;
    if (course.isEmpty) return null;
    return ClassSlot(
      day: day,
      slot: slotIndexFor(times.start),
      start: times.start,
      end: times.end,
      course: course,
      group: group,
      teacher: item.teacher.isEmpty ? 'TBA' : item.teacher,
      room: item.room.isEmpty ? 'TBA' : item.room.replaceAll('\n', ' ').trim(),
    );
  }

  static int slotIndexFor(String start) {
    final index = slotStarts.indexOf(start);
    return index < 0 ? 0 : index;
  }

  static ({String start, String end})? _splitTime(String raw) {
    final cleaned = raw.replaceAll(' ', '');
    final dash = cleaned.indexOf('-');
    if (dash <= 0 || dash == cleaned.length - 1) return null;
    return (
      start: cleaned.substring(0, dash),
      end: cleaned.substring(dash + 1),
    );
  }

  static RoutineDay? _dayFromApi(String raw) {
    final target = raw.trim().toLowerCase();
    if (target.isEmpty) return null;
    for (final day in RoutineDay.values) {
      if (day.fullLabel.toLowerCase() == target) return day;
      if (day.wireName.toLowerCase() == target) return day;
      if (day.shortLabel.toLowerCase() == target) return day;
    }
    return null;
  }
}
