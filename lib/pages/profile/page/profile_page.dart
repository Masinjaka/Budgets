import 'package:budgets/core/constants.dart';
import 'package:budgets/core/theme.dart';
import 'package:budgets/main.dart';
import 'package:budgets/provider/app_theme_provider.dart';
import 'package:budgets/provider/auth_provider.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isLoading = false;
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext buildcontext) {
    final globalTheme = ref.watch(globalThemeProvider);

    _isDarkMode = globalTheme == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Profil',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 19.5.sp,
            ),
          ),
        ),
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(left: 7.w, right: 7.w, top: 5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Préferences',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15.5.sp,
                  ),
                ),
                SizedBox(
                  height: 3.h,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 1.2.h),
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    height: 9.h,
                    decoration: BoxDecoration(
                      color: _isDarkMode ? AppTheme.secondaryDark : null,
                      border: Border.all(
                          color:
                              _isDarkMode ? Colors.transparent : Colors.black),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mode nuit',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15.5.sp,
                          ),
                        ),
                        Switch(
                          activeColor: AppTheme.secondaryDark,
                          activeTrackColor: AppTheme.backgroundDark,
                          value: _isDarkMode,
                          onChanged: (bool newValue) {
                            ref.read(appThemeProvider.notifier).state =  newValue ? ThemeMode.dark:ThemeMode.light;
                            ref.read(globalThemeProvider.notifier).state =  newValue ? Brightness.dark:Brightness.light;
                            storageBox.put(LocalAppStorage.globalTheme, newValue ? 'dark':'light');
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildSignoutButton(),
    );
  }

  Padding _buildSignoutButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: CustomButton(
        text: 'Se déconnecter',
        onPressed: () async {
          // start authenticating
          setState(() => _isLoading = true);
          await ref.read(authProvider.notifier).signOut();
          if (!mounted) return;
          context.go('/login');
          setState(() => _isLoading = false);
          // end authenticating
        },
        isLoading: _isLoading,
      ),
    );
  }
}
