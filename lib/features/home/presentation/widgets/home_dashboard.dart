import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/ai_entry/domain/errors/ai_entry_exception.dart';
import 'package:budgets/features/ai_entry/presentation/view_models/ai_entry_view_model.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/daily_entry_section.dart';
import 'package:budgets/features/home/domain/errors/insufficient_funds_exception.dart';
import 'package:budgets/features/home/domain/errors/wallet_selection_required_exception.dart';
import 'package:budgets/features/home/domain/models/wallet_funding_choice.dart';
import 'package:budgets/features/home/presentation/widgets/ai_entry_result_feedback.dart';
import 'package:budgets/features/home/presentation/widgets/ai_request_quota_label.dart';
import 'package:budgets/features/home/presentation/widgets/chat_input_bar.dart';
import 'package:budgets/features/home/presentation/widgets/home_header.dart';
import 'package:budgets/features/home/presentation/widgets/manual_entry_sheet.dart';
import 'package:budgets/features/home/presentation/widgets/wallet_funding_prompt.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    required this.today,
    required this.drawerProgress,
    required this.onMenuPressed,
    required this.viewModel,
    super.key,
  });

  final DateTime today;
  final Animation<double> drawerProgress;
  final VoidCallback onMenuPressed;
  final AiEntryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFEFEFE),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width =
              constraints.maxWidth > 480 ? 480.0 : constraints.maxWidth;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: width),
              child: SafeArea(
                minimum: const EdgeInsets.only(top: 44, bottom: 4),
                child: ListenableBuilder(
                  listenable: viewModel,
                  builder: (context, _) => Column(
                    children: [
                      HomeHeader(
                        drawerProgress: drawerProgress,
                        onMenuPressed: onMenuPressed,
                        balance: viewModel.totalWalletBalance,
                        currencyCode: viewModel.walletCurrencyCode,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 40),
                          child: DailyEntrySection(
                            dateLabel: _dateLabel(viewModel.selectedDate),
                            entries: viewModel.entries,
                            isLoading: viewModel.isLoading,
                          ),
                        ),
                      ),
                      AiRequestQuotaLabel(
                        remaining: viewModel.remainingRequests,
                        unlimited: viewModel.hasUnlimitedAiRequests,
                      ),
                      const SizedBox(height: 6),
                      ChatInputBar(
                        isSubmitting: viewModel.isSubmitting,
                        isQuotaExhausted: !viewModel.hasUnlimitedAiRequests &&
                            viewModel.remainingRequests == 0,
                        onSubmit: (message) => _submit(context, message),
                        onManualEntryRequested: () => _addManual(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _dateLabel(DateTime selectedDate) {
    return DateUtils.isSameDay(selectedDate, today)
        ? 'Today, ${DateFormat('d MMMM').format(selectedDate)}'
        : DateFormat('EEEE, d MMMM').format(selectedDate);
  }

  Future<bool> _submit(BuildContext context, String message) async {
    try {
      final result = await viewModel.submit(message);
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
        await _cancelPendingRequest(error.requestId!);
        return false;
      }
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
        return false;
      } catch (retryError) {
        if (context.mounted) showErrorToast(context, retryError);
        return false;
      }
    } on InsufficientFundsException {
      if (context.mounted) _showInsufficientFunds(context);
      return false;
    } on AiEntryException catch (error) {
      if (context.mounted) {
        showAppToast(context, error.message, type: AppToastType.error);
      }
      return false;
    } catch (error) {
      if (context.mounted) showErrorToast(context, error);
      return false;
    }
  }

  Future<void> _addManual(BuildContext context) async {
    try {
      final categories = await viewModel.manualEntryCategories();
      if (!context.mounted) return;
      final input = await ManualEntrySheet.show(
        context,
        categories: categories,
        targetDate: viewModel.selectedDate,
      );
      if (input == null) return;
      try {
        await viewModel.addManualEntry(input);
      } on WalletSelectionRequiredException catch (error) {
        if (!context.mounted) return;
        final funding = await _chooseFunding(context, error.requiredAmount);
        if (funding == null) return;
        await viewModel.addManualEntry(input.copyWith(
          sourceWalletId: funding.walletId,
          useAllWallets: funding.useAllWallets,
        ));
      }
      if (context.mounted) {
        showSuccessToast(context, 'Entry added.');
      }
    } on InsufficientFundsException {
      if (context.mounted) _showInsufficientFunds(context);
    } catch (error) {
      if (context.mounted) showErrorToast(context, error);
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

  Future<void> _cancelPendingRequest(String requestId) async {
    try {
      await viewModel.cancelPendingRequest(requestId);
    } catch (_) {}
  }

  void _showInsufficientFunds(BuildContext context) {
    showAppToast(
      context,
      'Insufficient funds across all wallets.',
      type: AppToastType.error,
    );
  }
}
