import 'package:budgets/features/ai_entry/domain/repositories/ai_entry_repository.dart';
import 'package:flutter/material.dart';

class ActivityCalendarViewModel extends ChangeNotifier {
  ActivityCalendarViewModel(this._repository);

  final AiEntryRepository _repository;
  Set<DateTime> _activityDates = const {};
  final Set<String> _loadedMonths = {};

  Set<DateTime> get activityDates => _activityDates;

  Future<void> loadMonth(DateTime month) async {
    final normalizedMonth = DateTime(month.year, month.month);
    final key = '${normalizedMonth.year}-${normalizedMonth.month}';
    if (_loadedMonths.contains(key)) return;
    late final Set<DateTime> dates;
    try {
      dates = await _repository.activityDatesForMonth(normalizedMonth);
    } catch (_) {
      return;
    }
    _activityDates = Set.unmodifiable({..._activityDates, ...dates});
    _loadedMonths.add(key);
    notifyListeners();
  }

  void markActivity(DateTime date) {
    final normalized = DateUtils.dateOnly(date);
    if (_activityDates.contains(normalized)) return;
    _activityDates = Set.unmodifiable({..._activityDates, normalized});
    notifyListeners();
  }
}
