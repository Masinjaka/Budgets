import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/features/planning/domain/models/budget_model.dart';
import 'package:budgets/features/planning/domain/providers/budget_provider.dart';
import 'package:budgets/features/planning/presentation/widgets/add_budget_bottom_sheet.dart';
import 'package:budgets/features/planning/presentation/widgets/planning_common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Budgets tab content widget for the planning page
class BudgetsTabContent extends ConsumerWidget {
  const BudgetsTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsyncValue = ref.watch(budgetsProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: switch (budgetsAsyncValue) {
              AsyncData(:final value) => _buildBudgetList(context, value, ref),
              AsyncError(:final error) => Center(
                  child: Text('Erreur: $error',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ),
              _ => PlanningListSkeleton(itemHeight: 12.h),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetList(
      BuildContext context, List<Budget> budgets, WidgetRef ref) {
    if (budgets.isEmpty) {
      return const PlanningEmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Aucun budget créé',
        subtitle: 'Créez votre premier budget pour mieux gérer vos dépenses',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 2.h),
      itemCount: budgets.length,
      itemBuilder: (context, index) =>
          _BudgetListItem(budget: budgets[index], index: index),
    );
  }
}

/// Individual budget list item with swipe-to-delete
class _BudgetListItem extends ConsumerWidget {
  final Budget budget;
  final int index;

  const _BudgetListItem({
    required this.budget,
    required this.index,
  });

  String _periodLabel(String? period) {
    switch (period) {
      case 'weekly':
        return 'Hebdomadaire';
      case 'biweekly':
        return 'Toutes les 2 semaines';
      case 'bimonthly':
        return 'Bimensuel';
      case 'yearly':
        return 'Annuel';
      case 'monthly':
      default:
        return 'Mensuel';
    }
  }

  Future<bool?> _showDeleteDialog(BuildContext context) async {
    return showAnimatedDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le budget'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce budget ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyControllerProvider).value;
    final currencyCode = currencyState?.code ?? 'MGA';
    final rate = currencyState?.rateFor(currencyCode) ?? 1.0;
    final category = budget.category;
    final amountMga = double.tryParse(budget.amount ?? '0') ?? 0;
    final spentMga = double.tryParse(budget.amountSpent ?? '0') ?? 0;
    final amount = convertFromMga(amountMga, rate);
    final spent = convertFromMga(spentMga, rate);
    final progress = amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0.0;

    return Dismissible(
      key: Key(budget.id?.toString() ?? DateTime.now().toString()),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {DismissDirection.endToStart: 0.7},
      confirmDismiss: (direction) async {
        final result = await _showDeleteDialog(context);
        if (result == true && budget.id != null) {
          await ref.read(budgetsProvider.notifier).deleteSomeBudget(budget.id!);
        }
        return false; // Don't auto-dismiss, provider refresh handles UI
      },
      background: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 5.w),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4.w),
        ),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 18.sp),
      ),
      child: GestureDetector(
        onTap: () => _showEditDialog(context),
        child: PlanningCard(
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
                          color: Theme.of(context).colorScheme.surfaceDim,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(1.5.w),
                        child: Center(
                          child: Text(
                            category?.emoji ?? '🏷️',
                            style: TextStyle(fontSize: 18.sp),
                          ),
                        ),
                      ),
                      Text(category?.name ?? 'Catégorie inconnue',
                          style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${formatAmountValue(spent)} / ${formatAmountValue(amount)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                            ),
                            TextSpan(
                              text: ' $currencyCode',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 0.4.h),
                      Text(
                        _periodLabel(budget.period),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),
              PlanningProgressBar(progress: progress, useWarningColors: true),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (50 * index).ms)
        .fade(duration: 200.ms)
        .slideY(begin: 0.3, duration: 200.ms, curve: Curves.easeOut);
  }

  void _showEditDialog(BuildContext context) {
    AddBudgetBottomSheet.show(context, budget: budget);
  }
}
