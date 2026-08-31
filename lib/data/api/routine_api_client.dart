import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'routine_api_exception.dart';
import 'schedule_item_dto.dart';

/// HTTP only. Paths are relative; host comes from [ApiConfig].
class RoutineApiClient {
  RoutineApiClient({http.Client? httpClient, Duration? timeout})
    : _http = httpClient ?? http.Client(),
      _timeout = timeout ?? const Duration(seconds: 12);

  static const department = 'cse';

  final http.Client _http;
  final Duration _timeout;

  Future<RoutineVersionDto> fetchVersion() async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final json = await _getMap('/api/routine_version', {'t': '$now'});
    return RoutineVersionDto.fromJson(json);
  }

  Future<List<String>> autocomplete({
    required String query,
    required String viewMode,
  }) async {
    final json = await _getMap('/api/search_autocomplete', {
      'query': query,
      'view_mode': viewMode,
      'department': department,
    });
    final raw = json['suggestions'];
    if (raw is! List) return const [];
    return raw.map((item) => '$item'.trim()).where((s) => s.isNotEmpty).toList();
  }

  Future<List<ScheduleItemDto>> fetchSchedule({
    required String viewMode,
    String? batch,
    String? roomNumber,
    String? day,
    String? time,
  }) async {
    final body = <String, dynamic>{
      'view_mode': viewMode,
      'department': department,
      if (batch != null && batch.isNotEmpty) 'batch': batch,
      if (roomNumber != null && roomNumber.isNotEmpty) 'room_number': roomNumber,
      if (day != null && day.isNotEmpty) 'day': day,
      if (time != null && time.isNotEmpty) 'time': time,
    };
    final json = await _postMap('/api/schedule', body, emptyOn404: true);
    if (json == null) return const [];
    final raw = json['result'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ScheduleItemDto.fromJson)
        .toList();
  }

  Future<List<String>> fetchFreeRooms({
    required String time,
    required String day,
  }) async {
    final json = await _getMap('/api/free-rooms', {
      'time': time,
      'department': department,
    });
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
    final json = await _getMap('/static/rooms.json');
    return json.keys
        .map((key) => key.replaceAll('\n', ' ').trim())
        .where((s) => s.isNotEmpty)
        .toList()
      ..sort();
  }

  Future<Map<String, dynamic>> _getMap(
    String path, [
    Map<String, String>? query,
  ]) async {
    if (!ApiConfig.isConfigured) {
      throw const RoutineApiException('API_BASE_URL is not configured');
    }
    final response = await _http
        .get(ApiConfig.uri(path, query))
        .timeout(_timeout);
    return _decodeMap(response, emptyOn404: false) ??
        (throw RoutineApiException.parse());
  }

  Future<Map<String, dynamic>?> _postMap(
    String path,
    Map<String, dynamic> body, {
    required bool emptyOn404,
  }) async {
    if (!ApiConfig.isConfigured) {
      throw const RoutineApiException('API_BASE_URL is not configured');
    }
    final response = await _http
        .post(
          ApiConfig.uri(path),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(_timeout);
    return _decodeMap(response, emptyOn404: emptyOn404);
  }

  Map<String, dynamic>? _decodeMap(
    http.Response response, {
    required bool emptyOn404,
  }) {
    if (emptyOn404 && response.statusCode == 404) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RoutineApiException.http(response.statusCode);
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw RoutineApiException.parse();
  }
}
