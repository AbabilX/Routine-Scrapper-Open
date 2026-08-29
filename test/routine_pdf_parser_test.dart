import 'package:flutter_test/flutter_test.dart';

import 'package:diu/data/pdf_word.dart';
import 'package:diu/data/routine_pdf_parser.dart';

void main() {
  test('parser reads a course row the same way as the Python script', () {
    final parsed = RoutinePdfParser.parse(
      const ExtractedPdfText(
        pageWidth: 1300,
        words: [
          PdfWord(page: 0, y: 40, x: 620, text: 'SATURDAY'),
          PdfWord(page: 0, y: 90, x: 235, text: 'KT-503'),
          PdfWord(page: 0, y: 100, x: 250, text: 'CSE114(68_C)'),
          PdfWord(page: 0, y: 100, x: 330, text: 'SRH'),
        ],
      ),
      sourcePdf: 'routine.pdf',
    );

    expect(parsed.meta.origin, 'user');
    expect(parsed.meta.sourcePdf, 'routine.pdf');
    expect(parsed.slots, hasLength(1));
    expect(parsed.slots.first.day, 'SATURDAY');
    expect(parsed.slots.first.course, 'CSE114');
    expect(parsed.slots.first.group, '68_C');
    expect(parsed.slots.first.teacher, 'SRH');
    expect(parsed.slots.first.room, 'KT-503');
    expect(parsed.slots.first.slot, 1);
    expect(parsed.slots.first.start, '10:00');
  });

  test('parser returns no slots when the PDF has no course tokens', () {
    final parsed = RoutinePdfParser.parse(
      const ExtractedPdfText(
        pageWidth: 1300,
        words: [PdfWord(page: 0, y: 10, x: 10, text: 'HELLO')],
      ),
      sourcePdf: 'empty.pdf',
    );
    expect(parsed.slots, isEmpty);
  });
}
