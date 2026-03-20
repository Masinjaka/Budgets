import 'package:budgets/core/paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionSearchIncomeEmptyState extends StatelessWidget {
  final bool hasFilters;

  const TransactionSearchIncomeEmptyState({
    super.key,
    required this.hasFilters,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                      isDark ? AppPaths.noIncomeDark : AppPaths.noIncomeLight)
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 400.ms),
              Text(
                hasFilters ? 'Aucun revenu' : 'Aucun revenu enregistré',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 22.5.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: 500.ms,
                    delay: 200.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeIn(duration: 400.ms, delay: 200.ms),
              SizedBox(height: 2.h),
              Text(
                hasFilters
                    ? 'Essayez de modifier votre recherche ou vos catégories'
                    : 'Commencez par ajouter vos premiers revenus',
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
                  .fadeIn(duration: 400.ms, delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
