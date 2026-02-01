import 'package:budgets/core/paths.dart';
import 'package:budgets/core/theme.dart';
import 'package:budgets/features/onboarding/presentation/module/splash_module.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SplashModule splashModule = SplashModule();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      splashModule.listeToSession(context);
    });
  }

  @override
  void dispose() {
    splashModule.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(1.w),
          child: Image.asset(
            AppPaths.logo,
            width: 15.h,
            height: 15.h,
          ),
        ),
      ),
    );
  }
}
