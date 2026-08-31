import 'package:flutter_test/flutter_test.dart';

import 'package:diu/data/schedule_pdf_builder.dart';
import 'package:diu/domain/model/routine_day.dart';
import 'package:diu/domain/model/routine_meta.dart';
import 'package:diu/domain/model/student_summary.dart';

void main() {
  test('builds a PDF for the searched section week', () async {
    final bytes = await SchedulePdfBuilder.build(
      queryLabel: '68_A',
      meta: const RoutineMeta(
        department: 'CSE',
        version: '5.0',
        semester: 'Summer 2026',
        effectiveFrom: 'Saturday 11 July, 2026',
        sourcePdf: 'file.pdf',
      ),
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
        ],
      },
    );
    expect(bytes.length, greaterThan(200));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
