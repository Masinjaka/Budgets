import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget avatarSkeleton(BuildContext context, double size) {
  final theme = Theme.of(context);
  return Shimmer.fromColors(
    baseColor: theme.colorScheme.surface,
    highlightColor: theme.colorScheme.onSurface.withOpacity(0.1),
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
    highlightColor: theme.colorScheme.onSurface.withOpacity(0.1),
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

  return ClipOval(
    child: CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (context, _) => avatarSkeleton(context, size),
      errorWidget: (context, _, __) =>
          Icon(Icons.person, size: size, color: theme.colorScheme.onSurface),
    ),
  );
}
