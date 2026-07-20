import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileDataSource {
  final SupabaseClient client;
  SupabaseProfileDataSource(this.client);

  Future<String> uploadToStorage(
      {required File file, required String userId}) async {
    final storagePath =
        'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await client.storage.from('profile').upload(
          storagePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );
    return client.storage.from('profile').getPublicUrl(storagePath);
  }

  Future<void> updateUserProfilePhoto(
      {required String userId, required String photoUrl}) async {
    try {
      debugPrint('Updating profile photo URL for userId: $userId to $photoUrl');
      await client.from('user').upsert(
        {'user_id': userId, 'profile_photo': photoUrl},
        onConflict: 'user_id',
      );
    } catch (e, s) {
      debugPrint('Error updating profile photo URL: $e, $s');
      throw Exception('Failed to update profile photo URL: $e');
    }
  }
}
