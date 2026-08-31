import 'package:flutter_test/flutter_test.dart';

import 'package:diu/data/schedule_pdf_builder.dart';
import 'package:diu/domain/model/routine_day.dart';
import 'package:diu/domain/model/student_summary.dart';

void main() {
  test('builds a PDF for the searched section week', () async {
    final bytes = await SchedulePdfBuilder.build(
      queryLabel: '68_A',
      week: {
        RoutineDay.saturday: [
          const ClassBlock(
            day: RoutineDay.saturday,
            startSlot: 1,
            endSlot: 1,
            start: '10:00',
            end: '11:30',
            course: 'CSE221',
            courseTitle: 'Object Oriented Programming',
            group: '68_A',
            teacher: 'MAR',
            room: 'KT-516',
          ),
          const ClassBlock(
            day: RoutineDay.saturday,
            startSlot: 2,
            endSlot: 2,
            start: '11:30',
            end: '01:00',
            course: 'CSE222',
            courseTitle: 'Object Oriented Programming Lab',
            group: '68_A1',
            teacher: 'MAR',
            room: 'G1-018 (COM LAB)',
          ),
        ],
        RoutineDay.sunday: [
          const ClassBlock(
            day: RoutineDay.sunday,
            startSlot: 1,
            endSlot: 1,
            start: '08:30',
            end: '10:00',
            course: 'CSE223',
            courseTitle: 'Digital Electronics',
            group: '68_A',
            teacher: 'AAM',
            room: 'KT-415',
          ),
        ],
      },
    );
    expect(bytes.length, greaterThan(200));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
