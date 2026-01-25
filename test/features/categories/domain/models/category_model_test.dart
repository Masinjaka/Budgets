import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Category', () {
    group('constructor', () {
      test('creates category with all fields', () {
        final category = Category(
          id: '123',
          name: 'Food',
          emoji: '🍔',
          color: 'ff5733',
          transactionType: TransactionType.expense,
        );

        expect(category.id, '123');
        expect(category.name, 'Food');
        expect(category.emoji, '🍔');
        expect(category.color, 'ff5733');
        expect(category.transactionType, TransactionType.expense);
      });

      test('creates category with null fields', () {
        final category = Category();

        expect(category.id, null);
        expect(category.name, null);
        expect(category.emoji, null);
        expect(category.color, null);
        expect(category.transactionType, null);
      });
    });

    group('fromMap', () {
      test('parses complete map correctly', () {
        final map = {
          'id': 'abc-123',
          'name': 'Groceries',
          'emoji': '🛒',
          'color': '00ff00',
          'transaction_type': 'expense',
        };

        final category = Category.fromMap(map);

        expect(category.id, 'abc-123');
        expect(category.name, 'Groceries');
        expect(category.emoji, '🛒');
        expect(category.color, '00ff00');
        expect(category.transactionType, TransactionType.expense);
      });

      test('handles missing optional fields', () {
        final map = <String, dynamic>{
          'id': 'abc-123',
          'name': 'Salary',
        };

        final category = Category.fromMap(map);

        expect(category.id, 'abc-123');
        expect(category.name, 'Salary');
        expect(category.emoji, null);
        expect(category.color, null);
        expect(category.transactionType, null);
      });

      test('handles income transaction type', () {
        final map = {
          'id': '456',
          'name': 'Salary',
          'transaction_type': 'income',
        };

        final category = Category.fromMap(map);
        expect(category.transactionType, TransactionType.income);
      });

      test('handles null values in map', () {
        final map = <String, dynamic>{
          'id': null,
          'name': null,
          'emoji': null,
          'color': null,
          'transaction_type': null,
        };

        final category = Category.fromMap(map);

        expect(category.id, null);
        expect(category.name, null);
        expect(category.emoji, null);
        expect(category.color, null);
        expect(category.transactionType, null);
      });
    });

    group('toMap', () {
      test('converts to map correctly', () {
        final category = Category(
          id: 'xyz-789',
          name: 'Entertainment',
          emoji: '🎬',
          color: 'ff00ff',
          transactionType: TransactionType.expense,
        );

        final map = category.toMap();

        expect(map['id'], 'xyz-789');
        expect(map['name'], 'Entertainment');
        expect(map['emoji'], '🎬');
        expect(map['color'], 'ff00ff');
        expect(map['transaction_type'], 'expense');
      });

      test('converts null fields correctly', () {
        final category = Category();

        final map = category.toMap();

        expect(map['id'], null);
        expect(map['name'], null);
        expect(map['emoji'], null);
        expect(map['color'], null);
        expect(map['transaction_type'], null);
      });
    });

    group('copyWith', () {
      test('copies with updated values', () {
        final original = Category(
          id: '123',
          name: 'Food',
          emoji: '🍔',
          color: 'ff5733',
          transactionType: TransactionType.expense,
        );

        final copied = original.copyWith(
          name: 'Fast Food',
          emoji: '🍟',
        );

        expect(copied.id, '123'); // unchanged
        expect(copied.name, 'Fast Food'); // changed
        expect(copied.emoji, '🍟'); // changed
        expect(copied.color, 'ff5733'); // unchanged
        expect(copied.transactionType, TransactionType.expense); // unchanged
      });

      test('copies without changes returns equivalent object', () {
        final original = Category(
          id: '123',
          name: 'Food',
          emoji: '🍔',
          color: 'ff5733',
          transactionType: TransactionType.expense,
        );

        final copied = original.copyWith();

        expect(copied.id, original.id);
        expect(copied.name, original.name);
        expect(copied.emoji, original.emoji);
        expect(copied.color, original.color);
        expect(copied.transactionType, original.transactionType);
      });
    });

    group('round trip', () {
      test('fromMap -> toMap preserves data', () {
        final originalMap = {
          'id': 'test-id',
          'name': 'Test Category',
          'emoji': '✅',
          'color': 'aabbcc',
          'transaction_type': 'income',
        };

        final category = Category.fromMap(originalMap);
        final resultMap = category.toMap();

        expect(resultMap['id'], originalMap['id']);
        expect(resultMap['name'], originalMap['name']);
        expect(resultMap['emoji'], originalMap['emoji']);
        expect(resultMap['color'], originalMap['color']);
        expect(resultMap['transaction_type'], originalMap['transaction_type']);
      });
    });
  });
}
