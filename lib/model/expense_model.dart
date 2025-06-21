import 'package:budgets/model/category_model.dart';// Update with the actual path to your Category class

class Expense {
  final String? title;
  final String? description;
  final double? amount;
  final DateTime? date;
  final String? invoiceFile; // Changed from File? to String?
  final Category? category;

  Expense({
    this.title,
    this.description,
    this.amount,
    this.date,
    this.invoiceFile,
    this.category,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      title: map['title'] as String?,
      description: map['description'] as String?,
      amount: map['amount'] as double?,
      date: map['date'] != null ? DateTime.parse(map['date'] as String) : null,
      invoiceFile: map['invoice_file'] as String?, // Updated to handle String
      category: map['expense_categories'] != null ? Category.fromMap(map['expense_categories'] as Map<String, dynamic>) : null,
    );
  }

  Expense copyWith({
    String? title,
    String? description,
    double? amount,
    DateTime? date,
    String? invoiceFile, // Updated to String
    Category? category,
  }) {
    return Expense(
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      invoiceFile: invoiceFile ?? this.invoiceFile, // Updated to String
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'amount': amount,
      'date': date?.toIso8601String(),
      'invoice_file': invoiceFile, // Updated to String
      'expense_categories': category?.toMap(),
    };
  }
}