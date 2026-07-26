import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/animated_finance_entry_list.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/daily_entry_header.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budgets/l10n/app_localizations_context.dart';

class DailyEntrySection extends StatelessWidget {
  const DailyEntrySection({
    required this.dateLabel,
    required this.entries,
    required this.isLoading,
    this.controller,
    this.collapseProgress,
    this.expandedSurfaceRadius = 0,
    this.onEntryTap,
    this.currencyState,
    super.key,
  });

  final String dateLabel;
  final List<FinanceEntry> entries;
  final bool isLoading;
  final ScrollController? controller;
  final ValueListenable<double>? collapseProgress;
  final double expandedSurfaceRadius;
  final ValueChanged<FinanceEntry>? onEntryTap;
  final CurrencyState? currencyState;

  static const initialTopSpacing = 20.0;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const Key('transaction-scroll-view'),
      controller: controller,
      slivers: [
        const SliverToBoxAdapter(
          child: SizedBox(height: initialTopSpacing),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: DailyEntryHeader(
            dateLabel: dateLabel,
            summary: _summary(context),
            collapseProgress: collapseProgress,
            pinOffset: initialTopSpacing,
            expandedRadius: expandedSurfaceRadius,
          ),
        ),
        if (isLoading)
          SliverToBoxAdapter(child: _loadingState())
        else if (entries.isEmpty)
          SliverToBoxAdapter(child: _emptyState(context))
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            sliver: AnimatedFinanceEntryList(
              entries: entries,
              onEntryTap: onEntryTap,
              currencyState: currencyState,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  Widget _loadingState() => const Padding(
        padding: EdgeInsets.only(top: 28),
        child: Center(
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );

  Widget _emptyState(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 28),
        child: Center(
          child: Text(
            context.l10n.noEntriesForDate,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: AppTypography.supporting,
            ),
          ),
        ),
      );

  String _summary(BuildContext context) {
    final localizations = context.l10n;
    final expenses = entries.where((entry) => entry.isExpense).length;
    final incomes = entries.where((entry) => entry.isIncome).length;
    final transfers = entries.where((entry) => entry.isTransfer).length;
    if (transfers == entries.length) {
      return localizations.transferCount(transfers);
    }
    if (incomes == 0) {
      if (transfers > 0) return localizations.entryCount(entries.length);
      return localizations.expenseCount(expenses);
    }
    if (expenses == 0) {
      if (transfers > 0) return localizations.entryCount(entries.length);
      return localizations.incomeCount(incomes);
    }
    return localizations.entryCount(entries.length);
  }
}
