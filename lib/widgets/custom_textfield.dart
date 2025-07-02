import 'package:budgets/core/theme.dart';
import 'package:budgets/provider/app_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomTextField extends ConsumerStatefulWidget {
  const CustomTextField({
    super.key,
    required this.title,
    this.hint,
    required this.controller,
    this.isPassword,
    this.keyboardType,
    this.validator,
  });
  final String title;
  final String? hint;
  final TextEditingController controller;
  final bool? isPassword;
  final TextInputType? keyboardType;
  final Map<String,String>? validator;

  @override
  ConsumerState<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends ConsumerState<CustomTextField> {
  bool isObscure = true;
  bool _isDarkMode = false;

  String? validateEmail(String? v) {
    if (v == null || v.isEmpty) {
      return "Veuillez entrer une adresse email";
    }

    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(v)) {
      return "Veuillez entrer une adresse email valide";
    }
    return null;
  }

  String? validateTextRequired(String? v, String error) {
    if (v == null || v.isEmpty) return error;
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty || v.length < 8) {
      return "Le mot de passe doit contenir au moins";
    }

    // Check for uppercase, lowercase, number, and special character
    RegExp uppercaseRegex = RegExp(r'[A-Z]');
    RegExp lowercaseRegex = RegExp(r'[a-z]');
    RegExp digitRegex = RegExp(r'[0-9]');
    RegExp specialCharRegex = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');

    if (!uppercaseRegex.hasMatch(v)) {
      return "un majuscule";
    }

    if (!lowercaseRegex.hasMatch(v)) {
      return "un minuscule";
    }

    if (!digitRegex.hasMatch(v)) {
      return "un chiffre";
    }

    if (!specialCharRegex.hasMatch(v)) {
      return "un caractère spécial";
    }

    return null; // Password is valid
  }

  String? validate(String type, String? error, String? value) {
    switch (type) {
      case 'email':
        return validateEmail(value);
      case 'required':
        return validateTextRequired(value, error ?? "");
      case 'password':
        return validatePassword(value);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPassord = widget.isPassword != null && widget.isPassword!;

    final globalTheme = ref.watch(globalThemeProvider);

    _isDarkMode = globalTheme == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15.5.sp,
          ),
        ),
        SizedBox(
          height: 1.h,
        ),
        
        TextFormField(
          obscureText: isObscure && isPassord,
          controller: widget.controller,
          keyboardType: widget.keyboardType ?? TextInputType.text,
          validator: (String? value) {
            return validate(
              widget.validator?['type'] ?? '',
              widget.validator?['error'] ?? '',
              value,
            );
          },
          cursorColor: _isDarkMode ? AppTheme.textDark: Colors.black,
          decoration: InputDecoration(
            filled: _isDarkMode ? true:false,
            fillColor: AppTheme.secondaryDark,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _isDarkMode ? Colors.transparent: Colors.black,
              ),
              borderRadius: BorderRadius.circular(2.w),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: BorderSide(
                color: _isDarkMode ? Colors.transparent: Colors.black, // Match blue stroke when focused
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 252, 154, 147),
                width: 1.8,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: const BorderSide(
                color: Colors.black,
                width: 1.8,
              ),
            ),
            hintText: widget.hint,
            suffixIcon: isPassord
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isObscure = !isObscure;
                      });
                    },
                    icon: Icon(
                      isObscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _isDarkMode ? AppTheme.textDark: Colors.black,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
