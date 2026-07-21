import 'package:budgets/features/home/domain/models/wallet_funding_choice.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:budgets/features/home/presentation/widgets/wallet_funding_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('offers combined funding when no wallet covers the expense',
      (tester) async {
    WalletFundingChoice? result;
    await tester.pumpWidget(
      _FundingHarness(onResult: (value) => result = value),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Use multiple wallets?'), findsOneWidget);
    await tester.tap(find.text('Use all wallets'));
    await tester.pumpAndSettle();

    expect(result?.useAllWallets, isTrue);
    expect(result?.walletId, isNull);
  });
}

class _FundingHarness extends StatelessWidget {
  const _FundingHarness({required this.onResult});

  final ValueChanged<WalletFundingChoice?> onResult;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final result = await WalletFundingPrompt.show(
                context,
                wallets: const [
                  WalletSummary(
                    id: 'cash',
                    name: 'Cash',
                    balance: 4000,
                    currencyCode: 'MGA',
                    iconKey: 'wallet',
                    isDefault: true,
                  ),
                  WalletSummary(
                    id: 'bank',
                    name: 'Bank',
                    balance: 6000,
                    currencyCode: 'MGA',
                    iconKey: 'bank',
                    isDefault: false,
                  ),
                ],
                requiredAmount: 8000,
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
