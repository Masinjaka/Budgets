import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileDataSource {
  final SupabaseClient client;
  SupabaseProfileDataSource(this.client);

  /// Uploads file to 'profile' bucket at path 'avatars/<userId>/<timestamp>.jpg'
  /// Returns the public URL path (not full HTTP URL).
  Future<String> uploadToStorage(
      {required File file, required String userId}) async {
    final path = 'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await client.storage.from('profile').upload(path, file);
    // Get a public URL (assumes bucket or file is publicly readable)
    final publicUrl = client.storage.from('profile').getPublicUrl(path);
    return publicUrl;
  }

  /// Update profile_photo in user table for [userId]
  Future<void> updateUserProfilePhoto(
      {required String userId, required String photoUrl}) async {
    try {
      debugPrint('Updating profile photo URL for userId: $userId to $photoUrl');
      await client
          .from('user')
          .update({'profile_photo': photoUrl}).eq('user_id', userId);
    } catch (e, s) {
      debugPrint('Error updating profile photo URL: $e, $s');
      throw Exception('Failed to update profile photo URL: $e');
    }
  }
}
