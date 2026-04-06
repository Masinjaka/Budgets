import 'dart:io';
import 'package:budgets/core/powersync/powersync.dart' as powersync;
import 'package:budgets/core/offline/image_upload_queue.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileDataSource {
  final SupabaseClient client;
  SupabaseProfileDataSource(this.client);

  /// Uploads file to 'profile' bucket at path 'avatars/<userId>/<timestamp>.jpg'
  /// Uses the image queue for offline support. Returns a local path immediately.
  Future<String> uploadToStorage(
      {required File file, required String userId}) async {
    final storagePath =
        'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Queue for upload — returns local path immediately
    final localPath = await ImageUploadQueue.instance.enqueue(
      sourceFile: file,
      bucket: 'profile',
      storagePath: storagePath,
      table: 'user',
      rowId: userId,
      column: 'profile_photo',
      rowIdColumn: 'user_id',
    );

    return localPath;
  }

  /// Update profile_photo in user table for [userId] via PowerSync
  Future<void> updateUserProfilePhoto(
      {required String userId, required String photoUrl}) async {
    try {
      debugPrint('Updating profile photo URL for userId: $userId to $photoUrl');
      await powersync.db.execute(
        'UPDATE user SET profile_photo = ? WHERE user_id = ?',
        [photoUrl, userId],
      );
    } catch (e, s) {
      debugPrint('Error updating profile photo URL: $e, $s');
      throw Exception('Failed to update profile photo URL: $e');
    }
  }
}
