import 'dart:io';
import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/core/powersync/powersync.dart' as powersync;
import 'package:budgets/core/offline/image_upload_queue.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/planning/domain/models/goal_model.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Extract the storage path from a Supabase public URL
/// Returns null if the URL is invalid or doesn't contain the expected pattern
String? extractStoragePathFromUrl(String? publicUrl) {
  if (publicUrl == null || publicUrl.isEmpty) return null;
  try {
    final uri = Uri.parse(publicUrl);
    final pathSegments = uri.pathSegments;
    // Find 'profile' bucket and take everything after it
    final bucketIndex = pathSegments.indexOf('profile');
    if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
      return null;
    }
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

  // If it's a local path (offline image), just delete the local file
  if (!imageUrl.startsWith('http')) {
    try {
      final file = File(imageUrl);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Deleted local goal image: $imageUrl');
      }
      return true;
    } catch (e) {
      debugPrint('Warning: Failed to delete local goal image: $e');
      return false;
    }
  }

  final path = extractStoragePathFromUrl(imageUrl);
  if (path == null) {
    debugPrint('Warning: Could not extract storage path from URL: $imageUrl');
    return false;
  }

  try {
    await Supabase.instance.client.storage.from('profile').remove([path]);
    debugPrint('Successfully deleted old goal image: $path');
    return true;
  } catch (e) {
    debugPrint('Warning: Failed to delete old goal image: $e');
    return false;
  }
}

/// Upload goal image — uses the image queue for offline support.
/// Returns a local path immediately for display; the queue handles
/// uploading to Supabase Storage when connectivity is available.
Future<String> uploadGoalImage(File file, String userId,
    {String? goalId}) async {
  // Verify file exists and is readable
  if (!await file.exists()) {
    throw FileSystemException('Le fichier image n\'existe pas', file.path);
  }

  final storagePath =
      'goals/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

  // If goalId is provided, queue for background upload
  if (goalId != null) {
    final localPath = await ImageUploadQueue.instance.enqueue(
      sourceFile: file,
      bucket: 'profile',
      storagePath: storagePath,
      table: 'goals',
      rowId: goalId,
      column: 'image_path',
    );
    return localPath;
  }

  // Fallback: try direct upload (for online scenarios without a goalId yet)
  try {
    final client = Supabase.instance.client;
    await client.storage.from('profile').upload(storagePath, file);
    return client.storage.from('profile').getPublicUrl(storagePath);
  } catch (e) {
    // If upload fails (offline), save locally
    debugPrint('Direct upload failed, saving locally: $e');
    final localDir = await ImageUploadQueue.getLocalImageDirPath();
    final localFile = File(
        '$localDir/goal_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.copy(localFile.path);
    return localFile.path;
  }
}

/// Get all goals for the current user
Future<List<Goal>> getGoals() {
  return Wrapper.execute(() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final results = await powersync.db.getAll('''
      SELECT g.id, g.created_at, g.user_id, g.name, g.date_aim,
             g.goal_amount, g.current_amount, g.image_path,
             c.id AS cat_id, c.name AS cat_name, c.emoji AS cat_emoji,
             c.color AS cat_color, c.transaction_type AS cat_type
      FROM goals g
      LEFT JOIN categories c ON g.category = c.id
      WHERE g.user_id = ?
      ORDER BY g.created_at ASC
    ''', [userId]);

    if (results.isEmpty) return [];

    return results.map((row) {
      return Goal(
        id: row['id'] as String?,
        createdAt: row['created_at'] != null
            ? DateTime.parse(row['created_at'] as String)
            : null,
        userId: row['user_id'] as String?,
        name: row['name'] as String?,
        category: row['cat_id'] != null
            ? Category(
                id: row['cat_id'] as String?,
                name: row['cat_name'] as String?,
                emoji: row['cat_emoji'] as String?,
                color: row['cat_color'] as String?,
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

    await powersync.db.execute(
      '''INSERT INTO goals
         (id, created_at, user_id, name, category, date_aim,
          goal_amount, current_amount, image_path)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        goalId,
        nowIso,
        userId,
        goal.name,
        goal.category?.id,
        goal.dateAim?.toUtc().toIso8601String(),
        goal.goalAmount,
        goal.currentAmount ?? '0',
        goal.imagePath,
      ],
    );

    return goalId;
  });
}

/// Update an existing goal
Future<void> updateGoal(Goal goal) {
  return Wrapper.execute(() async {
    if (goal.id == null) throw Exception('Goal ID is required');

    await powersync.db.execute(
      '''UPDATE goals
         SET name = ?, category = ?, date_aim = ?,
             goal_amount = ?, current_amount = ?, image_path = ?
         WHERE id = ?''',
      [
        goal.name,
        goal.category?.id,
        goal.dateAim?.toUtc().toIso8601String(),
        goal.goalAmount,
        goal.currentAmount,
        goal.imagePath,
        goal.id,
      ],
    );
  });
}

/// Delete a goal by ID
Future<void> deleteGoal(String id) {
  return Wrapper.execute(() async {
    await powersync.db.execute(
      'DELETE FROM goals WHERE id = ?',
      [id],
    );
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
