import 'package:budgets/features/envelopes/domain/repositories/envelope_repository.dart';
import 'package:budgets/features/envelopes/presentation/pages/envelope_page.dart';
import 'package:budgets/features/plans/presentation/pages/plan_page.dart';
import 'package:budgets/features/settings/presentation/pages/settings_with_back_page.dart';
import 'package:budgets/features/stats/domain/repositories/monthly_stats_repository.dart';
import 'package:budgets/features/stats/presentation/pages/finance_stats_page.dart';
import 'package:flutter/material.dart';

class DrawerDestinationNavigator {
  const DrawerDestinationNavigator({
    required this.context,
    required this.selectedDate,
    required this.closeDrawer,
    this.onReturn,
    this.envelopeRepository,
    this.statsRepository,
  });

  final BuildContext context;
  final DateTime selectedDate;
  final VoidCallback closeDrawer;
  final Future<void> Function()? onReturn;
  final EnvelopeRepository? envelopeRepository;
  final MonthlyStatsRepository? statsRepository;

  void openSettings() => _push(const SettingsWithBackPage());

  void openPlans() => _push(const PlanPage());

  void openEnvelopes() => _push(
        EnvelopePage(
          initialMonth: selectedDate,
          repository: envelopeRepository,
        ),
      );

  void openStats() => _push(
        FinanceStatsPage(
          initialMonth: selectedDate,
          repository: statsRepository,
        ),
      );

  Future<void> _push(Widget page) async {
    closeDrawer();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
    await onReturn?.call();
  }
}
