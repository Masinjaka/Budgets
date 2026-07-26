import 'package:flutter/material.dart';

class SettingCard extends StatefulWidget {
  const SettingCard(
      {super.key,
      required this.title,
      required this.iconData,
      required this.onTap,
      this.showSuffixSettingChoice = false,
      this.settingChoice,
      this.settingChoiceWidget,
      this.useSwitch = false,
      this.onSwitchChanged,
      this.switchValue,
      this.switchDisabled = false,
      this.showTrailingArrow = true,
      this.trailingWidget});
  final String title;
  final IconData iconData;
  final VoidCallback onTap;
  final bool showSuffixSettingChoice;
  final String? settingChoice;
  final Widget? settingChoiceWidget;
  final bool useSwitch;
  final void Function(bool)? onSwitchChanged;
  final bool? switchValue;
  final bool switchDisabled;
  final bool showTrailingArrow;
  final Widget? trailingWidget;

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
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.iconData,
                      size: 20,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Flexible(
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  if (widget.showSuffixSettingChoice)
                    widget.settingChoiceWidget ??
                        Text(
                          widget.settingChoice ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                  if (widget.trailingWidget != null)
                    widget.trailingWidget!
                  else if (widget.useSwitch)
                    Opacity(
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
                        ),
                      ),
                    )
                  else if (widget.showTrailingArrow)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
