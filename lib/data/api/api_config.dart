/// Compile-time API host from `--dart-define-from-file=.env`.
///
/// The real URL must never appear in committed Dart, docs, or rules.
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment('API_BASE_URL');

  static bool get isConfigured => baseUrl.trim().isNotEmpty;

  /// Root URI (`https://host`). Throws if `.env` was not passed at build time.
  static Uri get origin {
    if (!isConfigured) {
      throw StateError(
        'API_BASE_URL is missing. Copy .env.example to .env, then run '
        'with --dart-define-from-file=.env',
      );
    }
    return Uri.parse(_withoutTrailingSlash(baseUrl.trim()));
  }

  /// Resolve a path or query against the env base URL.
  static Uri uri(String path, [Map<String, String>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return origin.replace(
      path: normalized,
      queryParameters: query == null || query.isEmpty ? null : query,
    );
  }

  static String _withoutTrailingSlash(String value) {
    if (value.length > 1 && value.endsWith('/')) {
      return value.substring(0, value.length - 1);
    }
    return value;
  }
}
