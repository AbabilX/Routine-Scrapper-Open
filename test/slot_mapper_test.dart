import 'package:flutter_test/flutter_test.dart';

import 'package:diu/data/api/schedule_item_dto.dart';
import 'package:diu/data/api/slot_mapper.dart';
import 'package:diu/domain/model/routine_day.dart';

void main() {
  test('maps student API row into ClassSlot', () {
    const item = ScheduleItemDto(
      courseCode: 'CSE121(70_E)',
      courseTitle: 'Electrical Circuits',
      day: 'Sunday',
      room: 'KT-219',
      teacher: 'MHK',
      timeSlot: '08:30-10:00',
    );

    final slot = SlotMapper.mapItem(item)!;

    expect(slot.course, 'CSE121');
    expect(slot.courseTitle, 'Electrical Circuits');
    expect(slot.group, '70_E');
    expect(slot.day, RoutineDay.sunday);
    expect(slot.start, '08:30');
    expect(slot.end, '10:00');
    expect(slot.slot, 0);
    expect(slot.teacher, 'MHK');
    expect(slot.room, 'KT-219');
  });

  test('maps lab span and nested group', () {
    const item = ScheduleItemDto(
      courseCode: 'CSE121(RE_A(3C))',
      courseTitle: 'Unknown',
      day: 'Wednesday',
      room: 'KT-809\n  (E.C. Lab)',
      teacher: 'MHK',
      timeSlot: '08:30-11:30',
    );

    final slot = SlotMapper.mapItem(item)!;

    expect(slot.course, 'CSE121');
    expect(slot.group, 'RE_A(3C)');
    expect(slot.start, '08:30');
    expect(slot.end, '11:30');
    expect(slot.room, 'KT-809   (E.C. Lab)');
  });

  test('maps numeric course code and int-like room string', () {
    const item = ScheduleItemDto(
      courseCode: '0412-123(68-D)',
      courseTitle: 'Principles of Finance',
      day: 'Sunday',
      room: '1506',
      teacher: 'MOG',
      timeSlot: '08:30-10:00',
    );

    final slot = SlotMapper.mapItem(item)!;

    expect(slot.course, '0412-123');
    expect(slot.group, '68-D');
    expect(slot.room, '1506');
    expect(slot.teacher, 'MOG');
  });

  test('ScheduleItemDto coerces int room from JSON', () {
    final item = ScheduleItemDto.fromJson({
      'course_code': '0412-221(67-G)',
      'course_title': 'Financial Management',
      'day': 'Thursday',
      'room': 1501,
      'teacher': 'MOG',
      'time_slot': '08:30-10:00',
    });

    expect(item.room, '1501');
    expect(SlotMapper.mapItem(item), isNotNull);
  });
}
