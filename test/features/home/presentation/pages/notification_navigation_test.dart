import 'package:budgets/features/envelopes/domain/models/envelope.dart';
import 'package:budgets/features/envelopes/domain/models/envelope_category.dart';
import 'package:budgets/features/envelopes/domain/repositories/envelope_repository.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:budgets/features/home/presentation/pages/chat_home_page.dart';
import 'package:budgets/features/notifications/domain/models/finance_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ai_entry/support/fake_ai_entry_repository.dart';
import '../../../notifications/support/fake_finance_notification_repository.dart';
import '../../support/home_test_window.dart';

void main() {
  testWidgets('warning opens and reveals its envelope', (tester) async {
    usePhoneWindow(tester);
    final notification = FinanceNotification(
      id: 'warning',
      envelopeId: 'envelope-9',
      envelopeName: 'Envelope 9',
      amount: 500,
      periodMonth: DateTime(2026, 7),
      isRead: false,
      createdAt: DateTime(2026, 7, 26),
    );
    final notifications = FakeFinanceNotificationRepository([notification]);

    await tester.pumpWidget(
      MaterialApp(
        home: ChatHomePage(
          today: DateTime(2026, 7, 26),
          aiEntryRepository: FakeAiEntryRepository(),
          envelopeRepository: _EnvelopeRepository(),
          notificationRepository: notifications,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('notification-warning-badge')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('notification-inbox-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('finance-notification-warning')));
    await tester.pumpAndSettle();

    final target = find.byKey(const Key('envelope-envelope-9'));
    expect(target, findsOneWidget);
    expect(tester.getBottomRight(target).dy, lessThan(900));
    expect(notifications.markedRead, ['warning']);
  });
}

class _EnvelopeRepository implements EnvelopeRepository {
  @override
  Future<List<Envelope>> envelopesForMonth(DateTime month) async {
    return List.generate(
      10,
      (index) => Envelope(
        id: 'envelope-$index',
        name: 'Envelope $index',
        categoryId: 'category-$index',
        categoryName: 'Category $index',
        emoji: '💰',
        color: 'FF9E9E9E',
        amount: 10000,
        spent: index == 9 ? 10500 : 1000,
        currencyCode: 'MGA',
        overspentAmount: index == 9 ? 500 : 0,
      ),
    );
  }

  @override
  Future<List<EnvelopeCategory>> expenseCategories() async => const [];

  @override
  Future<List<WalletSummary>> wallets() async => const [];

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
