/// Thin `dart:js_interop` bindings over `window.Telegram.WebApp`.
///
/// Only the raw JavaScript surface lives here. Conversions to Dart models
/// happen in `tma_web.dart`.
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// `window.Telegram`, or `null` when `telegram-web-app.js` is not loaded.
TelegramJS? get telegramGlobal {
  final tg = globalContext['Telegram'];
  return tg.isUndefinedOrNull ? null : tg as TelegramJS;
}

extension type TelegramJS._(JSObject _) implements JSObject {
  @JS('WebApp')
  external WebAppJS? get webApp;
}

extension type WebAppJS._(JSObject _) implements JSObject {
  external String get initData;
  external String get version;
  external String get platform;
  external String get colorScheme;
  external JSObject? get themeParams;
  external bool get isExpanded;
  external bool get isActive;
  external JSNumber get viewportHeight;
  external JSNumber get viewportStableHeight;
  external JSObject get safeAreaInset;
  external JSObject get contentSafeAreaInset;
  external bool get isClosingConfirmationEnabled;
  external bool get isVerticalSwipesEnabled;
  external bool get isFullscreen;
  external bool get isOrientationLocked;
  external String? get headerColor;
  external String? get backgroundColor;
  external String? get bottomBarColor;

  @JS('BackButton')
  external ButtonJS get backButton;
  @JS('SettingsButton')
  external ButtonJS get settingsButton;
  @JS('MainButton')
  external BottomButtonJS get mainButton;
  @JS('SecondaryButton')
  external BottomButtonJS get secondaryButton;
  @JS('HapticFeedback')
  external HapticFeedbackJS get hapticFeedback;
  @JS('CloudStorage')
  external CloudStorageJS get cloudStorage;
  @JS('DeviceStorage')
  external DeviceStorageJS get deviceStorage;
  @JS('SecureStorage')
  external SecureStorageJS get secureStorage;
  @JS('BiometricManager')
  external BiometricManagerJS get biometricManager;
  @JS('LocationManager')
  external LocationManagerJS get locationManager;
  @JS('Accelerometer')
  external SensorJS get accelerometer;
  @JS('Gyroscope')
  external SensorJS get gyroscope;
  @JS('DeviceOrientation')
  external DeviceOrientationJS get deviceOrientation;

  external void setHeaderColor(String color);
  external void setBackgroundColor(String color);
  external void setBottomBarColor(String color);
  external void enableClosingConfirmation();
  external void disableClosingConfirmation();
  external void enableVerticalSwipes();
  external void disableVerticalSwipes();
  external void requestFullscreen();
  external void exitFullscreen();
  external void lockOrientation();
  external void unlockOrientation();
  external void addToHomeScreen();
  external void checkHomeScreenStatus(JSFunction callback);
  external void onEvent(String eventType, JSFunction callback);
  external void offEvent(String eventType, JSFunction callback);
  external void sendData(String data);
  external void switchInlineQuery(
    String query, [
    JSArray<JSString>? chooseChatTypes,
  ]);
  external void openLink(String url, [JSObject? options]);
  external void openTelegramLink(String url, [JSObject? options]);
  external void openInvoice(String url, JSFunction callback);
  external void showPopup(JSObject params, JSFunction callback);
  external void showAlert(String message, JSFunction callback);
  external void showConfirm(String message, JSFunction callback);
  external void showScanQrPopup(JSObject params, JSFunction callback);
  external void closeScanQrPopup();
  external void readTextFromClipboard(JSFunction callback);
  external void requestWriteAccess(JSFunction callback);
  external void requestContact(JSFunction callback);
  external void downloadFile(JSObject params, JSFunction callback);
  external void shareToStory(String mediaUrl, [JSObject? params]);
  external void shareMessage(String msgId, JSFunction callback);
  external void requestChat(String reqId, JSFunction callback);
  external void setEmojiStatus(
    String customEmojiId,
    JSObject params,
    JSFunction callback,
  );
  external void requestEmojiStatusAccess(JSFunction callback);
  external void hideKeyboard();
  external void ready();
  external void expand();
  external void close([JSObject? options]);
}

/// `BackButton` and `SettingsButton` share the same shape.
extension type ButtonJS._(JSObject _) implements JSObject {
  external bool get isVisible;
  external void show();
  external void hide();
}

extension type BottomButtonJS._(JSObject _) implements ButtonJS {
  external String get type;
  external String get text;
  external String? get color;
  external String? get textColor;
  external bool get isActive;
  external bool get hasShineEffect;
  external String? get position;
  external bool get isProgressVisible;

  /// `false` until an icon is set, a string afterwards.
  external JSAny? get iconCustomEmojiId;
  external void setText(String text);
  external void enable();
  external void disable();
  external void showProgress([bool? leaveActive]);
  external void hideProgress();
  external void setParams(JSObject params);
}

extension type HapticFeedbackJS._(JSObject _) implements JSObject {
  external void impactOccurred(String style);
  external void notificationOccurred(String type);
  external void selectionChanged();
}

/// Calls shared by `CloudStorage`, `DeviceStorage` and `SecureStorage`.
/// Callbacks are node-style: `(error, result)`.
extension type KeyValueStorageJS._(JSObject _) implements JSObject {
  external void setItem(String key, String value, JSFunction callback);
  external void getItem(String key, JSFunction callback);
  external void removeItem(String key, JSFunction callback);
}

extension type CloudStorageJS._(JSObject _) implements KeyValueStorageJS {
  external void getItems(JSArray<JSString> keys, JSFunction callback);
  external void removeItems(JSArray<JSString> keys, JSFunction callback);
  external void getKeys(JSFunction callback);
}

extension type DeviceStorageJS._(JSObject _) implements KeyValueStorageJS {
  external void clear(JSFunction callback);
}

extension type SecureStorageJS._(JSObject _) implements KeyValueStorageJS {
  external void restoreItem(String key, JSFunction callback);
  external void clear(JSFunction callback);
}

extension type BiometricManagerJS._(JSObject _) implements JSObject {
  external bool get isInited;
  external bool get isBiometricAvailable;
  external String? get biometricType;
  external bool get isAccessRequested;
  external bool get isAccessGranted;
  external bool get isBiometricTokenSaved;
  external String? get deviceId;
  external void init(JSFunction callback);
  external void requestAccess(JSObject params, JSFunction callback);
  external void authenticate(JSObject params, JSFunction callback);
  external void updateBiometricToken(String token, JSFunction callback);
  external void openSettings();
}

extension type LocationManagerJS._(JSObject _) implements JSObject {
  external bool get isInited;
  external bool get isLocationAvailable;
  external bool get isAccessRequested;
  external bool get isAccessGranted;
  external void init(JSFunction callback);
  external void getLocation(JSFunction callback);
  external void openSettings();
}

/// Calls shared by `Accelerometer`, `Gyroscope` and `DeviceOrientation`.
extension type SensorBaseJS._(JSObject _) implements JSObject {
  external bool get isStarted;
  external void start(JSObject params, JSFunction callback);
  external void stop(JSFunction callback);
}

/// `Accelerometer` and `Gyroscope`.
extension type SensorJS._(JSObject _) implements SensorBaseJS {
  external JSNumber? get x;
  external JSNumber? get y;
  external JSNumber? get z;
}

extension type DeviceOrientationJS._(JSObject _) implements SensorBaseJS {
  external bool get absolute;
  external JSNumber? get alpha;
  external JSNumber? get beta;
  external JSNumber? get gamma;
}
