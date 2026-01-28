class Budget {
  final int? id;
  final DateTime? createdAt;
  final String? userId;
  final String? category; // UUID reference to categories table
  final String? amount;
  final String? amountSpent;

  Budget({
    this.id,
    this.createdAt,
    this.userId,
    this.category,
    this.amount,
    this.amountSpent,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      userId: map['user_id'] as String?,
      category: map['category'] as String?,
      amount: map['amount'] as String?,
      amountSpent: map['amount_spent'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'user_id': userId,
      'category': category,
      'amount': amount,
      'amount_spent': amountSpent,
    };
  }

  Budget copyWith({
    int? id,
    DateTime? createdAt,
    String? userId,
    String? category,
    String? amount,
    String? amountSpent,
  }) {
    return Budget(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      amountSpent: amountSpent ?? this.amountSpent,
    );
  }
}
