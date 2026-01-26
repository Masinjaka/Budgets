import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NewCategoryBreakdown extends StatefulWidget {
  final Map<String, double> expensesByCategory;
  final Map<String, double> incomeByCategory;
  final Map<String, String> categoryColors;
  final Map<String, String> categoryEmojis;

  const NewCategoryBreakdown({
    super.key,
    required this.expensesByCategory,
    required this.incomeByCategory,
    required this.categoryColors,
    required this.categoryEmojis,
  });

  @override
  State<NewCategoryBreakdown> createState() => _NewCategoryBreakdownState();
}

class _NewCategoryBreakdownState extends State<NewCategoryBreakdown> {
  bool _showExpenses = true;
  final GlobalKey _cardKey = GlobalKey();

  String _formatAmount(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'MGA',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  void _switchTab(bool showExpenses) {
    if (_showExpenses == showExpenses) return;
    setState(() => _showExpenses = showExpenses);
    // Smoothly scroll the card into view after switching tabs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_cardKey.currentContext != null) {
        Scrollable.ensureVisible(
          _cardKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final progressColor = isDarkMode ? Colors.white : Colors.black;

    // Get current data based on toggle
    final currentData =
        _showExpenses ? widget.expensesByCategory : widget.incomeByCategory;

    // Calculate total
    final total = currentData.values.fold(0.0, (sum, amount) => sum + amount);

    // Sort by amount descending
    final sortedEntries = currentData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      key: _cardKey,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Catégories',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: textColor?.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 1.5.h),
          // Toggle buttons - pill shaped, left aligned
          Row(
            children: [
              GestureDetector(
                onTap: () => _switchTab(true),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: _showExpenses ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                    border: _showExpenses
                        ? null
                        : Border.all(
                            color: textColor?.withValues(alpha: 0.3) ??
                                Colors.grey,
                          ),
                  ),
                  child: Text(
                    'Dépense',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: _showExpenses
                          ? Theme.of(context).colorScheme.onPrimary
                          : textColor,
                    ),
                  ),
                )
                    .animate(key: ValueKey('expense-$_showExpenses'))
                    .scaleX(
                      begin: _showExpenses ? 0.95 : 1.0,
                      end: 1.0,
                      duration: 200.ms,
                      curve: Curves.easeOut,
                    ),
              ),
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: () => _switchTab(false),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: !_showExpenses ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                    border: !_showExpenses
                        ? null
                        : Border.all(
                            color: textColor?.withValues(alpha: 0.3) ??
                                Colors.grey,
                          ),
                  ),
                  child: Text(
                    'Revenue',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: !_showExpenses
                          ? Theme.of(context).colorScheme.onPrimary
                          : textColor,
                    ),
                  ),
                )
                    .animate(key: ValueKey('income-${!_showExpenses}'))
                    .scaleX(
                      begin: !_showExpenses ? 0.95 : 1.0,
                      end: 1.0,
                      duration: 200.ms,
                      curve: Curves.easeOut,
                    ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Category list
          if (sortedEntries.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Center(
                child: Text(
                  _showExpenses
                      ? 'Aucune dépense ce mois'
                      : 'Aucun revenu ce mois',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: textColor?.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          else
            ...sortedEntries.map((entry) {
              final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
              final emoji = widget.categoryEmojis[entry.key] ?? '💰';

              return Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: _buildCategoryItem(
                  emoji: emoji,
                  name: entry.key,
                  amount: entry.value,
                  percentage: percentage,
                  progressColor: progressColor,
                  textColor: textColor,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required String emoji,
    required String name,
    required double amount,
    required double percentage,
    required Color progressColor,
    Color? textColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Emoji container - circular with surface variant background
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceDim,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        // Name, amount, progress bar and percentage
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name and amount row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatAmount(amount),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              // Progress bar and percentage row
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: progressColor.withValues(alpha: 0.1),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(progressColor),
                        minHeight: 0.6.h,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: textColor?.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
