import 'package:budgets/features/stats/domain/models/monthly_stats.dart';
import 'package:budgets/features/stats/presentation/widgets/stats_metrics_grid.dart';
import 'package:budgets/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the reference metrics in French without overflow',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SizedBox(width: 390, child: StatsMetricsGrid(stats: _stats)),
        ),
      ),
    );

    expect(find.text('Solde net du mois'), findsOneWidget);
    expect(find.text('Dépenses'), findsOneWidget);
    expect(find.text('Revenus'), findsOneWidget);
    expect(find.byKey(const Key('stats-net-card')), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
    expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

}

const _stats = MonthlyStats(
  income: 3000000,
  expenses: 2000000,
  transactionCount: 22,
  largestExpense: 400000,
  previousExpenses: 1000000,
  expenseCategories: [],
  dailyExpenses: [],
  currencyCode: 'MGA',
);
