import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String? extractStoragePathFromUrl(String? publicUrl) {
  if (publicUrl == null || publicUrl.isEmpty) return null;
  try {
    final segments = Uri.parse(publicUrl).pathSegments;
    final bucketIndex = segments.indexOf('profile');
    if (bucketIndex == -1 || bucketIndex >= segments.length - 1) return null;
    return segments.sublist(bucketIndex + 1).join('/');
  } catch (error) {
    debugPrint('Error extracting storage path: $error');
    return null;
  }
}

Future<bool> deleteGoalImage(String? imageUrl) async {
  if (imageUrl == null || imageUrl.isEmpty) return true;
  if (!imageUrl.startsWith('http')) {
    try {
      final file = File(imageUrl);
      if (await file.exists()) await file.delete();
      return true;
    } catch (error) {
      debugPrint('Failed to delete local goal image: $error');
      return false;
    }
  }

  final path = extractStoragePathFromUrl(imageUrl);
  if (path == null) return false;
  try {
    await Supabase.instance.client.storage.from('profile').remove([path]);
    return true;
  } catch (error) {
    debugPrint('Failed to delete goal image: $error');
    return false;
  }
}

Future<String> uploadGoalImage(
  File file,
  String userId,
) async {
  if (!await file.exists()) {
    throw FileSystemException('Le fichier image n\'existe pas', file.path);
  }

  final storagePath =
      'goals/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
  final client = Supabase.instance.client;
  await client.storage.from('profile').upload(storagePath, file);
  return client.storage.from('profile').getPublicUrl(storagePath);
}
