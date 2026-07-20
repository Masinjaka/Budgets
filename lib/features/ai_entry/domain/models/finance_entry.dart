class FinanceEntry {
  const FinanceEntry({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.amount,
    required this.occurredAt,
    required this.transactionType,
    required this.currencyCode,
    required this.iconKey,
    required this.emoji,
    this.entryType = 'transaction',
    this.description = '',
  });

  factory FinanceEntry.fromJson(Map<String, dynamic> json) {
    final category = json['category'] ?? json['categories'];
    final categoryJson = category is Map
        ? Map<String, dynamic>.from(category)
        : <String, dynamic>{};
    return FinanceEntry(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? 'Entry',
      description: (json['description'] as String?) ?? '',
      categoryName: (categoryJson['name'] as String?) ?? 'Other',
      amount: (json['amount'] as num).toDouble(),
      occurredAt: DateTime.parse(json['date'] as String).toLocal(),
      transactionType: (json['transaction_type'] as String?) ?? 'expense',
      currencyCode: (json['currency_code'] as String?) ?? 'MGA',
      iconKey: (categoryJson['icon_key'] as String?) ?? 'other',
      emoji: (categoryJson['emoji'] as String?) ?? '🧾',
      entryType: (json['entry_type'] as String?) ?? 'transaction',
    );
  }

  final String id;
  final String title;
  final String description;
  final String categoryName;
  final double amount;
  final DateTime occurredAt;
  final String transactionType;
  final String currencyCode;
  final String iconKey;
  final String emoji;
  final String entryType;

  bool get isExpense => transactionType == 'expense';
  bool get isIncome => transactionType == 'income';
  bool get isTransfer => entryType == 'transfer';
}
