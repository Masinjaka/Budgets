import 'package:budgets/core/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget avatarSkeleton(double size) {
    return Shimmer.fromColors(
      baseColor: AppTheme.secondaryDark,
      highlightColor: AppTheme.borderColorDark,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.borderColorDark,
        ),
      ),
    );
  }

  
  Widget textSkeleton(double width, double height) {
    return Shimmer.fromColors(
      baseColor: AppTheme.secondaryDark,
      highlightColor: AppTheme.borderColorDark,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget avatar(String? url, double size) {
    if (url == null || url.isEmpty) {
      return ClipOval(
        child: Icon(Icons.person, size: size, color: Colors.white),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, _) => avatarSkeleton(size),
        errorWidget: (context, _, __) => Icon(Icons.person, size: size, color: Colors.white),
      ),
    );
  }