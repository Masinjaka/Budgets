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
      this.onSwitchChanged,
      this.switchValue,
      this.switchDisabled = false});
  final String title;
  final IconData iconData;
  final VoidCallback onTap;
  final bool showSuffixSettingChoice;
  final String? settingChoice;
  final bool useSwitch;
  final void Function(bool)? onSwitchChanged;
  final bool? switchValue;
  final bool switchDisabled;

  @override
  State<SettingCard> createState() => _SettingCardState();
}

class _SettingCardState extends State<SettingCard> {
  bool _switchValue = false;

  void _toggleSwitch() {
    if (widget.onSwitchChanged == null || widget.switchDisabled) return;
    final next = !(widget.switchValue ?? _switchValue);
    if (widget.switchValue == null) {
      setState(() => _switchValue = next);
    }
    widget.onSwitchChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedSwitchValue = widget.switchValue ?? _switchValue;

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
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
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
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  child: Icon(
                    widget.iconData,
                    size: 20.sp,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
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
                    ? Opacity(
                        opacity: widget.switchDisabled ? 0.5 : 1,
                        child: IgnorePointer(
                          ignoring: widget.switchDisabled,
                          child: Switch(
                            value: resolvedSwitchValue,
                            onChanged: (val) {
                              if (widget.switchValue == null) {
                                setState(() => _switchValue = val);
                              }
                              widget.onSwitchChanged?.call(val);
                            },
                            // activeThumbColor: AppTheme.primaryGreen,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.arrow_forward_ios,
                        size: 16.sp,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
