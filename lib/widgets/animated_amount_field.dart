import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// A text field for amount input with a subtle scale animation on text change.
/// Uses a standard TextField for performance and cursor visibility.
class AnimatedAmountField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final double? fontSize;
  final double? height;
  final double? width;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final Map<String, String>? validator;

  const AnimatedAmountField({
    super.key,
    required this.controller,
    this.hint = '0.00',
    this.fontSize,
    this.height,
    this.width,
    this.fillColor,
    this.borderRadius,
    this.validator,
  });

  @override
  State<AnimatedAmountField> createState() => _AnimatedAmountFieldState();
}

class _AnimatedAmountFieldState extends State<AnimatedAmountField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String _previousText = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.03)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.03, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_animationController);

    widget.controller.addListener(_onTextChanged);
    _previousText = widget.controller.text;
  }

  void _onTextChanged() {
    if (widget.controller.text != _previousText) {
      _previousText = widget.controller.text;
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.fontSize ?? 28.sp;
    final height = widget.height ?? 15.h;
    final width = widget.width ?? double.infinity;
    final fillColor =
        widget.fillColor ?? Theme.of(context).colorScheme.surfaceDim;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(3.w);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: borderRadius,
          ),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: TextField(
        controller: widget.controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        cursorColor: Colors.grey,
        cursorWidth: 4.0,
        cursorHeight: fontSize * 0.8,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
        ],
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).hintColor,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

/// A smaller animated amount field for subcategory cards.
class AnimatedSubcategoryAmountField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final double? fontSize;
  final Color? fillColor;
  final BorderRadius? borderRadius;

  const AnimatedSubcategoryAmountField({
    super.key,
    required this.controller,
    this.hint = '0.00',
    this.fontSize,
    this.fillColor,
    this.borderRadius,
  });

  @override
  State<AnimatedSubcategoryAmountField> createState() =>
      _AnimatedSubcategoryAmountFieldState();
}

class _AnimatedSubcategoryAmountFieldState
    extends State<AnimatedSubcategoryAmountField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String _previousText = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.04)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.04, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_animationController);

    widget.controller.addListener(_onTextChanged);
    _previousText = widget.controller.text;
  }

  void _onTextChanged() {
    if (widget.controller.text != _previousText) {
      _previousText = widget.controller.text;
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.fontSize ?? 25.sp;
    final fillColor = widget.fillColor ?? Theme.of(context).colorScheme.surface;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(3.w);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: TextField(
        controller: widget.controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        cursorColor: const Color.fromARGB(255, 104, 104, 104),
        cursorWidth: 3.0,
        cursorHeight: fontSize * 0.9,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
        ],
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).hintColor.withAlpha(80),
          ),
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
        ),
      ),
    );
  }
}
