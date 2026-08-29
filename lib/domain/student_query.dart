class StudentQuery {
  const StudentQuery(this.batch, this.section);

  final String batch;
  final String section;

  String get label => section.isEmpty ? batch : '${batch}_$section';

  bool matches(String group) {
    final g = group.toUpperCase();
    if (section.isEmpty) {
      return g == batch || g.startsWith('${batch}_');
    }
    final exact = '${batch}_$section';
    if (g == exact) return true;
    return g.startsWith(exact) &&
        g.length > exact.length &&
        _isDigit(g.codeUnitAt(exact.length));
  }

  static final _full = RegExp(r'^(\d{2,3})_?([A-Z]\d?)$');
  static final _batchOnly = RegExp(r'^(\d{2,3})$');

  static StudentQuery? parse(String raw) {
    final cleaned = raw.trim().toUpperCase().replaceAll(' ', '');
    if (cleaned.isEmpty) return null;
    final full = _full.firstMatch(cleaned);
    if (full != null) {
      return StudentQuery(full.group(1)!, full.group(2)!);
    }
    final batchOnly = _batchOnly.firstMatch(cleaned);
    if (batchOnly != null) {
      return StudentQuery(batchOnly.group(1)!, '');
    }
    return null;
  }

  static bool _isDigit(int code) => code >= 48 && code <= 57;
}
