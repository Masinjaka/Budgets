import 'package:budgets/features/auth/presentation/controllers/auth_controller.dart';
import 'package:budgets/features/settings/presentation/providers/theme_provider.dart';
import 'package:budgets/features/settings/presentation/widgets/setting_card.dart';
import 'package:budgets/features/settings/presentation/widgets/setting_section.dart';
import 'package:budgets/features/settings/presentation/widgets/user_card.dart';
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
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const UserCard(),
                    SizedBox(height: 4.h),
                    SettingSection(
                      title: 'Profil',
                      children: [
                        SizedBox(height: 2.h),
                        SettingCard(
                          title: 'Modifier le profil',
                          iconData: Icons.person_outline,
                          onTap: () {
                            context.push('/edit-profile');
                          },
                        ),
                        SizedBox(height: 2.h),
                        SettingCard(
                          title: 'Changer le mot de passe',
                          iconData: Icons.lock_outline,
                          onTap: () {
                            context.push('/edit-password');
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    SettingSection(
                      title: 'Préférences',
                      children: [
                        SizedBox(height: 2.h),
                        SettingCard(
                          title: 'Activer la notification',
                          iconData: Icons.notifications_outlined,
                          useSwitch: true,
                          onSwitchChanged: (value) {
                            // Handle switch change
                          },
                          onTap: () {
                            // Toggle push notification settings
                          },
                        ),
                        SizedBox(height: 2.h),
                        SettingCard(
                          title: 'Devise',
                          iconData: Icons.attach_money_outlined,
                          onTap: () {
                            // Open currency selection dialog
                          },
                          showSuffixSettingChoice: true,
                          settingChoice: 'MGA',
                        ),
                        SizedBox(height: 2.h),
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
                        SizedBox(height: 2.h),
                        SettingCard(
                          title: 'Centre d\'aide',
                          iconData: Icons.contact_support_outlined,
                          onTap: () {
                            // Navigate to support web page
                          },
                        ),
                        SizedBox(height: 2.h),
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
      default:
        return 'Système';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeNotifier themeNotifier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Apparence'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                themeNotifier.setTheme(ThemeOptions.light);
                Navigator.pop(context);
              },
              child: const Text('Jour'),
            ),
            SimpleDialogOption(
              onPressed: () {
                themeNotifier.setTheme(ThemeOptions.dark);
                Navigator.pop(context);
              },
              child: const Text('Nuit'),
            ),
            SimpleDialogOption(
              onPressed: () {
                themeNotifier.setTheme(ThemeOptions.system);
                Navigator.pop(context);
              },
              child: const Text('Système'),
            ),
          ],
        );
      },
    );
  }

  _buildSignoutButton() {
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
