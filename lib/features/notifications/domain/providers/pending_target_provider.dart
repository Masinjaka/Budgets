import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_target_provider.g.dart';

enum ToggleTarget { master, reminders, reminderTime, warnings }

@riverpod
class PendingTarget extends _$PendingTarget {
  @override
  ToggleTarget? build() => null;

  void set(ToggleTarget? value) => state = value;
}
