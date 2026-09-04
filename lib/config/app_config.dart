/// App-level public config. Override at build time with `--dart-define`.
abstract final class AppConfig {
  /// Base URL of the web prototype. Advisor intro links open here.
  static const webBaseUrl = String.fromEnvironment(
    'WEB_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}
