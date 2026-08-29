enum StudentGender {
  girl,
  boy,
  unspecified;

  static StudentGender fromWire(String? value) {
    return switch (value) {
      'girl' => StudentGender.girl,
      'boy' => StudentGender.boy,
      _ => StudentGender.unspecified,
    };
  }

  String get wireName => name;
}
