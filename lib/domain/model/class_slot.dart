import 'routine_day.dart';

class ClassSlot {
  const ClassSlot({
    required this.day,
    required this.slot,
    required this.start,
    required this.end,
    required this.course,
    this.courseTitle = '',
    required this.group,
    required this.teacher,
    required this.room,
  });

  final RoutineDay day;
  final int slot;
  final String start;
  final String end;
  final String course;
  final String courseTitle;
  final String group;
  final String teacher;
  final String room;
}
