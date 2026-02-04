import 'package:budgets/features/planning/data/datasources/budget_history_datasource.dart';
import 'package:budgets/features/planning/domain/models/budget_history_model.dart';
import 'package:budgets/features/planning/domain/providers/budget_history_provider.dart';
import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

class BudgetHistoryCard extends ConsumerWidget {
  final DateTime date;

  const BudgetHistoryCard({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodMonth = getPeriodMonthString(date);
    final historyAsync = ref.watch(budgetHistoryForMonthProvider(periodMonth));
    final currencyState = ref.watch(currencyControllerProvider).value;
    final currencyCode = currencyState?.code ?? 'MGA';
    final rate = currencyState?.rateFor(currencyCode) ?? 1.0;

    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
            'Budgets du mois',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: textColor?.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 2.h),
          // Content
          historyAsync.when(
            data: (history) {
              if (history.isEmpty) {
                return _buildEmptyState(context, textColor);
              }
              return _buildHistoryList(
                context,
                history,
                textColor,
                isDarkMode,
                rate,
                currencyCode,
              );
            },
            loading: () => _buildLoadingSkeleton(context, isDarkMode),
            error: (error, stack) => _buildErrorState(context, textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color? textColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 24.sp,
              color: textColor?.withValues(alpha: 0.3),
            ),
            SizedBox(height: 1.h),
            Text(
              'Aucun budget enregistré pour ce mois',
              style: TextStyle(
                fontSize: 14.sp,
                color: textColor?.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Color? textColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Center(
        child: Text(
          'Erreur lors du chargement',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.red.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context, bool isDarkMode) {
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 1.5.h),
            child: Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 2.h,
                        width: 30.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Container(
                        height: 1.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    List<BudgetHistory> history,
    Color? textColor,
    bool isDarkMode,
    double rate,
    String currencyCode,
  ) {
    return Column(
      children: history.map((item) {
        return _buildBudgetItem(
          context,
          item,
          textColor,
          isDarkMode,
          rate,
          currencyCode,
        );
      }).toList(),
    );
  }

  Widget _buildBudgetItem(
    BuildContext context,
    BudgetHistory item,
    Color? textColor,
    bool isDarkMode,
    double rate,
    String currencyCode,
  ) {
    final progress = (item.percentageUsed.clamp(0.0, 100.0) / 100.0);
    final spent = convertFromMga(item.spentAsDouble, rate);
    final amount = convertFromMga(item.amountAsDouble, rate);

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceDim,
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 2.w,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(1.5.w),
                    child: Center(
                      child: Text(
                        item.category?.emoji ?? '🏷️',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ),
                  ),
                  Text(
                    item.category?.name ?? 'Catégorie inconnue',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              Text(
                '${formatAmountValue(spent)} / ${formatAmountValue(amount)} $currencyCode',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          _buildProgressBar(context, progress),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress) {
    Color getProgressColor() {
      if (progress > 0.9) return Colors.red;
      if (progress > 0.7) return Colors.orange;
      return Theme.of(context).primaryColor;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: progress),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        builder: (context, value, _) => LinearProgressIndicator(
          value: value,
          minHeight: 1.h,
          backgroundColor: Theme.of(context).colorScheme.surfaceDim,
          valueColor: AlwaysStoppedAnimation<Color>(getProgressColor()),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}
