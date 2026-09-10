class AppConfig {
  AppConfig._({required this.apiBaseUrl, required this.environment});

  factory AppConfig.fromEnvironment() {
    const rawUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:3000/api',
    );
    const environment = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw StateError(
        'Invalid API_BASE_URL "$rawUrl". Supply an absolute HTTP(S) URL with '
        '--dart-define=API_BASE_URL=https://example.com/api.',
      );
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw StateError('API_BASE_URL must use HTTP or HTTPS.');
    }
    if (!{'development', 'staging', 'production'}.contains(environment)) {
      throw StateError('APP_ENV must be development, staging, or production.');
    }
    return AppConfig._(
      apiBaseUrl: rawUrl.replaceFirst(RegExp(r'/+$'), ''),
      environment: environment,
    );
  }

  final String apiBaseUrl;
  final String environment;
  bool get isDevelopment => environment == 'development';
}
