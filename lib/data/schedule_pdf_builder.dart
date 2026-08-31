import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/course_label.dart';
import '../domain/model/routine_day.dart';
import '../domain/model/student_summary.dart';

/// On-device weekly schedule PDF. Layout matches the section table:
/// title + 5-column grid, day name only on the first row of each day.
class SchedulePdfBuilder {
  static const _headerBlue = PdfColor.fromInt(0xFF1D4E89);
  static const _grid = PdfColor.fromInt(0xFF9CA3AF);

  static Future<Uint8List> build({
    required String queryLabel,
    required Map<RoutineDay, List<ClassBlock>> week,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 36, 32, 32),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'Class Schedule : $queryLabel',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 16),
          _scheduleTable(week),
        ],
      ),
    );
    return doc.save();
  }

  static pw.Widget _scheduleTable(Map<RoutineDay, List<ClassBlock>> week) {
    final rows = <pw.TableRow>[
      pw.TableRow(
        repeat: true,
        decoration: const pw.BoxDecoration(color: _headerBlue),
        children: [
          _headCell('Day'),
          _headCell('Course'),
          _headCell('Time Slot'),
          _headCell('Room'),
          _headCell('Teacher'),
        ],
      ),
    ];
    for (final entry in week.entries) {
      final blocks = entry.value;
      for (var index = 0; index < blocks.length; index++) {
        final block = blocks[index];
        rows.add(
          pw.TableRow(
            children: [
              _bodyCell(index == 0 ? entry.key.fullLabel : ''),
              _bodyCell(
                CourseLabel.format(
                  code: block.course,
                  group: block.group,
                  name: block.courseTitle.isNotEmpty ? block.courseTitle : null,
                ),
                align: pw.TextAlign.left,
              ),
              _bodyCell('${block.start}-${block.end}'),
              _bodyCell(block.room),
              _bodyCell(block.teacher),
            ],
          ),
        );
      }
    }
    return pw.Table(
      border: pw.TableBorder.all(color: _grid, width: 0.6),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: pw.FlexColumnWidth(14),
        1: pw.FlexColumnWidth(42),
        2: pw.FlexColumnWidth(16),
        3: pw.FlexColumnWidth(20),
        4: pw.FlexColumnWidth(10),
      },
      children: rows,
    );
  }

  static pw.Widget _headCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _bodyCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.center,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: pw.Text(
        text,
        textAlign: align,
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }
}
