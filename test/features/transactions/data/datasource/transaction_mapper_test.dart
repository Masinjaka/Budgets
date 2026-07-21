import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/transactions/data/datasource/transaction_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionMapper', () {
    test('maps a nested Supabase category and converts the date to local time',
        () {
      const mapper = TransactionMapper();

      final transaction = mapper.fromSupabase({
        'id': 'transaction-id',
        'title': 'Lunch',
        'description': 'Burger',
        'amount': 24000,
        'date': '2026-07-17T09:30:00.000Z',
        'invoice_file': 'https://example.test/receipt.pdf',
        'transaction_type': 'expense',
        'category': {
          'id': 'category-id',
          'name': 'Food',
          'emoji': '🍔',
          'color': 'FF000000',
        },
      });

      expect(transaction.id, 'transaction-id');
      expect(transaction.amount, 24000);
      expect(transaction.transactionType, TransactionType.expense);
      expect(transaction.category?.id, 'category-id');
      expect(transaction.category?.name, 'Food');
      expect(transaction.date?.isUtc, isFalse);
    });

    test('supports transactions without a category', () {
      const mapper = TransactionMapper();

      final transaction = mapper.fromSupabase({
        'id': 'transaction-id',
        'amount': 5000,
        'transaction_type': 'income',
        'category': null,
      });

      expect(transaction.transactionType, TransactionType.income);
      expect(transaction.category, isNull);
      expect(transaction.date, isNull);
    });
  });
}
