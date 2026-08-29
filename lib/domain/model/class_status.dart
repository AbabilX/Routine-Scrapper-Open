import 'student_summary.dart';

enum ClassStatus { now, next, later, done }

class NowNextHint {
  const NowNextHint(this.status, this.block);

  final ClassStatus status;
  final ClassBlock block;
}
