import 'package:flutter_test/flutter_test.dart';

import 'package:rdiu/data/routine_file_dto.dart';
import 'package:rdiu/data/student_cache.dart';
import 'package:rdiu/domain/model/class_reminder.dart';
import 'package:rdiu/domain/model/routine_day.dart';
import 'package:rdiu/domain/model/student_summary.dart';
import 'package:rdiu/domain/course_label.dart';
import 'package:rdiu/domain/reminder_rules.dart';

void main() {
  final block = ClassBlock(
    day: RoutineDay.saturday,
    startSlot: 1,
    endSlot: 1,
    start: '10:00',
    end: '11:30',
    course: 'CSE114',
    group: '68_C',
    teacher: 'SRH',
    room: 'KT-503',
  );

  group('ClassReminderId', () {
    test('is stable for the same class block', () {
      expect(
        ClassReminderId.fromBlock(block),
        'SATURDAY|10:00|11:30|CSE114|68_C|KT-503',
      );
    });
  });

  group('ReminderRules', () {
    test('fireClock subtracts minutes and keeps afternoon slots', () {
      expect(ReminderRules.fireMinutes('10:00', 20), 9 * 60 + 40);
      expect(ReminderRules.fireClock('10:00', 20), (hour: 9, minute: 40));
      expect(ReminderRules.fireClock('01:00', 20), (hour: 12, minute: 40));
      expect(ReminderRules.formatFireTime('10:00', 20), '09:40');
      expect(ReminderRules.formatFireTime('01:00', 20), '12:40');
      expect(ReminderRules.dateTimeWeekday(RoutineDay.saturday), DateTime.saturday);
    });

    test('presets stay 5–30', () {
      expect(ReminderRules.presets, [5, 10, 15, 20, 30]);
      expect(ReminderRules.isPreset(20), isTrue);
      expect(ReminderRules.isPreset(12), isFalse);
    });
  });

  group('CourseLabel', () {
    test('uses name - CODE(group) when a name exists', () {
      expect(
        CourseLabel.format(code: 'CSE221', group: '68_A', name: 'Object Oriented Programming'),
        'Object Oriented Programming - CSE221(68_A)',
      );
      expect(CourseLabel.format(code: 'CSE221', group: '68_A'), 'CSE221(68_A)');
    });
  });

  group('JSON schema', () {
    test('routine meta defaults schemaVersion when missing', () {
      final dto = RoutineMetaDto.fromJson({
        'department': 'CSE',
        'version': '5.0',
        'semester': 'Summer 2026',
        'effectiveFrom': 'Saturday 11 July, 2026',
        'sourcePdf': 'file.pdf',
      });
      expect(dto.schemaVersion, 1);
      expect(dto.origin, 'bundled');
    });

    test('student cache round-trips reminders', () {
      final reminder = ClassReminder.fromBlock(block, 15);
      final data = StudentCacheData(
        lastQuery: '68_C',
        reminders: [reminder],
      );
      final parsed = StudentCacheData.fromJson(data.toJson());
      expect(parsed.lastQuery, '68_C');
      expect(parsed.schemaVersion, 1);
      expect(parsed.reminders, hasLength(1));
      expect(parsed.reminders.first.minutesBefore, 15);
      expect(parsed.reminders.first.id, reminder.id);
    });
  });
}
