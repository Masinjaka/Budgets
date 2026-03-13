import 'dart:async';

import 'package:budgets/core/paths.dart';
import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/planning/domain/models/goal_model.dart';
import 'package:budgets/features/planning/domain/providers/goal_provider.dart';
import 'package:budgets/features/planning/presentation/widgets/add_goal_bottom_sheet.dart';
import 'package:budgets/features/planning/presentation/widgets/planning_common_widgets.dart';
import 'package:budgets/features/categories/data/datasource/category_api.dart'
    as category_api;
import 'package:budgets/core/constants.dart';
import 'package:budgets/widgets/animated_amount_field.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/delete_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgets/features/stats/domain/providers/stats_provider.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibration/vibration.dart';

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
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String imagePath = isDarkMode ? AppPaths.noPlanDark : AppPaths.noPlanLight;

    if (goals.isEmpty) {
      return PlanningEmptyState(
        imagePath: imagePath,
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
class _GoalListItem extends ConsumerStatefulWidget {
  final Goal goal;
  final int index;

  const _GoalListItem({
    required this.goal,
    required this.index,
  });

  @override
  ConsumerState<_GoalListItem> createState() => _GoalListItemState();
}

class _GoalListItemState extends ConsumerState<_GoalListItem>
    with SingleTickerProviderStateMixin {
  static const String _deleteActionLabel = 'Supprimer';
  static const double _deletePaneExtentRatio = 0.20;

  bool _hasTriggeredHalfSwipeHaptic = false;
  bool _canVibrate = true;
  double _swipeProgress = 0;
  late final SlidableController _slidableController;

  @override
  void initState() {
    super.initState();
    _slidableController = SlidableController(this)
      ..animation.addListener(_handleSlideAnimation);
    _initializeVibrationSupport();
  }

  @override
  void dispose() {
    _slidableController.animation.removeListener(_handleSlideAnimation);
    _slidableController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<bool> _showDeleteDialog(BuildContext context) {
    return showDeleteConfirmationDialog(
      context: context,
      title: 'Supprimer l\'objectif',
      message: 'Êtes-vous sûr de vouloir supprimer cet objectif ?',
    );
  }

  Future<void> _initializeVibrationSupport() async {
    try {
      final canVibrate = await Vibration.hasVibrator();
      _canVibrate = canVibrate == true;
    } catch (_) {
      _canVibrate = false;
    }
  }

  Future<void> _triggerHalfSwipeVibration() async {
    if (!_canVibrate) return;
    try {
      await Vibration.vibrate(duration: 30);
    } catch (_) {
      // Ignore vibration failures to keep delete swipe stable.
    }
  }

  void _handleSlideAnimation() {
    final ratio = _slidableController.ratio.abs();
    final progress = (ratio / _deletePaneExtentRatio).clamp(0.0, 1.0);

    if ((progress - _swipeProgress).abs() > 0.005 && mounted) {
      setState(() {
        _swipeProgress = progress;
      });
    }

    if (!_hasTriggeredHalfSwipeHaptic && progress >= 0.5) {
      unawaited(_triggerHalfSwipeVibration());
      _hasTriggeredHalfSwipeHaptic = true;
      return;
    }

    if (_hasTriggeredHalfSwipeHaptic && progress < 0.2) {
      _hasTriggeredHalfSwipeHaptic = false;
    }
  }

  Future<void> _resetSwipeFeedbackState() async {
    if (_hasTriggeredHalfSwipeHaptic || _swipeProgress > 0) {
      if (mounted) {
        setState(() {
          _hasTriggeredHalfSwipeHaptic = false;
          _swipeProgress = 0;
        });
      } else {
        _hasTriggeredHalfSwipeHaptic = false;
        _swipeProgress = 0;
      }
    }

    if (_slidableController.ratio != 0) {
      await _slidableController.close(duration: 120.ms);
    }
  }

  Future<void> _handleDeleteAction() async {
    final goal = widget.goal;
    final shouldDelete = await _showDeleteDialog(context);
    if (!shouldDelete || goal.id == null) {
      await _resetSwipeFeedbackState();
      return;
    }

    try {
      await ref.read(goalsProvider.notifier).deleteSomeGoal(goal.id!);
      if (mounted) {
        await _resetSwipeFeedbackState();
      }
    } catch (e) {
      debugPrint('Error deleting goal: $e');
      if (mounted) {
        await _resetSwipeFeedbackState();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final cardBorderRadius = BorderRadius.circular(4.w);
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
    final progress = goalAmountMga > 0
        ? (currentAmountMga / goalAmountMga).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: ClipRRect(
        borderRadius: cardBorderRadius,
        clipBehavior: Clip.antiAlias,
        child: Slidable(
          controller: _slidableController,
          key: Key(goal.id ?? DateTime.now().toString()),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: _deletePaneExtentRatio,
            children: [
              CustomSlidableAction(
                autoClose: false,
                padding: EdgeInsets.only(left: 1.w),
                backgroundColor: Colors.transparent,
                onPressed: (_) => _handleDeleteAction(),
                child: SizedBox.expand(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Icon(Icons.delete_outline,
                            color: Colors.white, size: 18.sp),
                      ),
                    ],
                  ),
                ).animate(target: _swipeProgress).custom(
                      duration: 120.ms,
                      curve: Curves.linear,
                      builder: (context, value, child) => DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color.lerp(Colors.orange, Colors.red, value),
                          borderRadius: cardBorderRadius,
                        ),
                        child: child,
                      ),
                    ),
              ),
            ],
          ),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: cardBorderRadius,
            clipBehavior: Clip.antiAlias,
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
                              baseColor:
                                  Theme.of(context).colorScheme.surfaceDim,
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
                            onTap: () => _showEditDialog(context),
                            child: Container(
                              padding: EdgeInsets.all(1.5.w),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(20.w),
                              ),
                              child: Icon(Icons.edit_outlined,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
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
                              fontSize: 12.sp,
                              color: Theme.of(context).hintColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: (50 * widget.index).ms)
        .fade(duration: 200.ms)
        .slideY(begin: 0.3, duration: 200.ms, curve: Curves.easeOut);
  }

  void _showEditDialog(BuildContext context) {
    AddGoalBottomSheet.show(context, goal: widget.goal);
  }

  Future<void> _showAddAmountDialog(BuildContext context, WidgetRef ref,
      double rate, String currencyCode) async {
    final goal = widget.goal;
    final amountController = AmountTextEditingController();
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
                  Text(
                    formatAmountWithCurrency(
                      currentAmount,
                      currencyCode,
                      preserveFraction: true,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
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
                  Text(
                    formatAmountWithCurrency(
                      goalAmount,
                      currencyCode,
                      preserveFraction: true,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
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
                  Text(
                    formatAmountWithCurrency(
                      remaining,
                      currencyCode,
                      preserveFraction: true,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Text(
                'Montant à ajouter',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: 1.h),
              AnimatedAmountField(
                controller: amountController,
                hint: '0',
                fontSize: 23.sp,
                height: 10.h,
                fillColor: Theme.of(context).colorScheme.surfaceDim,
                borderRadius: BorderRadius.circular(3.w),
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
          showInfoToast(context, 'Solde insuffisant pour cette opération');
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
          showSuccessToast(context, 'Montant ajouté et déduit du solde global');
        }
      } catch (e) {
        if (context.mounted) {
          showErrorToast(context, e);
        }
      }
    }
  }

  Widget _buildHeader(
      BuildContext context, WidgetRef ref, double rate, String currencyCode) {
    final goal = widget.goal;
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
              if (goal.category?.name != null)
                Text(
                  '${goal.category?.emoji ?? '🏷️'} ${goal.category?.name}',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    color: Theme.of(context).hintColor,
                  ),
                ),
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
        Text(
          formatAmountWithCurrency(
            currentAmount,
            currencyCode,
            preserveFraction: true,
          ),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          formatAmountWithCurrency(
            goalAmount,
            currencyCode,
            preserveFraction: true,
          ),
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}
