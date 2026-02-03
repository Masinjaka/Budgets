class NotificationSettings {
  const NotificationSettings({
    required this.notificationsEnabled,
    required this.remindersEnabled,
    required this.warningsEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.timezoneOffsetMinutes,
    required this.warningThreshold,
  });

  final bool notificationsEnabled;
  final bool remindersEnabled;
  final bool warningsEnabled;
  final int reminderHour;
  final int reminderMinute;
  final int timezoneOffsetMinutes;
  final double warningThreshold;

  bool get anyEnabled => notificationsEnabled && (remindersEnabled || warningsEnabled);

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      notificationsEnabled: map['notifications_enabled'] as bool? ?? true,
      remindersEnabled: map['reminders_enabled'] as bool? ?? true,
      warningsEnabled: map['warnings_enabled'] as bool? ?? true,
      reminderHour: map['reminder_hour'] as int? ?? 10,
      reminderMinute: map['reminder_minute'] as int? ?? 0,
      timezoneOffsetMinutes: map['timezone_offset_minutes'] as int? ?? 0,
      warningThreshold: (map['warning_threshold'] as num?)?.toDouble() ?? 0.9,
    );
  }

  NotificationSettings copyWith({
    bool? notificationsEnabled,
    bool? remindersEnabled,
    bool? warningsEnabled,
    int? reminderHour,
    int? reminderMinute,
    int? timezoneOffsetMinutes,
    double? warningThreshold,
  }) {
    return NotificationSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      warningsEnabled: warningsEnabled ?? this.warningsEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      timezoneOffsetMinutes: timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
      warningThreshold: warningThreshold ?? this.warningThreshold,
    );
  }

  static NotificationSettings defaults({int timezoneOffsetMinutes = 0}) {
    return NotificationSettings(
      notificationsEnabled: true,
      remindersEnabled: true,
      warningsEnabled: true,
      reminderHour: 10,
      reminderMinute: 0,
      timezoneOffsetMinutes: timezoneOffsetMinutes,
      warningThreshold: 0.9,
    );
  }
}
