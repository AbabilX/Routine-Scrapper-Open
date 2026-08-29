import 'student_summary.dart';
import 'routine_day.dart';

class ClassReminderId {
  static String fromBlock(ClassBlock block) {
    return '${block.day.wireName}|${block.start}|${block.end}|${block.course}|${block.group}|${block.room}';
  }
}

class ClassReminder {
  const ClassReminder({
    required this.id,
    required this.minutesBefore,
    required this.day,
    required this.start,
    required this.end,
    required this.course,
    required this.group,
    required this.room,
  });

  final String id;
  final int minutesBefore;
  final String day;
  final String start;
  final String end;
  final String course;
  final String group;
  final String room;

  factory ClassReminder.fromBlock(ClassBlock block, int minutesBefore) {
    return ClassReminder(
      id: ClassReminderId.fromBlock(block),
      minutesBefore: minutesBefore,
      day: block.day.wireName,
      start: block.start,
      end: block.end,
      course: block.course,
      group: block.group,
      room: block.room,
    );
  }

  RoutineDay get routineDay => RoutineDay.fromName(day);

  ClassReminder copyWith({int? minutesBefore}) {
    return ClassReminder(
      id: id,
      minutesBefore: minutesBefore ?? this.minutesBefore,
      day: day,
      start: start,
      end: end,
      course: course,
      group: group,
      room: room,
    );
  }
}
