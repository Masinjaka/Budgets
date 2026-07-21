import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';

class AppToastOverlay extends StatefulWidget {
  const AppToastOverlay({
    required this.message,
    required this.color,
    required this.icon,
    required this.onDismissed,
    required this.onDisposed,
    this.displayDuration = const Duration(milliseconds: 2200),
    this.animationDuration = const Duration(milliseconds: 240),
    super.key,
  });

  final String message;
  final Color color;
  final IconData icon;
  final VoidCallback onDismissed;
  final VoidCallback onDisposed;
  final Duration displayDuration;
  final Duration animationDuration;

  @override
  State<AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<AppToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _position;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      reverseDuration: widget.animationDuration,
    );
    _position = Tween(
      begin: const Offset(1.25, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
    _controller.forward();
    _dismissTimer = Timer(
      widget.displayDuration,
      () => unawaited(_dismiss()),
    );
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    widget.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      right: 12,
      bottom: bottomInset + 12,
      child: IgnorePointer(
        child: SlideTransition(
          key: const Key('app-toast-slide'),
          position: _position,
          child: Semantics(
            liveRegion: true,
            child: Container(
              key: const Key('app-toast'),
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(11),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 17,
                    color: AppTheme.interactiveTextColor,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: AppTheme.interactiveTextColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
