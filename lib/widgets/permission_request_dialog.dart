import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:flutter/material.dart';

class PermissionRequestDialog extends StatelessWidget {
  final String title;
  final String message;
  final String allowText;
  final String denyText;
  final VoidCallback onAllow;
  final VoidCallback onDeny;
  final Color? backgroundColor;

  const PermissionRequestDialog({
    super.key,
    this.title = 'Autorisation requise',
    required this.message,
    this.allowText = 'Autoriser',
    this.denyText = 'Refuser',
    required this.onAllow,
    required this.onDeny,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 32),
      backgroundColor: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: AppTypography.title,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                  fontSize: AppTypography.body,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  text: denyText,
                  onPressed: onDeny,
                  backgroundColor: Theme.of(context).cardColor,
                  width: 120,
                  borderColor: Colors.transparent,
                ),
                SizedBox(width: 8),
                CustomButton(
                  backgroundColor:
                      backgroundColor ?? Theme.of(context).primaryColor,
                  text: allowText,
                  onPressed: onAllow,
                  width: 120,
                  borderColor: Colors.transparent,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
