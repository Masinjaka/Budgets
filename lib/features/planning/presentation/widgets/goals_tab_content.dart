import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/planning/domain/models/goal_model.dart';
import 'package:budgets/features/planning/domain/providers/goal_provider.dart';
import 'package:budgets/features/planning/presentation/widgets/add_goal_bottom_sheet.dart';
import 'package:budgets/features/planning/presentation/widgets/planning_common_widgets.dart';
import 'package:budgets/features/categories/data/datasource/category_api.dart'
    as category_api;
import 'package:budgets/core/constants.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgets/features/stats/domain/providers/stats_provider.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Goals tab content widget for the planning page
class GoalsTabContent extends ConsumerWidget {
  const GoalsTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsyncValue = ref.watch(goalsProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: switch (goalsAsyncValue) {
              AsyncData(:final value) => _buildGoalList(context, value, ref),
              AsyncError(:final error) => Center(
                  child: Text('Erreur: $error',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ),
              _ => PlanningListSkeleton(itemHeight: 15.h),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalList(BuildContext context, List<Goal> goals, WidgetRef ref) {
    if (goals.isEmpty) {
      return const PlanningEmptyState(
        icon: Icons.flag_outlined,
        title: 'Aucun objectif défini',
        subtitle: 'Définissez vos objectifs d\'épargne pour les atteindre',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 2.h),
      itemCount: goals.length,
      itemBuilder: (context, index) =>
          _GoalListItem(goal: goals[index], index: index),
    );
  }
}

/// Individual goal list item with swipe-to-delete
class _GoalListItem extends ConsumerWidget {
  final Goal goal;
  final int index;

  const _GoalListItem({
    required this.goal,
    required this.index,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<bool?> _showDeleteDialog(BuildContext context) async {
    return showAnimatedDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'objectif'),
        content:
            const Text('Êtes-vous sûr de vouloir supprimer cet objectif ?'),
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
    final hasNetworkImage = goal.imagePath != null &&
        goal.imagePath!.isNotEmpty &&
        goal.imagePath!.startsWith('http');
    final goalAmountMga = parseAmountInput(goal.goalAmount ?? '0');
    final currentAmountMga = parseAmountInput(goal.currentAmount ?? '0');
    final goalAmount = convertFromMga(goalAmountMga, rate);
    final currentAmount = convertFromMga(currentAmountMga, rate);
    final progress =
        goalAmountMga > 0 ? (currentAmountMga / goalAmountMga).clamp(0.0, 1.0) : 0.0;

    return Dismissible(
      key: Key(goal.id ?? DateTime.now().toString()),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {DismissDirection.endToStart: 0.7},
      confirmDismiss: (direction) async {
        final result = await _showDeleteDialog(context);
        if (result == true && goal.id != null) {
          await ref.read(goalsProvider.notifier).deleteSomeGoal(goal.id!);
        }
        return false;
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
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(4.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 15.h,
              margin: EdgeInsets.all(2.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2.5.w),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasNetworkImage)
                      CachedNetworkImage(
                        imageUrl: goal.imagePath!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Theme.of(context).colorScheme.surfaceDim,
                          highlightColor: Theme.of(context)
                              .colorScheme
                              .surface
                              .withValues(alpha: 0.9),
                          direction: ShimmerDirection.ltr,
                          period: 1000.ms,
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/image-placeholder.png',
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Image.asset(
                        'assets/images/image-placeholder.png',
                        fit: BoxFit.cover,
                      ),
                    Positioned(
                      top: 1.w,
                      right: 1.w,
                      child: GestureDetector(
                        onTap: () => _showEditBottomSheet(context),
                        child: Container(
                          padding: EdgeInsets.all(1.5.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20.w),
                          ),
                          child: Icon(Icons.edit_outlined,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              size: 18.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, ref, rate, currencyCode),
                  SizedBox(height: 1.h),
                  _buildAmountRow(
                    context,
                    currentAmount,
                    goalAmount,
                    currencyCode,
                  ),
                  SizedBox(height: 1.h),
                  PlanningProgressBar(progress: progress),
                  SizedBox(height: 0.5.h),
                  Text('${(progress * 100).toStringAsFixed(0)}% atteint',
                      style: TextStyle(
                          fontSize: 12.sp, color: Theme.of(context).hintColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: (50 * index).ms)
        .fade(duration: 200.ms)
        .slideY(begin: 0.3, duration: 200.ms, curve: Curves.easeOut);
  }

  void _showEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddGoalBottomSheet(goal: goal),
    );
  }

  Future<void> _showAddAmountDialog(
      BuildContext context,
      WidgetRef ref,
      double rate,
      String currencyCode) async {
    final amountController = TextEditingController();
    final currentAmountMga = parseAmountInput(goal.currentAmount ?? '0');
    final goalAmountMga = parseAmountInput(goal.goalAmount ?? '0');
    final currentAmount = convertFromMga(currentAmountMga, rate);
    final goalAmount = convertFromMga(goalAmountMga, rate);
    final remaining = goalAmount - currentAmount;

    final result = await showAnimatedDialog<double>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 8.w),
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.w),
        ),
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajouter à ${goal.name ?? 'l\'objectif'}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Montant actuel',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: formatAmountValue(currentAmount),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        TextSpan(
                          text: ' $currencyCode',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Objectif',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: formatAmountValue(goalAmount),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        TextSpan(
                          text: ' $currencyCode',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Restant',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: formatAmountValue(remaining),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        TextSpan(
                          text: ' $currencyCode',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              CustomTextField(
                title: Text(
                  'Montant à ajouter',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                controller: amountController,
                hint: '0 $currencyCode',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    text: 'Annuler',
                    onPressed: () => Navigator.of(ctx).pop(),
                    backgroundColor: Theme.of(context).cardColor,
                    width: 15.h,
                    foregroundColor:
                        Theme.of(context).textTheme.bodyLarge?.color,
                    borderColor: Colors.transparent,
                  ),
                  SizedBox(width: 2.w),
                  CustomButton(
                    text: 'Ajouter',
                    onPressed: () {
                      final amount = parseAmountInput(amountController.text);
                      if (amount > 0) {
                        Navigator.of(ctx).pop(amount);
                      }
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    width: 15.h,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      final balance = await ref.read(allTimeBalanceProvider.future);
      final resultMga = convertToMga(result, rate);

      if (balance < resultMga) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Solde insuffisant pour cette opération')),
          );
        }
        return;
      }

      final currentAmountMga = parseAmountInput(goal.currentAmount ?? '0');
      final newAmount = currentAmountMga + resultMga;
      final updatedGoal = goal.copyWith(
        currentAmount: newAmount.toStringAsFixed(0),
      );

      try {
        // Ensure the savings category exists before adding transaction
        await category_api.ensureSavingsCategoryExists();

        await ref.read(goalsProvider.notifier).updateSomeGoal(updatedGoal);

        // Add transaction to deduct from user balance
        await ref.read(transactionsProvider.notifier).addUserTransaction(
              resultMga.toStringAsFixed(0),
              'Contribution à ${goal.name}',
              SystemCategories.savingsCategoryName,
              null, // No subcategories
              TransactionType.expense,
            );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Montant ajouté et déduit du solde global')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, double rate, String currencyCode) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(goal.name ?? 'Objectif',
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color)),
              if (goal.dateAim != null)
                Text('D\'ici le ${_formatDate(goal.dateAim!)}',
                    style: TextStyle(
                        fontSize: 13.sp, color: Theme.of(context).hintColor)),
            ],
          ),
        ),
        InkWell(
          onTap: () => _showAddAmountDialog(
            context,
            ref,
            rate,
            currencyCode,
          ),
          child: Icon(
            Icons.add_circle_outline_rounded,
            color: Theme.of(context).textTheme.bodyMedium?.color,
            size: 20.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(BuildContext context, double currentAmount,
      double goalAmount, String currencyCode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: formatAmountValue(currentAmount),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              TextSpan(
                text: ' $currencyCode',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: formatAmountValue(goalAmount),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              TextSpan(
                text: ' $currencyCode',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
