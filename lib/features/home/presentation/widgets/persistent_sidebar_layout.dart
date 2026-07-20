import 'dart:ui';

import 'package:flutter/material.dart';

class PersistentSidebarLayout extends StatelessWidget {
  const PersistentSidebarLayout({
    required this.controller,
    required this.expandedWidth,
    required this.collapsedWidth,
    required this.expandedSidebar,
    required this.collapsedSidebar,
    required this.home,
    super.key,
  });

  final AnimationController controller;
  final double expandedWidth;
  final double collapsedWidth;
  final Widget expandedSidebar;
  final Widget collapsedSidebar;
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final progress = controller.value;
        final width = lerpDouble(
          collapsedWidth,
          expandedWidth,
          progress,
        )!;
        return Row(
          key: const Key('persistent-sidebar-layout'),
          children: [
            SizedBox(
              key: const Key('persistent-sidebar-container'),
              width: width,
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      width: expandedWidth,
                      child: IgnorePointer(
                        ignoring: progress < 0.5,
                        child: Opacity(
                          opacity: progress,
                          child: expandedSidebar,
                        ),
                      ),
                    ),
                    IgnorePointer(
                      ignoring: progress >= 0.5,
                      child: Opacity(
                        opacity: 1 - progress,
                        child: collapsedSidebar,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: home),
          ],
        );
      },
    );
  }
}
