import 'package:budgets/features/planning/domain/models/budget_model.dart';
import 'package:budgets/features/planning/domain/providers/budget_provider.dart';
import 'package:budgets/features/planning/presentation/widgets/budget_list_item.dart';
import 'package:budgets/features/planning/presentation/widgets/planning_common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class BudgetsTabContent extends ConsumerStatefulWidget {
  const BudgetsTabContent({super.key});

  @override
  ConsumerState<BudgetsTabContent> createState() => _BudgetsTabContentState();
}

class _BudgetsTabContentState extends ConsumerState<BudgetsTabContent> {
  late final ScrollController _scrollController;
  bool _canScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_updateScrollability);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollability);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollability() {
    if (!_scrollController.hasClients) {
      return;
    }
    final shouldScroll = _scrollController.position.maxScrollExtent > 0.5;
    if (shouldScroll != _canScroll && mounted) {
      setState(() {
        _canScroll = shouldScroll;
      });
    }
  }

  void _scheduleScrollabilityCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _updateScrollability();
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetsAsyncValue = ref.watch(budgetsProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: switch (budgetsAsyncValue) {
              AsyncData(:final value) => _buildBudgetList(context, value),
              AsyncError(:final error) => Center(
                  child: Text(
                    'Erreur: $error',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              _ => const BudgetListSkeleton(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetList(BuildContext context, List<Budget> budgets) {
    if (budgets.isEmpty) {
      if (_canScroll) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_canScroll) {
            return;
          }
          setState(() {
            _canScroll = false;
          });
        });
      }
      return PlanningEmptyState(
        title: 'Donnez un cap à vos dépenses',
        subtitle:
            'Créez votre premier budget et gardez le contrôle facilement.',
        icon: FontAwesomeIcons.wallet,
      );
    }

    _scheduleScrollabilityCheck();

    return ListView.builder(
      controller: _scrollController,
      physics: _canScroll
          ? const ClampingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 2.h),
      itemCount: budgets.length,
      itemBuilder: (context, index) =>
          BudgetListItem(budget: budgets[index], index: index),
    );
  }
}
