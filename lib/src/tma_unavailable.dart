import 'dart:ui' show Color;

import 'environment.dart';
import 'errors.dart';
import 'features/biometric_manager.dart';
import 'features/bottom_button.dart';
import 'features/button.dart';
import 'features/haptic_feedback.dart';
import 'features/location_manager.dart';
import 'features/sensors.dart';
import 'features/storage.dart';
import 'models/contact.dart';
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
  TmaEvents get events => TmaEvents.none;
  @override
  BackButton get backButton => const _NoButton();
  @override
  BottomButton get mainButton => const _NoBottomButton('main');
  @override
  BottomButton get secondaryButton => const _NoBottomButton('secondary');
  @override
  SettingsButton get settingsButton => const _NoButton();
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
  MotionSensor get accelerometer => const _NoSensor(Vector3.zero);
  @override
  MotionSensor get gyroscope => const _NoSensor(Vector3.zero);
  @override
  DeviceOrientation get deviceOrientation =>
      const _NoSensor(OrientationData.zero);

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

/// Shared by every button: invisible, never clicked, commands ignored.
mixin _NoButtonMixin on TmaButton {
  @override
  bool get isVisible => false;
  @override
  Stream<void> get onClick => _never;
  @override
  void show() {}
  @override
  void hide() {}
}

final class _NoButton extends TmaButton with _NoButtonMixin {
  const _NoButton();
}

final class _NoBottomButton extends BottomButton with _NoButtonMixin {
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
  void setText(String text) {}
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

/// Every storage call outside Telegram fails with
/// [TmaUnavailableException]: storage reads are data produced by Telegram.
mixin _NoStorageMixin {
  String get _name;
  Never _u(String method) => throw TmaUnavailableException('$_name.$method');

  Future<void> setItem(String key, String value) async => _u('setItem');
  Future<void> removeItem(String key) async => _u('removeItem');
}

final class _NoCloudStorage extends CloudStorage with _NoStorageMixin {
  const _NoCloudStorage();
  @override
  String get _name => 'CloudStorage';
  @override
  Future<String?> getItem(String key) async => _u('getItem');
  @override
  Future<Map<String, String>> getItems(List<String> keys) async =>
      _u('getItems');
  @override
  Future<void> removeItems(List<String> keys) async => _u('removeItems');
  @override
  Future<List<String>> getKeys() async => _u('getKeys');
}

final class _NoDeviceStorage extends DeviceStorage with _NoStorageMixin {
  const _NoDeviceStorage();
  @override
  String get _name => 'DeviceStorage';
  @override
  Future<String?> getItem(String key) async => _u('getItem');
  @override
  Future<void> clear() async => _u('clear');
}

final class _NoSecureStorage extends SecureStorage with _NoStorageMixin {
  const _NoSecureStorage();
  @override
  String get _name => 'SecureStorage';
  @override
  Future<SecureStorageItem> getItem(String key) async => _u('getItem');
  @override
  Future<String?> restoreItem(String key) async => _u('restoreItem');
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

final class _NoSensor<V, P extends SensorParams> extends Sensor<V, P> {
  const _NoSensor(this.value);
  @override
  final V value;
  @override
  bool get isStarted => false;
  @override
  Stream<V> get onChanged => _never;
  @override
  Stream<String> get onFailed => _never;
  @override
  Future<bool> start([P? params]) async => false;
  @override
  Future<bool> stop() async => false;
}
