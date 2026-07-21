class WalletFundingChoice {
  const WalletFundingChoice.single(this.walletId) : useAllWallets = false;

  const WalletFundingChoice.combined()
      : walletId = null,
        useAllWallets = true;

  final String? walletId;
  final bool useAllWallets;
}
