import 'package:budgets/features/planning/data/datasources/goal_datasource.dart';
import 'package:budgets/features/planning/domain/models/goal_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goal_provider.g.dart';

@riverpod
class Goals extends _$Goals {
  @override
  Future<List<Goal>> build() {
    return getGoals();
  }

  Future<void> addSomeGoal(Goal goal) async {
    state = const AsyncValue.loading();
    try {
      await addGoal(goal);
      final goals = await getGoals();
      state = AsyncValue.data(goals);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }

  Future<void> updateSomeGoal(Goal goal) async {
    try {
      await updateGoal(goal);
      final goals = await getGoals();
      state = AsyncValue.data(goals);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }

  Future<void> deleteSomeGoal(String id) async {
    state = const AsyncValue.loading();
    try {
      await deleteGoal(id);
      final goals = await getGoals();
      state = AsyncValue.data(goals);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }
}
