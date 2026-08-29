import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/asset_routine_repository.dart';
import '../../data/class_reminder_scheduler.dart';
import '../../data/pdf_exporter.dart';
import '../../data/student_cache.dart';
import '../../domain/model/class_reminder.dart';
import '../../domain/model/class_status.dart';
import '../../domain/model/routine_day.dart';
import '../../domain/model/routine_meta.dart';
import '../../domain/model/student_summary.dart';
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
  }) {
    return StudentUiState(
      queryText: queryText ?? this.queryText,
      parsedQuery: clearParsedQuery ? parsedQuery : (parsedQuery ?? this.parsedQuery),
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
    );
  }
}

class StudentViewModel extends ChangeNotifier {
  StudentViewModel({
    required this.repository,
    required this.cache,
    required this.scheduler,
  }) : _state = StudentUiState(
          selectedDay: RoutineQueries.todayOrSaturday(),
          today: RoutineQueries.todayOrSaturday(),
          meta: repository.meta,
          suggestions: RoutineQueries.suggestChips(repository.slots, ''),
          reminders: cache.reminders,
        ) {
    _restore();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) => rebuild());
  }

  final AssetRoutineRepository repository;
  final StudentCache cache;
  final ClassReminderScheduler scheduler;
  StudentUiState _state;
  Timer? _saveJob;
  Timer? _tick;

  StudentUiState get state => _state;

  Future<void> _restore() async {
    final saved = cache.lastQuery();
    if (saved.isNotEmpty) {
      applyQuery(saved, persist: false);
    }
    await scheduler.sync(cache.reminders);
    _state = _state.copyWith(restored: true, reminders: cache.reminders);
    notifyListeners();
  }

  void onQueryChange(String value) => applyQuery(value, persist: true);

  void onChipSelected(String chip) => applyQuery(chip, persist: true);

  void onDaySelected(RoutineDay day) {
    _state = _state.copyWith(selectedDay: day);
    rebuild();
  }

  void applyQuery(String value, {required bool persist}) {
    final parsed = StudentQuery.parse(value);
    _state = _state.copyWith(
      queryText: value,
      parsedQuery: parsed,
      clearParsedQuery: parsed == null,
      invalidQuery: value.trim().isNotEmpty && parsed == null,
      suggestions: RoutineQueries.suggestChips(repository.slots, value),
    );
    rebuild();
    if (persist && parsed != null) {
      _saveJob?.cancel();
      _saveJob = Timer(const Duration(milliseconds: 350), () {
        cache.saveQuery(parsed.label);
      });
    }
  }

  Future<void> downloadSchedule() async {
    final parsed = _state.parsedQuery;
    if (parsed == null) return;
    final matched = RoutineQueries.forStudent(repository.slots, parsed);
    await PdfExporter.shareSchedule(
      queryLabel: parsed.label,
      meta: repository.meta,
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
    if (parsed == null) {
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
    final matched = RoutineQueries.forStudent(repository.slots, parsed);
    final selectedDay = _state.resolvedSelectedDay;
    final daySlots = matched.where((slot) => slot.day == selectedDay).toList();
    _state = _state.copyWith(
      today: today,
      summary: RoutineQueries.summary(matched, parsed, repository.meta.version),
      timeline: RoutineQueries.timeline(daySlots),
      classStatuses: RoutineQueries.statusesForDay(daySlots, selectedDay, today: today),
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
    super.dispose();
  }
}
