class ManualEntryInput {
  const ManualEntryInput({
    required this.title,
    required this.amount,
    required this.transactionType,
    required this.occurredAt,
    this.description = '',
    this.categoryId,
    this.sourceWalletId,
    this.useAllWallets = false,
  });

  final String title;
  final String description;
  final int amount;
  final String transactionType;
  final DateTime occurredAt;
  final String? categoryId;
  final String? sourceWalletId;
  final bool useAllWallets;

  ManualEntryInput copyWith({
    String? sourceWalletId,
    bool? useAllWallets,
  }) =>
      ManualEntryInput(
        title: title,
        description: description,
        amount: amount,
        transactionType: transactionType,
        occurredAt: occurredAt,
        categoryId: categoryId,
        sourceWalletId: sourceWalletId ?? this.sourceWalletId,
        useAllWallets: useAllWallets ?? this.useAllWallets,
      );
}
