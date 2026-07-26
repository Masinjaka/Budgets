import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/features/envelopes/domain/repositories/envelope_repository.dart';
import 'package:budgets/features/envelopes/presentation/pages/envelope_page.dart';
import 'package:budgets/features/feedback/presentation/services/sentry_feedback_launcher.dart';
import 'package:budgets/features/notifications/domain/models/finance_notification.dart';
import 'package:budgets/features/notifications/presentation/pages/finance_notifications_page.dart';
import 'package:budgets/features/notifications/presentation/view_models/finance_notification_view_model.dart';
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
    this.shouldRunOnReturn,
    this.onDataDeleted,
    this.envelopeRepository,
    this.statsRepository,
    this.currencyState,
  });

  final BuildContext context;
  final DateTime selectedDate;
  final VoidCallback closeDrawer;
  final Future<void> Function()? onReturn;
  final bool Function()? shouldRunOnReturn;
  final VoidCallback? onDataDeleted;
  final EnvelopeRepository? envelopeRepository;
  final MonthlyStatsRepository? statsRepository;
  final CurrencyState? currencyState;

  Future<void> openSettings() => _push(
        SettingsWithBackPage(onDataDeleted: onDataDeleted),
      );

  void openPlans() => _push(const PlanPage());

  void openFeedback() => SentryFeedbackLauncher.show(
        context,
        beforeShow: closeDrawer,
      );

  void openEnvelopes() => _push(
        EnvelopePage(
          initialMonth: selectedDate,
          repository: envelopeRepository,
          displayCurrency: currencyState,
        ),
      );

  void openNotifications(FinanceNotificationViewModel viewModel) => _push(
        FinanceNotificationsPage(
          viewModel: viewModel,
          onSelected: _openNotificationEnvelope,
        ),
      );

  void openStats() => _push(
        FinanceStatsPage(
          initialMonth: selectedDate,
          repository: statsRepository,
          displayCurrency: currencyState,
        ),
      );

  Future<void> _openNotificationEnvelope(
    BuildContext notificationContext,
    FinanceNotification notification,
  ) {
    return Navigator.of(notificationContext).push(
      MaterialPageRoute<void>(
        builder: (_) => EnvelopePage(
          initialMonth: notification.periodMonth,
          initialEnvelopeId: notification.envelopeId,
          repository: envelopeRepository,
          displayCurrency: currencyState,
        ),
      ),
    );
  }

  Future<void> _push(Widget page) async {
    closeDrawer();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
    if (shouldRunOnReturn?.call() ?? true) {
      await onReturn?.call();
    }
  }
}
