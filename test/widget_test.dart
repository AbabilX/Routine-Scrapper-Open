import 'package:flutter_test/flutter_test.dart';

import 'package:diu/domain/student_query.dart';

void main() {
  test('StudentQuery still parses the demo batch', () {
    expect(StudentQuery.parse('68_C')?.batch, '68');
    expect(StudentQuery.parse('68_C')?.section, 'C');
  });
}
