import 'package:budgets/core/ui/app_typography.dart';
import 'package:flutter/material.dart';

class SettingsChoiceTile extends StatelessWidget {
  const SettingsChoiceTile({
    required this.title,
    required this.leading,
    required this.onTap,
    this.subtitle,
    this.subtitleWidget,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget leading;
  final VoidCallback? onTap;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final titleText = Text(
      title,
      style: const TextStyle(
        fontSize: AppTypography.body,
        fontWeight: FontWeight.w700,
      ),
    );
    final customSubtitle = subtitleWidget;
    return ListTile(
      minTileHeight: 54,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: onTap,
      leading: leading,
      title: customSubtitle == null
          ? titleText
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleText,
                const SizedBox(height: 2),
                customSubtitle,
              ],
            ),
      subtitle: customSubtitle != null || subtitle == null
          ? null
          : Text(
              subtitle!,
              style: const TextStyle(fontSize: AppTypography.supporting),
            ),
      trailing: trailing,
    );
  }
}
