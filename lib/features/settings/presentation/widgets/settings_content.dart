import 'package:budgets/features/settings/presentation/widgets/default_wallet_setting_card.dart';
import 'package:budgets/features/settings/presentation/widgets/setting_card.dart';
import 'package:budgets/features/settings/presentation/widgets/setting_section.dart';
import 'package:budgets/features/settings/presentation/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({
    required this.currencyChoice,
    required this.onAppearance,
    required this.signOutButton,
    required this.appVersion,
    super.key,
  });

  final Widget currencyChoice;
  final VoidCallback onAppearance;
  final Widget signOutButton;
  final String appVersion;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          const UserCard(),
          SizedBox(height: 4.h),
          _profile(context),
          SizedBox(height: 4.h),
          _preferences(context),
          SizedBox(height: 4.h),
          _support(),
          SizedBox(height: 4.h),
          signOutButton,
          SizedBox(height: 1.h),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Text(
                'Version $appVersion',
                style: TextStyle(fontSize: 15.sp, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profile(BuildContext context) => SettingSection(
        title: 'Profil',
        children: [
          SizedBox(height: 1.h),
          _routeCard(context, 'Modifier le profil', Icons.person_outline,
              '/edit-profile'),
          SizedBox(height: 1.h),
          _routeCard(context, 'Changer le mot de passe', Icons.lock_outline,
              '/edit-password'),
          SizedBox(height: 1.h),
          _routeCard(context, 'Mes catégories', Icons.category_outlined,
              '/categories'),
          SizedBox(height: 1.h),
          _routeCard(context, 'Rapports', Icons.bar_chart_outlined,
              '/settings/reports'),
        ],
      );

  Widget _preferences(BuildContext context) => SettingSection(
        title: 'Préférences',
        children: [
          SizedBox(height: 1.h),
          _routeCard(context, 'Activer la notification',
              Icons.notifications_outlined, '/notification-settings'),
          SizedBox(height: 1.h),
          SettingCard(
            title: 'Devise',
            iconData: Icons.attach_money_outlined,
            onTap: () => context.push('/currency-selection'),
            showSuffixSettingChoice: true,
            settingChoiceWidget: currencyChoice,
          ),
          SizedBox(height: 1.h),
          const DefaultWalletSettingCard(),
          SizedBox(height: 1.h),
          SettingCard(
            title: 'Apparence',
            iconData: Icons.dark_mode_outlined,
            onTap: onAppearance,
          ),
        ],
      );

  Widget _support() => SettingSection(
        title: 'Support & légal',
        children: [
          SizedBox(height: 1.h),
          SettingCard(
            title: 'Centre d\'aide',
            iconData: Icons.contact_support_outlined,
            onTap: () {},
          ),
          SizedBox(height: 1.h),
          SettingCard(
            title: 'CGU',
            iconData: Icons.article_outlined,
            onTap: () {},
          ),
        ],
      );

  SettingCard _routeCard(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) =>
      SettingCard(
        title: title,
        iconData: icon,
        onTap: () => context.push(route),
      );
}
