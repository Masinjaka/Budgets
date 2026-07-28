import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/features/ai_entry/presentation/view_models/ai_entry_view_model.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/daily_entry_section.dart';
import 'package:budgets/features/home/presentation/controllers/home_entry_actions.dart';
import 'package:budgets/features/home/presentation/widgets/ai_request_quota_label.dart';
import 'package:budgets/features/home/presentation/widgets/chat_input_bar.dart';
import 'package:budgets/features/home/presentation/widgets/home_collapsing_surface.dart';
import 'package:budgets/features/home/presentation/widgets/home_header.dart';
import 'package:budgets/features/notifications/presentation/view_models/finance_notification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budgets/l10n/app_localizations_context.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({
    required this.today,
    required this.drawerProgress,
    required this.onMenuPressed,
    required this.viewModel,
    required this.notificationViewModel,
    required this.onNotificationsPressed,
    required this.onFinanceChanged,
    this.currencyState,
    super.key,
  });

  final DateTime today;
  final Animation<double> drawerProgress;
  final VoidCallback onMenuPressed;
  final AiEntryViewModel viewModel;
  final FinanceNotificationViewModel notificationViewModel;
  final VoidCallback onNotificationsPressed;
  final Future<void> Function() onFinanceChanged;
  final CurrencyState? currencyState;

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  static const _collapseDistance = 72.0;
  final _scrollController = ScrollController();
  final _collapseProgress = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateCollapseProgress);
  }

  void _updateCollapseProgress() {
    final next = (_scrollController.offset / _collapseDistance).clamp(0.0, 1.0);
    if ((next - _collapseProgress.value).abs() > 0.001) {
      _collapseProgress.value = next;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateCollapseProgress);
    _scrollController.dispose();
    _collapseProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actions = HomeEntryActions(
      widget.viewModel,
      currencyState: widget.currencyState,
    );
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) => HomeCollapsingSurface(
        collapseProgress: _collapseProgress,
        header: HomeHeader(
          drawerProgress: widget.drawerProgress,
          collapseProgress: _collapseProgress,
          onMenuPressed: widget.onMenuPressed,
          balance: _displayBalance,
          notificationViewModel: widget.notificationViewModel,
          onNotificationsPressed: widget.onNotificationsPressed,
          currencyCode:
              widget.currencyState?.code ?? widget.viewModel.walletCurrencyCode,
        ),
        body: Column(
          children: [
            Expanded(
              child: DailyEntrySection(
                dateLabel: _dateLabel(
                  context,
                  widget.viewModel.selectedDate,
                ),
                entries: widget.viewModel.entries,
                isLoading: widget.viewModel.isLoading,
                controller: _scrollController,
                collapseProgress: _collapseProgress,
                expandedSurfaceRadius: HomeCollapsingSurface.expandedRadius,
                onEntryTap: (entry) async {
                  await actions.editEntry(context, entry);
                  await widget.onFinanceChanged();
                },
                currencyState: widget.currencyState,
                isFirstEntryExperience: widget.viewModel.isFirstEntryExperience,
              ),
            ),
            AiRequestQuotaLabel(
              remaining: widget.viewModel.remainingRequests,
              unlimited: widget.viewModel.hasUnlimitedAiRequests,
            ),
            const SizedBox(height: 6),
            ChatInputBar(
              isSubmitting: widget.viewModel.isSubmitting,
              isQuotaExhausted: !widget.viewModel.hasUnlimitedAiRequests &&
                  widget.viewModel.remainingRequests == 0,
              onSubmit: (message) => _refreshAfter(
                () => actions.submitMessage(context, message),
              ),
              onReceiptSubmit: (input) => _refreshAfter(
                () => actions.submitReceipt(context, input),
              ),
              onManualEntryRequested: () async {
                await actions.addManual(context);
                await widget.onFinanceChanged();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _refreshAfter(Future<bool> Function() action) async {
    final succeeded = await action();
    if (succeeded) await widget.onFinanceChanged();
    return succeeded;
  }

  String _dateLabel(BuildContext context, DateTime selectedDate) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateUtils.isSameDay(selectedDate, widget.today)
        ? context.l10n.todayWithDate(
            DateFormat('d MMMM', locale).format(selectedDate),
          )
        : DateFormat('EEEE, d MMMM', locale).format(selectedDate);
  }

  num get _displayBalance {
    final currency = widget.currencyState;
    if (currency == null) return widget.viewModel.totalWalletBalance;
    return currency.convertToSelected(
      widget.viewModel.totalWalletBalance,
      widget.viewModel.walletCurrencyCode,
    );
  }
}
