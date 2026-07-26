import 'package:flutter/animation.dart';
import 'package:flutter/gestures.dart';

class HomeDrawerMotionController {
  HomeDrawerMotionController(TickerProvider vsync)
      : animation = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 250),
        );

  static const _duration = Duration(milliseconds: 250);
  static const _flingVelocity = 500.0;
  final AnimationController animation;

  void open() => animateTo(1);

  void close() => animateTo(0);

  void animateTo(double target) {
    final distance = (target - animation.value).abs();
    if (distance == 0) return;
    animation.animateTo(
      target,
      duration: Duration(
        milliseconds: (_duration.inMilliseconds * distance)
            .round()
            .clamp(1, _duration.inMilliseconds),
      ),
      curve: Curves.easeOutCubic,
    );
  }

  void updateDrag(DragUpdateDetails details, double drawerWidth) {
    animation.value =
        (animation.value + details.delta.dx / drawerWidth).clamp(0, 1);
  }

  void settle(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final target = velocity.abs() >= _flingVelocity
        ? (velocity > 0 ? 1.0 : 0.0)
        : (animation.value >= 0.5 ? 1.0 : 0.0);
    animateTo(target);
  }

  void cancelDrag() => animateTo(animation.value >= 0.5 ? 1 : 0);

  void dispose() => animation.dispose();
}
