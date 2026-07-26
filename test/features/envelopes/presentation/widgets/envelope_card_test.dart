import 'package:budgets/features/envelopes/domain/models/envelope.dart';
import 'package:budgets/features/envelopes/presentation/widgets/envelope_card.dart';
import 'package:budgets/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a red warning when an envelope is over budget',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: EnvelopeCard(
            envelope: const Envelope(
              id: 'food',
              name: 'Food',
              categoryId: 'category',
              categoryName: 'Food',
              emoji: '🍔',
              color: 'FFFF9800',
              amount: 100000,
              spent: 125000,
              currencyCode: 'MGA',
              overspentAmount: 25000,
            ),
            onDelete: () {},
          ),
        ),
      ),
    );

    final warning = find.byKey(const Key('envelope-overspend-warning'));
    expect(warning, findsOneWidget);
    expect(find.text('Over budget by 25 000 Ar'), findsOneWidget);
    expect(
      tester
          .widget<Icon>(find.descendant(
            of: warning,
            matching: find.byIcon(Icons.warning_rounded),
          ))
          .color,
      const Color(0xFFD84A3A),
    );
  });
}
