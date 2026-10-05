import 'dart:ui' show Color;

import 'theme_params.dart';

/// Result of `openInvoice`.
enum InvoiceStatus {
  paid,
  cancelled,
  failed,
  pending,
  unknown;

  static InvoiceStatus fromRaw(String? raw) => switch (raw) {
    'paid' => paid,
    'cancelled' => cancelled,
    'failed' => failed,
    'pending' => pending,
    _ => unknown,
  };
}

/// Result of `checkHomeScreenStatus`.
enum HomeScreenStatus {
  unsupported,
  unknown,
  added,
  missed;

  static HomeScreenStatus fromRaw(String? raw) => switch (raw) {
    'unsupported' => unsupported,
    'added' => added,
    'missed' => missed,
    _ => unknown,
  };
}

enum HapticImpactStyle { light, medium, heavy, rigid, soft }

enum HapticNotificationType { success, warning, error }

/// Chat types accepted by `switchInlineQuery`.
enum ChooseChatType { users, bots, groups, channels }

/// Color for `setHeaderColor`: either a theme key or an explicit color
/// (Bot API 6.9+ for explicit colors).
sealed class HeaderColor {
  const HeaderColor();
  const factory HeaderColor.bg() = _HeaderColorKey.bg;
  const factory HeaderColor.secondaryBg() = _HeaderColorKey.secondaryBg;
  const factory HeaderColor.custom(Color color) = _HeaderColorCustom;

  /// The value passed to JavaScript.
  String toJs();
}

final class _HeaderColorKey extends HeaderColor {
  const _HeaderColorKey.bg() : key = 'bg_color';
  const _HeaderColorKey.secondaryBg() : key = 'secondary_bg_color';
  final String key;
  @override
  String toJs() => key;
}

final class _HeaderColorCustom extends HeaderColor {
  const _HeaderColorCustom(this.color);
  final Color color;
  @override
  String toJs() => ThemeParams.toHex(color);
}

/// Color for `setBackgroundColor` / `setBottomBarColor`.
sealed class BarColor {
  const BarColor();
  const factory BarColor.bg() = _BarColorKey.bg;
  const factory BarColor.secondaryBg() = _BarColorKey.secondaryBg;
  const factory BarColor.bottomBarBg() = _BarColorKey.bottomBarBg;
  const factory BarColor.custom(Color color) = _BarColorCustom;
  String toJs();
}

final class _BarColorKey extends BarColor {
  const _BarColorKey.bg() : key = 'bg_color';
  const _BarColorKey.secondaryBg() : key = 'secondary_bg_color';
  const _BarColorKey.bottomBarBg() : key = 'bottom_bar_bg_color';
  final String key;
  @override
  String toJs() => key;
}

final class _BarColorCustom extends BarColor {
  const _BarColorCustom(this.color);
  final Color color;
  @override
  String toJs() => ThemeParams.toHex(color);
}

/// Parameters of `showPopup`.
final class PopupParams {
  const PopupParams({
    required this.message,
    this.title,
    this.buttons = const [],
  }) : assert(message.length >= 1 && message.length <= 256),
       assert(title == null || title.length <= 64);

  /// 1-256 characters.
  final String message;

  /// 0-64 characters.
  final String? title;

  /// 1-3 buttons. If empty, Telegram shows a single "Close" button.
  final List<PopupButton> buttons;

  Map<String, Object?> toJson() {
    if (buttons.length > 3) {
      throw ArgumentError.value(buttons, 'buttons', 'at most 3 buttons');
    }
    return {
      'message': message,
      if (title != null) 'title': title,
      if (buttons.isNotEmpty) 'buttons': [for (final b in buttons) b.toJson()],
    };
  }
}

enum PopupButtonType { normal, ok, close, cancel, destructive }

final class PopupButton {
  const PopupButton({this.id, this.type = PopupButtonType.normal, this.text})
    : assert(id == null || id.length <= 64);

  /// Returned by `showPopup` when pressed. 0-64 characters.
  final String? id;
  final PopupButtonType type;

  /// 0-64 characters; required for [PopupButtonType.normal] and
  /// [PopupButtonType.destructive].
  final String? text;

  Map<String, Object?> toJson() => {
    if (id != null) 'id': id,
    'type': type == PopupButtonType.normal ? 'default' : type.name,
    if (text != null) 'text': text,
  };
}

/// Parameters of `shareToStory`.
final class StoryShareParams {
  const StoryShareParams({this.text, this.widgetLink});

  /// Caption, 0-200 characters (0-2048 for Premium users).
  final String? text;
  final StoryWidgetLink? widgetLink;

  Map<String, Object?> toJson() => {
    if (text != null) 'text': text,
    if (widgetLink != null) 'widget_link': widgetLink!.toJson(),
  };
}

final class StoryWidgetLink {
  const StoryWidgetLink({required this.url, this.name})
    : assert(name == null || name.length <= 48);
  final String url;

  /// 0-48 characters.
  final String? name;

  Map<String, Object?> toJson() => {'url': url, if (name != null) 'name': name};
}

/// Parameters of `setEmojiStatus`.
final class EmojiStatusParams {
  const EmojiStatusParams({this.duration});

  /// How long the status stays. Omit for a permanent status.
  final Duration? duration;

  Map<String, Object?> toJson() => {
    if (duration != null) 'duration': duration!.inSeconds,
  };
}

/// Parameters of `downloadFile`.
final class DownloadFileParams {
  const DownloadFileParams({required this.url, required this.fileName});
  final String url;
  final String fileName;

  Map<String, Object?> toJson() => {'url': url, 'file_name': fileName};
}

/// Parameters of `BiometricManager.requestAccess` / `authenticate`.
final class BiometricParams {
  const BiometricParams({this.reason})
    : assert(reason == null || reason.length <= 128);

  /// Text shown to the user, 0-128 characters.
  final String? reason;

  Map<String, Object?> toJson() => {if (reason != null) 'reason': reason};
}

enum BiometricType {
  finger,
  face,
  unknown;

  static BiometricType fromRaw(String? raw) => switch (raw) {
    'finger' => finger,
    'face' => face,
    _ => unknown,
  };
}

/// Result of `BiometricManager.authenticate`.
final class BiometricAuthResult {
  const BiometricAuthResult({required this.isAuthenticated, this.token});
  final bool isAuthenticated;

  /// Stored biometric token, if authentication succeeded and a token exists.
  final String? token;
}

enum SecondaryButtonPosition { left, right, top, bottom }

/// Parameters of `BottomButton.setParams`.
final class BottomButtonParams {
  const BottomButtonParams({
    this.text,
    this.color,
    this.textColor,
    this.hasShineEffect,
    this.position,
    this.isActive,
    this.isVisible,
    this.iconCustomEmojiId,
  });

  final String? text;
  final Color? color;
  final Color? textColor;

  /// Bot API 7.10+.
  final bool? hasShineEffect;

  /// Secondary button only, Bot API 7.10+.
  final SecondaryButtonPosition? position;
  final bool? isActive;
  final bool? isVisible;

  /// Bot API 9.5+.
  final String? iconCustomEmojiId;

  Map<String, Object?> toJson() => {
    if (text != null) 'text': text,
    if (color != null) 'color': ThemeParams.toHex(color!),
    if (textColor != null) 'text_color': ThemeParams.toHex(textColor!),
    if (hasShineEffect != null) 'has_shine_effect': hasShineEffect,
    if (position != null) 'position': position!.name,
    if (isActive != null) 'is_active': isActive,
    if (isVisible != null) 'is_visible': isVisible,
    if (iconCustomEmojiId != null) 'icon_custom_emoji_id': iconCustomEmojiId,
  };
}

/// Parameters of `Accelerometer.start`, `Gyroscope.start`.
final class SensorParams {
  const SensorParams({this.refreshRate = const Duration(seconds: 1)});

  /// 20-1000 ms; the SDK falls back to 1000 ms for values outside the range.
  final Duration refreshRate;

  Map<String, Object?> toJson() => {'refresh_rate': refreshRate.inMilliseconds};
}

/// Parameters of `DeviceOrientation.start`.
final class DeviceOrientationParams extends SensorParams {
  const DeviceOrientationParams({super.refreshRate, this.needAbsolute = false});

  /// Request absolute orientation (relative to Earth's magnetic field).
  final bool needAbsolute;

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'need_absolute': needAbsolute,
  };
}

/// Three-axis reading from the accelerometer or gyroscope.
final class Vector3 {
  const Vector3(this.x, this.y, this.z);
  static const zero = Vector3(0, 0, 0);
  final double x;
  final double y;
  final double z;

  @override
  bool operator ==(Object other) =>
      other is Vector3 && other.x == x && other.y == y && other.z == z;

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => 'Vector3($x, $y, $z)';
}

/// Reading from `DeviceOrientation`.
final class OrientationData {
  const OrientationData({
    required this.absolute,
    required this.alpha,
    required this.beta,
    required this.gamma,
  });
  static const zero = OrientationData(
    absolute: false,
    alpha: 0,
    beta: 0,
    gamma: 0,
  );

  final bool absolute;

  /// Rotation around Z axis, radians.
  final double alpha;

  /// Rotation around X axis, radians.
  final double beta;

  /// Rotation around Y axis, radians.
  final double gamma;

  @override
  String toString() =>
      'OrientationData(absolute: $absolute, α: $alpha, β: $beta, γ: $gamma)';
}
