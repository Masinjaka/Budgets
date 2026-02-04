import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_permission_provider.g.dart';

@riverpod
class NotificationPermissionPrompted extends _$NotificationPermissionPrompted {
  @override
  bool build() => false;

  void setPrompted() => state = true;
}
