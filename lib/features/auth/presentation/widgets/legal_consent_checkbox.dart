import 'package:budgets/core/legal/legal_document_launcher.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';

class LegalConsentCheckbox extends StatelessWidget {
  const LegalConsentCheckbox({
    required this.value,
    required this.onChanged,
    required this.launcher,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final LegalDocumentLauncher launcher;

  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      decoration: TextDecoration.underline,
      fontSize: AppTypography.caption,
      fontWeight: FontWeight.w800,
    );
    final textStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: AppTypography.caption,
      fontWeight: FontWeight.w600,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          key: const Key('legal-consent-checkbox'),
          value: value,
          onChanged: (selected) => onChanged(selected ?? false),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 11),
            child: Wrap(
              children: [
                Text(context.l10n.legalConsentPrefix, style: textStyle),
                _LegalLink(
                  key: const Key('terms-and-conditions-link'),
                  label: context.l10n.termsAndConditions,
                  style: linkStyle,
                  onTap: launcher.openTermsAndConditions,
                ),
                Text(context.l10n.legalConsentConnector, style: textStyle),
                _LegalLink(
                  key: const Key('privacy-policy-link'),
                  label: context.l10n.privacyPolicy,
                  style: linkStyle,
                  onTap: launcher.openPrivacyPolicy,
                ),
                Text('.', style: textStyle),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({
    required this.label,
    required this.style,
    required this.onTap,
    super.key,
  });

  final String label;
  final TextStyle style;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          await onTap();
        } catch (error) {
          if (context.mounted) showErrorToast(context, error);
        }
      },
      child: Text(label, style: style),
    );
  }
}
