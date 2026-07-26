import 'package:flutter/material.dart';

class BottomSheetDragHandle extends StatelessWidget {
  const BottomSheetDragHandle({this.height = 8, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 53,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .24),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
