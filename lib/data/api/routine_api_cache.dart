import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../domain/model/class_slot.dart';
import '../../domain/model/routine_day.dart';
import 'schedule_item_dto.dart';

class RoutineApiCache {
  Future<Directory> _dir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/api_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _file(String name) async => File('${(await _dir()).path}/$name');

  Future<RoutineVersionDto?> loadVersion() async {
    final file = await _file('version.json');
    if (!await file.exists()) return null;
    try {
      return RoutineVersionDto.fromJson(
        jsonDecode(await file.readAsString()) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveVersion(RoutineVersionDto version) async {
    final file = await _file('version.json');
    await file.writeAsString(
      jsonEncode({
        'version': version.version,
        'updated_at': version.updatedAt,
        'cache_invalidation_timestamp': version.cacheInvalidationTimestamp,
      }),
    );
  }

  Future<List<ClassSlot>?> loadSlots(String key) async {
    final file = await _file(_slotsName(key));
    if (!await file.exists()) return null;
    try {
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final raw = json['slots'] as List<dynamic>? ?? const [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(_slotFromJson)
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSlots(String key, List<ClassSlot> slots) async {
    final file = await _file(_slotsName(key));
    await file.writeAsString(
      jsonEncode({
        'slots': slots.map(_slotToJson).toList(),
      }),
    );
  }

  Future<List<String>?> loadStringList(String key) async {
    final file = await _file('$key.json');
    if (!await file.exists()) return null;
    try {
      final json = jsonDecode(await file.readAsString());
      if (json is List) {
        return json.map((item) => '$item').toList();
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveStringList(String key, List<String> values) async {
    final file = await _file('$key.json');
    await file.writeAsString(jsonEncode(values));
  }

  Future<void> clearSchedules() async {
    final dir = await _dir();
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (name == 'version.json') continue;
      await entity.delete();
    }
  }

  String _slotsName(String key) => 'slots_${key.hashCode}.json';

  Map<String, dynamic> _slotToJson(ClassSlot slot) {
    return {
      'day': slot.day.wireName,
      'slot': slot.slot,
      'start': slot.start,
      'end': slot.end,
      'course': slot.course,
      'course_title': slot.courseTitle,
      'group': slot.group,
      'teacher': slot.teacher,
      'room': slot.room,
    };
  }

  ClassSlot _slotFromJson(Map<String, dynamic> json) {
    return ClassSlot(
      day: RoutineDay.fromName(json['day'] as String? ?? ''),
      slot: (json['slot'] as num?)?.toInt() ?? 0,
      start: json['start'] as String? ?? '',
      end: json['end'] as String? ?? '',
      course: json['course'] as String? ?? '',
      courseTitle: json['course_title'] as String? ?? '',
      group: json['group'] as String? ?? '',
      teacher: json['teacher'] as String? ?? '',
      room: json['room'] as String? ?? '',
    );
  }
}
