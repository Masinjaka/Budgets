import 'package:budgets/features/planning/domain/models/goal_model.dart';
import 'package:budgets/features/planning/domain/providers/goal_provider.dart';
import 'package:budgets/features/planning/presentation/widgets/goal_list_item.dart';
import 'package:budgets/features/planning/presentation/widgets/planning_common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GoalsTabContent extends ConsumerStatefulWidget {
  const GoalsTabContent({super.key});

  @override
  ConsumerState<GoalsTabContent> createState() => _GoalsTabContentState();
}

class _GoalsTabContentState extends ConsumerState<GoalsTabContent> {
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
    final goalsAsyncValue = ref.watch(goalsProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: switch (goalsAsyncValue) {
              AsyncData(:final value) => _buildGoalList(context, value),
              AsyncError(:final error) => Center(
                  child: Text(
                    'Erreur: $error',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              _ => const GoalListSkeleton(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalList(BuildContext context, List<Goal> goals) {
    if (goals.isEmpty) {
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
        title: 'Vos objectifs commencent ici',
        subtitle:
            'Fixez votre premier objectif d’épargne et suivez votre élan.',
        icon: FontAwesomeIcons.bullseye,
      );
    }

    _scheduleScrollabilityCheck();

    return ListView.builder(
      controller: _scrollController,
      physics: _canScroll
          ? const ClampingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 16),
      itemCount: goals.length,
      itemBuilder: (context, index) =>
          GoalListItem(goal: goals[index], index: index),
    );
  }
}
