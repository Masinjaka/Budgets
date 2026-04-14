import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:budgets/core/powersync/powersync.dart' as powersync;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Represents a pending image upload.
class PendingImageUpload {
  final String id;
  final String localPath;
  final String storageBucket;
  final String storagePath;
  final String table;
  final String rowId;
  final String column;
  final String rowIdColumn;
  final DateTime createdAt;

  PendingImageUpload({
    required this.id,
    required this.localPath,
    required this.storageBucket,
    required this.storagePath,
    required this.table,
    required this.rowId,
    required this.column,
    this.rowIdColumn = 'id',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'localPath': localPath,
        'storageBucket': storageBucket,
        'storagePath': storagePath,
        'table': table,
        'rowId': rowId,
        'column': column,
        'rowIdColumn': rowIdColumn,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PendingImageUpload.fromJson(Map<String, dynamic> json) =>
      PendingImageUpload(
        id: json['id'] as String,
        localPath: json['localPath'] as String,
        storageBucket: json['storageBucket'] as String,
        storagePath: json['storagePath'] as String,
        table: json['table'] as String,
        rowId: json['rowId'] as String,
        column: json['column'] as String,
        rowIdColumn: json['rowIdColumn'] as String? ?? 'id',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// Manages offline image storage and queued uploads.
///
/// Images are copied to a dedicated local app directory and queued for upload
/// when connectivity is restored. After successful upload the database row is
/// updated with the Supabase public URL via PowerSync.
class ImageUploadQueue {
  static const String _boxName = 'image_upload_queue';
  static const String _queueKey = 'pending_uploads';
  static const String _localImageDir = 'budgets_images';

  static ImageUploadQueue? _instance;
  static ImageUploadQueue get instance {
    _instance ??= ImageUploadQueue._();
    return _instance!;
  }

  ImageUploadQueue._();

  Box<dynamic>? _box;
  StreamSubscription? _connectivitySubscription;
  bool _processing = false;

  /// Initialize the queue system. Call once at app startup.
  Future<void> init() async {
    _box = await Hive.openBox<dynamic>(_boxName);
    await _ensureLocalImageDir();
    _listenForConnectivity();
    // Try processing any pending uploads on init
    unawaited(_processQueue());
  }

  /// Get the local image directory path.
  static Future<String> getLocalImageDirPath() async {
    if (kIsWeb) return _localImageDir;
    final appDir = await getApplicationDocumentsDirectory();
    return p.join(appDir.path, _localImageDir);
  }

  /// Ensure the local image directory exists.
  Future<void> _ensureLocalImageDir() async {
    if (kIsWeb) return;
    final dirPath = await getLocalImageDirPath();
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// Copy a file to the local image directory and return the local path.
  Future<String> copyToLocalStorage(File file, String fileName) async {
    final dirPath = await getLocalImageDirPath();
    final localFile = File(p.join(dirPath, fileName));
    await file.copy(localFile.path);
    return localFile.path;
  }

  /// Queue an image for upload.
  ///
  /// [sourceFile] — The original file to upload.
  /// [bucket] — Supabase storage bucket name (e.g. 'profile').
  /// [storagePath] — Path within the bucket (e.g. 'goals/userId/123.jpg').
  /// [table] — The database table to update after upload (e.g. 'goals').
  /// [rowId] — The row ID to update.
  /// [column] — The column to update with the public URL (e.g. 'image_path').
  /// [rowIdColumn] — The column name for the row id (defaults to 'id').
  ///
  /// Returns the local file path for immediate use in the UI.
  Future<String> enqueue({
    required File sourceFile,
    required String bucket,
    required String storagePath,
    required String table,
    required String rowId,
    required String column,
    String rowIdColumn = 'id',
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(sourceFile.path)}';
    final localPath = await copyToLocalStorage(sourceFile, fileName);

    final pending = PendingImageUpload(
      id: '${DateTime.now().millisecondsSinceEpoch}_$fileName',
      localPath: localPath,
      storageBucket: bucket,
      storagePath: storagePath,
      table: table,
      rowId: rowId,
      column: column,
      rowIdColumn: rowIdColumn,
      createdAt: DateTime.now(),
    );

    final queue = _getQueue();
    queue.add(pending.toJson());
    await _saveQueue(queue);

    debugPrint(
        '📤 Image queued for upload: ${pending.storagePath} (local: $localPath)');

    // Try to process immediately
    unawaited(_processQueue());

    return localPath;
  }

  /// Listen for connectivity changes and process queue when online.
  void _listenForConnectivity() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        debugPrint('📡 Connectivity restored, processing image upload queue…');
        _processQueue();
      }
    });
  }

  /// Process all pending uploads.
  Future<void> _processQueue() async {
    if (_processing) return;
    _processing = true;

    try {
      final queue = _getQueue();
      if (queue.isEmpty) return;

      final client = Supabase.instance.client;
      final completed = <int>[];

      for (var i = 0; i < queue.length; i++) {
        final pending =
            PendingImageUpload.fromJson(queue[i] as Map<String, dynamic>);

        try {
          final localFile = File(pending.localPath);
          if (!await localFile.exists()) {
            debugPrint(
                '⚠️ Local file missing, removing from queue: ${pending.localPath}');
            completed.add(i);
            continue;
          }

          // Upload to Supabase Storage
          await client.storage
              .from(pending.storageBucket)
              .upload(pending.storagePath, localFile);

          // Get the public URL
          final publicUrl = client.storage
              .from(pending.storageBucket)
              .getPublicUrl(pending.storagePath);

          // Update the database row with the public URL via PowerSync
          await powersync.db.execute(
            'UPDATE ${pending.table} SET ${pending.column} = ? WHERE ${pending.rowIdColumn} = ?',
            [publicUrl, pending.rowId],
          );

          debugPrint('✅ Image uploaded successfully: ${pending.storagePath}');
          completed.add(i);

          // Keep local avatar files to avoid broken UI if a stale local path is
          // still cached in memory while providers refresh to the remote URL.
          final keepLocalFile =
              pending.table == 'user' && pending.column == 'profile_photo';

          if (!keepLocalFile) {
            // Clean up local file after successful upload
            try {
              await localFile.delete();
            } catch (_) {
              // Non-critical — file cleanup failure is acceptable
            }
          }
        } catch (e) {
          debugPrint(
              '❌ Image upload failed (will retry): ${pending.storagePath} — $e');
          // Don't add to completed, will retry next time
        }
      }

      // Remove completed items (in reverse order to preserve indices)
      for (final idx in completed.reversed) {
        queue.removeAt(idx);
      }
      await _saveQueue(queue);
    } finally {
      _processing = false;
    }
  }

  List<dynamic> _getQueue() {
    final raw = _box?.get(_queueKey);
    if (raw == null) return [];
    if (raw is List) return List<dynamic>.from(raw);
    if (raw is String) {
      return List<dynamic>.from(jsonDecode(raw) as List);
    }
    return [];
  }

  Future<void> _saveQueue(List<dynamic> queue) async {
    await _box?.put(_queueKey, queue);
  }

  /// Get the number of pending uploads.
  int get pendingCount => _getQueue().length;

  /// Dispose resources.
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
