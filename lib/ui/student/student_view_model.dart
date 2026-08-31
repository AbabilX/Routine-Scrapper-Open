import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/api/live_routine_repository.dart';
import '../../data/api/routine_api_exception.dart';
import '../../data/class_reminder_scheduler.dart';
import '../../data/pdf_exporter.dart';
import '../../data/student_cache.dart';
import '../../domain/model/class_reminder.dart';
import '../../domain/model/class_slot.dart';
import '../../domain/model/class_status.dart';
import '../../domain/model/routine_day.dart';
import '../../domain/model/routine_meta.dart';
import '../../domain/model/student_profile.dart';
import '../../domain/model/student_summary.dart';
import '../../domain/model/teacher_info.dart';
import '../../domain/routine_queries.dart';
import '../../domain/student_query.dart';

class StudentUiState {
  const StudentUiState({
    this.queryText = '',
    this.parsedQuery,
    this.selectedDay,
    this.today,
    this.summary,
    this.timeline = const [],
    this.classStatuses = const {},
    this.nowNext,
    this.suggestions = const [],
    this.hasMatches = false,
    this.meta,
    this.invalidQuery = false,
    this.restored = false,
    this.reminders = const [],
    this.profile = StudentProfile.empty,
    this.isLoading = false,
    this.errorMessage,
  });

  final String queryText;
  final StudentQuery? parsedQuery;
  final RoutineDay? selectedDay;
  final RoutineDay? today;
  final StudentSummary? summary;
  final List<TimelineItem> timeline;
  final Map<ClassBlock, ClassStatus> classStatuses;
  final NowNextHint? nowNext;
  final List<String> suggestions;
  final bool hasMatches;
  final RoutineMeta? meta;
  final bool invalidQuery;
  final bool restored;
  final List<ClassReminder> reminders;
  final StudentProfile profile;
  final bool isLoading;
  final String? errorMessage;

  RoutineDay get resolvedSelectedDay =>
      selectedDay ?? RoutineQueries.todayOrSaturday();

  RoutineDay get resolvedToday => today ?? RoutineQueries.todayOrSaturday();

  int? reminderMinutesFor(ClassBlock block) {
    final id = ClassReminderId.fromBlock(block);
    for (final reminder in reminders) {
      if (reminder.id == id) return reminder.minutesBefore;
    }
    return null;
  }

  StudentUiState copyWith({
    String? queryText,
    StudentQuery? parsedQuery,
    bool clearParsedQuery = false,
    RoutineDay? selectedDay,
    RoutineDay? today,
    StudentSummary? summary,
    bool clearSummary = false,
    List<TimelineItem>? timeline,
    Map<ClassBlock, ClassStatus>? classStatuses,
    NowNextHint? nowNext,
    bool clearNowNext = false,
    List<String>? suggestions,
    bool? hasMatches,
    RoutineMeta? meta,
    bool? invalidQuery,
    bool? restored,
    List<ClassReminder>? reminders,
    StudentProfile? profile,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StudentUiState(
      queryText: queryText ?? this.queryText,
      parsedQuery: clearParsedQuery
          ? parsedQuery
          : (parsedQuery ?? this.parsedQuery),
      selectedDay: selectedDay ?? this.selectedDay,
      today: today ?? this.today,
      summary: clearSummary ? summary : (summary ?? this.summary),
      timeline: timeline ?? this.timeline,
      classStatuses: classStatuses ?? this.classStatuses,
      nowNext: clearNowNext ? nowNext : (nowNext ?? this.nowNext),
      suggestions: suggestions ?? this.suggestions,
      hasMatches: hasMatches ?? this.hasMatches,
      meta: meta ?? this.meta,
      invalidQuery: invalidQuery ?? this.invalidQuery,
      restored: restored ?? this.restored,
      reminders: reminders ?? this.reminders,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? errorMessage : (errorMessage ?? this.errorMessage),
    );
  }
}

class StudentViewModel extends ChangeNotifier {
  StudentViewModel({
    required this.live,
    required this.cache,
    required this.scheduler,
  }) : _state = StudentUiState(
         selectedDay: RoutineQueries.todayOrSaturday(),
         today: RoutineQueries.todayOrSaturday(),
         meta: live.meta,
         reminders: cache.reminders,
         profile: cache.profile,
       ) {
    _boot();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) => rebuild());
  }

  final LiveRoutineRepository live;
  final StudentCache cache;
  final ClassReminderScheduler scheduler;

  StudentUiState _state;
  List<ClassSlot> _slots = const [];
  Timer? _saveJob;
  Timer? _tick;
  Timer? _suggestJob;
  Timer? _fetchJob;
  int _fetchSeq = 0;

  StudentUiState get state => _state;

  Future<void> _boot() async {
    await live.syncVersion();
    _state = _state.copyWith(meta: live.meta);
    final saved = cache.lastQuery();
    if (saved.isNotEmpty) {
      applyQuery(saved, persist: false, fetchNow: true);
    }
    await scheduler.sync(cache.reminders);
    _state = _state.copyWith(
      restored: true,
      reminders: cache.reminders,
      profile: cache.profile,
      meta: live.meta,
    );
    notifyListeners();
  }

  Future<void> completeOnboarding(StudentProfile profile) async {
    await cache.completeOnboarding(profile);
    _state = _state.copyWith(profile: cache.profile);
    notifyListeners();
  }

  void onQueryChange(String value) => applyQuery(value, persist: true);

  void onChipSelected(String chip) {
    applyQuery(chip, persist: true, fetchNow: true);
  }

  void onDaySelected(RoutineDay day) {
    _state = _state.copyWith(selectedDay: day);
    rebuild();
  }

  void applyQuery(
    String value, {
    required bool persist,
    bool fetchNow = false,
  }) {
    final parsed = StudentQuery.parse(value);
    _state = _state.copyWith(
      queryText: value,
      parsedQuery: parsed,
      clearParsedQuery: parsed == null,
      invalidQuery: value.trim().isNotEmpty && parsed == null,
      clearError: true,
      errorMessage: null,
    );
    if (parsed == null || parsed.section.isEmpty) {
      _slots = const [];
      rebuild();
    }
    _scheduleSuggestions(value);
    if (parsed != null && parsed.section.isNotEmpty) {
      if (fetchNow) {
        _loadSchedule(parsed);
      } else {
        _fetchJob?.cancel();
        _fetchJob = Timer(const Duration(milliseconds: 400), () {
          _loadSchedule(parsed);
        });
      }
      if (persist) {
        _saveJob?.cancel();
        _saveJob = Timer(const Duration(milliseconds: 350), () {
          cache.saveQuery(parsed.label);
        });
      }
    } else {
      _fetchJob?.cancel();
    }
  }

  void _scheduleSuggestions(String value) {
    _suggestJob?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _state = _state.copyWith(suggestions: const []);
      notifyListeners();
      return;
    }
    _suggestJob = Timer(const Duration(milliseconds: 250), () {
      _loadSuggestions(trimmed);
    });
  }

  Future<void> _loadSuggestions(String query) async {
    try {
      final suggestions = await live.autocompleteStudent(query);
      if (_state.queryText.trim() != query) return;
      _state = _state.copyWith(suggestions: suggestions);
      notifyListeners();
    } on RoutineApiException {
      if (_state.queryText.trim() != query) return;
      _state = _state.copyWith(suggestions: const []);
      notifyListeners();
    }
  }

  Future<void> _loadSchedule(StudentQuery parsed) async {
    final seq = ++_fetchSeq;
    _state = _state.copyWith(isLoading: true, clearError: true, errorMessage: null);
    notifyListeners();
    try {
      final slots = await live.studentSchedule(parsed.label);
      if (seq != _fetchSeq) return;
      _slots = slots;
      _state = _state.copyWith(
        isLoading: false,
        meta: live.meta,
      );
      rebuild();
    } on RoutineApiException catch (error) {
      if (seq != _fetchSeq) return;
      _slots = const [];
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      );
      rebuild();
    }
  }

  Future<TeacherInfo?> getTeacherInfo(String initial) {
    return live.teacherInfo(initial);
  }

  Future<void> downloadSchedule() async {
    final parsed = _state.parsedQuery;
    if (parsed == null) return;
    final matched = RoutineQueries.forStudent(_slots, parsed);
    await PdfExporter.shareSchedule(
      queryLabel: parsed.label,
      week: RoutineQueries.weeklyBlocks(matched),
    );
  }

  Future<bool> onReminderPicked(ClassBlock block, int? minutes) async {
    if (minutes == null) {
      await cache.removeReminder(ClassReminderId.fromBlock(block));
    } else {
      final allowed = await scheduler.requestPermission();
      if (!allowed) return false;
      await cache.upsertReminder(ClassReminder.fromBlock(block, minutes));
    }
    await scheduler.sync(cache.reminders);
    _state = _state.copyWith(reminders: cache.reminders);
    notifyListeners();
    return true;
  }

  void rebuild() {
    final today = RoutineQueries.todayOrSaturday();
    final parsed = _state.parsedQuery;
    if (parsed == null || parsed.section.isEmpty) {
      _state = _state.copyWith(
        today: today,
        summary: null,
        clearSummary: true,
        timeline: const [],
        classStatuses: const {},
        nowNext: null,
        clearNowNext: true,
        hasMatches: false,
      );
      notifyListeners();
      return;
    }
    final matched = RoutineQueries.forStudent(_slots, parsed);
    final selectedDay = _state.resolvedSelectedDay;
    final daySlots = matched.where((slot) => slot.day == selectedDay).toList();
    _state = _state.copyWith(
      today: today,
      summary: RoutineQueries.summary(matched, parsed, live.meta.version),
      timeline: RoutineQueries.timeline(daySlots),
      classStatuses: RoutineQueries.statusesForDay(
        daySlots,
        selectedDay,
        today: today,
      ),
      nowNext: RoutineQueries.nowOrNext(daySlots, selectedDay, today: today),
      clearNowNext: true,
      hasMatches: matched.isNotEmpty,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _saveJob?.cancel();
    _tick?.cancel();
    _suggestJob?.cancel();
    _fetchJob?.cancel();
    super.dispose();
  }
}
