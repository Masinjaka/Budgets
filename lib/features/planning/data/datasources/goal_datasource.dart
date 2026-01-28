import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/main.dart';
import 'package:budgets/features/planning/domain/models/goal_model.dart';

/// Get all goals for the current user
Future<List<Goal>> getGoals() {
  return Wrapper.execute(() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('goals')
        .select(
            'id, created_at, user_id, name, date_aim, goal_amount, current_amount, image_path')
        .eq('user_id', userId)
        .order('created_at', ascending: true);

    if (response.isEmpty) return [];

    return (response as List).map((item) => Goal.fromMap(item)).toList();
  });
}

/// Add a new goal
Future<void> addGoal(Goal goal) {
  return Wrapper.execute(() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await supabase.from('goals').insert({
      'user_id': userId,
      'name': goal.name,
      'date_aim': goal.dateAim?.toIso8601String(),
      'goal_amount': goal.goalAmount,
      'current_amount': goal.currentAmount ?? '0',
      'image_path': goal.imagePath,
    });
  });
}

/// Update an existing goal
Future<void> updateGoal(Goal goal) {
  return Wrapper.execute(() async {
    await supabase.from('goals').update({
      'name': goal.name,
      'date_aim': goal.dateAim?.toIso8601String(),
      'goal_amount': goal.goalAmount,
      'current_amount': goal.currentAmount,
      'image_path': goal.imagePath,
    }).eq('id', goal.id!);
  });
}

/// Delete a goal by ID
Future<void> deleteGoal(String id) {
  return Wrapper.execute(() async {
    await supabase.from('goals').delete().eq('id', id);
  });
}
