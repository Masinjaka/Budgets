import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/stats/data/repositories/supabase_monthly_stats_repository.dart';
import 'package:budgets/features/stats/data/services/monthly_stats_service.dart';
import 'package:budgets/features/stats/domain/repositories/monthly_stats_repository.dart';
import 'package:budgets/features/stats/presentation/view_models/monthly_stats_view_model.dart';
import 'package:budgets/features/stats/presentation/widgets/category_spending_list.dart';
import 'package:budgets/features/stats/presentation/widgets/monthly_spending_chart.dart';
import 'package:budgets/features/stats/presentation/widgets/stats_metric_card.dart';
import 'package:budgets/features/stats/presentation/widgets/stats_overview_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinanceStatsPage extends StatefulWidget {
  const FinanceStatsPage({this.repository, this.initialMonth, super.key});

  final MonthlyStatsRepository? repository;
  final DateTime? initialMonth;

  @override
  State<FinanceStatsPage> createState() => _FinanceStatsPageState();
}

class _FinanceStatsPageState extends State<FinanceStatsPage> {
  late final MonthlyStatsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final repository = widget.repository ??
        SupabaseMonthlyStatsRepository(
          MonthlyStatsService(Supabase.instance.client),
        );
    _viewModel = MonthlyStatsViewModel(
      repository,
      widget.initialMonth ?? DateTime.now(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      await _viewModel.load();
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    }
  }

  Future<void> _changeMonth(int offset) async {
    try {
      await _viewModel.changeMonth(offset);
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFEFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFEFE),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Stats',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final stats = _viewModel.stats;
          if (stats == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 30),
              children: [
                _monthSelector(),
                const SizedBox(height: 18),
                StatsOverviewCard(stats: stats),
                const SizedBox(height: 14),
                Row(
                  children: [
                    StatsMetricCard(
                      label: 'Transactions',
                      value: '${stats.transactionCount}',
                      icon: Icons.receipt_long_outlined,
                    ),
                    const SizedBox(width: 11),
                    StatsMetricCard(
                      label: 'Average / day',
                      value: formatAmountWithCurrency(
                        stats.averageDailySpend,
                        stats.currencyCode,
                      ),
                      icon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(width: 11),
                    StatsMetricCard(
                      label: 'Largest expense',
                      value: formatAmountWithCurrency(
                        stats.largestExpense,
                        stats.currencyCode,
                      ),
                      icon: Icons.arrow_outward_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                MonthlySpendingChart(values: stats.dailyExpenses),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Top spending',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        _changeLabel(stats.expenseChange),
                        maxLines: 2,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: stats.expenseChange > 0
                              ? const Color(0xFFD84A3A)
                              : const Color(0xFF3D9360),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CategorySpendingList(
                  categories: stats.expenseCategories,
                  total: stats.expenses,
                  currencyCode: stats.currencyCode,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _monthSelector() {
    final now = DateTime.now();
    final canGoForward = _viewModel.month.isBefore(
      DateTime(now.year, now.month),
    );
    return Row(
      children: [
        IconButton(
          onPressed: () => _changeMonth(-1),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Text(
            DateFormat('MMMM yyyy').format(_viewModel.month),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          onPressed: canGoForward ? () => _changeMonth(1) : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }

  String _changeLabel(double change) {
    final direction = change > 0 ? 'more' : 'less';
    return '${change.abs().toStringAsFixed(0)}% $direction than last month';
  }
}
