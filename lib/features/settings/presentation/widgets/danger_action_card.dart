import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DangerActionCard extends StatelessWidget {
  const DangerActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.isLoading,
    required this.actionKey,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final Key actionKey;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.dangerColor.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(4.w),
      child: InkWell(
        key: actionKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.w),
        child: Padding(
          padding: EdgeInsets.all(3.5.w),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.dangerColor, size: 22),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 0.4.h),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(Icons.chevron_right, color: AppTheme.dangerColor),
            ],
          ),
        ),
      ),
    );
  }
}
