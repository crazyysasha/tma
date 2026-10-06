import 'dart:ui' show Color;

import '../models/params.dart';
import 'button.dart';

/// `Telegram.WebApp.MainButton` and `Telegram.WebApp.SecondaryButton`.
abstract class BottomButton extends TmaButton {
  const BottomButton();

  /// `main` or `secondary`.
  String get type;
  String get text;
  Color? get color;
  Color? get textColor;
  bool get isActive;

  /// Bot API 7.10+.
  bool get hasShineEffect;

  /// Secondary button only.
  SecondaryButtonPosition? get position;
  bool get isProgressVisible;

  /// Bot API 9.5+. `null` while no icon is set.
  String? get iconCustomEmojiId;

  void setText(String text);
  void enable();
  void disable();
  void showProgress({bool leaveActive = false});
  void hideProgress();
  void setParams(BottomButtonParams params);
}
