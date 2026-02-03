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
      Goal goalToSave = goal;
      // Upload image if it's a local file path (not a URL)
      if (goal.imagePath != null &&
          goal.imagePath!.isNotEmpty &&
          !goal.imagePath!.startsWith('http')) {
        final userId = goal.userId;
        if (userId != null) {
          final imageUrl = await uploadGoalImage(File(goal.imagePath!), userId);
          goalToSave = goal.copyWith(imagePath: imageUrl);
        } else {
          debugPrint('Warning: userId is null, cannot upload image');
        }
      }

      await addGoal(goalToSave);
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
          // Delete old image from storage if it exists (non-blocking, log errors)
          if (oldImagePath != null && oldImagePath.startsWith('http')) {
            await deleteGoalImage(oldImagePath);
          }

          // Upload new image
          final imageUrl = await uploadGoalImage(File(goal.imagePath!), userId);
          goalToUpdate = goal.copyWith(imagePath: imageUrl);
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
      if (goalToDelete?.imagePath != null &&
          goalToDelete!.imagePath!.startsWith('http')) {
        await deleteGoalImage(goalToDelete.imagePath);
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
