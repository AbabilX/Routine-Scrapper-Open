import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/api/live_routine_repository.dart';
import '../../data/api/routine_api_exception.dart';
import '../../data/pdf_exporter.dart';
import '../../domain/model/class_slot.dart';
import '../../domain/model/routine_day.dart';
import '../../domain/model/routine_meta.dart';
import '../../domain/model/student_summary.dart';
import '../../domain/model/teacher_info.dart';
import '../../domain/routine_queries.dart';

class TeacherUiState {
  const TeacherUiState({
    this.query = '',
    this.slots = const [],
    this.suggestions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.meta,
    this.selectedDeptIndex = 0,
    this.isWeekView = false,
    this.selectedDay,
    this.profile,
  });

  final String query;
  final List<ClassSlot> slots;
  final List<String> suggestions;
  final bool isLoading;
  final String? errorMessage;
  final RoutineMeta? meta;
  final int selectedDeptIndex;
  final bool isWeekView;
  final RoutineDay? selectedDay;
  final TeacherInfo? profile;

  static const List<String> deptOptions = ['CSE', 'BBA'];

  String get displayName {
    final info = profile;
    if (info == null) return cleanQuery;
    if (info.titleWithInitial.isNotEmpty) return info.titleWithInitial;
    return cleanQuery;
  }

  String get cleanQuery => query.trim().toUpperCase();
  bool get hasMatches => slots.isNotEmpty;
  String get selectedDeptLabel => deptOptions[selectedDeptIndex];

  RoutineDay get resolvedDay => selectedDay ?? RoutineQueries.todayOrSaturday();

  List<String> get sections =>
      slots.map((s) => s.group).toSet().toList()..sort();

  List<String> get courses =>
      slots.map((s) => s.course).toSet().toList()..sort();

  int get classesPerWeek => slots.length;

  Map<RoutineDay, List<ClassBlock>> get weeklyMap =>
      RoutineQueries.weeklyBlocks(slots);

  List<ClassBlock> get selectedDayClasses => weeklyMap[resolvedDay] ?? const [];

  TeacherUiState copyWith({
    String? query,
    List<ClassSlot>? slots,
    List<String>? suggestions,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    RoutineMeta? meta,
    int? selectedDeptIndex,
    bool? isWeekView,
    RoutineDay? selectedDay,
    TeacherInfo? profile,
    bool clearProfile = false,
  }) {
    return TeacherUiState(
      query: query ?? this.query,
      slots: slots ?? this.slots,
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError
          ? errorMessage
          : (errorMessage ?? this.errorMessage),
      meta: meta ?? this.meta,
      selectedDeptIndex: selectedDeptIndex ?? this.selectedDeptIndex,
      isWeekView: isWeekView ?? this.isWeekView,
      selectedDay: selectedDay ?? this.selectedDay,
      profile: clearProfile ? null : (profile ?? this.profile),
    );
  }
}

class TeacherViewModel extends ChangeNotifier {
  TeacherViewModel({required this.live})
    : _state = TeacherUiState(
        selectedDay: RoutineQueries.todayOrSaturday(),
        meta: live.meta,
      ) {
    _initRx();
  }

  final LiveRoutineRepository live;
  final _querySubject = PublishSubject<String>();
  final _compositeSubscription = CompositeSubscription();

  TeacherUiState _state;

  TeacherUiState get state => _state;

  static String extractInitial(String rawText) {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) return '';
    final parenMatch = RegExp(r'\(([A-Za-z0-9_-]+)\)').firstMatch(trimmed);
    if (parenMatch != null) {
      return parenMatch.group(1)!.trim().toUpperCase();
    }
    if (trimmed.contains('-')) {
      return trimmed.split('-').first.trim().toUpperCase();
    }
    if (trimmed.contains(':')) {
      return trimmed.split(':').first.trim().toUpperCase();
    }
    if (trimmed.contains('(')) {
      return trimmed.split('(').first.trim().toUpperCase();
    }
    return trimmed.split(RegExp(r'\s+')).first.trim().toUpperCase();
  }

  void _initRx() {
    _querySubject
        .debounceTime(const Duration(milliseconds: 250))
        .distinct()
        .switchMap((q) async* {
          final trimmed = q.trim();
          if (trimmed.isEmpty) {
            yield <String>[];
          } else {
            try {
              final result = await live.autocompleteTeacher(
                trimmed,
                _state.selectedDeptLabel.toLowerCase(),
              );
              yield result;
            } on RoutineApiException {
              yield <String>[];
            }
          }
        })
        .listen((suggestions) {
          _state = _state.copyWith(suggestions: suggestions);
          notifyListeners();
        })
        .addTo(_compositeSubscription);
  }

  void onQueryChanged(String value) {
    final cleaned = value.trim().toUpperCase();
    _state = _state.copyWith(
      query: cleaned,
      clearError: true,
      errorMessage: null,
      slots: cleaned.isEmpty ? const [] : _state.slots,
      suggestions: cleaned.isEmpty ? const [] : _state.suggestions,
      isLoading: cleaned.isEmpty ? false : _state.isLoading,
      clearProfile: cleaned.isEmpty,
    );
    _querySubject.add(cleaned);
    notifyListeners();
  }

  void onSuggestionTapped(String rawSuggestion) {
    final initial = extractInitial(rawSuggestion);
    if (initial.isEmpty) return;
    _state = _state.copyWith(
      query: initial,
      suggestions: const [],
      clearError: true,
      errorMessage: null,
    );
    notifyListeners();
    _load(initial);
  }

  void search([String? customInitial]) {
    final target = extractInitial(customInitial ?? _state.query);
    if (target.isEmpty) return;
    _state = _state.copyWith(
      query: target,
      suggestions: const [],
      clearError: true,
      errorMessage: null,
    );
    _load(target);
  }

  void clear() {
    _state = _state.copyWith(
      query: '',
      slots: const [],
      suggestions: const [],
      isLoading: false,
      clearError: true,
      errorMessage: null,
      clearProfile: true,
    );
    _querySubject.add('');
    notifyListeners();
  }

  void selectDeptIndex(int index) {
    if (index == _state.selectedDeptIndex) return;
    _state = _state.copyWith(
      selectedDeptIndex: index,
      suggestions: const [],
    );
    notifyListeners();
    if (_state.cleanQuery.isNotEmpty) {
      _load(_state.cleanQuery);
    }
  }

  void toggleView(bool isWeekView) {
    _state = _state.copyWith(isWeekView: isWeekView);
    notifyListeners();
  }

  void selectDay(RoutineDay day) {
    _state = _state.copyWith(selectedDay: day);
    notifyListeners();
  }

  Future<void> downloadPdf() async {
    final target = _state.cleanQuery;
    if (target.isEmpty || _state.slots.isEmpty) return;
    await PdfExporter.shareSchedule(
      queryLabel: target,
      week: _state.weeklyMap,
    );
  }

  Future<void> _load(String initials) async {
    _state = _state.copyWith(
      isLoading: true,
      clearError: true,
      errorMessage: null,
    );
    notifyListeners();
    try {
      final scheduleFuture = live.teacherSchedule(
        initials,
        _state.selectedDeptLabel.toLowerCase(),
      );
      final profileFuture = _loadProfile(initials);
      final slots = await scheduleFuture;
      final profile = await profileFuture;
      if (_state.cleanQuery != initials) return;
      _state = _state.copyWith(
        slots: slots,
        profile: profile,
        isLoading: false,
        clearError: true,
        errorMessage: null,
        meta: live.meta,
        clearProfile: profile == null,
      );
      notifyListeners();
    } on RoutineApiException catch (error) {
      if (_state.cleanQuery != initials) return;
      _state = _state.copyWith(
        slots: const [],
        isLoading: false,
        clearProfile: true,
        errorMessage: error.statusCode == 404
            ? 'No schedule found for teacher "$initials" in ${_state.selectedDeptLabel}'
            : 'Failed to load teacher schedule',
      );
      notifyListeners();
    } catch (_) {
      if (_state.cleanQuery != initials) return;
      _state = _state.copyWith(
        slots: const [],
        isLoading: false,
        clearProfile: true,
        errorMessage: 'Something went wrong',
      );
      notifyListeners();
    }
  }

  Future<TeacherInfo?> _loadProfile(String initials) async {
    try {
      return await live.teacherInfo(initials);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _compositeSubscription.dispose();
    _querySubject.close();
    super.dispose();
  }
}
