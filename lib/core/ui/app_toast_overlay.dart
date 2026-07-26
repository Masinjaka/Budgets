import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppToastOverlay extends StatefulWidget {
  const AppToastOverlay({
    required this.message,
    required this.color,
    required this.icon,
    required this.onDismissed,
    required this.onDisposed,
    this.displayDuration = const Duration(milliseconds: 3000),
    this.animationDuration = const Duration(milliseconds: 380),
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

class _AppToastOverlayState extends State<AppToastOverlay> {
  Timer? _dismissTimer;
  var _isExiting = false;

  void _startDismissTimer() {
    _dismissTimer?.cancel();
    _dismissTimer = Timer(
      widget.displayDuration,
      _dismiss,
    );
  }

  void _dismiss() {
    if (!mounted || _isExiting) return;
    setState(() => _isExiting = true);
  }

  void _finishDismissal(AnimationController _) {
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    widget.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Positioned(
      left: 12,
      right: 12,
      top: topInset + 12,
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: _buildToast(),
        ),
      ),
    );
  }

  Widget _buildToast() {
    final toast = Material(
      type: MaterialType.transparency,
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
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (_isExiting) {
      return toast
          .animate(
            key: const Key('app-toast-exit'),
            onComplete: _finishDismissal,
          )
          .fadeOut(
            duration: widget.animationDuration,
            curve: Curves.easeIn,
          )
          .slideY(
            begin: 0,
            end: -1.5,
            duration: widget.animationDuration,
            curve: Curves.easeInBack,
          );
    }

    return toast
        .animate(
          key: const Key('app-toast-enter'),
          onComplete: (_) => _startDismissTimer(),
        )
        .fadeIn(
          duration: widget.animationDuration,
          curve: Curves.easeOut,
        )
        .slideY(
          begin: -1.5,
          end: 0,
          duration: widget.animationDuration,
          curve: Curves.easeOutBack,
        );
  }
}
