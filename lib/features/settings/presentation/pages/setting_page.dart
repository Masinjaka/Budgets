import 'package:budgets/core/ui/glass_flexible_space.dart';
import 'package:budgets/features/auth/presentation/controllers/auth_controller.dart';
import 'package:budgets/features/settings/domain/providers/theme_provider.dart';
import 'package:budgets/features/settings/presentation/widgets/setting_card.dart';
import 'package:budgets/features/settings/presentation/widgets/setting_section.dart';
import 'package:budgets/features/settings/presentation/widgets/theme_selection_dialog.dart';
import 'package:budgets/features/settings/presentation/widgets/user_card.dart';
import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  bool _isLoading = false;
  String _appVersion = '';
  static const String _fallbackVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVersion());
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _appVersion = info.version; // or '${info.version}+${info.buildNumber}'
      });
    } on MissingPluginException catch (_) {
      if (!mounted) return;
      setState(() {
        _appVersion = _fallbackVersion;
      });
    } on PlatformException catch (_) {
      if (!mounted) return;
      setState(() {
        _appVersion = _fallbackVersion;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyState = ref.watch(currencyControllerProvider).value;
    final currencyCode = currencyState?.code ?? 'MGA';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: const GlassFlexibleSpace(),
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'Paramètres',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h), // Top padding for glass effect
                  const UserCard(),
                  SizedBox(height: 4.h),
                  SettingSection(
                    title: 'Profil',
                    children: [
                      SizedBox(height: 1.h),
                      SettingCard(
                        title: 'Modifier le profil',
                        iconData: Icons.person_outline,
                        onTap: () {
                          context.push('/edit-profile');
                        },
                      ),
                      SizedBox(height: 1.h),
                      SettingCard(
                        title: 'Changer le mot de passe',
                        iconData: Icons.lock_outline,
                        onTap: () {
                          context.push('/edit-password');
                        },
                      ),
                      SizedBox(height: 1.h),
                      SettingCard(
                        title: 'Mes catégories',
                        iconData: Icons.category_outlined,
                        onTap: () {
                          context.push('/categories');
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  SettingSection(
                    title: 'Préférences',
                    children: [
                      SizedBox(height: 1.h),
                      SettingCard(
                        title: 'Activer la notification',
                        iconData: Icons.notifications_outlined,
                        onTap: () {
                          context.push('/notification-settings');
                        },
                      ),
                      SizedBox(height: 1.h),
                      SettingCard(
                        title: 'Devise',
                        iconData: Icons.attach_money_outlined,
                        onTap: () {
                          context.push('/currency-selection');
                        },
                        showSuffixSettingChoice: true,
                        settingChoice: currencyCode,
                      ),
                      SizedBox(height: 1.h),
                      SettingCard(
                        title: 'Apparence',
                        iconData: Icons.dark_mode_outlined,
                        onTap: () => _showThemeDialog(
                            context, ref.read(themeProvider.notifier)),
                        showSuffixSettingChoice: true,
                        settingChoice:
                            _themeModeToString(ref.watch(themeProvider)),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  SettingSection(
                    title: 'Support & légal',
                    children: [
                      SizedBox(height: 1.h),
                      SettingCard(
                        title: 'Centre d\'aide',
                        iconData: Icons.contact_support_outlined,
                        onTap: () {
                          // Navigate to support web page
                        },
                      ),
                      SizedBox(height: 1.h),
                      SettingCard(
                        title: 'CGU',
                        iconData: Icons.article_outlined,
                        onTap: () {
                          // Navigate to terms and privacy policy web page
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  _buildSignoutButton(),
                  SizedBox(height: 1.h),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Text(
                        'Version ${_appVersion.isEmpty ? '...' : _appVersion}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Jour';
      case ThemeMode.dark:
        return 'Nuit';
      case ThemeMode.system:
        return 'Système';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeNotifier themeNotifier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ThemeSelectionDialog(
          currentTheme: ref.read(themeProvider),
          onThemeChanged: (option) {
            themeNotifier.setTheme(option);
            // Optional: Close dialog on selection or let user close it by tapping outside/back
            // Navigator.pop(context);
            // Better to keep it open to see effect?
            // User requested "theme selection dialog", standard tabs usually persist selection.
            // But immediate switch feels good.
            // Let's keep it open so they can switch back if they don't like it,
            // they can dismiss by tapping outside.
          },
        );
      },
    );
  }

  CustomButton _buildSignoutButton() {
    return CustomButton(
      text: 'Se déconnecter',
      onPressed: () async {
        setState(() => _isLoading = true);
        await ref.read(authControllerProvider.notifier).signOut();
        if (!mounted) return;
        context.go('/getting-started');
        setState(() => _isLoading = false);
      },
      isLoading: _isLoading,
    );
  }
}
