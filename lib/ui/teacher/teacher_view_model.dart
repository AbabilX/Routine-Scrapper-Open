import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/api/live_routine_repository.dart';
import '../../data/api/routine_api_exception.dart';
import '../../domain/model/class_slot.dart';
import '../../domain/model/routine_meta.dart';

class TeacherViewModel extends ChangeNotifier {
  TeacherViewModel({required this.live});

  final LiveRoutineRepository live;

  String _query = '';
  List<ClassSlot> _slots = const [];
  bool _isLoading = false;
  String? _error;
  Timer? _fetchJob;
  int _seq = 0;

  String get query => _query;
  List<ClassSlot> get slots => _slots;
  bool get isLoading => _isLoading;
  String? get error => _error;
  RoutineMeta get meta => live.meta;

  void onQueryChanged(String value) {
    _query = value.trim().toUpperCase();
    _error = null;
    _fetchJob?.cancel();
    if (_query.isEmpty) {
      _slots = const [];
      _isLoading = false;
      notifyListeners();
      return;
    }
    _fetchJob = Timer(const Duration(milliseconds: 400), () {
      _load(_query);
    });
    notifyListeners();
  }

  void clear() => onQueryChanged('');

  Future<void> _load(String initials) async {
    final seq = ++_seq;
    _isLoading = true;
    notifyListeners();
    try {
      final slots = await live.teacherSchedule(initials);
      if (seq != _seq) return;
      _slots = slots;
      _isLoading = false;
      _error = null;
      notifyListeners();
    } on RoutineApiException catch (error) {
      if (seq != _seq) return;
      _slots = const [];
      _isLoading = false;
      _error = error.message;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _fetchJob?.cancel();
    super.dispose();
  }
}
