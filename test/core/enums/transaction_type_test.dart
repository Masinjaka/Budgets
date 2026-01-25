import 'package:budgets/core/enums/transaction_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionType', () {
    group('values', () {
      test('has expense and income values', () {
        expect(TransactionType.values.length, 2);
        expect(TransactionType.values, contains(TransactionType.expense));
        expect(TransactionType.values, contains(TransactionType.income));
      });

      test('expense has correct string value', () {
        expect(TransactionType.expense.value, 'expense');
      });

      test('income has correct string value', () {
        expect(TransactionType.income.value, 'income');
      });
    });

    group('fromValue', () {
      test('returns expense for "expense"', () {
        expect(TransactionType.fromValue('expense'), TransactionType.expense);
      });

      test('returns income for "income"', () {
        expect(TransactionType.fromValue('income'), TransactionType.income);
      });

      test('is case insensitive', () {
        expect(TransactionType.fromValue('EXPENSE'), TransactionType.expense);
        expect(TransactionType.fromValue('Expense'), TransactionType.expense);
        expect(TransactionType.fromValue('INCOME'), TransactionType.income);
        expect(TransactionType.fromValue('Income'), TransactionType.income);
      });

      test('returns null for invalid value', () {
        expect(TransactionType.fromValue('invalid'), null);
        expect(TransactionType.fromValue(''), null);
        expect(TransactionType.fromValue('transfer'), null);
      });

      test('returns null for null input', () {
        expect(TransactionType.fromValue(null), null);
      });
    });

    group('displayName', () {
      test('expense displays as Dépense', () {
        expect(TransactionType.expense.displayName, 'Dépense');
      });

      test('income displays as Revenu', () {
        expect(TransactionType.income.displayName, 'Revenu');
      });
    });
  });
}
