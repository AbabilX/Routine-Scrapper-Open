import 'package:flutter/foundation.dart';

import '../../data/asset_routine_repository.dart';
import '../../domain/model/room_info.dart';
import '../../domain/model/routine_day.dart';
import '../../domain/room_queries.dart';
import '../../domain/routine_queries.dart';

class RoomUiState {
  const RoomUiState({
    this.roomQueryText = '',
    this.selectedDayIndex = 0, // Default: Select Day (0)
    this.selectedTimeIndex = 0, // Default: Select Time (0)
    this.selectedDeptIndex = 0, // Default: CSE (0)
    this.results = const [],
    this.allRoomNames = const [],
    this.isSubmitted = false,
  });

  final String roomQueryText;
  final int selectedDayIndex;
  final int selectedTimeIndex;
  final int selectedDeptIndex;
  final List<RoomInfo> results;
  final List<String> allRoomNames;
  final bool isSubmitted;

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

  static const List<String> deptOptions = ['CSE', 'BBA'];

  String get selectedDayLabel => daysOptions[selectedDayIndex];
  String get selectedTimeLabel => timeOptions[selectedTimeIndex];
  String get selectedDeptLabel => deptOptions[selectedDeptIndex];

  RoutineDay get resolvedDay {
    if (selectedDayIndex <= 0) return RoutineQueries.todayOrSaturday();
    final name = daysOptions[selectedDayIndex];
    return RoutineDay.fromName(name);
  }

  TimeSlotOption? get resolvedTimeSlot {
    if (selectedTimeIndex <= 0) return null;
    return TimeSlotOption.predefined[selectedTimeIndex - 1];
  }

  RoomUiState copyWith({
    String? roomQueryText,
    int? selectedDayIndex,
    int? selectedTimeIndex,
    int? selectedDeptIndex,
    List<RoomInfo>? results,
    List<String>? allRoomNames,
    bool? isSubmitted,
  }) {
    return RoomUiState(
      roomQueryText: roomQueryText ?? this.roomQueryText,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
      selectedTimeIndex: selectedTimeIndex ?? this.selectedTimeIndex,
      selectedDeptIndex: selectedDeptIndex ?? this.selectedDeptIndex,
      results: results ?? this.results,
      allRoomNames: allRoomNames ?? this.allRoomNames,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

class RoomViewModel extends ChangeNotifier {
  RoomViewModel({required AssetRoutineRepository repository})
    : _repository = repository {
    _init();
  }

  AssetRoutineRepository _repository;

  AssetRoutineRepository get repository => _repository;
  late RoomUiState _state;

  RoomUiState get state => _state;

  void updateRepository(AssetRoutineRepository repo) {
    if (identical(_repository, repo) || _repository.slots == repo.slots) {
      return;
    }
    _repository = repo;
    final rooms = RoomQueries.allRooms(repo.slots);
    _state = _state.copyWith(allRoomNames: rooms);
    if (_state.isSubmitted) {
      searchEmptyRooms();
    } else {
      notifyListeners();
    }
  }

  void _init({AssetRoutineRepository? repo}) {
    final activeRepo = repo ?? _repository;
    final rooms = RoomQueries.allRooms(activeRepo.slots);

    _state = RoomUiState(selectedDayIndex: 0, allRoomNames: rooms);
    notifyListeners();
  }

  void onRoomQueryChanged(String value) {
    _state = _state.copyWith(roomQueryText: value);
    if (_state.isSubmitted) {
      searchEmptyRooms();
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

  void selectDeptIndex(int index) {
    _state = _state.copyWith(selectedDeptIndex: index);
    if (_state.isSubmitted) {
      searchEmptyRooms();
    } else {
      notifyListeners();
    }
  }

  void searchEmptyRooms() {
    final results = RoomQueries.findEmptyRooms(
      slots: repository.slots,
      day: _state.resolvedDay,
      timeSlot: _state.resolvedTimeSlot,
      roomFilter: _state.roomQueryText,
      department: _state.selectedDeptLabel,
    );

    _state = _state.copyWith(results: results, isSubmitted: true);
    notifyListeners();
  }
}
