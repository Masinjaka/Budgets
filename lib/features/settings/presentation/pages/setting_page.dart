import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/auth/presentation/controllers/auth_controller.dart';
import 'package:budgets/features/notifications/presentation/pages/notification_settings_page.dart';
import 'package:budgets/features/settings/presentation/pages/currency_selection_page.dart';
import 'package:budgets/features/settings/presentation/pages/default_wallet_page.dart';
import 'package:budgets/features/settings/presentation/pages/edit_password_page.dart';
import 'package:budgets/features/settings/presentation/pages/edit_profile_page.dart';
import 'package:budgets/features/settings/presentation/pages/legal_settings_page.dart';
import 'package:budgets/features/settings/presentation/pages/language_settings_page.dart';
import 'package:budgets/features/settings/presentation/pages/theme_settings_page.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_content.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_profile_header.dart';
import 'package:budgets/features/receipts/presentation/pages/receipt_gallery_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:budgets/l10n/app_localizations_context.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({this.onDataDeleted, super.key});

  final VoidCallback? onDataDeleted;

  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).cardColor,
        centerTitle: true,
        toolbarHeight: 72,
        surfaceTintColor: Colors.transparent,
        title: Text(
          context.l10n.settings,
          style: const TextStyle(
            fontSize: AppTypography.title,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SettingsContent(
              profileHeader: const SettingsProfileHeader(),
              onEditProfile: () => _open(
                EditProfilePage(onDataDeleted: widget.onDataDeleted),
              ),
              onChangePassword: () => _open(const EditPasswordPage()),
              onNotifications: () => _open(const NotificationSettingsPage()),
              onCurrency: () => _open(const CurrencySelectionPage()),
              onDefaultWallet: () => _open(const DefaultWalletPage()),
              onTheme: () => _open(const ThemeSettingsPage()),
              onLanguage: () => _open(const LanguageSettingsPage()),
              onScannedReceipts: () => _open(const ReceiptGalleryPage()),
              onTerms: () => _open(const LegalSettingsPage.terms()),
              onPrivacy: () => _open(const LegalSettingsPage.privacy()),
              onLogout: _logout,
              isLoggingOut: _isLoggingOut,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _open(Widget page) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => page),
      );

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    await ref.read(authControllerProvider.notifier).signOut();
    if (!mounted) return;
    context.go('/getting-started');
  }
}
