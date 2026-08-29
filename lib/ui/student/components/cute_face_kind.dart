import 'package:flutter/material.dart';

import '../../../domain/model/student_gender.dart';
import '../../theme/app_colors.dart';

const _baldWarm = Color(0xFFF0C9A6);
const _baldGold = Color(0xFFE8B88A);
const _baldRose = Color(0xFFE2A888);
const _baldTan = Color(0xFFD9A07A);

enum CuteFaceKind {
  bunny(sky),
  cat(lavender),
  chick(mint),
  deer(peach),
  fox(rose),
  wolf(sky),
  raccoon(lavender),
  bear(peach),
  baldGrin(_baldWarm),
  baldWink(_baldGold),
  baldGlasses(_baldRose),
  baldBow(_baldTan);

  const CuteFaceKind(this.fill);

  final Color fill;

  static const girlPool = [bunny, cat, chick, deer];
  static const boyPool = [fox, wolf, raccoon, bear];
  static const baldPool = [baldGrin, baldWink, baldGlasses, baldBow];

  static List<CuteFaceKind> poolFor(StudentGender gender) {
    return switch (gender) {
      StudentGender.girl => girlPool,
      StudentGender.boy => boyPool,
      StudentGender.unspecified => baldPool,
    };
  }

  CuteFaceKind nextIn(StudentGender gender) {
    final pool = poolFor(gender);
    final index = pool.indexOf(this);
    final from = index < 0 ? 0 : index;
    return pool[(from + 1) % pool.length];
  }
}
