import 'dart:ui';
import 'package:flutter/material.dart';

class GlassFlexibleSpace extends StatelessWidget {
  final double blurSigma;
  final double opacity;

  const GlassFlexibleSpace({
    super.key,
    this.blurSigma = 10.0,
    this.opacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          color: Theme.of(context)
                  .appBarTheme
                  .backgroundColor
                  ?.withOpacity(opacity) ??
              Theme.of(context).colorScheme.surface.withOpacity(opacity),
        ),
      ),
    );
  }
}
