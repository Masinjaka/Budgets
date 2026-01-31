import 'package:budgets/features/planning/domain/models/goal_model.dart';
import 'package:budgets/features/planning/domain/providers/goal_provider.dart';
import 'package:budgets/features/planning/presentation/widgets/add_goal_bottom_sheet.dart';
import 'package:budgets/features/planning/presentation/widgets/planning_common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
          _GoalListItem(goal: goals[index], index: index, ref: ref),
    );
  }
}

/// Individual goal list item with swipe-to-delete
class _GoalListItem extends StatelessWidget {
  final Goal goal;
  final int index;
  final WidgetRef ref;

  const _GoalListItem({
    required this.goal,
    required this.index,
    required this.ref,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<bool?> _showDeleteDialog(BuildContext context) async {
    return showDialog<bool>(
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
  Widget build(BuildContext context) {
    final goalImage = goal.imagePath != null
        ? AssetImage(goal.imagePath!)
        : const AssetImage('assets/images/image-placeholder.png');
    final goalAmount = double.tryParse(goal.goalAmount ?? '0') ?? 0;
    final currentAmount = double.tryParse(goal.currentAmount ?? '0') ?? 0;
    final progress =
        goalAmount > 0 ? (currentAmount / goalAmount).clamp(0.0, 1.0) : 0.0;

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
              decoration: BoxDecoration(
                image: DecorationImage(image: goalImage, fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(2.5.w),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: 1.w,
                    right: 1.w,
                    child: Align(
                      alignment: Alignment.topRight,
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
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: 1.h),
                  _buildAmountRow(context, currentAmount, goalAmount),
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

  Future<void> _showAddAmountDialog(BuildContext context) async {
    final amountController = TextEditingController();
    final currentAmount = double.tryParse(goal.currentAmount ?? '0') ?? 0;
    final goalAmount = double.tryParse(goal.goalAmount ?? '0') ?? 0;

    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ajouter à ${goal.name ?? 'l\'objectif'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Montant actuel: ${currentAmount.toStringAsFixed(0)} Ar',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).hintColor,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Objectif: ${goalAmount.toStringAsFixed(0)} Ar',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).hintColor,
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Montant à ajouter',
                hintText: '0',
                suffixText: 'Ar',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.of(ctx).pop(amount);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result != null) {
      final newAmount = currentAmount + result;
      final updatedGoal = goal.copyWith(
        currentAmount: newAmount.toStringAsFixed(0),
      );
      await ref.read(goalsProvider.notifier).updateSomeGoal(updatedGoal);
    }
  }

  Widget _buildHeader(BuildContext context) {
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
          onTap: () => _showAddAmountDialog(context),
          child: Icon(
            Icons.add_circle_outline_rounded,
            color: Theme.of(context).textTheme.bodyMedium?.color,
            size: 20.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(
      BuildContext context, double currentAmount, double goalAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${currentAmount.toStringAsFixed(0)} Ar',
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor)),
        Text('${goalAmount.toStringAsFixed(0)} Ar',
            style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color)),
      ],
    );
  }
}
