import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SlidingDrawerLayout extends StatelessWidget {
  const SlidingDrawerLayout({
    required this.controller,
    required this.drawerWidth,
    required this.drawer,
    required this.home,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
    this.maximumDimming = 0.09,
    super.key,
  });

  final AnimationController controller;
  final double drawerWidth;
  final Widget drawer;
  final Widget home;
  final void Function(DragUpdateDetails details) onDragUpdate;
  final void Function(DragEndDetails details) onDragEnd;
  final VoidCallback onDragCancel;
  final double maximumDimming;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: drawerWidth,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) => Transform.translate(
              key: const Key('drawer-panel'),
              offset: Offset(drawerWidth * (controller.value - 1), 0),
              child: _dragSurface(
                key: const Key('drawer-drag-surface'),
                child: child!,
              ),
            ),
            child: drawer,
          ),
        ),
        _dragSurface(
          key: const Key('home-drag-surface'),
          behavior: HitTestBehavior.deferToChild,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final panel = KeyedSubtree(
                key: const Key('home-page-panel'),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    child!,
                    IgnorePointer(
                      child: ColoredBox(
                        key: const Key('home-dim-overlay'),
                        color: Color.fromRGBO(
                          0,
                          0,
                          0,
                          maximumDimming * controller.value,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              final offset = drawerWidth * controller.value;
              if (offset.abs() < 0.001) return panel;
              return Transform.translate(
                offset: Offset(offset, 0),
                child: panel,
              );
            },
            child: home,
          ),
        ),
      ],
    );
  }

  Widget _dragSurface({
    required Key key,
    required Widget child,
    HitTestBehavior behavior = HitTestBehavior.opaque,
  }) {
    return GestureDetector(
      key: key,
      behavior: behavior,
      dragStartBehavior: DragStartBehavior.down,
      onHorizontalDragStart: (_) => controller.stop(),
      onHorizontalDragUpdate: onDragUpdate,
      onHorizontalDragEnd: onDragEnd,
      onHorizontalDragCancel: onDragCancel,
      child: child,
    );
  }
}
