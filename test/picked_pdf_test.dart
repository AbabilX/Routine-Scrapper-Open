import 'package:flutter_test/flutter_test.dart';

import 'package:diu/data/picked_pdf.dart';

void main() {
  test('fromChannel reads path and name', () {
    final picked = PickedPdf.fromChannel({
      'path': '/tmp/routine.pdf',
      'name': 'CSE_V5.pdf',
    });
    expect(picked?.path, '/tmp/routine.pdf');
    expect(picked?.name, 'CSE_V5.pdf');
  });

  test('fromChannel rejects empty or missing maps', () {
    expect(PickedPdf.fromChannel(null), isNull);
    expect(PickedPdf.fromChannel(<String, String>{}), isNull);
    expect(PickedPdf.fromChannel({'name': 'x.pdf'}), isNull);
    expect(
      PickedPdf.fromChannel({'path': '/tmp/a.pdf', 'name': '  '})?.name,
      'routine.pdf',
    );
  });
}
