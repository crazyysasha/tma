import 'dart:async';
import 'dart:js_interop';
import 'dart:ui' show Color;

import '../environment.dart';
import '../errors.dart';
import '../features/biometric_manager.dart';
import '../features/bottom_button.dart';
import '../features/button.dart';
import '../features/haptic_feedback.dart';
import '../features/location_manager.dart';
import '../features/sensors.dart';
import '../features/storage.dart';
import '../models/contact.dart';
import '../models/events.dart';
import '../models/init_data.dart';
import '../models/location_data.dart';
import '../models/params.dart';
import '../models/safe_area_inset.dart';
import '../models/theme_params.dart';
import '../tma.dart';
import '../tma_events.dart';
import '../version.dart';
import 'js_bindings.dart';
import 'js_utils.dart';

/// Version guard and error routing shared by [TmaWeb] and its sub-objects.
///
/// * [run] is for fire-and-forget calls: an unsupported version or a JS error
///   throws synchronously.
/// * [future] and its helpers are for callback-based calls: every failure,
///   including an unsupported version, rejects the returned future. Several
///   SDK methods silently skip their callback on old clients, so gating here
///   is what guarantees that the future always completes.
final class _Gate {
  const _Gate(this.version);

  final TmaVersion version;

  void _require(String method, TmaVersion min) {
    if (version < min) {
      throw TmaUnsupportedException(
        method: method,
        required: min,
        current: version,
      );
    }
  }

  void run(String method, TmaVersion? min, void Function() body) {
    if (min != null) _require(method, min);
    guardJs(body);
  }

  Future<T> future<T>(
    String method,
    TmaVersion? min,
    void Function(void Function(T value) complete) invoke,
  ) {
    try {
      if (min != null) _require(method, min);
    } on TmaException catch (e, s) {
      return Future<T>.error(e, s);
    }
    return jsCallback<T>(invoke);
  }

  /// [future] for SDK callbacks that receive a single boolean.
  Future<bool> boolean(
    String method,
    TmaVersion? min,
    void Function(JSFunction callback) invoke,
  ) =>
      future<bool>(method, min, (complete) => invoke(jsBoolCallback(complete)));

  /// [future] for SDK callbacks that receive nothing.
  Future<void> done(
    String method,
    TmaVersion? min,
    void Function(JSFunction callback) invoke,
  ) =>
      future<void>(method, min, (complete) => invoke(jsDoneCallback(complete)));

  /// [future] for the node-style `(error, result)` storage callbacks.
  Future<T> storage<T>(
    String method,
    TmaVersion min,
    void Function(JSFunction callback) invoke,
    T Function(JSAny? result, JSAny? extra) decode,
  ) {
    try {
      _require(method, min);
    } on TmaException catch (e, s) {
      return Future<T>.error(e, s);
    }
    return jsStorageCallback<T>(invoke, decode);
  }
}

/// [Tma] backed by a real `window.Telegram.WebApp`.
final class TmaWeb extends Tma {
  TmaWeb(this._js)
    : version = TmaVersion.parse(_js.version),
      platform = TmaClientPlatform.fromRaw(_js.platform),
      initDataRaw = _js.initData;

  final WebAppJS _js;
  late final _Gate _gate = _Gate(version);

  /// The single bridge from JavaScript events to Dart streams. [events] and
  /// every sub-object build their streams from it.
  Stream<T> _source<T>(
    String type,
    T Function(Map<String, Object?> payload) decode,
  ) => jsEventStream<T>(
    eventType: type,
    on: (t, cb) => _js.onEvent(t, cb),
    off: (t, cb) => _js.offEvent(t, cb),
    decode: (payload) => decode(dartMap(payload)),
  );

  @override
  TmaEnvironment get environment => TmaEnvironment.telegram;
  @override
  TmaUnavailableReason? get unavailableReason => null;
  @override
  final TmaVersion version;
  @override
  final TmaClientPlatform platform;

  // ---------------------------------------------------------------------------
  // Init data. The SDK reads it once at load and never changes it.

  @override
  final String initDataRaw;

  @override
  late final WebAppInitData? initData = WebAppInitData.tryParse(initDataRaw);

  // ---------------------------------------------------------------------------
  // Appearance

  @override
  TmaColorScheme get colorScheme =>
      _js.colorScheme == 'dark' ? TmaColorScheme.dark : TmaColorScheme.light;
  @override
  ThemeParams get themeParams => ThemeParams.fromJson(dartMap(_js.themeParams));
  @override
  bool get isActive => _js.isActive;
  @override
  bool get isExpanded => _js.isExpanded;
  @override
  double get viewportHeight => jsDouble(_js.viewportHeight);
  @override
  double get viewportStableHeight => jsDouble(_js.viewportStableHeight);
  @override
  SafeAreaInset get safeAreaInset =>
      SafeAreaInset.fromJson(dartMap(_js.safeAreaInset));
  @override
  SafeAreaInset get contentSafeAreaInset =>
      SafeAreaInset.fromJson(dartMap(_js.contentSafeAreaInset));
  @override
  bool get isFullscreen => _js.isFullscreen;
  @override
  bool get isOrientationLocked => _js.isOrientationLocked;
  @override
  bool get isClosingConfirmationEnabled => _js.isClosingConfirmationEnabled;
  @override
  bool get isVerticalSwipesEnabled => _js.isVerticalSwipesEnabled;
  @override
  String get headerColor => _js.headerColor ?? '';
  @override
  String get backgroundColor => _js.backgroundColor ?? '';
  @override
  String get bottomBarColor => _js.bottomBarColor ?? '';

  @override
  void setHeaderColor(HeaderColor color) => _gate.run(
    'setHeaderColor',
    const TmaVersion(6, 1),
    () => _js.setHeaderColor(color.toJs()),
  );

  @override
  void setBackgroundColor(BarColor color) => _gate.run(
    'setBackgroundColor',
    const TmaVersion(6, 1),
    () => _js.setBackgroundColor(color.toJs()),
  );

  @override
  void setBottomBarColor(BarColor color) => _gate.run(
    'setBottomBarColor',
    const TmaVersion(7, 10),
    () => _js.setBottomBarColor(color.toJs()),
  );

  @override
  void enableClosingConfirmation() => _gate.run(
    'enableClosingConfirmation',
    const TmaVersion(6, 2),
    () => _js.enableClosingConfirmation(),
  );

  @override
  void disableClosingConfirmation() => _gate.run(
    'disableClosingConfirmation',
    const TmaVersion(6, 2),
    () => _js.disableClosingConfirmation(),
  );

  @override
  void enableVerticalSwipes() => _gate.run(
    'enableVerticalSwipes',
    const TmaVersion(7, 7),
    () => _js.enableVerticalSwipes(),
  );

  @override
  void disableVerticalSwipes() => _gate.run(
    'disableVerticalSwipes',
    const TmaVersion(7, 7),
    () => _js.disableVerticalSwipes(),
  );

  @override
  void requestFullscreen() => _gate.run(
    'requestFullscreen',
    const TmaVersion(8, 0),
    () => _js.requestFullscreen(),
  );

  @override
  void exitFullscreen() => _gate.run(
    'exitFullscreen',
    const TmaVersion(8, 0),
    () => _js.exitFullscreen(),
  );

  @override
  void lockOrientation() => _gate.run(
    'lockOrientation',
    const TmaVersion(8, 0),
    () => _js.lockOrientation(),
  );

  @override
  void unlockOrientation() => _gate.run(
    'unlockOrientation',
    const TmaVersion(8, 0),
    () => _js.unlockOrientation(),
  );

  // ---------------------------------------------------------------------------
  // Lifecycle

  @override
  void ready() => _gate.run('ready', null, () => _js.ready());

  @override
  void expand() => _gate.run('expand', null, () => _js.expand());

  @override
  void close({bool returnBack = false}) => _gate.run(
    'close',
    null,
    () => _js.close(returnBack ? jsObject({'return_back': true}) : null),
  );

  @override
  void hideKeyboard() => _gate.run(
    'hideKeyboard',
    const TmaVersion(9, 1),
    () => _js.hideKeyboard(),
  );

  // ---------------------------------------------------------------------------
  // Sub-objects, created on first access. Click and update streams are the
  // shared ones from [events], so no event type gets a second JS listener.

  @override
  late final TmaEvents events = TmaEvents(_source);

  @override
  late final BackButton backButton = _ButtonWeb(
    _js.backButton,
    events.backButtonClicked,
  );

  @override
  late final SettingsButton settingsButton = _ButtonWeb(
    _js.settingsButton,
    events.settingsButtonClicked,
  );

  @override
  late final BottomButton mainButton = _BottomButtonWeb(
    _js.mainButton,
    events.mainButtonClicked,
  );

  @override
  late final BottomButton secondaryButton = _BottomButtonWeb(
    _js.secondaryButton,
    events.secondaryButtonClicked,
  );

  @override
  late final HapticFeedback hapticFeedback = _HapticsWeb(_js.hapticFeedback);

  @override
  late final CloudStorage cloudStorage = _CloudStorageWeb(
    _gate,
    _js.cloudStorage,
  );

  @override
  late final DeviceStorage deviceStorage = _DeviceStorageWeb(
    _gate,
    _js.deviceStorage,
  );

  @override
  late final SecureStorage secureStorage = _SecureStorageWeb(
    _gate,
    _js.secureStorage,
  );

  @override
  late final BiometricManager biometricManager = _BiometricsWeb(
    _gate,
    _js.biometricManager,
    events.biometricManagerUpdated,
  );

  @override
  late final LocationManager locationManager = _LocationWeb(
    _gate,
    _js.locationManager,
    events.locationManagerUpdated,
  );

  @override
  late final MotionSensor accelerometer = _motionSensor(
    'Accelerometer',
    'accelerometer',
    _js.accelerometer,
  );

  @override
  late final MotionSensor gyroscope = _motionSensor(
    'Gyroscope',
    'gyroscope',
    _js.gyroscope,
  );

  @override
  late final DeviceOrientation deviceOrientation = _orientationSensor(
    _js.deviceOrientation,
  );

  MotionSensor _motionSensor(String name, String eventPrefix, SensorJS js) {
    Vector3 read() => Vector3(jsDouble(js.x), jsDouble(js.y), jsDouble(js.z));
    return _SensorWeb<Vector3, SensorParams>(
      _gate,
      name,
      js,
      read,
      const SensorParams(),
      onChanged: _source('${eventPrefix}Changed', (_) => read()),
      onFailed: _source('${eventPrefix}Failed', _errorOf),
    );
  }

  DeviceOrientation _orientationSensor(DeviceOrientationJS js) {
    OrientationData read() => OrientationData(
      absolute: js.absolute,
      alpha: jsDouble(js.alpha),
      beta: jsDouble(js.beta),
      gamma: jsDouble(js.gamma),
    );
    return _SensorWeb<OrientationData, DeviceOrientationParams>(
      _gate,
      'DeviceOrientation',
      js,
      read,
      const DeviceOrientationParams(),
      onChanged: _source('deviceOrientationChanged', (_) => read()),
      onFailed: _source('deviceOrientationFailed', _errorOf),
    );
  }

  static String _errorOf(Map<String, Object?> payload) =>
      FailedEvent.fromPayload(payload).error;

  // ---------------------------------------------------------------------------
  // Actions

  @override
  void sendData(String data) =>
      _gate.run('sendData', null, () => _js.sendData(data));

  @override
  void switchInlineQuery(
    String query, {
    List<ChooseChatType>? chooseChatTypes,
  }) => _gate.run(
    'switchInlineQuery',
    const TmaVersion(6, 7),
    () => _js.switchInlineQuery(
      query,
      chooseChatTypes == null
          ? null
          : jsStringArray(chooseChatTypes.map((t) => t.name)),
    ),
  );

  @override
  void openLink(
    String url, {
    bool tryInstantView = false,
    OpenLinkBrowser? tryBrowser,
  }) => _gate.run(
    'openLink',
    null,
    () => _js.openLink(
      url,
      jsObject({
        if (tryInstantView) 'try_instant_view': true,
        if (tryBrowser != null) 'try_browser': tryBrowser.id,
      }),
    ),
  );

  @override
  void openTelegramLink(String url, {bool forceRequest = false}) => _gate.run(
    'openTelegramLink',
    null,
    () => _js.openTelegramLink(
      url,
      jsObject({if (forceRequest) 'force_request': true}),
    ),
  );

  @override
  Future<InvoiceStatus> openInvoice(String url) => _gate.future(
    'openInvoice',
    const TmaVersion(6, 1),
    (complete) => _js.openInvoice(
      url,
      ((JSString status) => complete(InvoiceStatus.fromRaw(status.toDart)))
          .toJS,
    ),
  );

  @override
  void shareToStory(String mediaUrl, [StoryShareParams? params]) => _gate.run(
    'shareToStory',
    const TmaVersion(7, 8),
    () => _js.shareToStory(
      mediaUrl,
      params == null ? null : jsObject(params.toJson()),
    ),
  );

  @override
  Future<bool> shareMessage(String preparedMessageId) => _gate.boolean(
    'shareMessage',
    const TmaVersion(8, 0),
    (cb) => _js.shareMessage(preparedMessageId, cb),
  );

  @override
  Future<bool> setEmojiStatus(
    String customEmojiId, [
    EmojiStatusParams params = const EmojiStatusParams(),
  ]) => _gate.boolean(
    'setEmojiStatus',
    const TmaVersion(8, 0),
    (cb) => _js.setEmojiStatus(customEmojiId, jsObject(params.toJson()), cb),
  );

  @override
  Future<bool> requestEmojiStatusAccess() => _gate.boolean(
    'requestEmojiStatusAccess',
    const TmaVersion(8, 0),
    (cb) => _js.requestEmojiStatusAccess(cb),
  );

  @override
  Future<bool> downloadFile(DownloadFileParams params) => _gate.boolean(
    'downloadFile',
    const TmaVersion(8, 0),
    (cb) => _js.downloadFile(jsObject(params.toJson()), cb),
  );

  @override
  void addToHomeScreen() => _gate.run(
    'addToHomeScreen',
    const TmaVersion(8, 0),
    () => _js.addToHomeScreen(),
  );

  @override
  Future<HomeScreenStatus> checkHomeScreenStatus() => _gate.future(
    'checkHomeScreenStatus',
    const TmaVersion(8, 0),
    (complete) => _js.checkHomeScreenStatus(
      ((JSString status) => complete(HomeScreenStatus.fromRaw(status.toDart)))
          .toJS,
    ),
  );

  @override
  Future<String?> showPopup(PopupParams params) => _gate.future(
    'showPopup',
    const TmaVersion(6, 2),
    (complete) => _js.showPopup(
      jsObject(params.toJson()),
      ((JSAny? buttonId) => complete(jsStringOrNull(buttonId))).toJS,
    ),
  );

  @override
  Future<void> showAlert(String message) => _gate.done(
    'showAlert',
    const TmaVersion(6, 2),
    (cb) => _js.showAlert(message, cb),
  );

  @override
  Future<bool> showConfirm(String message) => _gate.boolean(
    'showConfirm',
    const TmaVersion(6, 2),
    (cb) => _js.showConfirm(message, cb),
  );

  @override
  Future<String?> scanQr({String? text}) =>
      _gate.future('showScanQrPopup', const TmaVersion(6, 4), (complete) {
        // Dismissing the scanner without a result fires `scanQrPopupClosed`.
        // The subscription goes through the shared event stream and is
        // cancelled on every exit path: scan, dismiss or a synchronous error.
        late final StreamSubscription<void> closed;
        closed = events.scanQrPopupClosed.listen((_) {
          closed.cancel();
          complete(null);
        });
        try {
          _js.showScanQrPopup(
            jsObject({if (text != null) 'text': text}),
            (JSAny? data) {
              closed.cancel();
              complete(jsStringOrNull(data));
              // Returning `true` tells the SDK to close the popup.
              return true.toJS;
            }.toJS,
          );
        } catch (_) {
          closed.cancel();
          rethrow;
        }
      });

  @override
  void closeScanQrPopup() => _gate.run(
    'closeScanQrPopup',
    const TmaVersion(6, 4),
    () => _js.closeScanQrPopup(),
  );

  @override
  Future<String?> readTextFromClipboard() => _gate.future(
    'readTextFromClipboard',
    const TmaVersion(6, 4),
    (complete) => _js.readTextFromClipboard(
      ((JSAny? data) => complete(jsStringOrNull(data))).toJS,
    ),
  );

  @override
  Future<bool> requestWriteAccess() => _gate.boolean(
    'requestWriteAccess',
    const TmaVersion(6, 9),
    (cb) => _js.requestWriteAccess(cb),
  );

  @override
  Future<ContactRequestResult> requestContact() => _gate.future(
    'requestContact',
    const TmaVersion(6, 9),
    (complete) => _js.requestContact(
      (JSBoolean sent, JSAny? event) {
        final map = dartMap(event);
        final status = switch (map['status']) {
          'sent' => ContactRequestStatus.sent,
          'cancelled' => ContactRequestStatus.cancelled,
          _ =>
            sent.toDart
                ? ContactRequestStatus.sent
                : ContactRequestStatus.unknown,
        };
        final response = map['response'];
        complete(
          ContactRequestResult(
            status: status,
            data: response is String ? ContactData.tryParse(response) : null,
          ),
        );
      }.toJS,
    ),
  );

  @override
  Future<bool> requestChat(String requestId) => _gate.boolean(
    'requestChat',
    const TmaVersion(9, 6),
    (cb) => _js.requestChat(requestId, cb),
  );
}

// -----------------------------------------------------------------------------
// Buttons. Fire-and-forget, like the SDK: on old clients they do nothing.

mixin _ButtonWebMixin on TmaButton {
  ButtonJS get _btn;

  @override
  bool get isVisible => _btn.isVisible;

  @override
  void show() {
    guardJs(() => _btn.show());
  }

  @override
  void hide() {
    guardJs(() => _btn.hide());
  }
}

final class _ButtonWeb extends TmaButton with _ButtonWebMixin {
  _ButtonWeb(this._btn, this.onClick);

  @override
  final ButtonJS _btn;
  @override
  final Stream<void> onClick;
}

final class _BottomButtonWeb extends BottomButton with _ButtonWebMixin {
  _BottomButtonWeb(this._btn, this.onClick);

  @override
  final BottomButtonJS _btn;
  @override
  final Stream<void> onClick;

  @override
  String get type => _btn.type;
  @override
  String get text => _btn.text;
  @override
  Color? get color => ThemeParams.parseHexColor(_btn.color);
  @override
  Color? get textColor => ThemeParams.parseHexColor(_btn.textColor);
  @override
  bool get isActive => _btn.isActive;
  @override
  bool get hasShineEffect => _btn.hasShineEffect;
  @override
  SecondaryButtonPosition? get position =>
      SecondaryButtonPosition.values.asNameMap()[_btn.position];
  @override
  bool get isProgressVisible => _btn.isProgressVisible;
  @override
  String? get iconCustomEmojiId => jsStringOrNull(_btn.iconCustomEmojiId);

  @override
  void setText(String text) {
    guardJs(() => _btn.setText(text));
  }

  @override
  void enable() {
    guardJs(() => _btn.enable());
  }

  @override
  void disable() {
    guardJs(() => _btn.disable());
  }

  @override
  void showProgress({bool leaveActive = false}) {
    guardJs(() => _btn.showProgress(leaveActive));
  }

  @override
  void hideProgress() {
    guardJs(() => _btn.hideProgress());
  }

  @override
  void setParams(BottomButtonParams params) {
    guardJs(() => _btn.setParams(jsObject(params.toJson())));
  }
}

final class _HapticsWeb extends HapticFeedback {
  _HapticsWeb(this._h);
  final HapticFeedbackJS _h;

  @override
  void impactOccurred(HapticImpactStyle style) {
    guardJs(() => _h.impactOccurred(style.name));
  }

  @override
  void notificationOccurred(HapticNotificationType type) {
    guardJs(() => _h.notificationOccurred(type.name));
  }

  @override
  void selectionChanged() {
    guardJs(() => _h.selectionChanged());
  }
}

// -----------------------------------------------------------------------------
// Storage

/// The calls shared by all three storages, version-gated per storage.
mixin _StorageWeb {
  _Gate get _gate;
  KeyValueStorageJS get _store;
  String get _name;
  TmaVersion get _since;

  Future<T> _call<T>(
    String method,
    void Function(JSFunction callback) invoke,
    T Function(JSAny? result, JSAny? extra) decode,
  ) => _gate.storage('$_name.$method', _since, invoke, decode);

  Future<void> _void(String method, void Function(JSFunction) invoke) =>
      _call(method, invoke, (_, _) {});

  Future<String?> _string(String method, void Function(JSFunction) invoke) =>
      _call(method, invoke, (result, _) => jsStringOrNull(result));

  Future<void> setItem(String key, String value) =>
      _void('setItem', (cb) => _store.setItem(key, value, cb));

  Future<void> removeItem(String key) =>
      _void('removeItem', (cb) => _store.removeItem(key, cb));
}

final class _CloudStorageWeb extends CloudStorage with _StorageWeb {
  _CloudStorageWeb(this._gate, this._store);

  @override
  final _Gate _gate;
  @override
  final CloudStorageJS _store;
  @override
  String get _name => 'CloudStorage';
  @override
  TmaVersion get _since => const TmaVersion(6, 9);

  @override
  Future<String?> getItem(String key) =>
      _string('getItem', (cb) => _store.getItem(key, cb));

  @override
  Future<Map<String, String>> getItems(List<String> keys) => _call(
    'getItems',
    (cb) => _store.getItems(jsStringArray(keys), cb),
    (result, _) =>
        dartMap(result).map((k, v) => MapEntry(k, v?.toString() ?? '')),
  );

  @override
  Future<void> removeItems(List<String> keys) =>
      _void('removeItems', (cb) => _store.removeItems(jsStringArray(keys), cb));

  @override
  Future<List<String>> getKeys() => _call(
    'getKeys',
    (cb) => _store.getKeys(cb),
    (result, _) => switch (result.dartify()) {
      List<Object?> keys => [for (final k in keys) k.toString()],
      _ => const <String>[],
    },
  );
}

final class _DeviceStorageWeb extends DeviceStorage with _StorageWeb {
  _DeviceStorageWeb(this._gate, this._store);

  @override
  final _Gate _gate;
  @override
  final DeviceStorageJS _store;
  @override
  String get _name => 'DeviceStorage';
  @override
  TmaVersion get _since => const TmaVersion(9, 0);

  @override
  Future<String?> getItem(String key) =>
      _string('getItem', (cb) => _store.getItem(key, cb));

  @override
  Future<void> clear() => _void('clear', (cb) => _store.clear(cb));
}

final class _SecureStorageWeb extends SecureStorage with _StorageWeb {
  _SecureStorageWeb(this._gate, this._store);

  @override
  final _Gate _gate;
  @override
  final SecureStorageJS _store;
  @override
  String get _name => 'SecureStorage';
  @override
  TmaVersion get _since => const TmaVersion(9, 0);

  @override
  Future<SecureStorageItem> getItem(String key) => _call(
    'getItem',
    (cb) => _store.getItem(key, cb),
    (result, canRestore) => SecureStorageItem(
      value: jsStringOrNull(result),
      canRestore:
          canRestore.isA<JSBoolean>() && (canRestore as JSBoolean).toDart,
    ),
  );

  @override
  Future<String?> restoreItem(String key) =>
      _string('restoreItem', (cb) => _store.restoreItem(key, cb));

  @override
  Future<void> clear() => _void('clear', (cb) => _store.clear(cb));
}

// -----------------------------------------------------------------------------
// Biometrics, location, sensors

final class _BiometricsWeb extends BiometricManager {
  _BiometricsWeb(this._gate, this._b, this.onUpdated);

  static const _since = TmaVersion(7, 2);
  final _Gate _gate;
  final BiometricManagerJS _b;

  @override
  final Stream<void> onUpdated;
  @override
  bool get isInited => _b.isInited;
  @override
  bool get isBiometricAvailable => _b.isBiometricAvailable;
  @override
  BiometricType get biometricType => BiometricType.fromRaw(_b.biometricType);
  @override
  bool get isAccessRequested => _b.isAccessRequested;
  @override
  bool get isAccessGranted => _b.isAccessGranted;
  @override
  bool get isBiometricTokenSaved => _b.isBiometricTokenSaved;
  @override
  String get deviceId => _b.deviceId ?? '';

  @override
  Future<void> init() {
    // The SDK returns without calling back when already initialised.
    if (_b.isInited) return Future<void>.value();
    return _gate.done('BiometricManager.init', _since, (cb) => _b.init(cb));
  }

  @override
  Future<bool> requestAccess([
    BiometricParams params = const BiometricParams(),
  ]) => _gate.boolean(
    'BiometricManager.requestAccess',
    _since,
    (cb) => _b.requestAccess(jsObject(params.toJson()), cb),
  );

  @override
  Future<BiometricAuthResult> authenticate([
    BiometricParams params = const BiometricParams(),
  ]) => _gate.future(
    'BiometricManager.authenticate',
    _since,
    (complete) => _b.authenticate(
      jsObject(params.toJson()),
      ((JSBoolean ok, JSAny? token) => complete(
            BiometricAuthResult(
              isAuthenticated: ok.toDart,
              token: jsStringOrNull(token),
            ),
          ))
          .toJS,
    ),
  );

  @override
  Future<bool> updateBiometricToken(String token) => _gate.boolean(
    'BiometricManager.updateBiometricToken',
    _since,
    (cb) => _b.updateBiometricToken(token, cb),
  );

  @override
  void openSettings() {
    guardJs(() => _b.openSettings());
  }
}

final class _LocationWeb extends LocationManager {
  _LocationWeb(this._gate, this._l, this.onUpdated);

  static const _since = TmaVersion(8, 0);
  final _Gate _gate;
  final LocationManagerJS _l;

  @override
  final Stream<void> onUpdated;
  @override
  bool get isInited => _l.isInited;
  @override
  bool get isLocationAvailable => _l.isLocationAvailable;
  @override
  bool get isAccessRequested => _l.isAccessRequested;
  @override
  bool get isAccessGranted => _l.isAccessGranted;

  @override
  Future<void> init() {
    // The SDK returns without calling back when already initialised.
    if (_l.isInited) return Future<void>.value();
    return _gate.done('LocationManager.init', _since, (cb) => _l.init(cb));
  }

  @override
  Future<LocationData?> getLocation() => _gate.future(
    'LocationManager.getLocation',
    _since,
    (complete) => _l.getLocation(
      (JSAny? data) {
        complete(
          data.isUndefinedOrNull ? null : LocationData.fromJson(dartMap(data)),
        );
      }.toJS,
    ),
  );

  @override
  void openSettings() {
    guardJs(() => _l.openSettings());
  }
}

final class _SensorWeb<V, P extends SensorParams> extends Sensor<V, P> {
  _SensorWeb(
    this._gate,
    this._name,
    this._js,
    this._read,
    this._defaults, {
    required this.onChanged,
    required this.onFailed,
  });

  static const _since = TmaVersion(8, 0);
  final _Gate _gate;
  final String _name;
  final SensorBaseJS _js;
  final V Function() _read;
  final P _defaults;

  @override
  final Stream<V> onChanged;
  @override
  final Stream<String> onFailed;
  @override
  bool get isStarted => _js.isStarted;
  @override
  V get value => _read();

  @override
  Future<bool> start([P? params]) => _gate.boolean(
    '$_name.start',
    _since,
    (cb) => _js.start(jsObject((params ?? _defaults).toJson()), cb),
  );

  @override
  Future<bool> stop() =>
      _gate.boolean('$_name.stop', _since, (cb) => _js.stop(cb));
}
