import 'package:flutter_test/flutter_test.dart';

import 'package:DIU/domain/model/student_gender.dart';
import 'package:DIU/ui/student/components/cute_face_kind.dart';

void main() {
  test('twelve faces split by gender; no-gender is bald men', () {
    expect(CuteFaceKind.values, hasLength(12));
    expect(CuteFaceKind.girlPool, hasLength(4));
    expect(CuteFaceKind.boyPool, hasLength(4));
    expect(CuteFaceKind.baldPool, hasLength(4));
    expect(CuteFaceKind.poolFor(StudentGender.girl), CuteFaceKind.girlPool);
    expect(CuteFaceKind.poolFor(StudentGender.boy), CuteFaceKind.boyPool);
    expect(
      CuteFaceKind.poolFor(StudentGender.unspecified),
      CuteFaceKind.baldPool,
    );
    expect(CuteFaceKind.baldPool, contains(CuteFaceKind.baldGrin));
    expect(CuteFaceKind.bunny.nextIn(StudentGender.girl), CuteFaceKind.cat);
    expect(CuteFaceKind.fox.nextIn(StudentGender.boy), CuteFaceKind.wolf);
    expect(
      CuteFaceKind.baldBow.nextIn(StudentGender.unspecified),
      CuteFaceKind.baldGrin,
    );
  });
}
