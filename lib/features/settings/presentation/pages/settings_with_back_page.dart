import 'package:budgets/features/settings/presentation/pages/setting_page.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';

class SettingsWithBackPage extends StatelessWidget {
  const SettingsWithBackPage({this.onDataDeleted, super.key});

  final VoidCallback? onDataDeleted;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SettingPage(onDataDeleted: onDataDeleted),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 64,
              height: kToolbarHeight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: context.l10n.back,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
