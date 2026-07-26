import 'package:budgets/core/ui/amount_visibility_controller.dart';
import 'package:budgets/core/ui/amount_visibility_scope.dart';
import 'package:budgets/core/ui/app_responsive_scope.dart';
import 'package:budgets/features/ai_entry/presentation/view_models/ai_entry_view_model.dart';
import 'package:budgets/features/home/presentation/widgets/home_collapsing_surface.dart';
import 'package:budgets/features/home/presentation/widgets/home_dashboard.dart';
import 'package:budgets/features/notifications/presentation/view_models/finance_notification_view_model.dart';
import 'package:budgets/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ai_entry/support/fake_ai_entry_repository.dart';
import '../../../notifications/support/fake_finance_notification_repository.dart';
import '../../support/home_test_window.dart';

void main() {
  testWidgets('fills the available tablet and landscape width', (tester) async {
    useTabletWindow(tester);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(HomeCollapsingSurface)).width,
      900,
    );
  });

  testWidgets('continues to fill the portrait phone width', (tester) async {
    usePhoneWindow(tester);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(HomeCollapsingSurface)).width,
      400,
    );
  });
}

Widget _app() {
  final visibility = AmountVisibilityController();
  final viewModel = AiEntryViewModel(
    FakeAiEntryRepository(),
    DateTime(2026, 7, 25),
  );
  final notifications = FinanceNotificationViewModel(
    FakeFinanceNotificationRepository(),
  );
  addTearDown(visibility.dispose);
  addTearDown(viewModel.dispose);
  addTearDown(notifications.dispose);
  return AmountVisibilityScope(
    controller: visibility,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AppResponsiveScope(
        child: Scaffold(
          body: HomeDashboard(
            today: DateTime(2026, 7, 25),
            drawerProgress: const AlwaysStoppedAnimation(0.0),
            onMenuPressed: () {},
            viewModel: viewModel,
            notificationViewModel: notifications,
            onNotificationsPressed: () {},
            onFinanceChanged: () async {},
          ),
        ),
      ),
    ),
  );
}
