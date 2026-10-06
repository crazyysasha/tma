import 'dart:ui' show VoidCallback;

/// A Telegram-drawn button that can be shown, hidden and clicked.
///
/// [BackButton] and [SettingsButton] are this type; [BottomButton] extends
/// it with text, colors and progress.
abstract class TmaButton {
  const TmaButton();

  bool get isVisible;

  /// Emits every time the user presses the button.
  Stream<void> get onClick;

  void show();
  void hide();

  /// Convenience wrapper over [onClick] that returns an unsubscribe callback.
  VoidCallback addListener(void Function() listener) {
    final sub = onClick.listen((_) => listener());
    return sub.cancel;
  }
}

/// `Telegram.WebApp.BackButton` (Bot API 6.1+).
typedef BackButton = TmaButton;

/// `Telegram.WebApp.SettingsButton` (Bot API 7.0+).
typedef SettingsButton = TmaButton;
