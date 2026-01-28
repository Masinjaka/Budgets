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
      child: GestureDetector(
        onTap: () => _showEditBottomSheet(context),
        child: PlanningCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 2.h),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3.w),
          ),
          child: Icon(Icons.savings,
              color: Theme.of(context).primaryColor, size: 20.sp),
        ),
        SizedBox(width: 3.w),
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
                Text('Échéance: ${_formatDate(goal.dateAim!)}',
                    style: TextStyle(
                        fontSize: 13.sp, color: Theme.of(context).hintColor)),
            ],
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
