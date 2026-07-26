import 'package:budgets/features/settings/presentation/widgets/settings_menu_group.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_menu_item.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_section_title.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:budgets/l10n/app_localizations_context.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({
    required this.profileHeader,
    required this.onEditProfile,
    required this.onChangePassword,
    required this.onNotifications,
    required this.onCurrency,
    required this.onDefaultWallet,
    required this.onTheme,
    required this.onLanguage,
    required this.onScannedReceipts,
    required this.onTerms,
    required this.onPrivacy,
    required this.onLogout,
    required this.isLoggingOut,
    super.key,
  });

  final Widget profileHeader;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;
  final VoidCallback onNotifications;
  final VoidCallback onCurrency;
  final VoidCallback onDefaultWallet;
  final VoidCallback onTheme;
  final VoidCallback onLanguage;
  final VoidCallback onScannedReceipts;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;
  final VoidCallback onLogout;
  final bool isLoggingOut;

  @override
  Widget build(BuildContext context) {
    final localizations = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
      children: [
        profileHeader,
        const SizedBox(height: 39),
        SettingsMenuGroup(
          items: [
            SettingsMenuItem(
              title: localizations.editProfile,
              icon: Icons.manage_accounts_outlined,
              onTap: onEditProfile,
            ),
            SettingsMenuItem(
              title: localizations.changePassword,
              icon: Icons.lock_reset_rounded,
              onTap: onChangePassword,
            ),
          ],
        ),
        const SizedBox(height: 32),
        SettingsSectionTitle(localizations.preferences),
        const SizedBox(height: 12),
        SettingsMenuGroup(
          items: [
            SettingsMenuItem(
              title: localizations.notification,
              icon: Icons.notifications_none_rounded,
              onTap: onNotifications,
            ),
            SettingsMenuItem(
              title: localizations.currency,
              icon: Icons.currency_exchange_rounded,
              onTap: onCurrency,
            ),
            SettingsMenuItem(
              title: localizations.setDefaultWallet,
              icon: Icons.account_balance_wallet_outlined,
              onTap: onDefaultWallet,
            ),
            SettingsMenuItem(
              title: localizations.theme,
              icon: Icons.contrast_rounded,
              onTap: onTheme,
            ),
            SettingsMenuItem(
              title: localizations.language,
              icon: Icons.language_rounded,
              onTap: onLanguage,
            ),
            SettingsMenuItem(
              title: localizations.scannedReceipts,
              icon: Icons.document_scanner_outlined,
              onTap: onScannedReceipts,
            ),
          ],
        ),
        const SizedBox(height: 25),
        SettingsSectionTitle(localizations.legal),
        const SizedBox(height: 12),
        SettingsMenuGroup(
          items: [
            SettingsMenuItem(
              title: localizations.termsOfService,
              icon: Icons.description_outlined,
              onTap: onTerms,
            ),
            SettingsMenuItem(
              title: localizations.privacyPolicy,
              icon: Icons.shield_outlined,
              onTap: onPrivacy,
            ),
          ],
        ),
        const SizedBox(height: 38),
        CustomButton.outlined(
          text: localizations.logOut,
          isLoading: isLoggingOut,
          onPressed: isLoggingOut ? null : onLogout,
        ),
      ],
    );
  }
}
