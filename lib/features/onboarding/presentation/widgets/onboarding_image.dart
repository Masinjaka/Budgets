import 'package:flutter/material.dart';

class OnboardingImage extends StatelessWidget {
  final String path;

  const OnboardingImage(this.path, {super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
    );
  }
}
