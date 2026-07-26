class SentryConfig {
  const SentryConfig({
    required this.dsn,
    required this.environment,
    required this.startupTestEnabled,
  });

  factory SentryConfig.fromValues({
    required String dsn,
    required String environment,
    required bool isRelease,
    bool startupTestEnabled = false,
  }) {
    final normalizedEnvironment = environment.trim();
    return SentryConfig(
      dsn: dsn.trim(),
      environment: normalizedEnvironment.isEmpty
          ? (isRelease ? 'production' : 'development')
          : normalizedEnvironment,
      startupTestEnabled: startupTestEnabled,
    );
  }

  final String dsn;
  final String environment;
  final bool startupTestEnabled;

  bool get isEnabled => dsn.isNotEmpty;
}
