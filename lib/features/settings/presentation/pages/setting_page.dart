import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/ui/glass_flexible_space.dart';
import 'package:budgets/features/categories/domain/providers/category_provider.dart';
import 'package:budgets/features/planning/domain/providers/budget_provider.dart';
import 'package:budgets/features/planning/domain/providers/goal_provider.dart';
import 'package:budgets/features/settings/data/repositories/supabase_account_data_repository.dart';
import 'package:budgets/features/settings/data/repositories/unavailable_account_data_repository.dart';
import 'package:budgets/features/settings/data/services/account_data_service.dart';
import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/features/auth/presentation/controllers/auth_controller.dart';
import 'package:budgets/features/settings/domain/providers/theme_provider.dart';
import 'package:budgets/features/settings/domain/repositories/account_data_repository.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_content.dart';
import 'package:budgets/features/settings/presentation/view_models/danger_zone_view_model.dart';
import 'package:budgets/features/settings/presentation/widgets/danger_zone.dart';
import 'package:budgets/features/settings/presentation/widgets/theme_selection_dialog.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_expenses_provider.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_incomes_provider.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:budgets/features/user/domain/provider/user_providers.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/skeleton/profile_picture_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({this.onDataDeleted, super.key});

  final VoidCallback? onDataDeleted;

  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  bool _isLoading = false;
  String _appVersion = '';
  late final DangerZoneViewModel _dangerZoneViewModel;

  @override
  void initState() {
    super.initState();
    _dangerZoneViewModel = DangerZoneViewModel(_accountDataRepository());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVersion());
  }

  @override
  void dispose() {
    _dangerZoneViewModel.dispose();
    super.dispose();
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
            dangerZone: DangerZone(
              viewModel: _dangerZoneViewModel,
              accountEmail: _accountEmail(),
              onDataDeleted: _onDataDeleted,
              onAccountDeleted: () => context.go('/getting-started'),
            ),
            appVersion: _appVersion.isEmpty ? '...' : _appVersion,
          ),
        ),
      ),
    );
  }

  Text _currencyText(String value) => Text(
        value,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  void _onDataDeleted() {
    ref.invalidate(userModelProvider);
    ref.invalidate(currencyControllerProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(transactionsProvider);
    ref.invalidate(paginatedExpensesProvider);
    ref.invalidate(paginatedIncomesProvider);
    ref.invalidate(budgetsProvider);
    ref.invalidate(goalsProvider);
    if (widget.onDataDeleted case final callback?) {
      callback();
      Navigator.of(context).pop();
    } else {
      context.go('/home');
    }
  }

  AccountDataRepository _accountDataRepository() {
    try {
      final service = AccountDataService(Supabase.instance.client);
      return SupabaseAccountDataRepository(service);
    } catch (_) {
      return const UnavailableAccountDataRepository();
    }
  }

  String _accountEmail() {
    try {
      return Supabase.instance.client.auth.currentUser?.email ?? '';
    } catch (_) {
      return '';
    }
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
