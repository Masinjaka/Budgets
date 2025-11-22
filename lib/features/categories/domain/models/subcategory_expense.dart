import 'package:equatable/equatable.dart';

class SubcategoryExpense extends Equatable {
  final String id;
  final DateTime createdAt;
  final double? amount;
  final String? subId;
  final String? transactionId;

  const SubcategoryExpense({
    required this.id,
    required this.createdAt,
    this.amount,
    this.subId,
    this.transactionId,
  });

  factory SubcategoryExpense.fromJson(Map<String, dynamic> json) {
    return SubcategoryExpense(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      amount: json['amount'] != null ? double.tryParse(json['amount'].toString()) : null,
      subId: json['sub_id'] as String?,
      transactionId: json['transaction_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'amount': amount,
      'sub_id': subId,
      'transaction_id': transactionId,
    };
  }

  @override
  List<Object?> get props => [id, createdAt, amount, subId, transactionId];
}
