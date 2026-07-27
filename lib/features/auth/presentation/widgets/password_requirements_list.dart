import 'package:budgets/features/auth/domain/models/password_validation.dart';
import 'package:budgets/features/auth/presentation/widgets/password_requirement_item.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';

class PasswordRequirementsList extends StatelessWidget {
  const PasswordRequirementsList({
    required this.validation,
    super.key,
  });

  final PasswordValidation validation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('password-requirements'),
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          PasswordRequirementItem(
            requirementKey: const Key('password-requirement-length'),
            label: context.l10n.passwordRuleMinLength,
            isSatisfied: validation.hasMinimumLength,
          ),
          PasswordRequirementItem(
            requirementKey: const Key('password-requirement-uppercase'),
            label: context.l10n.passwordRuleUppercase,
            isSatisfied: validation.hasUppercase,
          ),
          PasswordRequirementItem(
            requirementKey: const Key('password-requirement-lowercase'),
            label: context.l10n.passwordRuleLowercase,
            isSatisfied: validation.hasLowercase,
          ),
          PasswordRequirementItem(
            requirementKey: const Key('password-requirement-number'),
            label: context.l10n.passwordRuleNumber,
            isSatisfied: validation.hasNumber,
          ),
          PasswordRequirementItem(
            requirementKey: const Key('password-requirement-special'),
            label: context.l10n.passwordRuleSpecialCharacter,
            isSatisfied: validation.hasSpecialCharacter,
          ),
        ],
      ),
    );
  }
}
