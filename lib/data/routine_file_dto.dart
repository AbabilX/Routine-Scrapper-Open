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
}

class RoutineMetaDto {
  const RoutineMetaDto({
    required this.department,
    required this.version,
    required this.semester,
    required this.effectiveFrom,
    required this.sourcePdf,
  });

  final String department;
  final String version;
  final String semester;
  final String effectiveFrom;
  final String sourcePdf;

  factory RoutineMetaDto.fromJson(Map<String, dynamic> json) {
    return RoutineMetaDto(
      department: json['department'] as String,
      version: json['version'] as String,
      semester: json['semester'] as String,
      effectiveFrom: json['effectiveFrom'] as String,
      sourcePdf: json['sourcePdf'] as String,
    );
  }
}

class ClassSlotDto {
  const ClassSlotDto({
    required this.day,
    required this.slot,
    required this.start,
    required this.end,
    required this.course,
    required this.group,
    required this.teacher,
    required this.room,
  });

  final String day;
  final int slot;
  final String start;
  final String end;
  final String course;
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
      group: json['group'] as String,
      teacher: json['teacher'] as String,
      room: json['room'] as String,
    );
  }
}
