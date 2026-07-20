import 'package:budgets/features/home/presentation/widgets/multi_wallet_consent_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('returns consent when all-wallet funding is accepted',
      (tester) async {
    bool? result;
    await tester.pumpWidget(_ConsentHarness(
      onResult: (value) => result = value,
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Use multiple wallets?'), findsOneWidget);
    expect(find.textContaining('Drala can combine wallet balances'),
        findsOneWidget);

    await tester.tap(find.text('Use all wallets'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('returns no consent when combined funding is declined',
      (tester) async {
    bool? result;
    await tester.pumpWidget(_ConsentHarness(
      onResult: (value) => result = value,
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });
}

class _ConsentHarness extends StatelessWidget {
  const _ConsentHarness({required this.onResult});

  final ValueChanged<bool> onResult;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final result = await MultiWalletConsentSheet.show(
                context,
                requiredAmount: 10000,
                availableAmount: 12000,
              );
              onResult(result);
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }
}
