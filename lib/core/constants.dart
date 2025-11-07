class LocalAppStorage {
  static const String storageBox = 'budgets_storage';

  static const String refreshKey = 'refresh_token';
  static const String accessKey = 'access_token';
  static const String globalTheme = 'global_theme';

  // Deep link / redirect URI used for Supabase password reset
  static const String resetRedirectUri = 'io.supabase.budgets://reset-callback';
}
