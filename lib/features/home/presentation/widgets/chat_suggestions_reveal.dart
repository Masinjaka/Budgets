import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatSuggestionsReveal extends StatefulWidget {
  const ChatSuggestionsReveal({
    required this.visible,
    required this.child,
    super.key,
  });

  final bool visible;
  final Widget child;

  @override
  State<ChatSuggestionsReveal> createState() => _ChatSuggestionsRevealState();
}

class _ChatSuggestionsRevealState extends State<ChatSuggestionsReveal> {
  bool _showChild = false;
  bool _isExiting = false;

  @override
  void didUpdateWidget(ChatSuggestionsReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) return;
    _showChild = true;
    _isExiting = !widget.visible;
  }

  void _finishExit(AnimationController _) {
    if (!mounted || widget.visible) return;
    setState(() {
      _showChild = false;
      _isExiting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_showChild) {
      return const SizedBox(key: Key('chat-suggestions-reveal'));
    }
    final animated = _isExiting ? _exitAnimation() : _enterAnimation();
    return KeyedSubtree(
      key: const Key('chat-suggestions-reveal'),
      child: IgnorePointer(
        ignoring: !widget.visible,
        child: animated,
      ),
    );
  }

  Widget _enterAnimation() => widget.child
      .animate(key: const ValueKey('suggestions-enter'))
      .custom(
        duration: 340.ms,
        curve: Curves.easeOutBack,
        builder: _sizeBuilder,
      )
      .fadeIn(duration: 180.ms)
      .slideY(begin: 0.18, end: 0, duration: 340.ms, curve: Curves.easeOutBack)
      .scaleXY(
        begin: 0.96,
        end: 1,
        duration: 340.ms,
        curve: Curves.easeOutBack,
        alignment: Alignment.bottomCenter,
      );

  Widget _exitAnimation() => widget.child
      .animate(
        key: const ValueKey('suggestions-exit'),
        onComplete: _finishExit,
      )
      .custom(
        duration: 220.ms,
        curve: Curves.easeInBack,
        begin: 1,
        end: 0,
        builder: _sizeBuilder,
      )
      .fadeOut(duration: 150.ms)
      .slideY(begin: 0, end: 0.12, duration: 220.ms, curve: Curves.easeInBack)
      .scaleXY(
        begin: 1,
        end: 0.96,
        duration: 220.ms,
        curve: Curves.easeInBack,
        alignment: Alignment.bottomCenter,
      );

  Widget _sizeBuilder(BuildContext context, double value, Widget child) {
    return ClipRect(
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: value,
        child: child,
      ),
    );
  }
}
