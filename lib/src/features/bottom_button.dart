import 'dart:ui' show Color, VoidCallback;

import '../models/params.dart';

/// `Telegram.WebApp.MainButton` and `Telegram.WebApp.SecondaryButton`.
abstract class BottomButton {
  const BottomButton();

  /// `main` or `secondary`.
  String get type;
  String get text;
  Color? get color;
  Color? get textColor;
  bool get isVisible;
  bool get isActive;

  /// Bot API 7.10+.
  bool get hasShineEffect;

  /// Secondary button only.
  SecondaryButtonPosition? get position;
  bool get isProgressVisible;

  /// Bot API 9.5+.
  String? get iconCustomEmojiId;

  Stream<void> get onClick;

  void setText(String text);
  void show();
  void hide();
  void enable();
  void disable();
  void showProgress({bool leaveActive = false});
  void hideProgress();
  void setParams(BottomButtonParams params);

  VoidCallback addListener(void Function() listener) {
    final sub = onClick.listen((_) => listener());
    return sub.cancel;
  }
}
