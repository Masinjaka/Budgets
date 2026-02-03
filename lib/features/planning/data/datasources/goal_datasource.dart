import 'dart:io';
import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/main.dart';
import 'package:budgets/features/planning/domain/models/goal_model.dart';
import 'package:flutter/foundation.dart';

/// Extract the storage path from a Supabase public URL
/// Returns null if the URL is invalid or doesn't contain the expected pattern
String? extractStoragePathFromUrl(String? publicUrl) {
  if (publicUrl == null || publicUrl.isEmpty) return null;
  try {
    final uri = Uri.parse(publicUrl);
    final pathSegments = uri.pathSegments;
    // Find 'profile' bucket and take everything after it
    final bucketIndex = pathSegments.indexOf('profile');
    if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1)
      return null;
    return pathSegments.sublist(bucketIndex + 1).join('/');
  } catch (e) {
    debugPrint('Error extracting storage path: $e');
    return null;
  }
}

/// Delete goal image from Supabase storage
/// Returns true if successful, false otherwise
/// Silently fails and logs warning if deletion fails (non-critical operation)
Future<bool> deleteGoalImage(String? imageUrl) async {
  if (imageUrl == null || imageUrl.isEmpty) return true;

  final path = extractStoragePathFromUrl(imageUrl);
  if (path == null) {
    debugPrint('Warning: Could not extract storage path from URL: $imageUrl');
    return false;
  }

  try {
    await supabase.storage.from('profile').remove([path]);
    debugPrint('Successfully deleted old goal image: $path');
    return true;
  } catch (e) {
    debugPrint('Warning: Failed to delete old goal image: $e');
    return false;
  }
}

/// Upload goal image to Supabase storage
/// Throws SocketException for network errors
/// Throws StorageException for Supabase storage errors
/// Throws FileSystemException if file cannot be read
Future<String> uploadGoalImage(File file, String userId) async {
  // Verify file exists and is readable
  if (!await file.exists()) {
    throw FileSystemException('Le fichier image n\'existe pas', file.path);
  }

  final path = 'goals/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
  await supabase.storage.from('profile').upload(path, file);
  return supabase.storage.from('profile').getPublicUrl(path);
}

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
Future<bool> updateGoalAmountByDelta(String goalName, double amountDelta) async {
  try {
    final goal = await findGoalByName(goalName);
    if (goal == null) {
      debugPrint('Goal not found: $goalName');
      return false;
    }

    final currentAmount =
        double.tryParse(goal.currentAmount?.replaceAll(',', '').replaceAll(' ', '') ?? '0') ?? 0;
    final newAmount = (currentAmount + amountDelta).clamp(0, double.infinity);

    final updatedGoal = goal.copyWith(
      currentAmount: newAmount.toStringAsFixed(0),
    );

    await updateGoal(updatedGoal);
    debugPrint('Updated goal "$goalName" amount: $currentAmount -> $newAmount (delta: $amountDelta)');
    return true;
  } catch (e) {
    debugPrint('Error updating goal amount: $e');
    return false;
  }
}
