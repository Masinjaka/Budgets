import 'package:budgets/core/ui/app_control_metrics.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/widgets/custom_textfield_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomTextField extends ConsumerStatefulWidget {
  const CustomTextField({
    super.key,
    required this.title,
    this.hint,
    required this.controller,
    this.isPassword,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.isReadOnly,
    this.onTap,
    this.width,
    this.height,
    this.textAlign,
    this.fontSize,
    this.borderRadius,
    this.contentPadding,
    this.maxLines = 1,
    this.minLines,
    this.fillColor,
  });
  final Widget title;
  final String? hint;
  final TextEditingController controller;
  final bool? isPassword;
  final TextInputType? keyboardType;
  final Map<String, String>? validator;
  final Widget? suffixIcon;
  final bool? isReadOnly;
  final void Function()? onTap;
  final double? width;
  final double? height;
  final TextAlign? textAlign;
  final double? fontSize;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final int? maxLines;
  final int? minLines;
  final Color? fillColor;

  @override
  ConsumerState<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends ConsumerState<CustomTextField> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.isPassword == true;
    final fontSize = widget.fontSize ?? AppTypography.body;
    final fieldHeight = widget.height ?? AppControlMetrics.height;
    const textFieldRoundingCorrection = 0.2;
    final verticalPadding =
        ((fieldHeight - fontSize * 1.2) / 2 - textFieldRoundingCorrection)
            .clamp(0, fieldHeight)
            .toDouble();
    final effectivePadding = widget.contentPadding ??
        EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: AppControlMetrics.horizontalPadding,
        );
    final radius =
        widget.borderRadius ?? BorderRadius.circular(fieldHeight / 2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.title,
        const SizedBox(height: AppControlMetrics.contentGap),
        SizedBox(
          width: widget.width,
          child: TextFormField(
            readOnly: widget.isReadOnly ?? false,
            obscureText: isObscure && isPassword,
            controller: widget.controller,
            keyboardType: widget.keyboardType ?? TextInputType.text,
            textAlign: widget.textAlign ?? TextAlign.start,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: fontSize,
              height: 1.2,
            ),
            validator: (String? value) {
              return CustomTextFieldValidator(context).validate(
                widget.validator?['type'] ?? '',
                widget.validator?['error'] ?? '',
                value,
              );
            },
            cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: widget.fillColor ?? Theme.of(context).cardColor,
              contentPadding: effectivePadding,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.transparent,
                ),
                borderRadius: radius,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: const BorderSide(
                  color: Colors.transparent, // Match blue stroke when focused
                  width: 1.8,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 1.8,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 1.8,
                ),
              ),
              hintText: widget.hint,
              suffixIcon: isPassword
                  ? IconButton(
                      constraints: BoxConstraints.tightFor(
                        width: fieldHeight,
                        height: fieldHeight,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          isObscure = !isObscure;
                        });
                      },
                      icon: Icon(
                        isObscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    )
                  : widget.suffixIcon,
              hintStyle: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withAlpha(100),
                fontSize: fontSize,
              ),
            ),
            onTap: widget.onTap,
          ),
        ),
      ],
    );
  }
}
