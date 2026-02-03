class LocalAppStorage {
  static const String storageBox = 'budgets_storage';

  static const String refreshKey = 'refresh_token';
  static const String accessKey = 'access_token';
  static const String globalTheme = 'global_theme';

  // Deep link / redirect URI used for Supabase password reset
  static const String resetRedirectUri = 'io.supabase.budgets://reset-callback';
}

/// Constants for system-managed categories
class SystemCategories {
  /// The savings category name used for goal contributions
  static const String savingsCategoryName = 'Épargne';

  /// The emoji used for the savings category
  static const String savingsCategoryEmoji = '🐷';

  /// The color used for the savings category (teal)
  static const String savingsCategoryColor = 'FF009688';
}
