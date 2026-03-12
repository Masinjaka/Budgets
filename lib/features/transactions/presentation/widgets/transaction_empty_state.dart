import 'package:budgets/core/paths.dart';
import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Reusable empty state widget for transactions
class TransactionEmptyState extends StatelessWidget {
  final bool hasFilters;

  const TransactionEmptyState({
    super.key,
    required this.hasFilters,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String imagePath =
        isDarkMode ? AppPaths.noExpenseDark : AppPaths.noExpenseLight;
    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath)
                .animate()
                .scale(
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(
                  duration: 400.ms,
                ),
            Text(
                'Aucune dépense',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 22.5.sp,
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate()
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: 500.ms,
                    delay: 200.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeIn(
                    duration: 400.ms,
                    delay: 200.ms,
                  ),
      
              SizedBox(height: 2.h),
      
              // Description
              Text(
                'Commencez par ajouter vos premières dépense.',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16.sp,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: 500.ms,
                    delay: 400.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeIn(
                    duration: 400.ms,
                    delay: 400.ms,
                  ),
          ],
        ),
      ),
    );
  }
}

/// Reusable empty state widget for incomes with enhanced animation
class IncomeEmptyState extends StatelessWidget {
  const IncomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String imagePath =
        isDarkMode ? AppPaths.noIncomeDark : AppPaths.noIncomeLight;
    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath)
              .animate()
              .scale(
                duration: 600.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(
                duration: 400.ms,
              ),
            // Title
            Text(
              'Aucun revenu',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 22.5.sp,
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 500.ms,
                  delay: 200.ms,
                  curve: Curves.easeOutCubic,
                )
                .fadeIn(
                  duration: 400.ms,
                  delay: 200.ms,
                ),

            SizedBox(height: 2.h),

            // Description
            Text(
              'Commencez par ajouter vos premiers revenus.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 16.sp,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 500.ms,
                  delay: 400.ms,
                  curve: Curves.easeOutCubic,
                )
                .fadeIn(
                  duration: 400.ms,
                  delay: 400.ms,
                ),
          ],
        ),
      ),
    );
  }
}
