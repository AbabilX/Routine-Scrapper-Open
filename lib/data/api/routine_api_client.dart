import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/model/teacher_info.dart';
import 'api_config.dart';
import 'api_endpoints.dart';
import 'routine_api_exception.dart';
import 'schedule_item_dto.dart';

/// HTTP only. Host from [ApiConfig], paths from [ApiEndpoints] (compile-time env).
class RoutineApiClient {
  RoutineApiClient({http.Client? httpClient, Duration? timeout})
    : _http = httpClient ?? http.Client(),
      _timeout = timeout ?? const Duration(seconds: 12);

  static const department = 'cse';

  final http.Client _http;
  final Duration _timeout;

  Future<RoutineVersionDto> fetchVersion() async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final json = await _getMap(
      ApiEndpoints.routineVersion,
      action: 'Fetching Routine Version',
      query: {'t': '$now'},
    );
    return RoutineVersionDto.fromJson(json);
  }

  Future<List<String>> autocomplete({
    required String query,
    required String viewMode,
    String department = department,
  }) async {
    final json = await _getMap(
      ApiEndpoints.autocomplete,
      action: 'Fetching $viewMode Autocomplete ($query)',
      query: {
        'query': query,
        'view_mode': viewMode,
        'department': department.toLowerCase(),
      },
    );
    final raw = json['suggestions'];
    if (raw is! List) return const [];
    return raw
        .map((item) => '$item'.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<List<ScheduleItemDto>> fetchSchedule({
    required String viewMode,
    String department = department,
    String? batch,
    String? roomNumber,
    String? day,
    String? time,
  }) async {
    final body = <String, dynamic>{
      'view_mode': viewMode,
      'department': department.toLowerCase(),
      if (batch != null && batch.isNotEmpty) 'batch': batch,
      if (roomNumber != null && roomNumber.isNotEmpty)
        'room_number': roomNumber,
      if (day != null && day.isNotEmpty) 'day': day,
      if (time != null && time.isNotEmpty) 'time': time,
    };

    final String action;
    if (viewMode == 'student') {
      action = 'Fetching Student Section Routine ($batch)';
    } else if (viewMode == 'teacher') {
      action = 'Fetching Teacher Routine ($batch)';
    } else if (viewMode == 'room') {
      action = 'Fetching Room Schedule ($roomNumber - $day)';
    } else {
      action = 'Fetching Schedule ($viewMode)';
    }

    final json = await _postMap(
      ApiEndpoints.schedule,
      action: action,
      body: body,
      emptyOn404: true,
    );
    if (json == null) return const [];
    final raw = json['result'];
    if (raw is! List) return const [];
    return raw
        .map((item) {
          if (item is Map<String, dynamic>) return item;
          if (item is Map) return Map<String, dynamic>.from(item);
          return null;
        })
        .whereType<Map<String, dynamic>>()
        .map(ScheduleItemDto.fromJson)
        .toList();
  }

  Future<List<String>> fetchFreeRooms({
    required String time,
    required String day,
  }) async {
    final json = await _getMap(
      ApiEndpoints.freeRooms,
      action: 'Fetching Empty Rooms ($time - $day)',
      query: {
        'time': time,
        'department': department,
      },
    );
    final byDay = json['empty_classrooms'];
    if (byDay is! Map) return const [];
    final rooms = byDay[day] ?? byDay[day.toLowerCase()];
    if (rooms is! List) return const [];
    return rooms
        .map((item) => '$item'.replaceAll('\n', ' ').trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<List<String>> fetchRoomNames() async {
    final json = await _getMap(
      ApiEndpoints.roomsStatic,
      action: 'Fetching Room List',
    );
    return json.keys
        .map((key) => key.replaceAll('\n', ' ').trim())
        .where((s) => s.isNotEmpty)
        .toList()
      ..sort();
  }

  Future<Map<String, TeacherInfo>> fetchTeachers() async {
    final json = await _getMap(
      ApiEndpoints.teachersStatic,
      action: 'Fetching Teachers Directory',
    );
    final map = <String, TeacherInfo>{};

    final list =
        json['teachers'] ??
        json['result'] ??
        (json['data'] is List ? json['data'] : null);
    if (list is List) {
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final teacher = TeacherInfo.fromJson(item);
          if (teacher.initial.isNotEmpty) {
            map[teacher.initial.toUpperCase()] = teacher;
          }
        }
      }
    } else {
      for (final entry in json.entries) {
        if (entry.value is Map<String, dynamic>) {
          final teacher = TeacherInfo.fromJson(
            entry.value as Map<String, dynamic>,
            entry.key,
          );
          final key = (teacher.initial.isNotEmpty ? teacher.initial : entry.key)
              .toUpperCase();
          map[key] = teacher;
        }
      }
    }
    return map;
  }

  Future<Map<String, dynamic>> _getMap(
    String path, {
    required String action,
    Map<String, String>? query,
  }) async {
    if (!ApiConfig.isConfigured) {
      throw const RoutineApiException('API_BASE_URL is not configured');
    }
    if (!ApiEndpoints.isConfigured) {
      throw const RoutineApiException('API endpoint paths are not configured');
    }
    final uri = ApiConfig.uri(path, query);
    _ApiLogger.logRequest(action: action, method: 'GET');
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _http.get(uri).timeout(_timeout);
      stopwatch.stop();
      return _decodeMap(
            response,
            action: action,
            method: 'GET',
            duration: stopwatch.elapsed,
            emptyOn404: false,
          ) ??
          (throw RoutineApiException.parse());
    } catch (e, stack) {
      stopwatch.stop();
      _ApiLogger.logError(
        action: action,
        method: 'GET',
        error: e,
        duration: stopwatch.elapsed,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _postMap(
    String path, {
    required String action,
    required Map<String, dynamic> body,
    required bool emptyOn404,
  }) async {
    if (!ApiConfig.isConfigured) {
      throw const RoutineApiException('API_BASE_URL is not configured');
    }
    if (!ApiEndpoints.isConfigured) {
      throw const RoutineApiException('API endpoint paths are not configured');
    }
    final uri = ApiConfig.uri(path);
    _ApiLogger.logRequest(action: action, method: 'POST', body: body);
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      stopwatch.stop();
      return _decodeMap(
        response,
        action: action,
        method: 'POST',
        duration: stopwatch.elapsed,
        emptyOn404: emptyOn404,
      );
    } catch (e, stack) {
      stopwatch.stop();
      _ApiLogger.logError(
        action: action,
        method: 'POST',
        error: e,
        duration: stopwatch.elapsed,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Map<String, dynamic>? _decodeMap(
    http.Response response, {
    required String action,
    required String method,
    required Duration duration,
    required bool emptyOn404,
  }) {
    if (emptyOn404 && response.statusCode == 404) {
      _ApiLogger.logResponse(
        action: action,
        method: method,
        statusCode: response.statusCode,
        duration: duration,
        rawBody: '404 Not Found (empty)',
      );
      return null;
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }

    _ApiLogger.logResponse(
      action: action,
      method: method,
      statusCode: response.statusCode,
      duration: duration,
      decodedBody: decoded,
      rawBody: decoded == null ? response.body : null,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RoutineApiException.http(response.statusCode);
    }
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    if (decoded is List) return {'result': decoded};
    throw RoutineApiException.parse();
  }
}

class _ApiLogger {
  static const _encoder = JsonEncoder.withIndent('  ');

  static void logRequest({
    required String action,
    required String method,
    Map<String, dynamic>? body,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('┌── [API REQUEST: $action] ──────────────────────────────────');
    buffer.writeln('│ Method : $method');
    if (body != null && body.isNotEmpty) {
      buffer.writeln('│ Body   :');
      try {
        final formatted = _encoder.convert(body);
        for (final line in formatted.split('\n')) {
          buffer.writeln('│   $line');
        }
      } catch (_) {
        buffer.writeln('│   $body');
      }
    }
    buffer.write('└───────────────────────────────────────────────────────────');
    _print(buffer.toString(), name: 'API.REQ');
  }

  static void logResponse({
    required String action,
    required String method,
    required int statusCode,
    required Duration duration,
    dynamic decodedBody,
    String? rawBody,
  }) {
    final buffer = StringBuffer();
    final statusSymbol = (statusCode >= 200 && statusCode < 300) ? '✓' : '✗';
    buffer.writeln(
      '┌── [API RESPONSE: $action] $statusSymbol $statusCode (${duration.inMilliseconds}ms) ────',
    );
    buffer.writeln('│ Method : $method');
    buffer.writeln('│ Data   :');
    if (decodedBody != null) {
      try {
        final formatted = _encoder.convert(decodedBody);
        for (final line in formatted.split('\n')) {
          buffer.writeln('│   $line');
        }
      } catch (_) {
        buffer.writeln('│   $decodedBody');
      }
    } else if (rawBody != null && rawBody.isNotEmpty) {
      buffer.writeln('│   $rawBody');
    } else {
      buffer.writeln('│   (empty)');
    }
    buffer.write('└───────────────────────────────────────────────────────────');
    _print(buffer.toString(), name: 'API.RES');
  }

  static void logError({
    required String action,
    required String method,
    required Object error,
    Duration? duration,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer();
    final timeStr = duration != null ? ' (${duration.inMilliseconds}ms)' : '';
    buffer.writeln('┌── [API ERROR: $action] ✗$timeStr ────────────────────────────');
    buffer.writeln('│ Method : $method');
    buffer.writeln('│ Error  : $error');
    if (stackTrace != null) {
      buffer.writeln('│ StackTrace:');
      for (final line in stackTrace.toString().split('\n').take(4)) {
        buffer.writeln('│   $line');
      }
    }
    buffer.write('└───────────────────────────────────────────────────────────');
    _print(buffer.toString(), name: 'API.ERR');
  }

  static void _print(String message, {required String name}) {
    if (kDebugMode) {
      debugPrint(message);
      developer.log(message, name: name);
    }
  }
}

