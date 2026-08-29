import 'model/class_slot.dart';
import 'model/class_status.dart';
import 'model/routine_day.dart';
import 'model/student_summary.dart';
import 'student_query.dart';

class RoutineQueries {
  static List<ClassSlot> forStudent(List<ClassSlot> slots, StudentQuery query) {
    final matched = slots.where((slot) => query.matches(slot.group)).toList();
    matched.sort((a, b) {
      final day = a.day.index.compareTo(b.day.index);
      if (day != 0) return day;
      final slot = a.slot.compareTo(b.slot);
      if (slot != 0) return slot;
      return a.start.compareTo(b.start);
    });
    return matched;
  }

  /// Days that actually have classes, Sat–Thu, labs already merged.
  static Map<RoutineDay, List<ClassBlock>> weeklyBlocks(List<ClassSlot> slots) {
    final week = <RoutineDay, List<ClassBlock>>{};
    for (final day in RoutineDay.values) {
      final blocks = merge(slots.where((slot) => slot.day == day).toList());
      if (blocks.isNotEmpty) week[day] = blocks;
    }
    return week;
  }

  static StudentSummary summary(
    List<ClassSlot> slots,
    StudentQuery query,
    String version,
  ) {
    final courses = slots.map((s) => s.course).toSet();
    return StudentSummary(
      batch: query.batch,
      section: query.section.isEmpty ? 'All' : query.section,
      totalCourses: courses.length,
      classesPerWeek: slots.length,
      routineVersion: version,
    );
  }

  static List<TimelineItem> timeline(List<ClassSlot> daySlots) {
    final blocks = merge(daySlots);
    if (blocks.isEmpty) return const [];
    final items = <TimelineItem>[];
    for (var index = 0; index < blocks.length; index++) {
      final block = blocks[index];
      if (index > 0) {
        final prev = blocks[index - 1];
        final gap = minutes(block.start) - minutes(prev.end);
        if (gap >= 30) {
          items.add(TimelineBreak(prev.end, block.start, gap));
        }
      }
      items.add(TimelineClass(block));
    }
    return items;
  }

  static List<ClassBlock> blocksForDay(List<ClassSlot> daySlots) =>
      merge(daySlots);

  static int nowMinutes([DateTime? now]) {
    final time = now ?? DateTime.now();
    return time.hour * 60 + time.minute;
  }

  static ClassStatus statusOf(
    ClassBlock block,
    RoutineDay selectedDay, {
    RoutineDay? today,
    int? nowMin,
    String? nextStart,
  }) {
    final todayDay = today ?? todayOrSaturday();
    final now = nowMin ?? nowMinutes();
    if (selectedDay != todayDay) return ClassStatus.later;
    final start = minutes(block.start);
    final end = minutes(block.end);
    if (now >= start && now < end) return ClassStatus.now;
    if (now >= end) return ClassStatus.done;
    if (nextStart != null && block.start == nextStart) return ClassStatus.next;
    return ClassStatus.later;
  }

  static Map<ClassBlock, ClassStatus> statusesForDay(
    List<ClassSlot> daySlots,
    RoutineDay selectedDay, {
    RoutineDay? today,
    int? nowMin,
  }) {
    final todayDay = today ?? todayOrSaturday();
    final now = nowMin ?? nowMinutes();
    final blocks = merge(daySlots);
    if (selectedDay != todayDay) {
      return {for (final block in blocks) block: ClassStatus.later};
    }
    String? nextStart;
    for (final block in blocks) {
      if (minutes(block.start) > now) {
        nextStart = block.start;
        break;
      }
    }
    return {
      for (final block in blocks)
        block: statusOf(
          block,
          selectedDay,
          today: todayDay,
          nowMin: now,
          nextStart: nextStart,
        ),
    };
  }

  static NowNextHint? nowOrNext(
    List<ClassSlot> daySlots,
    RoutineDay selectedDay, {
    RoutineDay? today,
    int? nowMin,
  }) {
    final todayDay = today ?? todayOrSaturday();
    final now = nowMin ?? nowMinutes();
    if (selectedDay != todayDay) return null;
    final blocks = merge(daySlots);
    if (blocks.isEmpty) return null;
    for (final block in blocks) {
      if (now >= minutes(block.start) && now < minutes(block.end)) {
        return NowNextHint(ClassStatus.now, block);
      }
    }
    for (final block in blocks) {
      if (minutes(block.start) > now) {
        return NowNextHint(ClassStatus.next, block);
      }
    }
    return null;
  }

  static List<String> suggestChips(
    List<ClassSlot> slots,
    String queryText, {
    int limit = 8,
  }) {
    final cleaned = queryText.trim().toUpperCase().replaceAll(' ', '');
    final counts = <String, int>{};
    for (final slot in slots) {
      final group = slot.group.toUpperCase();
      if (!group.contains('_')) continue;
      counts[group] = (counts[group] ?? 0) + 1;
    }
    final ranked = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) return byCount;
        return a.key.compareTo(b.key);
      });
    final rankedKeys = ranked.map((e) => e.key).toList();

    if (cleaned.isEmpty) return rankedKeys.take(limit).toList();

    final parsed = StudentQuery.parse(cleaned);
    if (parsed != null && parsed.section.isNotEmpty) return const [];
    if (parsed != null) {
      return rankedKeys
          .where((key) => key.startsWith('${parsed.batch}_'))
          .take(limit)
          .toList();
    }
    if (cleaned.codeUnits.every(_isDigit)) {
      return rankedKeys
          .where((key) => key.startsWith('${cleaned}_'))
          .take(limit)
          .toList();
    }
    return const [];
  }

  static List<ClassBlock> merge(List<ClassSlot> slots) {
    final ordered = [...slots]..sort((a, b) => a.slot.compareTo(b.slot));
    final result = <ClassBlock>[];
    for (final slot in ordered) {
      final last = result.isEmpty ? null : result.last;
      if (last != null &&
          last.course == slot.course &&
          last.group == slot.group &&
          last.teacher == slot.teacher &&
          last.room == slot.room &&
          last.endSlot + 1 == slot.slot) {
        result[result.length - 1] = last.copyWith(
          endSlot: slot.slot,
          end: slot.end,
        );
      } else {
        result.add(
          ClassBlock(
            day: slot.day,
            startSlot: slot.slot,
            endSlot: slot.slot,
            start: slot.start,
            end: slot.end,
            course: slot.course,
            group: slot.group,
            teacher: slot.teacher,
            room: slot.room,
          ),
        );
      }
    }
    return result;
  }

  static int minutes(String hhmm) {
    final parts = hhmm.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final normalized = hour < 8 ? hour + 12 : hour;
    return normalized * 60 + minute;
  }

  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    if (hours > 0 && rest > 0) return '${hours}h ${rest}m';
    if (hours > 0) return '${hours}h';
    return '${rest}m';
  }

  static RoutineDay todayOrSaturday([DateTime? now]) {
    final weekday = (now ?? DateTime.now()).weekday;
    return switch (weekday) {
      DateTime.saturday => RoutineDay.saturday,
      DateTime.sunday => RoutineDay.sunday,
      DateTime.monday => RoutineDay.monday,
      DateTime.tuesday => RoutineDay.tuesday,
      DateTime.wednesday => RoutineDay.wednesday,
      DateTime.thursday => RoutineDay.thursday,
      _ => RoutineDay.saturday,
    };
  }

  static bool _isDigit(int code) => code >= 48 && code <= 57;
}
