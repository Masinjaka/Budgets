class WalletDeletionException implements Exception {
  const WalletDeletionException.inUse() : reason = WalletDeletionReason.inUse;

  final WalletDeletionReason reason;
}

enum WalletDeletionReason { inUse }
