import 'package:budgets/features/categories/domain/models/category_model.dart';

class Budget {
  final int? id;
  final DateTime? createdAt;
  final DateTime? lastResetAt;
  final String? userId;
  final Category? category; // UUID reference to categories table
  final String? amount;
  final String? amountSpent;
  final String? period;

  Budget({
    this.id,
    this.createdAt,
    this.lastResetAt,
    this.userId,
    this.category,
    this.amount,
    this.amountSpent,
    this.period,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      lastResetAt: map['last_reset_at'] != null
          ? DateTime.parse(map['last_reset_at'] as String)
          : null,
      userId: map['user_id'] as String?,
      category: map['category'] != null
          ? Category.fromMap(map['category'] as Map<String, dynamic>)
          : null,
      amount: map['amount'] as String?,
      amountSpent: map['amount_spent'] as String?,
      period: map['period'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'last_reset_at': lastResetAt?.toIso8601String(),
      'user_id': userId,
      'category': category?.toMap(),
      'amount': amount,
      'amount_spent': amountSpent,
      'period': period,
    };
  }

  Budget copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? lastResetAt,
    String? userId,
    Category? category,
    String? amount,
    String? amountSpent,
    String? period,
  }) {
    return Budget(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      lastResetAt: lastResetAt ?? this.lastResetAt,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      amountSpent: amountSpent ?? this.amountSpent,
      period: period ?? this.period,
    );
  }
}
