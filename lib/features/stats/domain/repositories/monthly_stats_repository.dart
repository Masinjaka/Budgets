import 'package:budgets/features/stats/domain/models/monthly_stats.dart';

abstract interface class MonthlyStatsRepository {
  Future<MonthlyStats> statsForMonth(DateTime month);
}
