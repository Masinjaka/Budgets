import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/auth/domain/models/password_validation.dart';
import 'package:budgets/features/auth/presentation/widgets/password_animated_section.dart';
import 'package:budgets/features/auth/presentation/widgets/password_requirements_list.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class SignUpPasswordFields extends StatefulWidget {
  const SignUpPasswordFields({
    required this.passwordController,
    required this.confirmPasswordController,
    super.key,
  });

  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  @override
  State<SignUpPasswordFields> createState() => SignUpPasswordFieldsState();
}

class SignUpPasswordFieldsState extends State<SignUpPasswordFields> {
  final FocusNode _passwordFocusNode = FocusNode();
  late PasswordValidation _validation;

  bool get _showRequirements => _passwordFocusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _validation = PasswordValidation(widget.passwordController.text);
    _passwordFocusNode.addListener(_refresh);
  }

  @override
  void dispose() {
    _passwordFocusNode
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh([String? password]) {
    if (!mounted) return;
    setState(() {
      _validation =
          PasswordValidation(password ?? widget.passwordController.text);
      if (!_validation.isSatisfied) {
        widget.confirmPasswordController.clear();
      }
    });
  }

  void focusPassword() => _passwordFocusNode.requestFocus();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextField(
          title: const Text(
            'Mot de passe',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: AppTypography.body,
            ),
          ),
          hint: 'votre mot de passe',
          controller: widget.passwordController,
          focusNode: _passwordFocusNode,
          onChanged: _refresh,
          keyboardType: TextInputType.visiblePassword,
          isPassword: true,
        ),
        PasswordAnimatedSection(
          isVisible: _showRequirements,
          child: PasswordRequirementsList(validation: _validation),
        ),
        PasswordAnimatedSection(
          isVisible: _validation.isSatisfied,
          padding: const EdgeInsets.only(top: 16),
          child: CustomTextField(
            key: const Key('confirm-password-field'),
            title: const Text(
              'Confirmer le mot de passe',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: AppTypography.body,
              ),
            ),
            hint: 'votre mot de passe',
            controller: widget.confirmPasswordController,
            keyboardType: TextInputType.visiblePassword,
            isPassword: true,
            validator: <String, String>{
              'type': 'required',
              'error': context.l10n.enterPassword,
            },
          ),
        ),
      ],
    );
  }
}
