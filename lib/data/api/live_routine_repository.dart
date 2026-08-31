import '../../domain/model/class_slot.dart';
import '../../domain/model/room_info.dart';
import '../../domain/model/routine_day.dart';
import '../../domain/model/routine_meta.dart';
import 'routine_api_client.dart';
import 'routine_api_cache.dart';
import 'routine_api_exception.dart';
import 'schedule_item_dto.dart';
import 'slot_mapper.dart';

class LiveRoutineRepository {
  LiveRoutineRepository({
    required this._client,
    required this._cache,
  });

  final RoutineApiClient _client;
  final RoutineApiCache _cache;

  RoutineVersionDto _version = const RoutineVersionDto(
    version: '',
    updatedAt: '',
    cacheInvalidationTimestamp: 0,
  );

  RoutineMeta get meta => RoutineMeta(
    department: RoutineApiClient.department.toUpperCase(),
    version: _version.version.isEmpty ? 'live' : _version.version,
    semester: '',
    effectiveFrom: _version.updatedAt,
    sourcePdf: '',
  );

  Future<void> syncVersion() async {
    final local = await _cache.loadVersion();
    if (local != null) _version = local;
    try {
      final remote = await _client.fetchVersion();
      final changed =
          local == null ||
          local.version != remote.version ||
          local.cacheInvalidationTimestamp != remote.cacheInvalidationTimestamp;
      _version = remote;
      await _cache.saveVersion(remote);
      if (changed && local != null) {
        await _cache.clearSchedules();
      }
    } on RoutineApiException {
      // Offline: keep disk cache + last known version.
    }
  }

  Future<List<String>> autocompleteStudent(String query) {
    return _client.autocomplete(query: query, viewMode: 'student');
  }

  Future<List<ClassSlot>> studentSchedule(String batch) {
    return _slots(
      key: 'student_$batch',
      fallbackGroup: batch,
      fetch: () => _client.fetchSchedule(viewMode: 'student', batch: batch),
    );
  }

  Future<List<ClassSlot>> teacherSchedule(String initials) {
    return _slots(
      key: 'teacher_$initials',
      fallbackGroup: '',
      fetch: () => _client.fetchSchedule(viewMode: 'teacher', batch: initials),
    );
  }

  Future<List<ClassSlot>> roomDaySchedule(String room, RoutineDay day) {
    return _slots(
      key: 'room_${room}_${day.fullLabel}',
      fallbackGroup: '',
      fetch: () => _fetchRoomDay(room, day),
    );
  }

  Future<List<String>> roomNames() async {
    const key = 'room_names';
    try {
      final names = await _client.fetchRoomNames();
      await _cache.saveStringList(key, names);
      return names;
    } on RoutineApiException {
      return await _cache.loadStringList(key) ?? const [];
    }
  }

  Future<List<String>> freeRooms({
    required String time,
    required String day,
  }) async {
    final key = 'free_${time}_$day';
    try {
      final rooms = await _client.fetchFreeRooms(time: time, day: day);
      await _cache.saveStringList(key, rooms);
      return rooms;
    } on RoutineApiException {
      final cached = await _cache.loadStringList(key);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<List<ScheduleItemDto>> _fetchRoomDay(
    String room,
    RoutineDay day,
  ) async {
    final parts = await Future.wait(
      TimeSlotOption.predefined.map((slot) {
        return _client.fetchSchedule(
          viewMode: 'room',
          roomNumber: room,
          day: day.fullLabel,
          time: slot.label,
        );
      }),
    );
    return [for (final chunk in parts) ...chunk];
  }

  Future<List<ClassSlot>> _slots({
    required String key,
    required String fallbackGroup,
    required Future<List<ScheduleItemDto>> Function() fetch,
  }) async {
    try {
      final items = await fetch();
      final slots = SlotMapper.mapItems(items, fallbackGroup: fallbackGroup);
      await _cache.saveSlots(key, slots);
      return slots;
    } on RoutineApiException {
      final cached = await _cache.loadSlots(key);
      if (cached != null) return cached;
      rethrow;
    }
  }
}
