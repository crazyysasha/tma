import 'dart:ui' show VoidCallback;

/// `Telegram.WebApp.BackButton` (Bot API 6.1+).
abstract class BackButton {
  const BackButton();

  bool get isVisible;

  /// Emits every time the user presses the back button.
  Stream<void> get onClick;

  void show();
  void hide();

  /// Convenience wrapper over [onClick] that returns an unsubscribe callback.
  VoidCallback addListener(void Function() listener) {
    final sub = onClick.listen((_) => listener());
    return sub.cancel;
  }
}
