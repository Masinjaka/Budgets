import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SettingCard extends StatefulWidget {
  const SettingCard(
      {super.key,
      required this.title,
      required this.iconData,
      required this.onTap,
      this.showSuffixSettingChoice = false,
      this.settingChoice,
      this.useSwitch = false,
      this.onSwitchChanged});
  final String title;
  final IconData iconData;
  final VoidCallback onTap;
  final bool showSuffixSettingChoice;
  final String? settingChoice;
  final bool useSwitch;
  final void Function(bool)? onSwitchChanged;

  @override
  State<SettingCard> createState() => _SettingCardState();
}

class _SettingCardState extends State<SettingCard> {
  bool _switchValue = false;

  void _toggleSwitch() {
    setState(() => _switchValue = !_switchValue);
    widget.onSwitchChanged?.call(_switchValue);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.useSwitch) {
          _toggleSwitch();
        } else {
          widget.onTap();
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark,
          borderRadius: BorderRadius.circular(5.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark,
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  child: Icon(
                    widget.iconData,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 2.w,
              children: [
                if (widget.showSuffixSettingChoice)
                  Text(
                    widget.settingChoice ?? 'MGA',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey,
                    ),
                  ),
                widget.useSwitch
                    ? Switch(
                        value: _switchValue,
                        onChanged: (val) {
                          setState(() => _switchValue = val);
                          widget.onSwitchChanged?.call(val);
                        },
                        activeThumbColor: AppTheme.primaryGreen,
                      )
                    : Icon(
                        Icons.arrow_forward_ios,
                        size: 16.sp,
                        color: Colors.white,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
