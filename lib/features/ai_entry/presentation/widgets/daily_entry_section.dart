import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/animated_finance_entry_list.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/daily_entry_header.dart';
import 'package:flutter/material.dart';

class DailyEntrySection extends StatelessWidget {
  const DailyEntrySection({
    required this.dateLabel,
    required this.entries,
    required this.isLoading,
    super.key,
  });

  final String dateLabel;
  final List<FinanceEntry> entries;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const Key('transaction-scroll-view'),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
        SliverPersistentHeader(
          pinned: true,
          delegate: DailyEntryHeader(
            dateLabel: dateLabel,
            summary: _summary,
          ),
        ),
        if (isLoading)
          SliverToBoxAdapter(child: _loadingState())
        else if (entries.isEmpty)
          SliverToBoxAdapter(child: _emptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            sliver: AnimatedFinanceEntryList(entries: entries),
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

  Widget _emptyState() => const Padding(
        padding: EdgeInsets.only(top: 28),
        child: Center(
          child: Text(
            'No entries for this date',
            style: TextStyle(color: Color(0xFF777777), fontSize: 12),
          ),
        ),
      );

  String get _summary {
    final expenses = entries.where((entry) => entry.isExpense).length;
    final incomes = entries.where((entry) => entry.isIncome).length;
    final transfers = entries.where((entry) => entry.isTransfer).length;
    if (transfers == entries.length) {
      return '$transfers ${transfers == 1 ? 'transfer' : 'transfers'}';
    }
    if (incomes == 0) {
      if (transfers > 0) return '${entries.length} entries';
      return '$expenses ${expenses == 1 ? 'expense' : 'expenses'}';
    }
    if (expenses == 0) {
      if (transfers > 0) return '${entries.length} entries';
      return '$incomes ${incomes == 1 ? 'income' : 'incomes'}';
    }
    return '${entries.length} entries';
  }
}
