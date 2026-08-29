enum RoutineDay {
  saturday('Sat', 'Saturday'),
  sunday('Sun', 'Sunday'),
  monday('Mon', 'Monday'),
  tuesday('Tue', 'Tuesday'),
  wednesday('Wed', 'Wednesday'),
  thursday('Thu', 'Thursday');

  const RoutineDay(this.shortLabel, this.fullLabel);

  final String shortLabel;
  final String fullLabel;

  String get wireName => name.toUpperCase();

  static RoutineDay fromName(String raw) {
    final target = raw.toUpperCase();
    for (final day in RoutineDay.values) {
      if (day.wireName == target) return day;
    }
    return RoutineDay.saturday;
  }
}
