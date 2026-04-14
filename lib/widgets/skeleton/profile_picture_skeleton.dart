import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget avatarSkeleton(BuildContext context, double size) {
  final theme = Theme.of(context);
  return Shimmer.fromColors(
    baseColor: theme.colorScheme.surface,
    highlightColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surface,
      ),
    ),
  );
}

Widget textSkeleton(BuildContext context, double width, double height) {
  final theme = Theme.of(context);
  return Shimmer.fromColors(
    baseColor: theme.colorScheme.surface,
    highlightColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  );
}

Widget avatar(BuildContext context, String? url, double size) {
  final theme = Theme.of(context);
  if (url == null || url.isEmpty) {
    return ClipOval(
      child: Icon(Icons.person, size: size, color: theme.colorScheme.onSurface),
    );
  }

  // Offline-first support:
  // profile_photo may temporarily contain a local file path while upload is queued.
  if (!kIsWeb) {
    final filePath =
        url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;
    final file = File(filePath);
    if (file.existsSync()) {
      return ClipOval(
        child: Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }
    if (_isLocalFilePath(url)) {
      // Local path no longer exists (e.g. cleaned after successful upload).
      // Avoid treating it as a network URL.
      return ClipOval(
        child: Icon(
          Icons.person,
          size: size,
          color: theme.colorScheme.onSurface,
        ),
      );
    }
  }

  return ClipOval(
    child: CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (context, _) => Center(
        child: SizedBox(
          width: size * 0.36,
          height: size * 0.36,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, _, __) =>
          Icon(Icons.person, size: size, color: theme.colorScheme.onSurface),
    ),
  );
}

bool _isLocalFilePath(String value) {
  if (value.startsWith('file://')) return true;
  final uri = Uri.tryParse(value);
  if (uri != null && uri.scheme.isNotEmpty) {
    return false;
  }
  return value.startsWith('/');
}
