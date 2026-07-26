import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_choice_tile.dart';
import 'package:flutter/material.dart';

class NotificationSettingsToggle extends StatefulWidget {
  const NotificationSettingsToggle({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String title;
  final IconData icon;
  final bool value;
  final bool enabled;
  final Future<bool> Function(bool value) onChanged;

  @override
  State<NotificationSettingsToggle> createState() =>
      _NotificationSettingsToggleState();
}

class _NotificationSettingsToggleState
    extends State<NotificationSettingsToggle> {
  late bool _value;
  bool _updating = false;

  bool get _enabled => widget.enabled && !_updating;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant NotificationSettingsToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_updating && oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsChoiceTile(
      title: widget.title,
      leading: Icon(widget.icon, size: 20),
      onTap: _enabled ? () => _change(!_value) : null,
      trailing: Switch(
        value: _value,
        onChanged: _enabled ? _change : null,
      ),
    );
  }

  Future<void> _change(bool nextValue) async {
    final previousValue = _value;
    setState(() {
      _value = nextValue;
      _updating = true;
    });

    try {
      final saved = await widget.onChanged(nextValue);
      if (mounted && !saved) setState(() => _value = previousValue);
    } catch (error) {
      if (!mounted) return;
      setState(() => _value = previousValue);
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }
}
