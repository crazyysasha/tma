import 'dart:ui' show VoidCallback;

/// `Telegram.WebApp.SettingsButton` (Bot API 7.0+).
abstract class SettingsButton {
  const SettingsButton();

  bool get isVisible;
  Stream<void> get onClick;
  void show();
  void hide();

  VoidCallback addListener(void Function() listener) {
    final sub = onClick.listen((_) => listener());
    return sub.cancel;
  }
}
