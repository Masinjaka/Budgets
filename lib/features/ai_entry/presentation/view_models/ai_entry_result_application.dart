part of 'ai_entry_view_model.dart';

extension AiEntryResultApplication on AiEntryViewModel {
  Future<void> _applyResult(
    AiEntryResult result,
    DateTime targetDate,
  ) async {
    _quota = AiQuota(
      plan: result.plan,
      unlimited: result.unlimited,
      remaining: result.remaining,
    );
    if (DateUtils.isSameDay(_selectedDate, targetDate)) {
      _entries = _mergeNewEntries(result.entries, _entries);
    }
    final wallets = result.wallets;
    if (wallets == null) {
      await refreshBalances();
      return;
    }
    _wallets = List.unmodifiable(wallets);
    _walletsLoaded = true;
    _totalFunds = _walletBalance;
  }

  List<FinanceEntry> _mergeNewEntries(
    List<FinanceEntry> additions,
    List<FinanceEntry> existing,
  ) {
    if (additions.isEmpty) return existing;
    final addedIds = additions.map((entry) => entry.id).toSet();
    return List.unmodifiable([
      ...additions,
      ...existing.where((entry) => !addedIds.contains(entry.id)),
    ]);
  }
}
