import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Reusable empty state widget for expenses
class ExpenseEmptyState extends StatelessWidget {
  final bool hasFilters;

  const ExpenseEmptyState({
    super.key,
    required this.hasFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            hasFilters
                ? 'Aucune dépense trouvée'
                : 'Aucune dépense enregistrée',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            hasFilters
                ? 'Essayez de modifier vos filtres'
                : 'Commencez par ajouter vos premières dépenses',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Reusable empty state widget for incomes with enhanced animation
class IncomeEmptyState extends StatelessWidget {
  const IncomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with animation
                Icon(
                  Icons.trending_up,
                  size: 80,
                  color: AppTheme.primaryGreen,
                ).animate().scale(
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ).fadeIn(
                  duration: 400.ms,
                ),
                
                SizedBox(height: 3.h),
                
                // Title
                Text(
                  'Aucun revenu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 500.ms,
                  delay: 200.ms,
                  curve: Curves.easeOutCubic,
                ).fadeIn(
                  duration: 400.ms,
                  delay: 200.ms,
                ),
                
                SizedBox(height: 2.h),
                
                // Description
                Text(
                  'Vous n\'avez encore enregistré aucun revenu.\nCommencez par ajouter vos premiers revenus.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16.sp,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ).animate().slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 500.ms,
                  delay: 400.ms,
                  curve: Curves.easeOutCubic,
                ).fadeIn(
                  duration: 400.ms,
                  delay: 400.ms,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
