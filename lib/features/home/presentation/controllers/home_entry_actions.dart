import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/ai_entry/domain/errors/ai_entry_exception.dart';
import 'package:budgets/features/ai_entry/domain/models/ai_entry_result.dart';
import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/presentation/view_models/ai_entry_view_model.dart';
import 'package:budgets/features/home/domain/errors/insufficient_funds_exception.dart';
import 'package:budgets/features/home/domain/errors/wallet_selection_required_exception.dart';
import 'package:budgets/features/home/domain/models/receipt_input_result.dart';
import 'package:budgets/features/home/domain/models/wallet_funding_choice.dart';
import 'package:budgets/features/home/presentation/controllers/manual_finance_entry_actions.dart';
import 'package:budgets/features/home/presentation/widgets/ai_entry_result_feedback.dart';
import 'package:budgets/features/home/presentation/widgets/wallet_funding_prompt.dart';
import 'package:flutter/material.dart';

class HomeEntryActions {
  const HomeEntryActions(this.viewModel, {this.currencyState});

  final AiEntryViewModel viewModel;
  final CurrencyState? currencyState;

  Future<bool> submitMessage(BuildContext context, String message) =>
      _submit(context, () => viewModel.submit(message));

  Future<bool> submitReceipt(
    BuildContext context,
    ReceiptInputResult input,
  ) =>
      _submit(
        context,
        () => viewModel.submitReceipt(
          input,
          outputLanguage: Localizations.localeOf(context).languageCode,
        ),
      );

  Future<bool> _submit(
    BuildContext context,
    Future<AiEntryResult> Function() action,
  ) async {
    try {
      final result = await action();
      if (!context.mounted) return true;
      AiEntryResultFeedback.show(context, result);
      return true;
    } on WalletSelectionRequiredException catch (error) {
      if (!context.mounted ||
          error.requestId == null ||
          error.extraction == null) {
        return false;
      }
      final funding = await _chooseFunding(context, error.requiredAmount);
      if (funding == null || !context.mounted) {
        await _cancel(error.requestId!);
        return false;
      }
      return _resume(context, error, funding);
    } on InsufficientFundsException {
      if (context.mounted) _showInsufficientFunds(context);
      return false;
    } on AiEntryException catch (error) {
      if (context.mounted) {
        showAppToast(context, error.message, type: AppToastType.error);
      }
      return false;
    } on StateError catch (error) {
      if (context.mounted) {
        showAppToast(context, error.message, type: AppToastType.error);
      }
      return false;
    } catch (error) {
      if (context.mounted) showErrorToast(context, error);
      return false;
    }
  }

  Future<bool> _resume(
    BuildContext context,
    WalletSelectionRequiredException error,
    WalletFundingChoice funding,
  ) async {
    try {
      final result = await viewModel.resumeMessage(
        requestId: error.requestId!,
        extraction: error.extraction!,
        walletId: funding.walletId,
        useAllWallets: funding.useAllWallets,
      );
      if (context.mounted) AiEntryResultFeedback.show(context, result);
      return true;
    } on InsufficientFundsException {
      if (context.mounted) _showInsufficientFunds(context);
    } catch (error) {
      if (context.mounted) showErrorToast(context, error);
    }
    return false;
  }

  Future<void> addManual(BuildContext context) => ManualFinanceEntryActions(
        viewModel,
        currencyState: currencyState,
      ).add(context);

  Future<void> editEntry(BuildContext context, FinanceEntry entry) =>
      ManualFinanceEntryActions(
        viewModel,
        currencyState: currencyState,
      ).edit(context, entry);

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

  Future<void> _cancel(String requestId) async {
    try {
      await viewModel.cancelPendingRequest(requestId);
    } catch (_) {}
  }

  void _showInsufficientFunds(BuildContext context) => showAppToast(
        context,
        'Insufficient funds across all wallets.',
        type: AppToastType.error,
      );
}
