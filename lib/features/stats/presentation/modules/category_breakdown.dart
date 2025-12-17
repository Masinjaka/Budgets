import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CategoryBreakdown extends StatelessWidget {
  final Map<String, double> expensesByCategory;
  final Map<String, double> incomeByCategory;
  final Map<String, String> categoryColors;
  final Map<String, String> categoryEmojis;

  const CategoryBreakdown({
    super.key,
    required this.expensesByCategory,
    required this.incomeByCategory,
    required this.categoryColors,
    required this.categoryEmojis,
  });

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
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppTheme.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final surfaceDim = Theme.of(context).colorScheme.surface;

    // Calculate totals
    final totalExpenses =
        expensesByCategory.values.fold(0.0, (sum, amount) => sum + amount);
    final totalIncome =
        incomeByCategory.values.fold(0.0, (sum, amount) => sum + amount);

    // Sort categories by amount (descending)
    final sortedExpenses = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sortedIncome = incomeByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      color: surfaceDim,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transactions par catégorie',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 2.h),

            // Expenses section
            if (sortedExpenses.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    width: 1.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Dépenses',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatAmount(totalExpenses),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              ...sortedExpenses.take(5).map((entry) {
                final percentage = (entry.value / totalExpenses * 100);
                final color =
                    _parseColor(categoryColors[entry.key] ?? '#10B981');
                final emoji = categoryEmojis[entry.key] ?? '💰';

                return Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
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
              if (sortedExpenses.length > 5) ...[
                SizedBox(height: 0.5.h),
                Text(
                  '+${sortedExpenses.length - 5} autres catégories',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: textColor?.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              SizedBox(height: 2.h),
            ],

            // Income section
            if (sortedIncome.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    width: 1.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Revenus',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatAmount(totalIncome),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              ...sortedIncome.take(5).map((entry) {
                final percentage = (entry.value / totalIncome * 100);
                final color =
                    _parseColor(categoryColors[entry.key] ?? '#10B981');
                final emoji = categoryEmojis[entry.key] ?? '💰';

                return Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
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
              if (sortedIncome.length > 5) ...[
                SizedBox(height: 0.5.h),
                Text(
                  '+${sortedIncome.length - 5} autres catégories',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: textColor?.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],

            // Empty state
            if (sortedExpenses.isEmpty && sortedIncome.isEmpty) ...[
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 40.sp,
                        color: textColor?.withValues(alpha: 0.3),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Aucune transaction pour cette période',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: textColor?.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem({
    required String emoji,
    required String name,
    required double amount,
    required double percentage,
    required Color color,
    required Color? textColor,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: 18.sp),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1.w),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: color.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 0.8.h,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              _formatAmount(amount),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
