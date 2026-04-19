import 'package:budgets/core/powersync/powersync.dart' as powersync;
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/core/utils/wrapper.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Paginated response model for transactions
class PaginatedTransactions {
  final List<TransactionModel> transactions;
  final bool hasMore;
  final int currentPage;

  const PaginatedTransactions({
    required this.transactions,
    required this.hasMore,
    required this.currentPage,
  });
}

const _uuid = Uuid();

class TransactionsApi {
  TransactionsApi();

  Future<List<TransactionModel>> getTransactions() {
    return Wrapper.execute(() async {
      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) return [];

        final results = await powersync.db.getAll('''
          SELECT t.id, t.title, t.description, t.amount, t.date,
                 t.invoice_file, t.transaction_type,
                 c.id AS cat_id, c.name AS cat_name,
                 c.emoji AS cat_emoji, c.color AS cat_color
          FROM "transaction" t
          LEFT JOIN categories c ON t.category_id = c.id
          WHERE t.user_id = ?
          ORDER BY t.date DESC
        ''', [userId]);

        if (results.isEmpty) return [];

        return results.map((row) => _transactionFromRow(row)).toList();
      } catch (e, s) {
        debugPrint('$e,$s');
        rethrow;
      }
    });
  }

  /// Build a [TransactionModel] from a PowerSync JOIN row.
  TransactionModel _transactionFromRow(Map<String, dynamic> row) {
    return TransactionModel(
      id: row['id'] as String?,
      title: row['title'] as String?,
      description: row['description'] as String?,
      amount: row['amount'] != null ? (row['amount'] as num).toDouble() : null,
      date: row['date'] != null
          ? DateTime.parse(row['date'] as String).toLocal()
          : null,
      invoiceFile: row['invoice_file'] as String?,
      transactionType:
          TransactionType.fromValue(row['transaction_type'] as String?),
      category: row['cat_id'] != null
          ? Category(
              id: row['cat_id'] as String?,
              name: row['cat_name'] as String?,
              emoji: row['cat_emoji'] as String?,
              color: row['cat_color'] as String?,
            )
          : null,
    );
  }

  /// Get transactions with pagination
  Future<PaginatedTransactions> getTransactionsPaginated({
    int page = 0,
    int limit = 10,
    TransactionType? type,
  }) {
    return Wrapper.execute(() async {
      try {
        final offset = page * limit;
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) {
          return const PaginatedTransactions(
            transactions: [],
            hasMore: false,
            currentPage: 0,
          );
        }

        final typeFilter = type != null ? 'AND t.transaction_type = ?' : '';
        final args = <Object?>[userId];
        if (type != null) args.add(type.value);

        // Fetch limit+1 to check if there are more pages
        final results = await powersync.db.getAll('''
          SELECT t.id, t.title, t.description, t.amount, t.date,
                 t.invoice_file, t.transaction_type,
                 c.id AS cat_id, c.name AS cat_name,
                 c.emoji AS cat_emoji, c.color AS cat_color
          FROM "transaction" t
          LEFT JOIN categories c ON t.category_id = c.id
          WHERE t.user_id = ?
          $typeFilter
          ORDER BY t.date DESC
          LIMIT ${limit + 1} OFFSET $offset
        ''', args);

        if (results.isEmpty) {
          return const PaginatedTransactions(
            transactions: [],
            hasMore: false,
            currentPage: 0,
          );
        }

        final transactions =
            results.map((row) => _transactionFromRow(row)).toList();

        final hasMore = transactions.length > limit;
        if (hasMore) {
          transactions.removeLast();
        }

        return PaginatedTransactions(
          transactions: transactions,
          hasMore: hasMore,
          currentPage: page,
        );
      } catch (e, s) {
        debugPrint('Error getting paginated transactions: $e, $s');
        rethrow;
      }
    });
  }

  // Add transactions — replaces RPC 'add_expense_with_budget_check'
  Future<void> addTransaction(
      String? amount,
      String? description,
      String? categoryName,
      Map<String, String>? subcategoryAmounts,
      TransactionType? transactionType) {
    return Wrapper.execute(() async {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('No authenticated user found');
      if (amount == null || amount.trim().isEmpty) {
        throw Exception('Amount cannot be null or empty');
      }
      if (categoryName == null || categoryName.trim().isEmpty) {
        throw Exception('Category name cannot be null or empty');
      }

      final validDescription = description?.trim() ?? "";
      final amountNumeric = _parseAmountForBigint(amount);

      // Look up category_id locally
      final categoryRows = await powersync.db.getAll(
        'SELECT id FROM categories WHERE name = ? AND user_id = ? LIMIT 1',
        [categoryName, userId],
      );
      if (categoryRows.isEmpty) {
        throw Exception('Category $categoryName not found');
      }
      final categoryId = categoryRows.first['id'] as String;

      final transactionId = _uuid.v4();
      final trType = transactionType?.value ?? TransactionType.expense.value;
      final nowIso = DateTime.now().toUtc().toIso8601String();

      await powersync.db.writeTransaction((tx) async {
        // 1. Insert the transaction
        await tx.execute(
          '''INSERT INTO "transaction" (id, created_at, user_id, description, amount, date,
                 category_id, transaction_type)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
          [
            transactionId,
            nowIso,
            userId,
            validDescription,
            amountNumeric,
            nowIso,
            categoryId,
            trType,
          ],
        );

        // 2. Update budget amount_spent for matching category
        if (trType == TransactionType.expense.value) {
          await _applyBudgetDelta(tx, categoryId, userId, amountNumeric);
        }

        // 3. Handle subcategories if provided
        if (subcategoryAmounts != null && subcategoryAmounts.isNotEmpty) {
          for (final entry in subcategoryAmounts.entries) {
            final subName = entry.key;
            final subAmount = entry.value;

            // Find or create subcategory
            final subRows = await tx.getAll(
              '''SELECT id FROM subcategories
                 WHERE name = ? AND category_id = ? LIMIT 1''',
              [subName, categoryId],
            );

            String subcategoryId;
            if (subRows.isNotEmpty) {
              subcategoryId = subRows.first['id'] as String;
            } else {
              subcategoryId = _uuid.v4();
              await tx.execute(
                '''INSERT INTO subcategories (id, created_at, name, category_id)
                   VALUES (?, ?, ?, ?)''',
                [subcategoryId, nowIso, subName, categoryId],
              );
            }

            // Insert subcategory expense
            await tx.execute(
              '''INSERT INTO subcategory_expenses
                 (id, created_at, transaction_id, sub_id, amount)
                 VALUES (?, ?, ?, ?, ?)''',
              [_uuid.v4(), nowIso, transactionId, subcategoryId, subAmount],
            );
          }
        }
      });

      debugPrint("Transaction created locally: $transactionId");
    });
  }

  // Delete transaction — replaces RPC 'delete_expense'
  Future<void> deleteTransaction(String transactionId) {
    return Wrapper.execute(() async {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('No authenticated user found');

      await powersync.db.writeTransaction((tx) async {
        final existingRows = await tx.getAll(
          '''SELECT category_id, amount, transaction_type
             FROM "transaction"
             WHERE id = ? AND user_id = ?
             LIMIT 1''',
          [transactionId, userId],
        );
        if (existingRows.isNotEmpty &&
            existingRows.first['transaction_type'] ==
                TransactionType.expense.value) {
          final oldCategoryId = existingRows.first['category_id'] as String?;
          final oldAmount = _numFromValue(existingRows.first['amount']);
          if (oldCategoryId != null) {
            await _applyBudgetDelta(tx, oldCategoryId, userId, -oldAmount);
          }
        }

        // Delete subcategory expenses first
        await tx.execute(
          'DELETE FROM subcategory_expenses WHERE transaction_id = ?',
          [transactionId],
        );
        // Delete the transaction
        await tx.execute(
          'DELETE FROM "transaction" WHERE id = ?',
          [transactionId],
        );
      });

      debugPrint("Transaction deleted locally: $transactionId");
    });
  }

  // Edit transaction — replaces RPC 'edit_expense'
  Future<void> editTransaction(
      String transactionId,
      String? amount,
      String? description,
      String? categoryName,
      Map<String, String>? subcategoryAmounts,
      TransactionType? transactionType,
      DateTime? date) {
    return Wrapper.execute(() async {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('No authenticated user found');
      if (amount == null || amount.trim().isEmpty) {
        throw Exception('Amount cannot be null or empty');
      }
      if (categoryName == null || categoryName.trim().isEmpty) {
        throw Exception('Category name cannot be null or empty');
      }

      final validDescription = description?.trim() ?? "";
      final amountNumeric = _parseAmountForBigint(amount);

      // Look up category_id locally
      final categoryRows = await powersync.db.getAll(
        'SELECT id FROM categories WHERE name = ? AND user_id = ? LIMIT 1',
        [categoryName, userId],
      );
      if (categoryRows.isEmpty) {
        throw Exception('Category $categoryName not found');
      }
      final categoryId = categoryRows.first['id'] as String;

      final trType = transactionType?.value ?? TransactionType.expense.value;
      final nowIso = DateTime.now().toUtc().toIso8601String();

      await powersync.db.writeTransaction((tx) async {
        final existingRows = await tx.getAll(
          '''SELECT category_id, amount, transaction_type
             FROM "transaction"
             WHERE id = ? AND user_id = ?
             LIMIT 1''',
          [transactionId, userId],
        );
        if (existingRows.isEmpty) {
          throw Exception('Transaction not found');
        }
        final old = existingRows.first;
        final oldType = old['transaction_type']?.toString();
        final oldCategoryId = old['category_id'] as String?;
        final oldAmount = _numFromValue(old['amount']);
        final existingDateRaw = old['date']?.toString();
        final resolvedDateIso = date?.toUtc().toIso8601String() ??
            existingDateRaw ??
            DateTime.now().toUtc().toIso8601String();

        // 1. Update the transaction
        await tx.execute(
          '''UPDATE "transaction"
             SET description = ?, amount = ?, date = ?,
                 category_id = ?, transaction_type = ?
             WHERE id = ?''',
          [
            validDescription,
            amountNumeric,
            resolvedDateIso,
            categoryId,
            trType,
            transactionId,
          ],
        );

        if (oldType == TransactionType.expense.value && oldCategoryId != null) {
          await _applyBudgetDelta(tx, oldCategoryId, userId, -oldAmount);
        }
        if (trType == TransactionType.expense.value) {
          await _applyBudgetDelta(tx, categoryId, userId, amountNumeric);
        }

        // 2. Delete existing subcategory expenses
        await tx.execute(
          'DELETE FROM subcategory_expenses WHERE transaction_id = ?',
          [transactionId],
        );

        // 3. Re-create subcategories if provided
        if (subcategoryAmounts != null && subcategoryAmounts.isNotEmpty) {
          for (final entry in subcategoryAmounts.entries) {
            final subName = entry.key;
            final subAmount = entry.value;

            // Find or create subcategory
            final subRows = await tx.getAll(
              '''SELECT id FROM subcategories
                 WHERE name = ? AND category_id = ? LIMIT 1''',
              [subName, categoryId],
            );

            String subcategoryId;
            if (subRows.isNotEmpty) {
              subcategoryId = subRows.first['id'] as String;
            } else {
              subcategoryId = _uuid.v4();
              await tx.execute(
                '''INSERT INTO subcategories (id, created_at, name, category_id)
                   VALUES (?, ?, ?, ?)''',
                [subcategoryId, nowIso, subName, categoryId],
              );
            }

            // Insert subcategory expense
            await tx.execute(
              '''INSERT INTO subcategory_expenses
                 (id, created_at, transaction_id, sub_id, amount)
                 VALUES (?, ?, ?, ?, ?)''',
              [_uuid.v4(), nowIso, transactionId, subcategoryId, subAmount],
            );
          }
        }
      });

      debugPrint("Transaction edited locally: $transactionId");
    });
  }

  num _numFromValue(Object? value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// Normalizes numeric strings to a Postgres bigint-safe integer.
  /// Accepts inputs like "45568", "45568.0", "45 568", or "45,568.00".
  int _parseAmountForBigint(String rawAmount) {
    final cleaned = rawAmount.replaceAll(RegExp(r'[,\s]'), '');
    final parsed = num.tryParse(cleaned);
    if (parsed == null) {
      throw Exception('Invalid amount format');
    }
    return parsed.round();
  }

  Future<void> _applyBudgetDelta(
    dynamic tx,
    String categoryId,
    String userId,
    num delta,
  ) async {
    await tx.execute(
      '''UPDATE budgets
         SET amount_spent = CAST(
           max(COALESCE(CAST(amount_spent AS REAL), 0) + ?, 0)
         AS TEXT)
         WHERE category = ? AND user_id = ?''',
      [delta, categoryId, userId],
    );
  }
}
