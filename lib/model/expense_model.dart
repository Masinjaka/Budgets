import 'package:budgets/model/category_model.dart';// Update with the actual path to your Category class
import 'package:budgets/core/enums/transaction_type.dart';

class Expense {
  final String? title;
  final String? description;
  final double? amount; // Changed from int? to double?
  final DateTime? date;
  final String? invoiceFile; // Changed from File? to String?
  final Category? category;
  final TransactionType? transactionType;

  Expense({
    this.title,
    this.description,
    this.amount,
    this.date,
    this.invoiceFile,
    this.category,
    this.transactionType,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      title: map['title'] as String?,
      description: map['description'] as String?,
      amount: map['amount'] != null ? (map['amount'] as num).toDouble() : null, // Updated to handle double
      date: map['date'] != null ? DateTime.parse(map['date'] as String).toLocal() : null,
      invoiceFile: map['invoice_file'] as String?, // Updated to handle String
      transactionType: TransactionType.fromValue(map['transaction_type'] as String?), // Updated to handle TransactionType
      category: map['categories'] != null ? Category.fromMap(map['categories'] as Map<String, dynamic>) : null,
    );
  }

  Expense copyWith({
    String? title,
    String? description,
    double? amount, // Updated to double
    DateTime? date,
    String? invoiceFile, // Updated to String
    Category? category,
    TransactionType? transactionType,
  }) {
    return Expense(
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount, // Updated to double
      date: date ?? this.date,
      invoiceFile: invoiceFile ?? this.invoiceFile, // Updated to String
      category: category ?? this.category,
      transactionType: transactionType ?? this.transactionType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'amount': amount, // Updated to double
      'date': date?.toIso8601String(),
      'invoice_file': invoiceFile, // Updated to String
      'categories': category?.toMap(),
      'transaction_type': transactionType?.value, // Updated to use enum value
    };
  }
}