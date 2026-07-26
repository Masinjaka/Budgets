part of 'ai_entry_view_model.dart';

extension AiEntryReceipt on AiEntryViewModel {
  Future<AiEntryResult> submitReceipt(
    ReceiptInputResult input, {
    required String outputLanguage,
  }) async {
    final repository = _receiptRepository;
    if (repository == null) {
      throw StateError('Receipt scanning is unavailable.');
    }
    final targetDate = _selectedDate;
    _isSubmitting = true;
    _notifyReceiptChanged();
    try {
      final result = await repository.process(
        input,
        targetDate: targetDate,
        outputLanguage: outputLanguage,
      );
      await _applyResult(result, targetDate);
      _notifyReceiptChanged();
      return result;
    } finally {
      _isSubmitting = false;
      _notifyReceiptChanged();
    }
  }
}
