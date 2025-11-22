import 'package:flutter/material.dart';

class AnimatedSliverAppBar extends StatelessWidget {
  final bool isVisible;
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color backgroundColor;
  final Duration duration;
  final Curve curve;

  const AnimatedSliverAppBar({
    super.key,
    required this.isVisible,
    required this.title,
    this.actions,
    this.leading,
    required this.backgroundColor,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        return SliverAppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: backgroundColor,
          pinned: true,
          floating: true,
          leading: leading,
          title: AnimatedOpacity(
            opacity: isVisible ? 1.0 : 0.0,
            duration: duration,
            curve: curve,
            child: AnimatedSlide(
              offset: isVisible ? Offset.zero : const Offset(0, -0.5),
              duration: duration,
              curve: curve,
              child: title,
            ),
          ),
          actions: actions
              ?.map((action) => AnimatedOpacity(
                    opacity: isVisible ? 1.0 : 0.0,
                    duration: duration,
                    curve: curve,
                    child: AnimatedSlide(
                      offset: isVisible ? Offset.zero : const Offset(0, -0.5),
                      duration: duration,
                      curve: curve,
                      child: action,
                    ),
                  ))
              .toList(),
          expandedHeight: isVisible ? kToolbarHeight : 0,
          toolbarHeight: isVisible ? kToolbarHeight : 0,
        );
      },
    );
  }
}
