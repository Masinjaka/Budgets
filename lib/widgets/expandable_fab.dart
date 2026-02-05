import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

/// An expandable floating action button that reveals child action buttons
/// when pressed. The child buttons animate outward from the main FAB.
class ExpandableFab extends StatefulWidget {
  final List<FabChildButton> children;
  final IconData icon;
  final IconData closeIcon;
  final Color? backgroundColor;
  final Color? iconColor;

  const ExpandableFab({
    super.key,
    required this.children,
    this.icon = Icons.add,
    this.closeIcon = Icons.close,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    Vibration.vibrate(duration: 30);
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        _controller.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.backgroundColor ?? Theme.of(context).primaryColor;
    final iconColor =
        widget.iconColor ?? Theme.of(context).colorScheme.onPrimary;

    return SizedBox(
      width: 56,
      height: _calculateHeight(),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Overlay to close when tapping outside
          if (_isOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                behavior: HitTestBehavior.translucent,
              ),
            ),
          // Child buttons
          ..._buildChildButtons(),
          // Main FAB
          _buildMainFab(backgroundColor, iconColor),
        ],
      ),
    );
  }

  double _calculateHeight() {
    // Base height for FAB + spacing for children
    const fabSize = 56.0;
    const childSize = 56.0;
    const spacing = 16.0;
    return fabSize + (widget.children.length * (childSize + spacing));
  }

  List<Widget> _buildChildButtons() {
    final List<Widget> buttons = [];
    const childSize = 56.0;
    const spacing = 16.0;
    const fabSize = 56.0;

    for (int i = 0; i < widget.children.length; i++) {
      final child = widget.children[i];
      // Calculate offset from bottom (above the main FAB)
      final offsetFromBottom = fabSize + spacing + (i * (childSize + spacing));

      buttons.add(
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, _) {
            return Positioned(
              bottom: offsetFromBottom * _expandAnimation.value,
              child: Transform.scale(
                scale: _expandAnimation.value,
                child: Opacity(
                  opacity: _expandAnimation.value,
                  child: _FabChildButton(
                    icon: child.icon,
                    backgroundColor:
                        child.backgroundColor ?? Theme.of(context).primaryColor,
                    iconColor: child.iconColor ??
                        Theme.of(context).colorScheme.onPrimary,
                    onPressed: () {
                      Vibration.vibrate(duration: 30);
                      _close();
                      child.onPressed();
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return buttons;
  }

  Widget _buildMainFab(Color backgroundColor, Color iconColor) {
    return SizedBox(
      width: 56,
      height: 56,
      child: FloatingActionButton(
        heroTag: 'expandable_fab_main',
        shape: const CircleBorder(),
        backgroundColor: backgroundColor,
        elevation: 4,
        onPressed: _toggle,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: Tween(begin: 0.5, end: 1.0).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Icon(
            _isOpen ? Icons.close : widget.icon,
            key: ValueKey(_isOpen),
            color: iconColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Configuration for a child button in the ExpandableFab
class FabChildButton {
  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final Color? backgroundColor;
  final Color? iconColor;

  const FabChildButton({
    required this.icon,
    required this.onPressed,
    this.label,
    this.backgroundColor,
    this.iconColor,
  });
}

/// Internal widget for rendering child FAB buttons
class _FabChildButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onPressed;

  const _FabChildButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: FloatingActionButton(
        heroTag: null,
        shape: const CircleBorder(),
        backgroundColor: backgroundColor,
        elevation: 4,
        onPressed: onPressed,
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
    );
  }
}
