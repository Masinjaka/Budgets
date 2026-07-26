import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_input.dart';
import 'package:budgets/features/ai_entry/presentation/view_models/ai_entry_view_model.dart';
import 'package:budgets/features/home/domain/errors/insufficient_funds_exception.dart';
import 'package:budgets/features/home/domain/errors/wallet_selection_required_exception.dart';
import 'package:budgets/features/home/domain/models/manual_entry_sheet_result.dart';
import 'package:budgets/features/home/domain/models/wallet_funding_choice.dart';
import 'package:budgets/features/home/presentation/widgets/manual_entry_sheet.dart';
import 'package:budgets/features/home/presentation/widgets/wallet_funding_prompt.dart';
import 'package:budgets/widgets/delete_confirmation_dialog.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';

class ManualFinanceEntryActions {
  const ManualFinanceEntryActions(this.viewModel, {this.currencyState});

  final AiEntryViewModel viewModel;
  final CurrencyState? currencyState;

  Future<void> add(BuildContext context) async {
    try {
      final result = await _showSheet(context);
      final input = result?.input;
      if (input == null || !context.mounted) return;
      await _saveWithFunding(
        context,
        input,
        viewModel.addManualEntry,
      );
      if (context.mounted) showSuccessToast(context, 'Entry added.');
    } on InsufficientFundsException {
      if (context.mounted) _showInsufficientFunds(context);
    } catch (error) {
      if (context.mounted) showErrorToast(context, error);
    }
  }

  Future<void> edit(BuildContext context, FinanceEntry entry) async {
    if (entry.isTransfer) return;
    try {
      final result = await _showSheet(context, entry: entry);
      if (result == null || !context.mounted) return;
      if (result.action == ManualEntrySheetAction.delete) {
        await _delete(context, entry);
        return;
      }
      final input = result.input;
      if (input == null) return;
      await _saveWithFunding(
        context,
        input,
        (value) => viewModel.updateFinanceEntry(entry.id, value),
      );
      if (context.mounted) showSuccessToast(context, 'Entry updated.');
    } on InsufficientFundsException {
      if (context.mounted) _showInsufficientFunds(context);
    } catch (error) {
      if (context.mounted) showErrorToast(context, error);
    }
  }

  Future<ManualEntrySheetResult?> _showSheet(
    BuildContext context, {
    FinanceEntry? entry,
  }) {
    return ManualEntrySheet.show(
      context,
      categories: viewModel.manualEntryCategories(),
      targetDate: entry?.occurredAt ?? viewModel.selectedDate,
      currencyState: currencyState,
      entry: entry,
    );
  }

  Future<void> _delete(BuildContext context, FinanceEntry entry) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete entry?',
      message: 'This transaction and its balance changes will be removed.',
      confirmText: context.l10n.delete,
      cancelText: context.l10n.cancel,
    );
    if (!confirmed || !context.mounted) return;
    await viewModel.deleteFinanceEntry(entry.id);
    if (context.mounted) showSuccessToast(context, 'Entry deleted.');
  }

  Future<void> _saveWithFunding<T>(
    BuildContext context,
    ManualEntryInput input,
    Future<T> Function(ManualEntryInput input) save,
  ) async {
    try {
      await save(input);
    } on WalletSelectionRequiredException catch (error) {
      if (!context.mounted) return;
      final funding = await _chooseFunding(context, error.requiredAmount);
      if (funding == null) return;
      await save(input.copyWith(
        sourceWalletId: funding.walletId,
        useAllWallets: funding.useAllWallets,
      ));
    }
  }

  Future<WalletFundingChoice?> _chooseFunding(
    BuildContext context,
    int amount,
  ) async {
    await viewModel.refreshBalances();
    if (!context.mounted) return null;
    return WalletFundingPrompt.show(
      context,
      wallets: viewModel.wallets,
      requiredAmount: amount,
    );
  }

  void _showInsufficientFunds(BuildContext context) => showAppToast(
        context,
        'Insufficient funds across all wallets.',
        type: AppToastType.error,
      );
}
