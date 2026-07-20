import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a Supabase transaction and nested category', () {
    final entry = FinanceEntry.fromJson({
      'id': 'entry-id',
      'title': 'Lunch',
      'description': 'Team lunch',
      'amount': 24000,
      'date': '2026-07-17T09:30:00.000Z',
      'transaction_type': 'expense',
      'currency_code': 'MGA',
      'categories': {
        'name': 'Foods & Drinks',
        'icon_key': 'food',
        'emoji': '🍔',
      },
    });

    expect(entry.title, 'Lunch');
    expect(entry.categoryName, 'Foods & Drinks');
    expect(entry.amount, 24000);
    expect(entry.iconKey, 'food');
    expect(entry.isExpense, isTrue);
  });
}
