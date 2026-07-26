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
    this.categoryId,
    this.sourceWalletId,
    this.envelopeName,
    this.usedMultipleWallets = false,
  });

  factory FinanceEntry.fromJson(Map<String, dynamic> json) {
    final category = json['category'] ?? json['categories'];
    final categoryJson = category is Map
        ? Map<String, dynamic>.from(category)
        : <String, dynamic>{};
    final entryType = (json['entry_type'] as String?) ?? 'transaction';
    final isTransfer = entryType == 'transfer';
    return FinanceEntry(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? 'Entry',
      description: (json['description'] as String?) ?? '',
      categoryName: (categoryJson['name'] as String?) ?? 'Other',
      amount: (json['amount'] as num).toDouble(),
      occurredAt: DateTime.parse(json['date'] as String).toLocal(),
      transactionType: (json['transaction_type'] as String?) ?? 'expense',
      currencyCode: (json['currency_code'] as String?) ?? 'MGA',
      iconKey: isTransfer
          ? 'transfer'
          : (categoryJson['icon_key'] as String?) ?? 'other',
      emoji: isTransfer ? '🔄' : (categoryJson['emoji'] as String?) ?? '🧾',
      entryType: entryType,
      categoryId: categoryJson['id'] as String?,
      sourceWalletId: json['source_wallet_id'] as String?,
      envelopeName: _envelopeName(json),
      usedMultipleWallets: _hasWalletDebits(json),
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
  final String? categoryId;
  final String? sourceWalletId;
  final String? envelopeName;
  final bool usedMultipleWallets;

  bool get isExpense => transactionType == 'expense';
  bool get isIncome => transactionType == 'income';
  bool get isTransfer => entryType == 'transfer';

  static bool _hasWalletDebits(Map<String, dynamic> json) {
    if (json['source_wallet_id'] != null) return false;
    final debits = json['transaction_wallet_debits'];
    return debits is List && debits.isNotEmpty;
  }

  static String? _envelopeName(Map<String, dynamic> json) {
    if (json['transaction_type'] != 'expense') return null;
    final amount = (json['envelope_amount_used'] as num?) ?? 0;
    if (amount <= 0) return null;
    final envelope = json['envelope'] ?? json['envelopes'];
    if (envelope is! Map) return json['envelope_name'] as String?;
    return envelope['name'] as String?;
  }
}
