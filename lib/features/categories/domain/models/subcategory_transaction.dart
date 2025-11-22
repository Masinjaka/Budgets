import 'package:budgets/features/categories/domain/models/subcategories.dart';

class SubcategoryTransaction {
  final String id;
  final DateTime createdAt;
  final double? amount;
  final Subcategory? subcategory;
  final String? transactionId;

  const SubcategoryTransaction({
    required this.id,
    required this.createdAt,
    this.amount,
    this.subcategory,
    this.transactionId,
  });

  factory SubcategoryTransaction.fromJson(Map<String, dynamic> json) {
    return SubcategoryTransaction(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      amount: json['amount'] != null
          ? double.tryParse(json['amount'].toString())
          : null,
      subcategory: json['subcategories'] != null
          ? Subcategory.fromMap(json['subcategories'] as Map<String, dynamic>)
          : null,
      transactionId: json['transaction_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'amount': amount,
      'sub_id': subcategory?.id,
      'transaction_id': transactionId,
    };
  }
}
