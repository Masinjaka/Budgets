import 'dart:io';
import 'package:budgets/features/planning/data/datasources/goal_datasource.dart';
import 'package:budgets/features/planning/domain/models/goal_model.dart';
import 'package:flutter/foundation.dart';
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
      // First save the goal without the image (or with local path)
      final goalToSave = goal;

      // Add the goal and get its ID
      final goalId = await addGoal(goalToSave);

      // If there's a local image, queue it for upload with the new goalId
      if (goal.imagePath != null &&
          goal.imagePath!.isNotEmpty &&
          !goal.imagePath!.startsWith('http')) {
        final userId = goal.userId;
        if (userId != null) {
          final localPath =
              await uploadGoalImage(File(goal.imagePath!), userId, goalId: goalId);
          // Update the goal with the local path for immediate display
          await updateGoal(goal.copyWith(id: goalId, imagePath: localPath));
        } else {
          debugPrint('Warning: userId is null, cannot upload image');
        }
      }

      final goals = await getGoals();
      state = AsyncValue.data(goals);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }

  Future<void> updateSomeGoal(Goal goal, {String? oldImagePath}) async {
    try {
      Goal goalToUpdate = goal;

      // Check if a new local image is being uploaded
      final hasNewLocalImage = goal.imagePath != null &&
          goal.imagePath!.isNotEmpty &&
          !goal.imagePath!.startsWith('http');

      if (hasNewLocalImage) {
        final userId = goal.userId;
        if (userId != null) {
          // Delete old image from storage if it exists (non-blocking)
          if (oldImagePath != null && oldImagePath.startsWith('http')) {
            await deleteGoalImage(oldImagePath);
          }

          // Queue new image for upload, get local path
          final localPath = await uploadGoalImage(
              File(goal.imagePath!), userId,
              goalId: goal.id);
          goalToUpdate = goal.copyWith(imagePath: localPath);
        } else {
          debugPrint('Warning: userId is null, cannot upload image');
        }
      }

      await updateGoal(goalToUpdate);
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
      // Get the goal first to delete its image
      final currentGoals = state.value ?? [];
      final goalToDelete = currentGoals.where((g) => g.id == id).firstOrNull;

      // Delete image from storage if it exists
      if (goalToDelete?.imagePath != null) {
        await deleteGoalImage(goalToDelete!.imagePath);
      }

      await deleteGoal(id);
      final goals = await getGoals();
      state = AsyncValue.data(goals);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }
}
