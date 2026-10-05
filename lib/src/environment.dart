/// Where the app is running from the point of view of this package.
enum TmaEnvironment {
  /// Running inside a Telegram client: the SDK script is loaded and the page
  /// was launched by Telegram (init data or platform is present).
  telegram,

  /// Running on the web, but not inside Telegram: either the SDK script is
  /// missing or the page was opened in a regular browser.
  browser,

  /// Compiled for a non-web target (Android, iOS, desktop). There is no
  /// JavaScript runtime and therefore no Telegram Web App object.
  native,
}

/// Why [TmaEnvironment] is not [TmaEnvironment.telegram].
enum TmaUnavailableReason {
  /// The app is not running inside Telegram; nothing is wrong.
  notLaunchedFromTelegram,

  /// `telegram-web-app.js` was not found on `window.Telegram.WebApp`.
  /// Add the script tag to `web/index.html`.
  scriptMissing,

  /// Compiled for a platform without JavaScript.
  nativePlatform,
}

/// Telegram client that opened the Mini App. The raw value is always kept in
/// [TmaClientPlatform.raw] so unknown future clients are not lost.
final class TmaClientPlatform {
  const TmaClientPlatform._(this.raw, this.kind);

  factory TmaClientPlatform.fromRaw(String raw) {
    final kind = switch (raw) {
      'android' => TmaClientPlatformKind.android,
      'android_x' => TmaClientPlatformKind.androidX,
      'ios' => TmaClientPlatformKind.ios,
      'macos' => TmaClientPlatformKind.macos,
      'tdesktop' => TmaClientPlatformKind.tdesktop,
      'weba' => TmaClientPlatformKind.weba,
      'webk' => TmaClientPlatformKind.webk,
      'unigram' => TmaClientPlatformKind.unigram,
      'unknown' => TmaClientPlatformKind.unknown,
      _ => TmaClientPlatformKind.other,
    };
    return TmaClientPlatform._(raw, kind);
  }

  static const unknown =
      TmaClientPlatform._('unknown', TmaClientPlatformKind.unknown);

  final String raw;
  final TmaClientPlatformKind kind;

  bool get isMobile =>
      kind == TmaClientPlatformKind.android ||
      kind == TmaClientPlatformKind.androidX ||
      kind == TmaClientPlatformKind.ios;

  bool get isDesktop =>
      kind == TmaClientPlatformKind.macos ||
      kind == TmaClientPlatformKind.tdesktop ||
      kind == TmaClientPlatformKind.unigram;

  bool get isWeb =>
      kind == TmaClientPlatformKind.weba || kind == TmaClientPlatformKind.webk;

  @override
  bool operator ==(Object other) =>
      other is TmaClientPlatform && other.raw == raw;

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() => raw;
}

enum TmaClientPlatformKind {
  android,
  androidX,
  ios,
  macos,
  tdesktop,
  weba,
  webk,
  unigram,
  unknown,
  other,
}

enum TmaColorScheme { light, dark }
