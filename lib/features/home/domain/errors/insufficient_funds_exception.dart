class InsufficientFundsException implements Exception {
  const InsufficientFundsException({
    required this.requiredAmount,
    required this.availableAmount,
  });

  final int requiredAmount;
  final int availableAmount;

  @override
  String toString() => 'Insufficient funds across all wallets.';
}
