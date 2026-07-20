import 'package:budgets/features/home/presentation/view_models/activity_calendar_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ai_entry/support/fake_ai_entry_repository.dart';

void main() {
  test('loads activity dates once per calendar month', () async {
    final repository = FakeAiEntryRepository()
      ..activityDates = {DateTime(2026, 7, 12)};
    final viewModel = ActivityCalendarViewModel(repository);

    await viewModel.loadMonth(DateTime(2026, 7, 20));
    await viewModel.loadMonth(DateTime(2026, 7, 1));

    expect(viewModel.activityDates, {DateTime(2026, 7, 12)});
    expect(repository.requestedActivityMonth, DateTime(2026, 7));
  });

  test('marks a newly created activity without another database query', () {
    final viewModel = ActivityCalendarViewModel(FakeAiEntryRepository());

    viewModel.markActivity(DateTime(2026, 7, 15, 18));

    expect(viewModel.activityDates, {DateTime(2026, 7, 15)});
  });
}
