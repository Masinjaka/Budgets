import 'package:budgets/features/categories/domain/models/category_model.dart';

class BudgetHistory {
  final String? id;
  final DateTime? createdAt;
  final String? budgetId;
  final String? userId;
  final Category? category;
  final String? amount;
  final String? amountSpent;
  final String? periodMonth; // Format: "YYYY-MM" e.g. "2026-01"

  BudgetHistory({
    this.id,
    this.createdAt,
    this.budgetId,
    this.userId,
    this.category,
    this.amount,
    this.amountSpent,
    this.periodMonth,
  });

  factory BudgetHistory.fromMap(Map<String, dynamic> map) {
    return BudgetHistory(
      id: map['id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      budgetId: map['budget_id']?.toString(),
      userId: map['user_id'] as String?,
      category: map['category'] != null
          ? Category.fromMap(map['category'] as Map<String, dynamic>)
          : null,
      amount: map['amount'] as String?,
      amountSpent: map['amount_spent'] as String?,
      periodMonth: map['period_month'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'budget_id': budgetId,
      'user_id': userId,
      'category': category?.toMap(),
      'amount': amount,
      'amount_spent': amountSpent,
      'period_month': periodMonth,
    };
  }

  /// Returns the spent amount as a double
  double get spentAsDouble {
    if (amountSpent == null || amountSpent!.isEmpty) return 0.0;
    return double.tryParse(amountSpent!) ?? 0.0;
  }

  /// Returns the budget amount as a double
  double get amountAsDouble {
    if (amount == null || amount!.isEmpty) return 0.0;
    return double.tryParse(amount!) ?? 0.0;
  }

  /// Returns true if spending exceeded the budget
  bool get isOverBudget => spentAsDouble > amountAsDouble;

  /// Returns the percentage of budget used (can be > 100%)
  double get percentageUsed {
    if (amountAsDouble == 0) return 0.0;
    return (spentAsDouble / amountAsDouble) * 100;
  }

  /// Returns the difference between budget and spent (negative if over budget)
  double get remainingOrOverspent => amountAsDouble - spentAsDouble;

  BudgetHistory copyWith({
    String? id,
    DateTime? createdAt,
    String? budgetId,
    String? userId,
    Category? category,
    String? amount,
    String? amountSpent,
    String? periodMonth,
  }) {
    return BudgetHistory(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      budgetId: budgetId ?? this.budgetId,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      amountSpent: amountSpent ?? this.amountSpent,
      periodMonth: periodMonth ?? this.periodMonth,
    );
  }
}
