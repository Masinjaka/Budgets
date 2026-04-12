import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LottieNavIcon extends StatefulWidget {
  const LottieNavIcon({
    super.key,
    required this.darkAsset,
    required this.lightAsset,
    required this.isActive,
    required this.tapNotifier,
    this.size,
  });

  final String darkAsset;
  final String lightAsset;
  final bool isActive;
  final ValueNotifier<int> tapNotifier;
  final double? size;

  @override
  State<LottieNavIcon> createState() => _LottieNavIconState();
}

class _LottieNavIconState extends State<LottieNavIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _lastTap = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _lastTap = widget.tapNotifier.value;
    widget.tapNotifier.addListener(_onTap);
  }

  void _onTap() {
    if (widget.tapNotifier.value != _lastTap) {
      _lastTap = widget.tapNotifier.value;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    widget.tapNotifier.removeListener(_onTap);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Dark icons for light mode, light icons for dark mode
    final asset = isDark ? widget.lightAsset : widget.darkAsset;

    final iconSize = widget.size ?? 5.w;
    return Lottie.asset(
      asset,
      controller: _controller,
      width: iconSize,
      height: iconSize,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
        if (widget.isActive) {
          _controller.forward();
        }
      },
    );
  }
}
