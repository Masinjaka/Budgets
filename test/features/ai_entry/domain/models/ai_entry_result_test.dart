import 'package:budgets/features/ai_entry/domain/models/ai_entry_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the committed wallet and total-funds snapshot', () {
    final result = AiEntryResult.fromJson({
      'entries': <Object>[],
      'message': 'Expense added.',
      'remaining': 19,
      'wallets': [
        {
          'id': 'cash',
          'name': 'Cash',
          'balance': 397000,
          'currency_code': 'MGA',
          'icon_key': 'wallet',
          'is_default': true,
        },
      ],
      'total_funds': 397000,
      'model': {
        'provider': 'gemini',
        'name': 'gemini-2.5-flash-lite',
        'billing_tier': 'free',
      },
    });

    expect(result.wallets, hasLength(1));
    expect(result.wallets!.single.balance, 397000);
    expect(result.wallets!.single.isDefault, isTrue);
    expect(result.totalFunds, 397000);
  });
}
