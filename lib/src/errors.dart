import 'version.dart';

/// Base class for all errors thrown by this package.
sealed class TmaException implements Exception {
  const TmaException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a method that needs a real Telegram client is called while the
/// app is not running inside Telegram (see `Tma.instance.isAvailable`).
final class TmaUnavailableException extends TmaException {
  const TmaUnavailableException(String method)
    : super(
        '$method requires the app to run inside Telegram. '
        'Check Tma.instance.isAvailable before calling it.',
      );
}

/// Thrown before calling a method that the current Telegram client is too
/// old for. Mirrors `WebAppMethodUnsupported` from the official SDK but is
/// raised in Dart, before touching JavaScript.
final class TmaUnsupportedException extends TmaException {
  TmaUnsupportedException({
    required this.method,
    required this.required,
    required this.current,
  }) : super(
         '$method requires Bot API $required, '
         'but the client supports only $current.',
       );

  final String method;
  final TmaVersion required;
  final TmaVersion current;
}

/// An error raised by `telegram-web-app.js` itself, for example
/// `WebAppPopupOpened` or `WebAppTgUrlInvalid`.
final class TmaJsException extends TmaException {
  const TmaJsException(super.message, [this.cause]);
  final Object? cause;
}
