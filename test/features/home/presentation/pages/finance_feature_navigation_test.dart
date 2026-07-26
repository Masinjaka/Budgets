import 'package:budgets/features/envelopes/domain/models/envelope.dart';
import 'package:budgets/features/envelopes/domain/models/envelope_category.dart';
import 'package:budgets/features/envelopes/domain/repositories/envelope_repository.dart';
import 'package:budgets/features/envelopes/presentation/pages/envelope_page.dart';
import 'package:budgets/features/home/presentation/pages/chat_home_page.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:budgets/features/stats/presentation/pages/finance_stats_page.dart';
import 'package:budgets/features/stats/domain/models/monthly_stats.dart';
import 'package:budgets/features/stats/domain/repositories/monthly_stats_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/home_test_window.dart';

class _EnvelopeRepository implements EnvelopeRepository {
  @override
  Future<List<Envelope>> envelopesForMonth(DateTime month) async => [];

  @override
  Future<List<EnvelopeCategory>> expenseCategories() async => [];

  @override
  Future<List<WalletSummary>> wallets() async => [];

  @override
  Future<void> addEnvelope({
    required String name,
    required String categoryId,
    required int amount,
    required DateTime month,
    String? walletId,
  }) async {}

  @override
  Future<void> deleteEnvelope(String id) async {}
}

class _StatsRepository implements MonthlyStatsRepository {
  @override
  Future<MonthlyStats> statsForMonth(DateTime month) async {
    return const MonthlyStats(
      income: 0,
      expenses: 0,
      transactionCount: 0,
      largestExpense: 0,
      previousExpenses: 0,
      expenseCategories: [],
      dailyExpenses: [],
      currencyCode: 'MGA',
    );
  }
}

void main() {
  testWidgets('Envelope drawer item opens envelope page', (tester) async {
    usePhoneWindow(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: ChatHomePage(
          today: DateTime(2026, 7, 16),
          envelopeRepository: _EnvelopeRepository(),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drawer-envelope-button')));
    await tester.pumpAndSettle();

    expect(find.byType(EnvelopePage), findsOneWidget);
    expect(find.text('Envelope'), findsOneWidget);
  });

  testWidgets('Stats drawer item opens new stats page', (tester) async {
    usePhoneWindow(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: ChatHomePage(
          today: DateTime(2026, 7, 16),
          statsRepository: _StatsRepository(),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drawer-stats-button')));
    await tester.pumpAndSettle();

    expect(find.byType(FinanceStatsPage), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
  });
}
