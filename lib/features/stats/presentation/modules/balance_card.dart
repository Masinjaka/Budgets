import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class BalanceCard extends StatelessWidget {
  final String title;
  final double amount;
  final String? subtitle;
  final double? comparisonAmount;
  final double? comparisonPercentage;
  final bool? isPositiveChange;
  final Color? backgroundColor;
  final bool isLarge;
  final bool isHidden;

  const BalanceCard({
    super.key,
    required this.title,
    required this.amount,
    this.subtitle,
    this.comparisonAmount,
    this.comparisonPercentage,
    this.isPositiveChange,
    this.backgroundColor,
    this.isLarge = false,
    this.isHidden = false,
  });

  String _formatAmount(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'MGA',
      decimalDigits: 0,
    );
    return formatter.format(amount.abs());
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final surfaceDim = backgroundColor ?? Theme.of(context).colorScheme.surface;

    final isNegative = amount < 0;
    final displayColor = isNegative ? Colors.red : Theme.of(context).textTheme.bodyMedium?.color;

    return Card(
      color: surfaceDim,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(isLarge ? 6.w : 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isLarge ? 14.sp : 13.sp,
                fontWeight: FontWeight.w600,
                color: textColor?.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: isLarge ? 1.5.h : 1.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      isHidden ? '*******' : '${isNegative ? '-' : ''}${_formatAmount(amount)}',
                      key: ValueKey<bool>(isHidden),
                      style: TextStyle(
                        fontSize: isLarge ? 22.sp : 18.sp,
                        fontWeight: FontWeight.bold,
                        color: displayColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (comparisonAmount != null && comparisonPercentage != null)
                  Padding(
                    padding: EdgeInsets.only(left: 2.w),
                    child: _buildComparisonChip(),
                  ),
              ],
            ),
            if (subtitle != null) ...[
              SizedBox(height: 1.h),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: textColor?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonChip() {
    if (comparisonAmount == null ||
        comparisonPercentage == null ||
        isPositiveChange == null) {
      return const SizedBox.shrink();
    }

    final chipColor = isPositiveChange! ? AppTheme.primaryGreen : Colors.red;
    final icon = isPositiveChange! ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.sp,
            color: chipColor,
          ),
          SizedBox(width: 1.w),
          Text(
            '${comparisonPercentage!.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }
}
