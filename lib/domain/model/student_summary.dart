import 'routine_day.dart';

class StudentSummary {
  const StudentSummary({
    required this.batch,
    required this.section,
    required this.totalCourses,
    required this.classesPerWeek,
    required this.routineVersion,
  });

  final String batch;
  final String section;
  final int totalCourses;
  final int classesPerWeek;
  final String routineVersion;
}

class ClassBlock {
  const ClassBlock({
    required this.day,
    required this.startSlot,
    required this.endSlot,
    required this.start,
    required this.end,
    required this.course,
    required this.group,
    required this.teacher,
    required this.room,
  });

  final RoutineDay day;
  final int startSlot;
  final int endSlot;
  final String start;
  final String end;
  final String course;
  final String group;
  final String teacher;
  final String room;

  ClassBlock copyWith({int? endSlot, String? end}) {
    return ClassBlock(
      day: day,
      startSlot: startSlot,
      endSlot: endSlot ?? this.endSlot,
      start: start,
      end: end ?? this.end,
      course: course,
      group: group,
      teacher: teacher,
      room: room,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ClassBlock &&
        other.day == day &&
        other.startSlot == startSlot &&
        other.endSlot == endSlot &&
        other.start == start &&
        other.end == end &&
        other.course == course &&
        other.group == group &&
        other.teacher == teacher &&
        other.room == room;
  }

  @override
  int get hashCode => Object.hash(
    day,
    startSlot,
    endSlot,
    start,
    end,
    course,
    group,
    teacher,
    room,
  );
}

sealed class TimelineItem {
  const TimelineItem();
}

class TimelineClass extends TimelineItem {
  const TimelineClass(this.block);

  final ClassBlock block;
}

class TimelineBreak extends TimelineItem {
  const TimelineBreak(this.start, this.end, this.minutes);

  final String start;
  final String end;
  final int minutes;
}
