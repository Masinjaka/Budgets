import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
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

  String _formatAmount(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'MGA',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return AppTheme.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    // Get current data based on toggle
    final currentData =
        _showExpenses ? widget.expensesByCategory : widget.incomeByCategory;

    // Calculate total
    final total = currentData.values.fold(0.0, (sum, amount) => sum + amount);

    // Sort by amount descending
    final sortedEntries = currentData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle buttons
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showExpenses = true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color:
                            _showExpenses ? primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Dépense',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: _showExpenses
                                ? Theme.of(context).colorScheme.onPrimary
                                : textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showExpenses = false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color:
                            !_showExpenses ? primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Revenue',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: !_showExpenses
                                ? Theme.of(context).colorScheme.onPrimary
                                : textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
              final color =
                  _parseColor(widget.categoryColors[entry.key] ?? '#10B981');
              final emoji = widget.categoryEmojis[entry.key] ?? '💰';

              return Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: _buildCategoryItem(
                  emoji: emoji,
                  name: entry.key,
                  amount: entry.value,
                  percentage: percentage,
                  color: color,
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
    required Color color,
    Color? textColor,
  }) {
    return Column(
      children: [
        Row(
          children: [
            // Emoji container
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            // Name and percentage
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: textColor?.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              _formatAmount(amount),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: _showExpenses ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 0.8.h,
          ),
        ),
      ],
    );
  }
}
