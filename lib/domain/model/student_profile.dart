import 'student_gender.dart';

class StudentProfile {
  const StudentProfile({
    this.name = '',
    this.gender = StudentGender.unspecified,
  });

  final String name;
  final StudentGender gender;

  static const empty = StudentProfile();

  String get greeting => name.isEmpty ? 'Hello' : 'Hello, $name';

  StudentProfile copyWith({String? name, StudentGender? gender}) {
    return StudentProfile(
      name: name ?? this.name,
      gender: gender ?? this.gender,
    );
  }
}
