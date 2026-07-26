import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/ui/month_navigation.dart';
import 'package:budgets/features/stats/data/repositories/supabase_monthly_stats_repository.dart';
import 'package:budgets/features/stats/data/services/monthly_stats_service.dart';
import 'package:budgets/features/stats/domain/repositories/monthly_stats_repository.dart';
import 'package:budgets/features/stats/presentation/view_models/monthly_stats_view_model.dart';
import 'package:budgets/features/stats/presentation/widgets/monthly_spending_chart.dart';
import 'package:budgets/features/stats/presentation/widgets/stats_metrics_grid.dart';
import 'package:budgets/features/stats/presentation/widgets/stats_top_spending_card.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinanceStatsPage extends StatefulWidget {
  const FinanceStatsPage({
    this.repository,
    this.initialMonth,
    this.displayCurrency,
    super.key,
  });

  final MonthlyStatsRepository? repository;
  final DateTime? initialMonth;
  final CurrencyState? displayCurrency;

  @override
  State<FinanceStatsPage> createState() => _FinanceStatsPageState();
}

class _FinanceStatsPageState extends State<FinanceStatsPage> {
  late final MonthlyStatsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MonthlyStatsViewModel(
      widget.repository ??
          SupabaseMonthlyStatsRepository(
            MonthlyStatsService(Supabase.instance.client),
          ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.stats,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 8),
              MonthNavigation(
                month: _viewModel.month,
                onPrevious: () => _changeMonth(-1),
                onNext: () => _changeMonth(1),
                canGoNext: _canGoForward,
              ),
            ],
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final stats = _viewModel.stats;
          if (stats == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return LayoutBuilder(
            builder: (context, constraints) => RefreshIndicator(
              onRefresh: _load,
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: constraints.maxWidth.clamp(0, 760),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
                    children: [
                      StatsMetricsGrid(
                        stats: stats,
                        displayCurrency: widget.displayCurrency,
                      ),
                      const SizedBox(height: 28),
                      MonthlySpendingChart(values: stats.dailyExpenses),
                      const SizedBox(height: 28),
                      StatsTopSpendingCard(
                        stats: stats,
                        displayCurrency: widget.displayCurrency,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool get _canGoForward {
    final now = DateTime.now();
    return _viewModel.month.isBefore(DateTime(now.year, now.month));
  }
}
