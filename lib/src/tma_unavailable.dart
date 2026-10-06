import 'dart:ui' show Color;

import 'environment.dart';
import 'errors.dart';
import 'features/back_button.dart';
import 'features/biometric_manager.dart';
import 'features/bottom_button.dart';
import 'features/haptic_feedback.dart';
import 'features/location_manager.dart';
import 'features/sensors.dart';
import 'features/settings_button.dart';
import 'features/storage.dart';
import 'models/contact.dart';
import 'models/events.dart';
import 'models/init_data.dart';
import 'models/location_data.dart';
import 'models/params.dart';
import 'models/safe_area_inset.dart';
import 'models/theme_params.dart';
import 'tma.dart';
import 'tma_events.dart';
import 'version.dart';

/// [Tma] used when the app is not running inside Telegram: on native
/// platforms, in a plain browser, or when the SDK script is missing.
///
/// See the class documentation of [Tma] for the exact behaviour contract.
final class TmaUnavailable extends Tma {
  const TmaUnavailable({required this.environment, required this.reason});

  @override
  final TmaEnvironment environment;
  final TmaUnavailableReason reason;

  @override
  TmaUnavailableReason? get unavailableReason => reason;

  Never _unavailable(String method) => throw TmaUnavailableException(method);

  @override
  TmaVersion get version => TmaVersion.zero;
  @override
  TmaClientPlatform get platform => TmaClientPlatform.unknown;
  @override
  String get initDataRaw => '';
  @override
  WebAppInitData? get initData => null;
  @override
  TmaColorScheme get colorScheme => TmaColorScheme.light;
  @override
  ThemeParams get themeParams => ThemeParams.empty;
  @override
  bool get isActive => true;
  @override
  bool get isExpanded => false;
  @override
  double get viewportHeight => 0;
  @override
  double get viewportStableHeight => 0;
  @override
  SafeAreaInset get safeAreaInset => SafeAreaInset.zero;
  @override
  SafeAreaInset get contentSafeAreaInset => SafeAreaInset.zero;
  @override
  bool get isFullscreen => false;
  @override
  bool get isOrientationLocked => false;
  @override
  bool get isClosingConfirmationEnabled => false;
  @override
  bool get isVerticalSwipesEnabled => true;
  @override
  String get headerColor => '';
  @override
  String get backgroundColor => '';
  @override
  String get bottomBarColor => '';

  @override
  void setHeaderColor(HeaderColor color) {}
  @override
  void setBackgroundColor(BarColor color) {}
  @override
  void setBottomBarColor(BarColor color) {}
  @override
  void enableClosingConfirmation() {}
  @override
  void disableClosingConfirmation() {}
  @override
  void enableVerticalSwipes() {}
  @override
  void disableVerticalSwipes() {}
  @override
  void requestFullscreen() {}
  @override
  void exitFullscreen() {}
  @override
  void lockOrientation() {}
  @override
  void unlockOrientation() {}
  @override
  void ready() {}
  @override
  void expand() {}
  @override
  void close({bool returnBack = false}) {}
  @override
  void hideKeyboard() {}

  @override
  TmaEvents get events => const _NoEvents();
  @override
  BackButton get backButton => const _NoBackButton();
  @override
  BottomButton get mainButton => const _NoBottomButton('main');
  @override
  BottomButton get secondaryButton => const _NoBottomButton('secondary');
  @override
  SettingsButton get settingsButton => const _NoSettingsButton();
  @override
  HapticFeedback get hapticFeedback => const _NoHaptics();
  @override
  CloudStorage get cloudStorage => const _NoCloudStorage();
  @override
  DeviceStorage get deviceStorage => const _NoDeviceStorage();
  @override
  SecureStorage get secureStorage => const _NoSecureStorage();
  @override
  BiometricManager get biometricManager => const _NoBiometrics();
  @override
  LocationManager get locationManager => const _NoLocation();
  @override
  MotionSensor get accelerometer => const _NoMotionSensor();
  @override
  MotionSensor get gyroscope => const _NoMotionSensor();
  @override
  DeviceOrientation get deviceOrientation => const _NoDeviceOrientation();

  @override
  void sendData(String data) {}
  @override
  void switchInlineQuery(
    String query, {
    List<ChooseChatType>? chooseChatTypes,
  }) {}
  @override
  void openLink(
    String url, {
    bool tryInstantView = false,
    OpenLinkBrowser? tryBrowser,
  }) {}
  @override
  void openTelegramLink(String url, {bool forceRequest = false}) {}
  @override
  Future<InvoiceStatus> openInvoice(String url) async =>
      _unavailable('openInvoice');
  @override
  void shareToStory(String mediaUrl, [StoryShareParams? params]) {}
  @override
  Future<bool> shareMessage(String preparedMessageId) async => false;
  @override
  Future<bool> setEmojiStatus(
    String customEmojiId, [
    EmojiStatusParams params = const EmojiStatusParams(),
  ]) async => false;
  @override
  Future<bool> requestEmojiStatusAccess() async => false;
  @override
  Future<bool> downloadFile(DownloadFileParams params) async => false;
  @override
  void addToHomeScreen() {}
  @override
  Future<HomeScreenStatus> checkHomeScreenStatus() async =>
      HomeScreenStatus.unsupported;
  @override
  Future<String?> showPopup(PopupParams params) async =>
      _unavailable('showPopup');
  @override
  Future<void> showAlert(String message) async {}
  @override
  Future<bool> showConfirm(String message) async => _unavailable('showConfirm');
  @override
  Future<String?> scanQr({String? text}) async => _unavailable('scanQr');
  @override
  void closeScanQrPopup() {}
  @override
  Future<String?> readTextFromClipboard() async =>
      _unavailable('readTextFromClipboard');
  @override
  Future<bool> requestWriteAccess() async => false;
  @override
  Future<ContactRequestResult> requestContact() async =>
      const ContactRequestResult.cancelled();
  @override
  Future<bool> requestChat(String requestId) async => false;
}

const Stream<Never> _never = Stream<Never>.empty();

final class _NoEvents extends TmaEvents {
  const _NoEvents();
  @override
  Stream<void> get activated => _never;
  @override
  Stream<void> get deactivated => _never;
  @override
  Stream<void> get themeChanged => _never;
  @override
  Stream<ViewportChangedEvent> get viewportChanged => _never;
  @override
  Stream<void> get safeAreaChanged => _never;
  @override
  Stream<void> get contentSafeAreaChanged => _never;
  @override
  Stream<void> get mainButtonClicked => _never;
  @override
  Stream<void> get secondaryButtonClicked => _never;
  @override
  Stream<void> get backButtonClicked => _never;
  @override
  Stream<void> get settingsButtonClicked => _never;
  @override
  Stream<InvoiceClosedEvent> get invoiceClosed => _never;
  @override
  Stream<PopupClosedEvent> get popupClosed => _never;
  @override
  Stream<QrTextReceivedEvent> get qrTextReceived => _never;
  @override
  Stream<void> get scanQrPopupClosed => _never;
  @override
  Stream<ClipboardTextReceivedEvent> get clipboardTextReceived => _never;
  @override
  Stream<WriteAccessRequestedEvent> get writeAccessRequested => _never;
  @override
  Stream<void> get contactRequested => _never;
  @override
  Stream<void> get fullscreenChanged => _never;
  @override
  Stream<FailedEvent> get fullscreenFailed => _never;
  @override
  Stream<void> get homeScreenAdded => _never;
  @override
  Stream<HomeScreenCheckedEvent> get homeScreenChecked => _never;
  @override
  Stream<void> get emojiStatusSet => _never;
  @override
  Stream<FailedEvent> get emojiStatusFailed => _never;
  @override
  Stream<void> get emojiStatusAccessRequested => _never;
  @override
  Stream<void> get shareMessageSent => _never;
  @override
  Stream<FailedEvent> get shareMessageFailed => _never;
  @override
  Stream<FileDownloadRequestedEvent> get fileDownloadRequested => _never;
  @override
  Stream<void> get locationManagerUpdated => _never;
  @override
  Stream<void> get locationRequested => _never;
  @override
  Stream<void> get biometricManagerUpdated => _never;
  @override
  Stream<BiometricAuthRequestedEvent> get biometricAuthRequested => _never;
  @override
  Stream<BiometricTokenUpdatedEvent> get biometricTokenUpdated => _never;
  @override
  Stream<void> get requestedChatSent => _never;
  @override
  Stream<FailedEvent> get requestedChatFailed => _never;
}

final class _NoBackButton extends BackButton {
  const _NoBackButton();
  @override
  bool get isVisible => false;
  @override
  Stream<void> get onClick => _never;
  @override
  void show() {}
  @override
  void hide() {}
}

final class _NoSettingsButton extends SettingsButton {
  const _NoSettingsButton();
  @override
  bool get isVisible => false;
  @override
  Stream<void> get onClick => _never;
  @override
  void show() {}
  @override
  void hide() {}
}

final class _NoBottomButton extends BottomButton {
  const _NoBottomButton(this.type);
  @override
  final String type;
  @override
  String get text => '';
  @override
  Color? get color => null;
  @override
  Color? get textColor => null;
  @override
  bool get isVisible => false;
  @override
  bool get isActive => false;
  @override
  bool get hasShineEffect => false;
  @override
  SecondaryButtonPosition? get position => null;
  @override
  bool get isProgressVisible => false;
  @override
  String? get iconCustomEmojiId => null;
  @override
  Stream<void> get onClick => _never;
  @override
  void setText(String text) {}
  @override
  void show() {}
  @override
  void hide() {}
  @override
  void enable() {}
  @override
  void disable() {}
  @override
  void showProgress({bool leaveActive = false}) {}
  @override
  void hideProgress() {}
  @override
  void setParams(BottomButtonParams params) {}
}

final class _NoHaptics extends HapticFeedback {
  const _NoHaptics();
  @override
  void impactOccurred(HapticImpactStyle style) {}
  @override
  void notificationOccurred(HapticNotificationType type) {}
  @override
  void selectionChanged() {}
}

final class _NoCloudStorage extends CloudStorage {
  const _NoCloudStorage();
  Never _u(String m) => throw TmaUnavailableException('CloudStorage.$m');
  @override
  Future<void> setItem(String key, String value) async => _u('setItem');
  @override
  Future<String?> getItem(String key) async => _u('getItem');
  @override
  Future<Map<String, String>> getItems(List<String> keys) async =>
      _u('getItems');
  @override
  Future<void> removeItem(String key) async => _u('removeItem');
  @override
  Future<void> removeItems(List<String> keys) async => _u('removeItems');
  @override
  Future<List<String>> getKeys() async => _u('getKeys');
}

final class _NoDeviceStorage extends DeviceStorage {
  const _NoDeviceStorage();
  Never _u(String m) => throw TmaUnavailableException('DeviceStorage.$m');
  @override
  Future<void> setItem(String key, String value) async => _u('setItem');
  @override
  Future<String?> getItem(String key) async => _u('getItem');
  @override
  Future<void> removeItem(String key) async => _u('removeItem');
  @override
  Future<void> clear() async => _u('clear');
}

final class _NoSecureStorage extends SecureStorage {
  const _NoSecureStorage();
  Never _u(String m) => throw TmaUnavailableException('SecureStorage.$m');
  @override
  Future<void> setItem(String key, String value) async => _u('setItem');
  @override
  Future<SecureStorageItem> getItem(String key) async => _u('getItem');
  @override
  Future<String?> restoreItem(String key) async => _u('restoreItem');
  @override
  Future<void> removeItem(String key) async => _u('removeItem');
  @override
  Future<void> clear() async => _u('clear');
}

final class _NoBiometrics extends BiometricManager {
  const _NoBiometrics();
  @override
  bool get isInited => false;
  @override
  bool get isBiometricAvailable => false;
  @override
  BiometricType get biometricType => BiometricType.unknown;
  @override
  bool get isAccessRequested => false;
  @override
  bool get isAccessGranted => false;
  @override
  bool get isBiometricTokenSaved => false;
  @override
  String get deviceId => '';
  @override
  Stream<void> get onUpdated => _never;
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestAccess([
    BiometricParams params = const BiometricParams(),
  ]) async => false;
  @override
  Future<BiometricAuthResult> authenticate([
    BiometricParams params = const BiometricParams(),
  ]) async => const BiometricAuthResult(isAuthenticated: false);
  @override
  Future<bool> updateBiometricToken(String token) async => false;
  @override
  void openSettings() {}
}

final class _NoLocation extends LocationManager {
  const _NoLocation();
  @override
  bool get isInited => false;
  @override
  bool get isLocationAvailable => false;
  @override
  bool get isAccessRequested => false;
  @override
  bool get isAccessGranted => false;
  @override
  Stream<void> get onUpdated => _never;
  @override
  Future<void> init() async {}
  @override
  Future<LocationData?> getLocation() async => null;
  @override
  void openSettings() {}
}

final class _NoMotionSensor extends MotionSensor {
  const _NoMotionSensor();
  @override
  bool get isStarted => false;
  @override
  Vector3 get value => Vector3.zero;
  @override
  Stream<Vector3> get onChanged => _never;
  @override
  Stream<String> get onFailed => _never;
  @override
  Future<bool> start([SensorParams params = const SensorParams()]) async =>
      false;
  @override
  Future<bool> stop() async => false;
}

final class _NoDeviceOrientation extends DeviceOrientation {
  const _NoDeviceOrientation();
  @override
  bool get isStarted => false;
  @override
  OrientationData get value => OrientationData.zero;
  @override
  Stream<OrientationData> get onChanged => _never;
  @override
  Stream<String> get onFailed => _never;
  @override
  Future<bool> start([
    DeviceOrientationParams params = const DeviceOrientationParams(),
  ]) async => false;
  @override
  Future<bool> stop() async => false;
}
