import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<void> deleteLegacyImageData() async {
  if (kIsWeb) return;
  try {
    final documents = await getApplicationDocumentsDirectory();
    final imageDirectory = Directory('${documents.path}/budgets_images');
    if (await imageDirectory.exists()) {
      await imageDirectory.delete(recursive: true);
    }
    for (final name in const [
      'image_upload_queue.hive',
      'image_upload_queue.lock',
    ]) {
      final file = File('${documents.path}/$name');
      if (await file.exists()) await file.delete();
    }
  } on FileSystemException catch (error) {
    debugPrint('Legacy image cleanup failed: $error');
  }
}
