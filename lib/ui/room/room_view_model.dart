import 'package:flutter/foundation.dart';

import '../../data/api/live_routine_repository.dart';
import '../../data/api/routine_api_exception.dart';
import '../../domain/model/class_slot.dart';
import '../../domain/model/room_info.dart';
import '../../domain/model/routine_day.dart';
import '../../domain/routine_queries.dart';

class RoomUiState {
  const RoomUiState({
    this.roomQueryText = '',
    this.selectedDayIndex = 0,
    this.selectedTimeIndex = 0,
    this.results = const [],
    this.allRoomNames = const [],
    this.isSubmitted = false,
    this.isLoading = false,
    this.errorMessage,
    this.scheduleRoom = '',
    this.scheduleDay,
    this.roomDaySlots = const [],
    this.scheduleLoading = false,
  });

  final String roomQueryText;
  final int selectedDayIndex;
  final int selectedTimeIndex;
  final List<RoomInfo> results;
  final List<String> allRoomNames;
  final bool isSubmitted;
  final bool isLoading;
  final String? errorMessage;
  final String scheduleRoom;
  final RoutineDay? scheduleDay;
  final List<ClassSlot> roomDaySlots;
  final bool scheduleLoading;

  static const List<String> daysOptions = [
    'Select Day',
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
  ];

  static const List<String> timeOptions = [
    'Select Time',
    '08:30-10:00',
    '10:00-11:30',
    '11:30-01:00',
    '01:00-02:30',
    '02:30-04:00',
    '04:00-05:30',
  ];

  static const List<String> deptOptions = ['CSE'];

  String get selectedDayLabel => daysOptions[selectedDayIndex];
  String get selectedTimeLabel => timeOptions[selectedTimeIndex];
  String get selectedDeptLabel => deptOptions.first;
  int get selectedDeptIndex => 0;

  RoutineDay get resolvedDay {
    if (selectedDayIndex <= 0) return RoutineQueries.todayOrSaturday();
    return RoutineDay.fromName(daysOptions[selectedDayIndex]);
  }

  TimeSlotOption get resolvedTimeSlot {
    if (selectedTimeIndex <= 0) return _slotForNow();
    return TimeSlotOption.predefined[selectedTimeIndex - 1];
  }

  static TimeSlotOption _slotForNow() {
    final now = RoutineQueries.nowMinutes();
    for (final slot in TimeSlotOption.predefined) {
      if (now < RoutineQueries.minutes(slot.end)) return slot;
    }
    return TimeSlotOption.predefined.last;
  }

  RoomUiState copyWith({
    String? roomQueryText,
    int? selectedDayIndex,
    int? selectedTimeIndex,
    List<RoomInfo>? results,
    List<String>? allRoomNames,
    bool? isSubmitted,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? scheduleRoom,
    RoutineDay? scheduleDay,
    List<ClassSlot>? roomDaySlots,
    bool? scheduleLoading,
  }) {
    return RoomUiState(
      roomQueryText: roomQueryText ?? this.roomQueryText,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
      selectedTimeIndex: selectedTimeIndex ?? this.selectedTimeIndex,
      results: results ?? this.results,
      allRoomNames: allRoomNames ?? this.allRoomNames,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? errorMessage : (errorMessage ?? this.errorMessage),
      scheduleRoom: scheduleRoom ?? this.scheduleRoom,
      scheduleDay: scheduleDay ?? this.scheduleDay,
      roomDaySlots: roomDaySlots ?? this.roomDaySlots,
      scheduleLoading: scheduleLoading ?? this.scheduleLoading,
    );
  }
}

class RoomViewModel extends ChangeNotifier {
  RoomViewModel({required this.live}) : _state = const RoomUiState() {
    _warmUp();
  }

  final LiveRoutineRepository live;
  RoomUiState _state;
  List<String> _lastFreeRooms = const [];

  RoomUiState get state => _state;

  Future<void> _warmUp() async {
    final names = await live.roomNames();
    _state = _state.copyWith(allRoomNames: names);
    notifyListeners();
  }

  void onRoomQueryChanged(String value) {
    _state = _state.copyWith(roomQueryText: value);
    if (_state.isSubmitted) {
      _applyFreeRoomFilter(_lastFreeRooms);
    } else {
      notifyListeners();
    }
  }

  void selectDayIndex(int index) {
    _state = _state.copyWith(selectedDayIndex: index);
    if (_state.isSubmitted) {
      searchEmptyRooms();
    } else {
      notifyListeners();
    }
  }

  void selectTimeIndex(int index) {
    _state = _state.copyWith(selectedTimeIndex: index);
    if (_state.isSubmitted) {
      searchEmptyRooms();
    } else {
      notifyListeners();
    }
  }

  void selectDeptIndex(int _) {
    notifyListeners();
  }

  Future<void> searchEmptyRooms() async {
    _state = _state.copyWith(
      isLoading: true,
      isSubmitted: true,
      clearError: true,
      errorMessage: null,
    );
    notifyListeners();
    try {
      final rooms = await live.freeRooms(
        time: _state.resolvedTimeSlot.label,
        day: _state.resolvedDay.fullLabel,
      );
      _lastFreeRooms = rooms;
      _state = _state.copyWith(isLoading: false);
      _applyFreeRoomFilter(rooms);
    } on RoutineApiException catch (error) {
      _lastFreeRooms = const [];
      _state = _state.copyWith(
        isLoading: false,
        results: const [],
        errorMessage: error.message,
      );
      notifyListeners();
    }
  }

  Future<void> loadRoomDay(String room, RoutineDay day) async {
    final cleaned = room.trim();
    if (cleaned.isEmpty) {
      _state = _state.copyWith(
        scheduleRoom: '',
        scheduleDay: day,
        roomDaySlots: const [],
        scheduleLoading: false,
      );
      notifyListeners();
      return;
    }
    _state = _state.copyWith(
      scheduleRoom: cleaned,
      scheduleDay: day,
      scheduleLoading: true,
    );
    notifyListeners();
    try {
      final slots = await live.roomDaySchedule(cleaned, day);
      if (_state.scheduleRoom != cleaned || _state.scheduleDay != day) return;
      _state = _state.copyWith(roomDaySlots: slots, scheduleLoading: false);
      notifyListeners();
    } on RoutineApiException {
      if (_state.scheduleRoom != cleaned || _state.scheduleDay != day) return;
      _state = _state.copyWith(roomDaySlots: const [], scheduleLoading: false);
      notifyListeners();
    }
  }

  void _applyFreeRoomFilter(List<String> rooms) {
    final query = _state.roomQueryText.trim().toLowerCase();
    final filtered = rooms.where((name) {
      if (query.isEmpty) return true;
      return name.toLowerCase().contains(query);
    });
    _state = _state.copyWith(
      results: filtered
          .map(
            (name) => RoomInfo(
              roomName: name,
              building: RoomInfo.deriveBuilding(name),
              isEmpty: true,
              daySlots: const [],
            ),
          )
          .toList(),
    );
    notifyListeners();
  }
}
