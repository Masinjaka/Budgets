import 'dart:io';

import 'package:budgets/core/offline/legacy_image_data_cleanup.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory documents;

  setUp(() async {
    documents = await Directory.systemTemp.createTemp(
      'drala_legacy_images_test_',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return documents.path;
      }
      return null;
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    if (await documents.exists()) await documents.delete(recursive: true);
  });

  test('removes legacy queue files and locally cached goal images', () async {
    final images = Directory('${documents.path}/budgets_images');
    await images.create();
    await File('${images.path}/goal.jpg').writeAsBytes([1, 2, 3]);
    await File('${documents.path}/image_upload_queue.hive').writeAsString('');
    await File('${documents.path}/image_upload_queue.lock').writeAsString('');

    await deleteLegacyImageData();

    expect(images.existsSync(), isFalse);
    expect(
      File('${documents.path}/image_upload_queue.hive').existsSync(),
      isFalse,
    );
    expect(
      File('${documents.path}/image_upload_queue.lock').existsSync(),
      isFalse,
    );
  });
}
