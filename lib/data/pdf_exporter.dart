import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/model/routine_day.dart';
import '../domain/model/routine_meta.dart';
import '../domain/model/student_summary.dart';
import 'course_catalog.dart';
import 'schedule_pdf_builder.dart';

class PdfExporter {
  static Future<void> shareSchedule({
    required String queryLabel,
    required RoutineMeta meta,
    required Map<RoutineDay, List<ClassBlock>> week,
  }) async {
    final safe = queryLabel.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
    final bytes = await SchedulePdfBuilder.build(
      queryLabel: queryLabel,
      meta: meta,
      week: week,
      catalog: await CourseCatalog.load(),
    );
    final dir = await getTemporaryDirectory();
    final out = File('${dir.path}/Class_Schedule_$safe.pdf');
    await out.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(out.path, mimeType: 'application/pdf')],
        title: 'Class Schedule : $queryLabel',
      ),
    );
  }
}
