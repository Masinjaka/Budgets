import 'package:budgets/core/ui/app_control_metrics.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.text,
    required this.onPressed,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.icon,
    this.iconColor,
    this.isSquare = false,
    this.borderRadius,
    this.isLoading,
    super.key,
  }) : outlined = false;

  const CustomButton.outlined({
    required this.text,
    required this.onPressed,
    this.width,
    this.foregroundColor,
    this.borderColor,
    this.icon,
    this.iconColor,
    this.isSquare = false,
    this.borderRadius,
    this.isLoading,
    super.key,
  })  : backgroundColor = Colors.transparent,
        outlined = true;

  const CustomButton.icon({
    required this.icon,
    required this.onPressed,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.iconColor,
    this.isSquare = false,
    this.borderColor,
    this.borderRadius,
    this.isLoading,
    super.key,
  })  : text = null,
        outlined = false;

  final String? text;
  final double? width;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final IconData? icon;
  final Color? iconColor;
  final bool isSquare;
  final BorderRadius? borderRadius;
  final VoidCallback? onPressed;
  final bool? isLoading;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(context);
    return SizedBox(
      width: width ?? double.infinity,
      height: AppControlMetrics.height,
      child: ElevatedButton(
        onPressed: isLoading == true ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colors.background,
          foregroundColor: colors.foreground,
          disabledBackgroundColor: colors.background.withValues(alpha: 0.65),
          disabledForegroundColor: colors.foreground,
          side: _border(colors.foreground),
          shape: RoundedRectangleBorder(
            borderRadius:
                borderRadius ?? BorderRadius.circular(isSquare ? 12 : 999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading == true
            ? SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.foreground,
                ),
              )
            : _content(colors.foreground),
      ),
    );
  }

  BorderSide _border(Color fallback) {
    if (borderColor != null) return BorderSide(color: borderColor!);
    return outlined ? BorderSide(color: fallback) : BorderSide.none;
  }

  ({Color background, Color foreground}) _resolveColors(
    BuildContext context,
  ) {
    final colors = Theme.of(context).colorScheme;
    if (outlined) {
      return (
        background: Colors.transparent,
        foreground: foregroundColor ?? colors.onSurface,
      );
    }
    final background = backgroundColor ?? colors.inverseSurface;
    final defaultForeground = backgroundColor == null
        ? colors.onInverseSurface
        : ThemeData.estimateBrightnessForColor(background) == Brightness.dark
            ? Colors.white
            : Colors.black;
    return (
      background: background,
      foreground: foregroundColor ?? defaultForeground,
    );
  }

  Widget _content(Color color) {
    final label = Text(
      text ?? '',
      style: TextStyle(
        fontSize: AppTypography.body,
        fontWeight: FontWeight.w800,
        color: color,
      ),
    );
    if (icon == null) return label;
    if (text == null || text!.isEmpty) {
      return Icon(icon, color: iconColor ?? color);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor ?? color),
        const SizedBox(width: AppControlMetrics.contentGap),
        label,
      ],
    );
  }
}
