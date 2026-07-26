import 'dart:async';

import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/planning/domain/models/budget_model.dart';
import 'package:budgets/features/planning/domain/providers/budget_provider.dart';
import 'package:budgets/features/planning/presentation/widgets/add_budget_bottom_sheet.dart';
import 'package:budgets/features/planning/presentation/widgets/planning_common_widgets.dart';
import 'package:budgets/widgets/delete_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vibration/vibration.dart';

class BudgetListItem extends ConsumerStatefulWidget {
  final Budget budget;
  final int index;

  const BudgetListItem({
    super.key,
    required this.budget,
    required this.index,
  });

  @override
  ConsumerState<BudgetListItem> createState() => _BudgetListItemState();
}

class _BudgetListItemState extends ConsumerState<BudgetListItem>
    with SingleTickerProviderStateMixin {
  static const double _deletePaneExtentRatio = 0.20;
  static const _dismissDuration = Duration(milliseconds: 220);

  bool _hasTriggeredHalfSwipeHaptic = false;
  bool _canVibrate = true;
  double _swipeProgress = 0;
  bool _isDismissing = false;
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

  Future<bool> _showDeleteDialog(BuildContext context) {
    return showDeleteConfirmationDialog(
      context: context,
      title: 'Supprimer le budget',
      message: 'Êtes-vous sûr de vouloir supprimer ce budget ?',
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
    if (!_canVibrate) {
      return;
    }
    try {
      await Vibration.vibrate(duration: 30);
    } catch (_) {
      // Keep swipe/delete flow resilient if vibration fails.
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
    if (_isDismissing) {
      return;
    }
    final budget = widget.budget;
    final shouldDelete = await _showDeleteDialog(context);
    if (!shouldDelete || budget.id == null) {
      await _resetSwipeFeedbackState();
      return;
    }

    await _resetSwipeFeedbackState();
    if (!mounted) {
      return;
    }

    setState(() {
      _isDismissing = true;
    });

    await Future.delayed(_dismissDuration);

    try {
      await ref.read(budgetsProvider.notifier).deleteSomeBudget(budget.id!);
    } catch (e) {
      debugPrint('Error deleting budget: $e');
      if (mounted) {
        setState(() {
          _isDismissing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final budget = widget.budget;
    final cardBorderRadius = BorderRadius.circular(16);
    final currencyState = ref.watch(currencyControllerProvider).value;
    final currencyCode = currencyState?.code ?? 'MGA';
    final rate = currencyState?.rateFor(currencyCode) ?? 1.0;
    final category = budget.category;
    final amountMga = double.tryParse(budget.amount ?? '0') ?? 0;
    final spentMga = double.tryParse(budget.amountSpent ?? '0') ?? 0;
    final amount = convertFromMga(amountMga, rate);
    final spent = convertFromMga(spentMga, rate);
    final progress = amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0.0;

    final card = Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: cardBorderRadius,
        clipBehavior: Clip.antiAlias,
        child: Slidable(
          controller: _slidableController,
          key: Key(budget.id?.toString() ?? DateTime.now().toString()),
          enabled: !_isDismissing,
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: _deletePaneExtentRatio,
            children: [
              CustomSlidableAction(
                autoClose: false,
                padding: EdgeInsets.only(left: 4),
                backgroundColor: Colors.transparent,
                onPressed: (_) => _handleDeleteAction(),
                child: SizedBox.expand(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 18,
                        ),
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
            color: Theme.of(context).cardColor,
            borderRadius: cardBorderRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: cardBorderRadius,
              onTap: _isDismissing ? null : () => _showEditDialog(context),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceDim,
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(6),
                              child: Center(
                                child: Text(
                                  category?.emoji ?? '🏷️',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            Text(
                              category?.name ?? 'Catégorie inconnue',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${formatAmountWithCurrency(spent, currencyCode, preserveFraction: true)} / ${formatAmountWithCurrency(amount, currencyCode, preserveFraction: true)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                            ),
                            SizedBox(height: 3.2),
                            Text(
                              _periodLabel(budget.period),
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    PlanningProgressBar(
                        progress: progress, useWarningColors: true),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final animatedEntry = card
        .animate(delay: (50 * widget.index).ms)
        .fade(duration: 200.ms)
        .slideY(begin: 0.3, duration: 200.ms, curve: Curves.easeOut);

    return AnimatedSlide(
      duration: _dismissDuration,
      curve: Curves.easeOutCubic,
      offset: _isDismissing ? const Offset(0.15, 0) : Offset.zero,
      child: AnimatedOpacity(
        duration: _dismissDuration,
        curve: Curves.easeOut,
        opacity: _isDismissing ? 0 : 1,
        child: AnimatedSize(
          duration: _dismissDuration,
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _isDismissing ? const SizedBox.shrink() : animatedEntry,
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    AddBudgetBottomSheet.show(context, budget: widget.budget);
  }
}
