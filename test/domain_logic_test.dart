import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:rdiu/data/routine_file_dto.dart';
import 'package:rdiu/domain/model/class_slot.dart';
import 'package:rdiu/domain/model/class_status.dart';
import 'package:rdiu/domain/model/routine_day.dart';
import 'package:rdiu/domain/model/student_summary.dart';
import 'package:rdiu/domain/routine_queries.dart';
import 'package:rdiu/domain/student_query.dart';
import 'package:rdiu/ui/student/components/date_strip.dart';

ClassSlot _slot({
  RoutineDay day = RoutineDay.saturday,
  int slot = 1,
  String start = '10:00',
  String end = '11:30',
  String course = 'CSE114',
  String group = '68_C',
  String teacher = 'SRH',
  String room = 'KT-503',
}) {
  return ClassSlot(
    day: day,
    slot: slot,
    start: start,
    end: end,
    course: course,
    group: group,
    teacher: teacher,
    room: room,
  );
}

void main() {
  group('StudentQuery.parse', () {
    test('parses 68_C, 68C, 68, and 68_C1', () {
      expect(StudentQuery.parse('68_C')?.label, '68_C');
      expect(StudentQuery.parse('68C')?.label, '68_C');
      expect(StudentQuery.parse(' 68 c ')?.label, '68_C');
      expect(StudentQuery.parse('68')?.label, '68');
      expect(StudentQuery.parse('68_C1')?.label, '68_C1');
      expect(StudentQuery.parse(''), isNull);
      expect(StudentQuery.parse('SRH'), isNull);
      expect(StudentQuery.parse('68_'), isNull);
    });

    test('matches exact section and lab subsections', () {
      final query = StudentQuery.parse('68_C')!;
      expect(query.matches('68_C'), isTrue);
      expect(query.matches('68_C1'), isTrue);
      expect(query.matches('68_C2'), isTrue);
      expect(query.matches('68_D'), isFalse);
      expect(query.matches('68'), isFalse);
      expect(query.matches('168_C'), isFalse);
    });

    test('batch-only matches every section of that batch', () {
      final query = StudentQuery.parse('68')!;
      expect(query.matches('68'), isTrue);
      expect(query.matches('68_C'), isTrue);
      expect(query.matches('68_C1'), isTrue);
      expect(query.matches('71_B'), isFalse);
    });
  });

  group('RoutineQueries', () {
    test('minutes treats 1–7 as afternoon', () {
      expect(RoutineQueries.minutes('08:30'), 8 * 60 + 30);
      expect(RoutineQueries.minutes('10:00'), 10 * 60);
      expect(RoutineQueries.minutes('01:00'), 13 * 60);
      expect(RoutineQueries.minutes('04:00'), 16 * 60);
    });

    test('formatDuration matches Kotlin', () {
      expect(RoutineQueries.formatDuration(30), '30m');
      expect(RoutineQueries.formatDuration(60), '1h');
      expect(RoutineQueries.formatDuration(90), '1h 30m');
    });

    test('Friday maps to Saturday', () {
      expect(
        RoutineQueries.todayOrSaturday(DateTime(2026, 8, 28)),
        RoutineDay.saturday,
      );
      expect(
        RoutineQueries.todayOrSaturday(DateTime(2026, 8, 29)),
        RoutineDay.saturday,
      );
      expect(
        RoutineQueries.todayOrSaturday(DateTime(2026, 8, 30)),
        RoutineDay.sunday,
      );
    });

    test('weeklyBlocks keeps only days that have classes', () {
      final week = RoutineQueries.weeklyBlocks([
        _slot(day: RoutineDay.saturday, slot: 1, start: '10:00', end: '11:30'),
        _slot(
          day: RoutineDay.saturday,
          slot: 2,
          start: '11:30',
          end: '01:00',
          course: 'AOL101',
          teacher: 'AAM',
          room: 'G1-027',
        ),
        _slot(
          day: RoutineDay.thursday,
          slot: 1,
          start: '10:00',
          end: '11:30',
        ),
      ]);
      expect(week.keys, [RoutineDay.saturday, RoutineDay.thursday]);
      expect(week[RoutineDay.saturday], hasLength(2));
      expect(week.containsKey(RoutineDay.sunday), isFalse);
    });

    test('merges adjacent lab slots into one block', () {
      final blocks = RoutineQueries.merge([
        _slot(slot: 1, start: '10:00', end: '11:30'),
        _slot(slot: 2, start: '11:30', end: '01:00'),
      ]);
      expect(blocks, hasLength(1));
      expect(blocks.first.start, '10:00');
      expect(blocks.first.end, '01:00');
      expect(blocks.first.startSlot, 1);
      expect(blocks.first.endSlot, 2);
    });

    test('timeline inserts a break when the gap is 30 minutes or more', () {
      final items = RoutineQueries.timeline([
        _slot(slot: 1, start: '10:00', end: '11:30'),
        _slot(
          slot: 3,
          start: '01:00',
          end: '02:30',
          course: 'CSE212',
          teacher: 'ABC',
          room: 'KT-201',
        ),
      ]);
      expect(items, hasLength(3));
      expect(items[0], isA<TimelineClass>());
      final gap = items[1] as TimelineBreak;
      expect(gap.start, '11:30');
      expect(gap.end, '01:00');
      expect(gap.minutes, 90);
      expect(items[2], isA<TimelineClass>());
    });

    test('nowOrNext marks NOW then NEXT', () {
      final slots = [
        _slot(slot: 1, start: '10:00', end: '11:30'),
        _slot(
          slot: 3,
          start: '01:00',
          end: '02:30',
          course: 'CSE212',
          teacher: 'ABC',
          room: 'KT-201',
        ),
      ];
      final now = RoutineQueries.nowOrNext(
        slots,
        RoutineDay.saturday,
        today: RoutineDay.saturday,
        nowMin: RoutineQueries.minutes('10:15'),
      );
      expect(now?.status, ClassStatus.now);
      expect(now?.block.course, 'CSE114');

      final next = RoutineQueries.nowOrNext(
        slots,
        RoutineDay.saturday,
        today: RoutineDay.saturday,
        nowMin: RoutineQueries.minutes('12:00'),
      );
      expect(next?.status, ClassStatus.next);
      expect(next?.block.course, 'CSE212');
    });

    test('suggestChips ranks by frequency then key', () {
      final slots = [
        _slot(group: '68_C'),
        _slot(group: '68_C'),
        _slot(group: '68_B'),
        _slot(group: '71_A'),
      ];
      expect(RoutineQueries.suggestChips(slots, ''), ['68_C', '68_B', '71_A']);
      expect(RoutineQueries.suggestChips(slots, '68'), ['68_C', '68_B']);
      expect(RoutineQueries.suggestChips(slots, '68_C'), isEmpty);
    });
  });

  group('weekChips', () {
    test('starts from Saturday of the current week', () {
      final chips = weekChips(RoutineDay.sunday, DateTime(2026, 8, 30));
      expect(chips.map((c) => c.day), RoutineDay.values);
      expect(chips.first.date, 29);
      expect(chips.first.isToday, isFalse);
      expect(chips[1].isToday, isTrue);
    });
  });

  group('bundled routine JSON', () {
    test('68_C and 71_B have classes in the Summer 2026 file', () {
      final raw =
          File('assets/routine/cse_summer_2026_v5.json').readAsStringSync();
      final file = RoutineFileDto.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      final slots = file.slots
          .map(
            (dto) => ClassSlot(
              day: RoutineDay.fromName(dto.day),
              slot: dto.slot,
              start: dto.start,
              end: dto.end,
              course: dto.course,
              group: dto.group,
              teacher: dto.teacher,
              room: dto.room,
            ),
          )
          .toList();
      expect(file.meta.schemaVersion, 1);
      expect(file.meta.version, '5.0');
      expect(
        RoutineQueries.forStudent(slots, StudentQuery.parse('68_C')!),
        isNotEmpty,
      );
      expect(
        RoutineQueries.forStudent(slots, StudentQuery.parse('71_B')!),
        isNotEmpty,
      );
    });
  });
}
