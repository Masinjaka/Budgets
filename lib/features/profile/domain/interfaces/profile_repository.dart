import 'dart:io';

/// Abstraction for profile related operations.
abstract class ProfileRepository {
  /// Uploads the given image file to Supabase Storage (bucket: 'profile')
  /// and returns the public URL (or signed URL) to the stored image.
  Future<String> uploadProfileImage({required File file, required String userId});

  /// Persists the uploaded image URL to the user's profile row
  /// (updates `profile_photo` column) for the given [userId].
  Future<void> saveProfilePhotoUrl({required String userId, required String photoUrl});
}
