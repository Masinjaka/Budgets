import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:budgets/core/offline/pending_image_upload.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUploadQueue {
  ImageUploadQueue._();

  static const _boxName = 'image_upload_queue';
  static const _queueKey = 'pending_uploads';
  static const _localImageDir = 'budgets_images';
  static ImageUploadQueue? _instance;

  static ImageUploadQueue get instance => _instance ??= ImageUploadQueue._();

  Box<dynamic>? _box;
  StreamSubscription? _connectivitySubscription;
  bool _processing = false;

  Future<void> init() async {
    _box = await Hive.openBox<dynamic>(_boxName);
    await _ensureLocalImageDir();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        unawaited(_processQueue());
      }
    });
    unawaited(_processQueue());
  }

  static Future<String> getLocalImageDirPath() async {
    if (kIsWeb) return _localImageDir;
    final directory = await getApplicationDocumentsDirectory();
    return p.join(directory.path, _localImageDir);
  }

  Future<String> enqueue({
    required File sourceFile,
    required String bucket,
    required String storagePath,
    required String table,
    required String rowId,
    required String column,
    String rowIdColumn = 'id',
  }) async {
    await _ensureInitialized();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${timestamp}_${p.basename(sourceFile.path)}';
    final localPath = p.join(await getLocalImageDirPath(), fileName);
    await sourceFile.copy(localPath);
    final pending = PendingImageUpload(
      id: '${timestamp}_$fileName',
      localPath: localPath,
      storageBucket: bucket,
      storagePath: storagePath,
      table: table,
      rowId: rowId,
      column: column,
      rowIdColumn: rowIdColumn,
      createdAt: DateTime.now(),
    );
    final queue = _getQueue()..add(pending.toJson());
    await _saveQueue(queue);
    unawaited(_processQueue());
    return localPath;
  }

  Future<void> _ensureInitialized() async {
    if (_box != null) return;
    _box = await Hive.openBox<dynamic>(_boxName);
    await _ensureLocalImageDir();
  }

  Future<void> _ensureLocalImageDir() async {
    if (kIsWeb) return;
    final directory = Directory(await getLocalImageDirPath());
    if (!await directory.exists()) await directory.create(recursive: true);
  }

  Future<void> _processQueue() async {
    if (_processing) return;
    _processing = true;
    try {
      await _ensureInitialized();
      final queue = _getQueue();
      final completed = <int>[];
      final client = Supabase.instance.client;
      for (var index = 0; index < queue.length; index++) {
        final item = PendingImageUpload.fromJson(
          Map<String, dynamic>.from(queue[index] as Map),
        );
        try {
          final file = File(item.localPath);
          if (!await file.exists()) {
            completed.add(index);
            continue;
          }
          await client.storage.from(item.storageBucket).upload(
                item.storagePath,
                file,
                fileOptions: const FileOptions(upsert: true),
              );
          final url = client.storage
              .from(item.storageBucket)
              .getPublicUrl(item.storagePath);
          await client
              .from(item.table)
              .update({item.column: url}).eq(item.rowIdColumn, item.rowId);
          completed.add(index);
          if (item.table != 'user' || item.column != 'profile_photo') {
            await file.delete();
          }
        } catch (error) {
          debugPrint('Queued image upload will retry: $error');
        }
      }
      for (final index in completed.reversed) {
        queue.removeAt(index);
      }
      await _saveQueue(queue);
    } finally {
      _processing = false;
    }
  }

  List<dynamic> _getQueue() {
    final raw = _box?.get(_queueKey);
    if (raw is List) return List<dynamic>.from(raw);
    if (raw is String) return List<dynamic>.from(jsonDecode(raw) as List);
    return [];
  }

  Future<void> _saveQueue(List<dynamic> queue) async {
    await _box?.put(_queueKey, queue);
  }

  int get pendingCount => _getQueue().length;

  Future<void> processPendingUploads() => _processQueue();

  void dispose() => _connectivitySubscription?.cancel();
}
