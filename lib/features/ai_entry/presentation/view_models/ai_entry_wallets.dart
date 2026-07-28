part of 'ai_entry_view_model.dart';

extension AiEntryWallets on AiEntryViewModel {
  Future<void> addWallet(AddWalletInput input) async {
    if (_isAddingWallet) return;
    await _runWalletMutation(() async {
      final wallet = await _repository.addWallet(input);
      _wallets = List.unmodifiable([..._wallets, wallet]);
      await _refreshWalletTotal();
    });
  }

  Future<void> updateWallet(
    String walletId,
    AddWalletInput input,
  ) async {
    if (_isAddingWallet) return;
    await _runWalletMutation(() async {
      final updated = await _repository.updateWallet(walletId, input);
      _wallets = List.unmodifiable(
        _wallets.map((wallet) => wallet.id == walletId ? updated : wallet),
      );
      await _refreshWalletTotal();
    });
  }

  Future<void> deleteWallet(String walletId) async {
    if (_isAddingWallet) return;
    final wallet = _wallets.firstWhere((item) => item.id == walletId);
    if (wallet.isDefault) {
      throw StateError('The default wallet cannot be deleted.');
    }
    await _runWalletMutation(() async {
      await _repository.deleteWallet(walletId);
      _wallets = List.unmodifiable(
        _wallets.where((wallet) => wallet.id != walletId),
      );
      await _refreshWalletTotal();
    });
  }

  Future<void> refreshBalances() async {
    _wallets = List.unmodifiable(await _repository.wallets());
    _walletsLoaded = true;
    _totalFunds = await _repository.totalFunds();
    _notify();
  }

  Future<void> _runWalletMutation(Future<void> Function() action) async {
    _isAddingWallet = true;
    _notify();
    try {
      await action();
      _walletsLoaded = true;
    } finally {
      _isAddingWallet = false;
      _notify();
    }
  }

  Future<void> _refreshWalletTotal() async {
    _totalFunds = await _repository.totalFunds();
  }
}
