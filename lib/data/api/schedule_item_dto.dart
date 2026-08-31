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
      courseCode: (json['course_code'] as String? ?? '').trim(),
      courseTitle: (json['course_title'] as String? ?? '').trim(),
      day: (json['day'] as String? ?? '').trim(),
      room: (json['room'] as String? ?? '').trim(),
      teacher: (json['teacher'] as String? ?? '').trim(),
      timeSlot: (json['time_slot'] as String? ?? json['time'] as String? ?? '')
          .trim(),
    );
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
