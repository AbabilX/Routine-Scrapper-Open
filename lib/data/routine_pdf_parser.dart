import 'pdf_word.dart';
import 'routine_file_dto.dart';

/// On-device port of `scripts/parse_routine_pdf.py`.
class RoutinePdfParser {
  static const days = [
    'SATURDAY',
    'SUNDAY',
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
  ];

  static const timeSlots = [
    ('08:30', '10:00'),
    ('10:00', '11:30'),
    ('11:30', '01:00'),
    ('01:00', '02:30'),
    ('02:30', '04:00'),
    ('04:00', '05:30'),
  ];

  static const slotEdges = [0.0, 230.0, 415.0, 610.0, 800.0, 985.0, 1300.0];

  static final courseRe = RegExp(r'^([A-Z]{2,5}\d{3}[A-Z]?)\((.+)\)$');
  static final teacherRe = RegExp(r'^[A-Z]{2,6}(?:[_-]\d+)?$');
  static final roomRe = RegExp(
    r'^(KT-\d+(?:\([A-Z]\))?|G1-\d+|ANX1-\d+|SH-\d+|CTBA-\d+|EMBED|IOT)$',
  );

  static const skip = {
    'ROOM',
    'COURSE',
    'TEACHER',
    'COM',
    'LAB',
    '(COM',
    'LAB)',
    'RESERVED',
    'VERSION',
    'V5',
    'CLASS',
    'ROUTINE',
    'FOR',
    'CSE',
    'PROGRAM',
  };

  static RoutineFileDto parse(
    ExtractedPdfText extracted, {
    required String sourcePdf,
  }) {
    final scale = extracted.pageWidth <= 0 ? 1.0 : extracted.pageWidth / 1300.0;
    final words = [...extracted.words]
      ..sort((a, b) {
        final page = a.page.compareTo(b.page);
        if (page != 0) return page;
        final y = a.y.compareTo(b.y);
        if (y != 0) return y;
        return a.x.compareTo(b.x);
      });

    var currentDay = 'SATURDAY';
    final slots = <ClassSlotDto>[];
    final seen = <String>{};

    for (final word in words) {
      if (days.contains(word.text) && word.x > 500 * scale) {
        currentDay = word.text;
        continue;
      }

      final match = courseRe.firstMatch(word.text);
      if (match == null) continue;

      final course = match.group(1)!;
      final group = match.group(2)!.replaceAll(RegExp(r'\.+$'), '');
      final index = slotIndex(word.x, scale);
      final teacher = _findTeacher(words, word, index, scale);
      if (skip.contains(teacher.toUpperCase()) || teacher == 'Reserved') {
        continue;
      }
      final room = _findRoom(words, word, index, scale);
      final (start, end) = timeSlots[index];
      final key = '$currentDay|$start|$course|$group|$teacher|$room';
      if (!seen.add(key)) continue;
      slots.add(
        ClassSlotDto(
          day: currentDay,
          slot: index,
          start: start,
          end: end,
          course: course,
          group: group,
          teacher: teacher,
          room: room,
        ),
      );
    }

    slots.sort((a, b) {
      final day = days.indexOf(a.day).compareTo(days.indexOf(b.day));
      if (day != 0) return day;
      final start = a.start.compareTo(b.start);
      if (start != 0) return start;
      return a.room.compareTo(b.room);
    });

    return RoutineFileDto(
      meta: RoutineMetaDto(
        schemaVersion: 1,
        origin: 'user',
        department: 'CSE',
        version: _guessVersion(words),
        semester: _guessSemester(words),
        effectiveFrom: '',
        sourcePdf: sourcePdf,
      ),
      slots: slots,
    );
  }

  static int slotIndex(double x, double scale) {
    for (var i = 0; i < slotEdges.length - 1; i++) {
      final left = slotEdges[i] * scale;
      final right = slotEdges[i + 1] * scale;
      if (x >= left && x < right) return i;
    }
    return 5;
  }

  static bool isRoom(String text) => roomRe.hasMatch(text.trim());

  static String _findTeacher(
    List<PdfWord> words,
    PdfWord course,
    int index,
    double scale,
  ) {
    final left = slotEdges[index] * scale;
    final right = slotEdges[index + 1] * scale;
    ({double delta, String text})? best;
    for (final word in words) {
      if (word.page != course.page || (word.y - course.y).abs() > 4 * scale) {
        continue;
      }
      if (word.x <= course.x || word.x >= right || word.x < left) continue;
      if (courseRe.hasMatch(word.text) ||
          isRoom(word.text) ||
          skip.contains(word.text.toUpperCase())) {
        continue;
      }
      final upper = word.text.toUpperCase();
      final looksTeacher = teacherRe.hasMatch(word.text) ||
          (word.text == upper && word.text.length >= 2 && word.text.length <= 6);
      if (!looksTeacher) continue;
      final delta = word.x - course.x;
      if (best == null || delta < best.delta) {
        best = (delta: delta, text: word.text);
      }
    }
    return best?.text ?? '?';
  }

  static String _findRoom(
    List<PdfWord> words,
    PdfWord course,
    int index,
    double scale,
  ) {
    final left = slotEdges[index] * scale;
    final right = slotEdges[index + 1] * scale;
    ({double score, String text})? best;
    for (final word in words) {
      if (word.page != course.page || word.y > course.y + 2 * scale) continue;
      if (word.x < left || word.x >= right) continue;
      if (course.y - word.y > 24 * scale) continue;
      if (!isRoom(word.text)) continue;
      final score =
          (course.y - word.y) + (word.x < course.x ? 0.0 : 40.0 * scale);
      if (best == null || score < best.score) {
        final suffix = _labSuffix(words, word.page, word.y, index, scale);
        best = (score: score, text: '${word.text}$suffix');
      }
    }
    return best?.text ?? '?';
  }

  static String _labSuffix(
    List<PdfWord> words,
    int page,
    double roomY,
    int index,
    double scale,
  ) {
    final left = slotEdges[index] * scale;
    final right = slotEdges[index + 1] * scale;
    for (final word in words) {
      if (word.page != page) continue;
      if (word.x < left || word.x >= right) continue;
      final dy = word.y - roomY;
      if (dy > 0 && dy < 16 * scale && (word.text == '(COM' || word.text == 'LAB)')) {
        return ' (COM LAB)';
      }
    }
    return '';
  }

  static String _guessVersion(List<PdfWord> words) {
    for (final word in words) {
      final match = RegExp(r'^V(\d+(?:\.\d+)?)$', caseSensitive: false)
          .firstMatch(word.text);
      if (match != null) return '${match.group(1)}.0'.replaceAll('.0.0', '.0');
    }
    return 'uploaded';
  }

  static String _guessSemester(List<PdfWord> words) {
    final joined = words.map((word) => word.text).join(' ');
    final match = RegExp(
      r'(Spring|Summer|Fall|Autumn)\s+\d{4}',
      caseSensitive: false,
    ).firstMatch(joined);
    return match?.group(0) ?? 'Uploaded';
  }
}
