class ManualEntryCategory {
  const ManualEntryCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.transactionType,
  });

  factory ManualEntryCategory.fromJson(Map<String, dynamic> json) {
    return ManualEntryCategory(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? 'Other',
      emoji: (json['emoji'] as String?) ?? '🧾',
      transactionType: (json['transaction_type'] as String?) ?? 'expense',
    );
  }

  final String id;
  final String name;
  final String emoji;
  final String transactionType;
}
