class RoutineFileDto {
  const RoutineFileDto({required this.meta, required this.slots});

  final RoutineMetaDto meta;
  final List<ClassSlotDto> slots;

  factory RoutineFileDto.fromJson(Map<String, dynamic> json) {
    return RoutineFileDto(
      meta: RoutineMetaDto.fromJson(json['meta'] as Map<String, dynamic>),
      slots: (json['slots'] as List<dynamic>)
          .map((item) => ClassSlotDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'slots': slots.map((slot) => slot.toJson()).toList(),
    };
  }

  /// Device copy we can reopen: uploaded PDF or the bundled fallback.
  bool get isPersistedRoutine {
    if (slots.isEmpty) return false;
    return meta.origin == 'user' || meta.origin == 'bundled';
  }
}

class RoutineMetaDto {
  const RoutineMetaDto({
    required this.department,
    required this.version,
    required this.semester,
    required this.effectiveFrom,
    required this.sourcePdf,
    this.schemaVersion = 1,
    this.origin = 'bundled',
  });

  final int schemaVersion;
  final String origin;
  final String department;
  final String version;
  final String semester;
  final String effectiveFrom;
  final String sourcePdf;

  factory RoutineMetaDto.fromJson(Map<String, dynamic> json) {
    return RoutineMetaDto(
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      origin: json['origin'] as String? ?? 'bundled',
      department: json['department'] as String,
      version: json['version'] as String,
      semester: json['semester'] as String,
      effectiveFrom: json['effectiveFrom'] as String,
      sourcePdf: json['sourcePdf'] as String,
    );
  }

  String get fingerprint =>
      '$department|$version|$effectiveFrom|$schemaVersion';

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'origin': origin,
      'department': department,
      'version': version,
      'semester': semester,
      'effectiveFrom': effectiveFrom,
      'sourcePdf': sourcePdf,
    };
  }
}

class ClassSlotDto {
  const ClassSlotDto({
    required this.day,
    required this.slot,
    required this.start,
    required this.end,
    required this.course,
    this.courseTitle = '',
    required this.group,
    required this.teacher,
    required this.room,
  });

  final String day;
  final int slot;
  final String start;
  final String end;
  final String course;
  final String courseTitle;
  final String group;
  final String teacher;
  final String room;

  factory ClassSlotDto.fromJson(Map<String, dynamic> json) {
    return ClassSlotDto(
      day: json['day'] as String,
      slot: json['slot'] as int,
      start: json['start'] as String,
      end: json['end'] as String,
      course: json['course'] as String,
      courseTitle: json['courseTitle'] as String? ?? json['course_title'] as String? ?? '',
      group: json['group'] as String,
      teacher: json['teacher'] as String,
      room: json['room'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'slot': slot,
      'start': start,
      'end': end,
      'course': course,
      'course_title': courseTitle,
      'group': group,
      'teacher': teacher,
      'room': room,
    };
  }
}
