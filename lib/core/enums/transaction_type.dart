/// Enum representing the type of transaction
enum TransactionType {
  expense('expense'),
  income('income');

  const TransactionType(this.value);

  /// The string value stored in the database
  final String value;

  /// Create TransactionType from string value
  static TransactionType? fromValue(String? value) {
    switch (value?.toLowerCase()) {
      case 'expense':
        return TransactionType.expense;
      case 'income':
        return TransactionType.income;
      default:
        return null;
    }
  }

  /// Get display name for the transaction type
  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return 'Dépense';
      case TransactionType.income:
        return 'Revenu';
    }
  }

  @override
  String toString() => value;
}
