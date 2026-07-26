import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ReceiptThumbnail extends StatelessWidget {
  const ReceiptThumbnail({
    required this.url,
    required this.mimeType,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String url;
  final String mimeType;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (mimeType == 'application/pdf') {
      return ColoredBox(
        color: Theme.of(context).cardColor,
        child: const Center(
          child: Icon(Icons.picture_as_pdf_outlined, size: 48),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (_, __) => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      errorWidget: (_, __, ___) => const Center(
        child: Icon(Icons.broken_image_outlined),
      ),
    );
  }
}
