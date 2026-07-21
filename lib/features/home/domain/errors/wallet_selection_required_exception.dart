class WalletSelectionRequiredException implements Exception {
  const WalletSelectionRequiredException({
    required this.requiredAmount,
    this.availableAmount,
    this.requestId,
    this.extraction,
  });

  final int requiredAmount;
  final int? availableAmount;
  final String? requestId;
  final Map<String, dynamic>? extraction;

  @override
  String toString() => 'Choose a wallet with at least $requiredAmount.';
}
