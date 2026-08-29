import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/model/class_reminder.dart';

class StudentCacheData {
  const StudentCacheData({
    this.schemaVersion = 1,
    this.lastQuery = '',
    this.reminders = const [],
  });

  final int schemaVersion;
  final String lastQuery;
  final List<ClassReminder> reminders;

  factory StudentCacheData.empty() => const StudentCacheData();

  factory StudentCacheData.fromJson(Map<String, dynamic> json) {
    return StudentCacheData(
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      lastQuery: json['lastQuery'] as String? ?? '',
      reminders: (json['reminders'] as List<dynamic>? ?? [])
          .map((item) => _reminderFromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'lastQuery': lastQuery,
      'reminders': reminders.map(_reminderToJson).toList(),
    };
  }

  StudentCacheData copyWith({
    String? lastQuery,
    List<ClassReminder>? reminders,
  }) {
    return StudentCacheData(
      schemaVersion: schemaVersion,
      lastQuery: lastQuery ?? this.lastQuery,
      reminders: reminders ?? this.reminders,
    );
  }

  static ClassReminder _reminderFromJson(Map<String, dynamic> json) {
    return ClassReminder(
      id: json['id'] as String,
      minutesBefore: (json['minutesBefore'] as num).toInt(),
      day: json['day'] as String,
      start: json['start'] as String,
      end: json['end'] as String,
      course: json['course'] as String,
      group: json['group'] as String,
      room: json['room'] as String,
    );
  }

  static Map<String, dynamic> _reminderToJson(ClassReminder reminder) {
    return {
      'id': reminder.id,
      'minutesBefore': reminder.minutesBefore,
      'day': reminder.day,
      'start': reminder.start,
      'end': reminder.end,
      'course': reminder.course,
      'group': reminder.group,
      'room': reminder.room,
    };
  }
}

/// Offline student state: last search + per-class reminder picks.
class StudentCache {
  StudentCache._(this._file, this._data);

  static const fileName = 'student_cache.json';
  static const _legacyQueryKey = 'last_query';

  final File _file;
  StudentCacheData _data;

  String lastQuery() => _data.lastQuery;

  List<ClassReminder> get reminders => List.unmodifiable(_data.reminders);

  int? minutesFor(String reminderId) {
    for (final reminder in _data.reminders) {
      if (reminder.id == reminderId) return reminder.minutesBefore;
    }
    return null;
  }

  static Future<StudentCache> load() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    var data = StudentCacheData.empty();
    if (await file.exists()) {
      try {
        data = StudentCacheData.fromJson(
          jsonDecode(await file.readAsString()) as Map<String, dynamic>,
        );
      } catch (_) {
        data = StudentCacheData.empty();
      }
    }
    if (data.lastQuery.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final legacy = prefs.getString(_legacyQueryKey) ?? '';
      if (legacy.isNotEmpty) {
        data = data.copyWith(lastQuery: legacy.trim().toUpperCase());
        await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data.toJson()));
      }
    }
    return StudentCache._(file, data);
  }

  Future<void> saveQuery(String query) async {
    final cleaned = query.trim().toUpperCase();
    _data = _data.copyWith(lastQuery: cleaned);
    await _persist();
  }

  Future<void> upsertReminder(ClassReminder reminder) async {
    final next = [
      for (final item in _data.reminders)
        if (item.id != reminder.id) item,
      reminder,
    ];
    _data = _data.copyWith(reminders: next);
    await _persist();
  }

  Future<void> removeReminder(String reminderId) async {
    _data = _data.copyWith(
      reminders: [
        for (final item in _data.reminders)
          if (item.id != reminderId) item,
      ],
    );
    await _persist();
  }

  Future<void> _persist() async {
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(_data.toJson()),
    );
  }
}
