import 'package:budgets/core/ui/app_typography.dart';
import 'package:flutter/material.dart';

class SettingsPageShell extends StatelessWidget {
  const SettingsPageShell({
    required this.title,
    required this.child,
    this.bottomNavigationBar,
    this.maxWidth = 520,
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? bottomNavigationBar;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        centerTitle: true,
        toolbarHeight: 72,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
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
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
