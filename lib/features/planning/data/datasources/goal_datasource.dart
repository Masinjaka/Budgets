import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/planning/domain/models/goal_model.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Get all goals for the current user
Future<List<Goal>> getGoals() {
  return Wrapper.execute(() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final results = await Supabase.instance.client
        .from('goals')
        .select(
          'id, created_at, user_id, name, date_aim, goal_amount, '
          'current_amount, image_path, '
          'category_data:categories!goals_category_fkey'
          '(id, name, emoji, color)',
        )
        .eq('user_id', userId)
        .order('created_at');

    if (results.isEmpty) return [];

    return results.map((row) {
      final category = row['category_data'] as Map<String, dynamic>?;
      return Goal(
        id: row['id'] as String?,
        createdAt: row['created_at'] != null
            ? DateTime.parse(row['created_at'] as String)
            : null,
        userId: row['user_id'] as String?,
        name: row['name'] as String?,
        category: category != null
            ? Category(
                id: category['id'] as String?,
                name: category['name'] as String?,
                emoji: category['emoji'] as String?,
                color: category['color'] as String?,
              )
            : null,
        dateAim: row['date_aim'] != null
            ? DateTime.parse(row['date_aim'] as String)
            : null,
        goalAmount: row['goal_amount'] as String?,
        currentAmount: row['current_amount'] as String?,
        imagePath: row['image_path'] as String?,
      );
    }).toList();
  });
}

/// Add a new goal
Future<String> addGoal(Goal goal) {
  return Wrapper.execute(() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final goalId = _uuid.v4();
    final nowIso = DateTime.now().toUtc().toIso8601String();

    await Supabase.instance.client.from('goals').insert({
      'id': goalId,
      'created_at': nowIso,
      'user_id': userId,
      'name': goal.name,
      'category': goal.category?.id,
      'date_aim': goal.dateAim?.toUtc().toIso8601String(),
      'goal_amount': goal.goalAmount,
      'current_amount': goal.currentAmount ?? '0',
      'image_path': goal.imagePath,
    });

    return goalId;
  });
}

/// Update an existing goal
Future<void> updateGoal(Goal goal) {
  return Wrapper.execute(() async {
    if (goal.id == null) throw Exception('Goal ID is required');

    await Supabase.instance.client.from('goals').update({
      'name': goal.name,
      'category': goal.category?.id,
      'date_aim': goal.dateAim?.toUtc().toIso8601String(),
      'goal_amount': goal.goalAmount,
      'current_amount': goal.currentAmount,
      'image_path': goal.imagePath,
    }).eq('id', goal.id!);
  });
}

/// Delete a goal by ID
Future<void> deleteGoal(String id) {
  return Wrapper.execute(() async {
    await Supabase.instance.client.from('goals').delete().eq('id', id);
  });
}

/// Check if the user has any goals
Future<bool> hasAnyGoals() async {
  try {
    final goals = await getGoals();
    return goals.isNotEmpty;
  } catch (e) {
    debugPrint('Error checking for goals: $e');
    return false;
  }
}

/// Extract goal name from a transaction description
/// Returns null if the description doesn't match the expected pattern
String? extractGoalNameFromDescription(String? description) {
  if (description == null || description.isEmpty) return null;
  const prefix = 'Contribution à ';
  if (description.startsWith(prefix)) {
    return description.substring(prefix.length);
  }
  return null;
}

/// Find a goal by its name
Future<Goal?> findGoalByName(String name) async {
  try {
    final goals = await getGoals();
    return goals.where((g) => g.name == name).firstOrNull;
  } catch (e) {
    debugPrint('Error finding goal by name: $e');
    return null;
  }
}

/// Update a goal's current amount by adding or subtracting a value
/// [goalName] - The name of the goal to update
/// [amountDelta] - The amount to add (positive) or subtract (negative)
/// Returns true if successful, false otherwise
Future<bool> updateGoalAmountByDelta(
    String goalName, double amountDelta) async {
  try {
    final goal = await findGoalByName(goalName);
    if (goal == null) {
      debugPrint('Goal not found: $goalName');
      return false;
    }

    final currentAmount = double.tryParse(
            goal.currentAmount?.replaceAll(',', '').replaceAll(' ', '') ??
                '0') ??
        0;
    final newAmount = (currentAmount + amountDelta).clamp(0, double.infinity);

    final updatedGoal = goal.copyWith(
      currentAmount: newAmount.toStringAsFixed(0),
    );

    await updateGoal(updatedGoal);
    debugPrint(
        'Updated goal "$goalName" amount: $currentAmount -> $newAmount (delta: $amountDelta)');
    return true;
  } catch (e) {
    debugPrint('Error updating goal amount: $e');
    return false;
  }
}
