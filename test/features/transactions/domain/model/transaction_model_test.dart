import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionModel', () {
    final testCategory = Category(
      id: 'cat-123',
      name: 'Food',
      emoji: '🍔',
      color: 'ff5733',
      transactionType: TransactionType.expense,
    );

    final testDate = DateTime(2025, 1, 15, 10, 30);

    group('constructor', () {
      test('creates transaction with all fields', () {
        final transaction = TransactionModel(
          id: 'tx-123',
          title: 'Lunch',
          description: 'Lunch at restaurant',
          amount: 25.50,
          date: testDate,
          invoiceFile: 'path/to/invoice.pdf',
          category: testCategory,
          transactionType: TransactionType.expense,
        );

        expect(transaction.id, 'tx-123');
        expect(transaction.title, 'Lunch');
        expect(transaction.description, 'Lunch at restaurant');
        expect(transaction.amount, 25.50);
        expect(transaction.date, testDate);
        expect(transaction.invoiceFile, 'path/to/invoice.pdf');
        expect(transaction.category, testCategory);
        expect(transaction.transactionType, TransactionType.expense);
      });

      test('creates transaction with null fields', () {
        final transaction = TransactionModel();

        expect(transaction.id, null);
        expect(transaction.title, null);
        expect(transaction.description, null);
        expect(transaction.amount, null);
        expect(transaction.date, null);
        expect(transaction.invoiceFile, null);
        expect(transaction.category, null);
        expect(transaction.transactionType, null);
      });
    });

    group('fromMap', () {
      test('parses complete map correctly', () {
        final map = {
          'id': 'tx-456',
          'title': 'Grocery Shopping',
          'description': 'Weekly groceries',
          'amount': 150.75,
          'date': '2025-01-20T14:30:00.000Z',
          'invoice_file': 'invoices/grocery.jpg',
          'transaction_type': 'expense',
          'categories': {
            'id': 'cat-grocery',
            'name': 'Groceries',
            'emoji': '🛒',
            'color': '00ff00',
            'transaction_type': 'expense',
          },
        };

        final transaction = TransactionModel.fromMap(map);

        expect(transaction.id, 'tx-456');
        expect(transaction.title, 'Grocery Shopping');
        expect(transaction.description, 'Weekly groceries');
        expect(transaction.amount, 150.75);
        expect(transaction.date, isNotNull);
        expect(transaction.invoiceFile, 'invoices/grocery.jpg');
        expect(transaction.transactionType, TransactionType.expense);
        expect(transaction.category, isNotNull);
        expect(transaction.category!.name, 'Groceries');
      });

      test('handles integer amount', () {
        final map = {
          'id': 'tx-789',
          'amount': 100,
        };

        final transaction = TransactionModel.fromMap(map);
        expect(transaction.amount, 100.0);
      });

      test('handles missing optional fields', () {
        final map = <String, dynamic>{
          'id': 'tx-minimal',
        };

        final transaction = TransactionModel.fromMap(map);

        expect(transaction.id, 'tx-minimal');
        expect(transaction.title, null);
        expect(transaction.description, null);
        expect(transaction.amount, null);
        expect(transaction.date, null);
        expect(transaction.invoiceFile, null);
        expect(transaction.category, null);
        expect(transaction.transactionType, null);
      });

      test('handles income transaction type', () {
        final map = {
          'id': 'tx-income',
          'transaction_type': 'income',
        };

        final transaction = TransactionModel.fromMap(map);
        expect(transaction.transactionType, TransactionType.income);
      });

      test('converts date to local time', () {
        final utcDate = '2025-01-20T12:00:00.000Z';
        final map = {
          'id': 'tx-date',
          'date': utcDate,
        };

        final transaction = TransactionModel.fromMap(map);
        expect(transaction.date!.isUtc, false);
      });
    });

    group('toMap', () {
      test('converts to map correctly', () {
        final transaction = TransactionModel(
          id: 'tx-to-map',
          title: 'Test Transaction',
          description: 'Test description',
          amount: 99.99,
          date: testDate,
          invoiceFile: 'test/invoice.pdf',
          category: testCategory,
          transactionType: TransactionType.expense,
        );

        final map = transaction.toMap();

        expect(map['id'], 'tx-to-map');
        expect(map['title'], 'Test Transaction');
        expect(map['description'], 'Test description');
        expect(map['amount'], 99.99);
        expect(map['date'], testDate.toIso8601String());
        expect(map['invoice_file'], 'test/invoice.pdf');
        expect(map['transaction_type'], 'expense');
        expect(map['categories'], isNotNull);
        expect(map['categories']['name'], 'Food');
      });

      test('converts null fields correctly', () {
        final transaction = TransactionModel();

        final map = transaction.toMap();

        expect(map['id'], null);
        expect(map['title'], null);
        expect(map['description'], null);
        expect(map['amount'], null);
        expect(map['date'], null);
        expect(map['invoice_file'], null);
        expect(map['categories'], null);
        expect(map['transaction_type'], null);
      });
    });

    group('copyWith', () {
      test('copies with updated values', () {
        final original = TransactionModel(
          id: 'tx-original',
          title: 'Original Title',
          description: 'Original description',
          amount: 50.0,
          date: testDate,
          transactionType: TransactionType.expense,
        );

        final copied = original.copyWith(
          title: 'Updated Title',
          amount: 75.0,
        );

        expect(copied.id, 'tx-original'); // unchanged
        expect(copied.title, 'Updated Title'); // changed
        expect(copied.description, 'Original description'); // unchanged
        expect(copied.amount, 75.0); // changed
        expect(copied.date, testDate); // unchanged
        expect(copied.transactionType, TransactionType.expense); // unchanged
      });

      test('copies without changes returns equivalent object', () {
        final original = TransactionModel(
          id: 'tx-copy',
          title: 'Test',
          amount: 100.0,
        );

        final copied = original.copyWith();

        expect(copied.id, original.id);
        expect(copied.title, original.title);
        expect(copied.amount, original.amount);
      });

      test('can change transaction type', () {
        final expense = TransactionModel(
          id: 'tx-type',
          transactionType: TransactionType.expense,
        );

        final income = expense.copyWith(
          transactionType: TransactionType.income,
        );

        expect(income.transactionType, TransactionType.income);
      });
    });

    group('round trip', () {
      test('fromMap -> toMap preserves essential data', () {
        final originalMap = {
          'id': 'tx-roundtrip',
          'title': 'Round Trip Test',
          'description': 'Testing serialization',
          'amount': 123.45,
          'date': '2025-01-22T08:00:00.000',
          'invoice_file': 'test.pdf',
          'transaction_type': 'income',
          'categories': {
            'id': 'cat-test',
            'name': 'Test Category',
            'emoji': '🧪',
            'color': 'abcdef',
            'transaction_type': 'income',
          },
        };

        final transaction = TransactionModel.fromMap(originalMap);
        final resultMap = transaction.toMap();

        expect(resultMap['id'], originalMap['id']);
        expect(resultMap['title'], originalMap['title']);
        expect(resultMap['description'], originalMap['description']);
        expect(resultMap['amount'], originalMap['amount']);
        expect(resultMap['invoice_file'], originalMap['invoice_file']);
        expect(resultMap['transaction_type'], originalMap['transaction_type']);
        
        final originalCategories = originalMap['categories'] as Map<String, dynamic>;
        final resultCategories = resultMap['categories'] as Map<String, dynamic>;
        expect(resultCategories['name'], originalCategories['name']);
      });
    });
  });
}
