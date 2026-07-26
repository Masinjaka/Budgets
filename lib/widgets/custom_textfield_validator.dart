import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/widgets.dart';

class CustomTextFieldValidator {
  const CustomTextFieldValidator(this.context);

  final BuildContext context;

  String? validate(String type, String? error, String? value) {
    switch (type) {
      case 'email':
        return _email(value);
      case 'required':
        return value == null || value.isEmpty ? error ?? '' : null;
      case 'password':
        return _password(value);
      default:
        return null;
    }
  }

  String? _email(String? value) {
    if (value == null || value.isEmpty) return context.l10n.enterEmail;
    final pattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return pattern.hasMatch(value) ? null : context.l10n.invalidEmail;
  }

  String? _password(String? value) {
    if (value == null || value.isEmpty) return context.l10n.enterPassword;
    if (value.length < 8) return context.l10n.passwordMinLength;
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return context.l10n.passwordNeedsUppercase;
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return context.l10n.passwordNeedsLowercase;
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return context.l10n.passwordNeedsNumber;
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return context.l10n.passwordNeedsSpecialCharacter;
    }
    return null;
  }
}
