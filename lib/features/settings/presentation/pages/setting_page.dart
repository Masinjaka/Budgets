import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/ui/glass_flexible_space.dart';
import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/features/auth/presentation/controllers/auth_controller.dart';
import 'package:budgets/features/settings/domain/providers/theme_provider.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_content.dart';
import 'package:budgets/features/settings/presentation/widgets/theme_selection_dialog.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/skeleton/profile_picture_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  bool _isLoading = false;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVersion());
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _appVersion = info.version);
    } on MissingPluginException {
      if (mounted) setState(() => _appVersion = '1.0.0');
    } on PlatformException {
      if (mounted) setState(() => _appVersion = '1.0.0');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyControllerProvider);
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
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: SizedBox.expand(
          child: SettingsContent(
            currencyChoice: currency.when(
              data: (state) => _currencyText(state.code),
              loading: () => textSkeleton(context, 10.w, 1.8.h),
              error: (_, __) => _currencyText('MGA'),
            ),
            onAppearance: _showThemeDialog,
            signOutButton: _signOutButton(),
            appVersion: _appVersion.isEmpty ? '...' : _appVersion,
          ),
        ),
      ),
    );
  }

  Text _currencyText(String value) => Text(
        value,
        style: TextStyle(fontSize: 15.sp, color: Colors.grey),
      );

  void _showThemeDialog() {
    showAnimatedDialog(
      context: context,
      builder: (_) => ThemeSelectionDialog(
        currentTheme: ref.read(themeProvider),
        onThemeChanged: ref.read(themeProvider.notifier).setTheme,
      ),
    );
  }

  CustomButton _signOutButton() => CustomButton(
        text: 'Se déconnecter',
        isLoading: _isLoading,
        onPressed: () async {
          setState(() => _isLoading = true);
          await ref.read(authControllerProvider.notifier).signOut();
          if (!mounted) return;
          context.go('/getting-started');
          setState(() => _isLoading = false);
        },
      );
}
