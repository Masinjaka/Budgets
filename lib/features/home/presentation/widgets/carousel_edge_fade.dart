import 'package:flutter/material.dart';

class CarouselEdgeFade extends StatelessWidget {
  const CarouselEdgeFade({
    required this.isLeft,
    super.key,
  });

  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor;
    return Positioned(
      top: 0,
      bottom: 0,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      width: 30,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
              end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
              colors: [
                background,
                background.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
