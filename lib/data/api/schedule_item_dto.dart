class ScheduleItemDto {
  const ScheduleItemDto({
    required this.courseCode,
    required this.courseTitle,
    required this.day,
    required this.room,
    required this.teacher,
    required this.timeSlot,
  });

  final String courseCode;
  final String courseTitle;
  final String day;
  final String room;
  final String teacher;
  final String timeSlot;

  factory ScheduleItemDto.fromJson(Map<String, dynamic> json) {
    return ScheduleItemDto(
      courseCode: _asString(json['course_code']),
      courseTitle: _asString(json['course_title']),
      day: _asString(json['day']),
      // API may send room as int (1506) or String ("1118(B)").
      room: _asString(json['room']),
      teacher: _asString(json['teacher']),
      timeSlot: _asString(json['time_slot'] ?? json['time']),
    );
  }

  static String _asString(Object? value) {
    if (value == null) return '';
    return '$value'.trim();
  }
}

class RoutineVersionDto {
  const RoutineVersionDto({
    required this.version,
    required this.updatedAt,
    required this.cacheInvalidationTimestamp,
  });

  final String version;
  final String updatedAt;
  final int cacheInvalidationTimestamp;

  factory RoutineVersionDto.fromJson(Map<String, dynamic> json) {
    return RoutineVersionDto(
      version: (json['version'] as String? ?? '').trim(),
      updatedAt: (json['updated_at'] as String? ?? '').trim(),
      cacheInvalidationTimestamp:
          (json['cache_invalidation_timestamp'] as num?)?.toInt() ?? 0,
    );
  }
}
