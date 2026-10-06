import 'dart:js_interop';
import 'dart:ui' show Color;

import '../environment.dart';
import '../errors.dart';
import '../features/back_button.dart';
import '../features/biometric_manager.dart';
import '../features/bottom_button.dart';
import '../features/haptic_feedback.dart';
import '../features/location_manager.dart';
import '../features/sensors.dart';
import '../features/settings_button.dart';
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

/// [Tma] backed by a real `window.Telegram.WebApp`.
final class TmaWeb extends Tma {
  TmaWeb(this._js)
    : version = TmaVersion.parse(_js.version),
      platform = TmaClientPlatform.fromRaw(_js.platform),
      events = _EventsWeb(_js),
      backButton = _BackButtonWeb(_js),
      settingsButton = _SettingsButtonWeb(_js),
      mainButton = _BottomButtonWeb(_js, _js.mainButton, 'mainButtonClicked'),
      secondaryButton = _BottomButtonWeb(
        _js,
        _js.secondaryButton,
        'secondaryButtonClicked',
      ),
      hapticFeedback = _HapticsWeb(_js),
      cloudStorage = _CloudStorageWeb(_js),
      deviceStorage = _DeviceStorageWeb(_js),
      secureStorage = _SecureStorageWeb(_js),
      biometricManager = _BiometricsWeb(_js),
      locationManager = _LocationWeb(_js),
      accelerometer = _SensorWeb(_js, _js.accelerometer, 'accelerometer'),
      gyroscope = _SensorWeb(_js, _js.gyroscope, 'gyroscope'),
      deviceOrientation = _DeviceOrientationWeb(_js);

  final WebAppJS _js;

  @override
  TmaEnvironment get environment => TmaEnvironment.telegram;
  @override
  TmaUnavailableReason? get unavailableReason => null;
  @override
  final TmaVersion version;
  @override
  final TmaClientPlatform platform;

  /// Version-guarded [jsCallback]: an unsupported client rejects the returned
  /// future instead of throwing synchronously, so every failure of a
  /// `Future` method travels through the same channel.
  Future<T> _future<T>(
    String method,
    String min,
    void Function(void Function(T value) complete) invoke,
  ) {
    try {
      _require(method, min);
    } on TmaException catch (e, s) {
      return Future<T>.error(e, s);
    }
    return jsCallback<T>(invoke);
  }

  /// Throws [TmaUnsupportedException] if the client is older than [min].
  void _require(String method, String min) {
    final required = TmaVersion.parse(min);
    if (version < required) {
      throw TmaUnsupportedException(
        method: method,
        required: required,
        current: version,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Init data

  String? _cachedRaw;
  WebAppInitData? _cachedInitData;

  @override
  String get initDataRaw => _js.initData;

  @override
  WebAppInitData? get initData {
    final raw = _js.initData;
    if (raw != _cachedRaw) {
      _cachedRaw = raw;
      _cachedInitData = WebAppInitData.tryParse(raw);
    }
    return _cachedInitData;
  }

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
  void setHeaderColor(HeaderColor color) {
    _require('setHeaderColor', '6.1');
    guardJs(() => _js.setHeaderColor(color.toJs()));
  }

  @override
  void setBackgroundColor(BarColor color) {
    _require('setBackgroundColor', '6.1');
    guardJs(() => _js.setBackgroundColor(color.toJs()));
  }

  @override
  void setBottomBarColor(BarColor color) {
    _require('setBottomBarColor', '7.10');
    guardJs(() => _js.setBottomBarColor(color.toJs()));
  }

  @override
  void enableClosingConfirmation() {
    _require('enableClosingConfirmation', '6.2');
    guardJs(() => _js.enableClosingConfirmation());
  }

  @override
  void disableClosingConfirmation() {
    _require('disableClosingConfirmation', '6.2');
    guardJs(() => _js.disableClosingConfirmation());
  }

  @override
  void enableVerticalSwipes() {
    _require('enableVerticalSwipes', '7.7');
    guardJs(() => _js.enableVerticalSwipes());
  }

  @override
  void disableVerticalSwipes() {
    _require('disableVerticalSwipes', '7.7');
    guardJs(() => _js.disableVerticalSwipes());
  }

  @override
  void requestFullscreen() {
    _require('requestFullscreen', '8.0');
    guardJs(() => _js.requestFullscreen());
  }

  @override
  void exitFullscreen() {
    _require('exitFullscreen', '8.0');
    guardJs(() => _js.exitFullscreen());
  }

  @override
  void lockOrientation() {
    _require('lockOrientation', '8.0');
    guardJs(() => _js.lockOrientation());
  }

  @override
  void unlockOrientation() {
    _require('unlockOrientation', '8.0');
    guardJs(() => _js.unlockOrientation());
  }

  // ---------------------------------------------------------------------------
  // Lifecycle

  @override
  void ready() {
    guardJs(() => _js.ready());
  }

  @override
  void expand() {
    guardJs(() => _js.expand());
  }

  @override
  void close({bool returnBack = false}) {
    guardJs(
      () => _js.close(returnBack ? jsObject({'return_back': true}) : null),
    );
  }

  @override
  void hideKeyboard() {
    _require('hideKeyboard', '9.1');
    guardJs(() => _js.hideKeyboard());
  }

  // ---------------------------------------------------------------------------
  // Sub-objects

  @override
  final TmaEvents events;
  @override
  final BackButton backButton;
  @override
  final BottomButton mainButton;
  @override
  final BottomButton secondaryButton;
  @override
  final SettingsButton settingsButton;
  @override
  final HapticFeedback hapticFeedback;
  @override
  final CloudStorage cloudStorage;
  @override
  final DeviceStorage deviceStorage;
  @override
  final SecureStorage secureStorage;
  @override
  final BiometricManager biometricManager;
  @override
  final LocationManager locationManager;
  @override
  final MotionSensor accelerometer;
  @override
  final MotionSensor gyroscope;
  @override
  final DeviceOrientation deviceOrientation;

  // ---------------------------------------------------------------------------
  // Actions

  @override
  void sendData(String data) {
    guardJs(() => _js.sendData(data));
  }

  @override
  void switchInlineQuery(
    String query, {
    List<ChooseChatType>? chooseChatTypes,
  }) {
    _require('switchInlineQuery', '6.7');
    guardJs(
      () => _js.switchInlineQuery(
        query,
        chooseChatTypes == null
            ? null
            : jsStringArray(chooseChatTypes.map((t) => t.name)),
      ),
    );
  }

  @override
  void openLink(
    String url, {
    bool tryInstantView = false,
    OpenLinkBrowser? tryBrowser,
  }) {
    guardJs(
      () => _js.openLink(
        url,
        jsObject({
          if (tryInstantView) 'try_instant_view': true,
          if (tryBrowser != null) 'try_browser': tryBrowser.id,
        }),
      ),
    );
  }

  @override
  void openTelegramLink(String url, {bool forceRequest = false}) {
    guardJs(
      () => _js.openTelegramLink(
        url,
        jsObject({if (forceRequest) 'force_request': true}),
      ),
    );
  }

  @override
  Future<InvoiceStatus> openInvoice(String url) {
    return _future<InvoiceStatus>('openInvoice', '6.1', (complete) {
      _js.openInvoice(
        url,
        ((JSString status) => complete(InvoiceStatus.fromRaw(status.toDart)))
            .toJS,
      );
    });
  }

  @override
  void shareToStory(String mediaUrl, [StoryShareParams? params]) {
    _require('shareToStory', '7.8');
    guardJs(
      () => _js.shareToStory(
        mediaUrl,
        params == null ? null : jsObject(params.toJson()),
      ),
    );
  }

  @override
  Future<bool> shareMessage(String preparedMessageId) {
    return _future<bool>('shareMessage', '8.0', (complete) {
      _js.shareMessage(
        preparedMessageId,
        ((JSBoolean sent) => complete(sent.toDart)).toJS,
      );
    });
  }

  @override
  Future<bool> setEmojiStatus(
    String customEmojiId, [
    EmojiStatusParams params = const EmojiStatusParams(),
  ]) {
    return _future<bool>('setEmojiStatus', '8.0', (complete) {
      _js.setEmojiStatus(
        customEmojiId,
        jsObject(params.toJson()),
        ((JSBoolean ok) => complete(ok.toDart)).toJS,
      );
    });
  }

  @override
  Future<bool> requestEmojiStatusAccess() {
    return _future<bool>('requestEmojiStatusAccess', '8.0', (complete) {
      _js.requestEmojiStatusAccess(
        ((JSBoolean ok) => complete(ok.toDart)).toJS,
      );
    });
  }

  @override
  Future<bool> downloadFile(DownloadFileParams params) {
    return _future<bool>('downloadFile', '8.0', (complete) {
      _js.downloadFile(
        jsObject(params.toJson()),
        ((JSBoolean accepted) => complete(accepted.toDart)).toJS,
      );
    });
  }

  @override
  void addToHomeScreen() {
    _require('addToHomeScreen', '8.0');
    guardJs(() => _js.addToHomeScreen());
  }

  @override
  Future<HomeScreenStatus> checkHomeScreenStatus() {
    return _future<HomeScreenStatus>('checkHomeScreenStatus', '8.0', (
      complete,
    ) {
      _js.checkHomeScreenStatus(
        ((JSString status) => complete(HomeScreenStatus.fromRaw(status.toDart)))
            .toJS,
      );
    });
  }

  @override
  Future<String?> showPopup(PopupParams params) {
    return _future<String?>('showPopup', '6.2', (complete) {
      _js.showPopup(
        jsObject(params.toJson()),
        ((JSAny? buttonId) => complete(jsStringOrNull(buttonId))).toJS,
      );
    });
  }

  @override
  Future<void> showAlert(String message) {
    return _future<void>('showAlert', '6.2', (complete) {
      _js.showAlert(message, (() => complete(null)).toJS);
    });
  }

  @override
  Future<bool> showConfirm(String message) {
    return _future<bool>('showConfirm', '6.2', (complete) {
      _js.showConfirm(message, ((JSBoolean ok) => complete(ok.toDart)).toJS);
    });
  }

  @override
  Future<String?> scanQr({String? text}) {
    return _future<String?>('showScanQrPopup', '6.4', (complete) {
      // `scanQrPopupClosed` fires when the user dismisses the scanner
      // without scanning anything. The listener is removed on every exit
      // path: scan, dismiss, or a synchronous SDK error.
      late final JSFunction closed;
      void cleanup() => _js.offEvent('scanQrPopupClosed', closed);
      closed =
          () {
            cleanup();
            complete(null);
          }.toJS;
      // The SDK keeps the popup open until the callback returns `true`.
      final callback =
          (JSAny? data) {
            cleanup();
            complete(jsStringOrNull(data));
            return true.toJS;
          }.toJS;
      _js.onEvent('scanQrPopupClosed', closed);
      try {
        _js.showScanQrPopup(
          jsObject({if (text != null) 'text': text}),
          callback,
        );
      } catch (_) {
        cleanup();
        rethrow;
      }
    });
  }

  @override
  void closeScanQrPopup() {
    _require('closeScanQrPopup', '6.4');
    guardJs(() => _js.closeScanQrPopup());
  }

  @override
  Future<String?> readTextFromClipboard() {
    return _future<String?>('readTextFromClipboard', '6.4', (complete) {
      _js.readTextFromClipboard(
        ((JSAny? data) => complete(jsStringOrNull(data))).toJS,
      );
    });
  }

  @override
  Future<bool> requestWriteAccess() {
    return _future<bool>('requestWriteAccess', '6.9', (complete) {
      _js.requestWriteAccess(((JSBoolean ok) => complete(ok.toDart)).toJS);
    });
  }

  @override
  Future<ContactRequestResult> requestContact() {
    return _future<ContactRequestResult>('requestContact', '6.9', (complete) {
      _js.requestContact(
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
      );
    });
  }

  @override
  Future<bool> requestChat(String requestId) {
    return _future<bool>('requestChat', '9.6', (complete) {
      _js.requestChat(
        requestId,
        ((JSBoolean sent) => complete(sent.toDart)).toJS,
      );
    });
  }
}

// -----------------------------------------------------------------------------
// Events

Stream<T> _event<T>(WebAppJS js, String type, T Function(JSAny?) decode) =>
    jsEventStream<T>(
      eventType: type,
      on: (t, cb) => js.onEvent(t, cb),
      off: (t, cb) => js.offEvent(t, cb),
      decode: decode,
    );

Stream<void> _signal(WebAppJS js, String type) =>
    _event<void>(js, type, (_) {});

Stream<FailedEvent> _failed(WebAppJS js, String type) => _event(
  js,
  type,
  (p) => FailedEvent(error: dartMap(p)['error']?.toString() ?? 'UNKNOWN'),
);

final class _EventsWeb extends TmaEvents {
  _EventsWeb(this._js);
  final WebAppJS _js;

  @override
  late final Stream<void> activated = _signal(_js, 'activated');
  @override
  late final Stream<void> deactivated = _signal(_js, 'deactivated');
  @override
  late final Stream<void> themeChanged = _signal(_js, 'themeChanged');
  @override
  late final Stream<ViewportChangedEvent> viewportChanged = _event(
    _js,
    'viewportChanged',
    (p) => ViewportChangedEvent(
      isStateStable: dartMap(p)['isStateStable'] == true,
    ),
  );
  @override
  late final Stream<void> safeAreaChanged = _signal(_js, 'safeAreaChanged');
  @override
  late final Stream<void> contentSafeAreaChanged = _signal(
    _js,
    'contentSafeAreaChanged',
  );
  @override
  late final Stream<void> mainButtonClicked = _signal(_js, 'mainButtonClicked');
  @override
  late final Stream<void> secondaryButtonClicked = _signal(
    _js,
    'secondaryButtonClicked',
  );
  @override
  late final Stream<void> backButtonClicked = _signal(_js, 'backButtonClicked');
  @override
  late final Stream<void> settingsButtonClicked = _signal(
    _js,
    'settingsButtonClicked',
  );
  @override
  late final Stream<InvoiceClosedEvent> invoiceClosed = _event(
    _js,
    'invoiceClosed',
    (p) {
      final m = dartMap(p);
      return InvoiceClosedEvent(
        url: m['url']?.toString() ?? '',
        status: InvoiceStatus.fromRaw(m['status']?.toString()),
      );
    },
  );
  @override
  late final Stream<PopupClosedEvent> popupClosed = _event(
    _js,
    'popupClosed',
    (p) => PopupClosedEvent(buttonId: dartMap(p)['button_id']?.toString()),
  );
  @override
  late final Stream<QrTextReceivedEvent> qrTextReceived = _event(
    _js,
    'qrTextReceived',
    (p) => QrTextReceivedEvent(data: dartMap(p)['data']?.toString() ?? ''),
  );
  @override
  late final Stream<void> scanQrPopupClosed = _signal(_js, 'scanQrPopupClosed');
  @override
  late final Stream<ClipboardTextReceivedEvent> clipboardTextReceived = _event(
    _js,
    'clipboardTextReceived',
    (p) => ClipboardTextReceivedEvent(data: dartMap(p)['data']?.toString()),
  );
  @override
  late final Stream<WriteAccessRequestedEvent> writeAccessRequested = _event(
    _js,
    'writeAccessRequested',
    (p) =>
        WriteAccessRequestedEvent(allowed: dartMap(p)['status'] == 'allowed'),
  );
  @override
  late final Stream<void> contactRequested = _signal(_js, 'contactRequested');
  @override
  late final Stream<void> fullscreenChanged = _signal(_js, 'fullscreenChanged');
  @override
  late final Stream<FailedEvent> fullscreenFailed = _failed(
    _js,
    'fullscreenFailed',
  );
  @override
  late final Stream<void> homeScreenAdded = _signal(_js, 'homeScreenAdded');
  @override
  late final Stream<HomeScreenCheckedEvent> homeScreenChecked = _event(
    _js,
    'homeScreenChecked',
    (p) => HomeScreenCheckedEvent(
      status: HomeScreenStatus.fromRaw(dartMap(p)['status']?.toString()),
    ),
  );
  @override
  late final Stream<void> emojiStatusSet = _signal(_js, 'emojiStatusSet');
  @override
  late final Stream<FailedEvent> emojiStatusFailed = _failed(
    _js,
    'emojiStatusFailed',
  );
  @override
  late final Stream<void> emojiStatusAccessRequested = _signal(
    _js,
    'emojiStatusAccessRequested',
  );
  @override
  late final Stream<void> shareMessageSent = _signal(_js, 'shareMessageSent');
  @override
  late final Stream<FailedEvent> shareMessageFailed = _failed(
    _js,
    'shareMessageFailed',
  );
  @override
  late final Stream<FileDownloadRequestedEvent> fileDownloadRequested = _event(
    _js,
    'fileDownloadRequested',
    (p) => FileDownloadRequestedEvent(
      accepted: dartMap(p)['status'] == 'downloading',
    ),
  );
  @override
  late final Stream<void> locationManagerUpdated = _signal(
    _js,
    'locationManagerUpdated',
  );
  @override
  late final Stream<void> locationRequested = _signal(_js, 'locationRequested');
  @override
  late final Stream<void> biometricManagerUpdated = _signal(
    _js,
    'biometricManagerUpdated',
  );
  @override
  late final Stream<BiometricAuthRequestedEvent> biometricAuthRequested =
      _event(_js, 'biometricAuthRequested', (p) {
        final m = dartMap(p);
        return BiometricAuthRequestedEvent(
          isAuthenticated: m['isAuthenticated'] == true,
          token: m['biometricToken']?.toString(),
        );
      });
  @override
  late final Stream<BiometricTokenUpdatedEvent> biometricTokenUpdated = _event(
    _js,
    'biometricTokenUpdated',
    (p) =>
        BiometricTokenUpdatedEvent(isUpdated: dartMap(p)['isUpdated'] == true),
  );
  @override
  late final Stream<void> requestedChatSent = _signal(_js, 'requestedChatSent');
  @override
  late final Stream<FailedEvent> requestedChatFailed = _failed(
    _js,
    'requestedChatFailed',
  );
}

// -----------------------------------------------------------------------------
// Buttons

final class _BackButtonWeb extends BackButton {
  _BackButtonWeb(this._js);
  final WebAppJS _js;
  ButtonJS get _btn => _js.backButton;

  @override
  bool get isVisible => _btn.isVisible;
  @override
  late final Stream<void> onClick = _signal(_js, 'backButtonClicked');
  @override
  void show() {
    guardJs(() => _btn.show());
  }

  @override
  void hide() {
    guardJs(() => _btn.hide());
  }
}

final class _SettingsButtonWeb extends SettingsButton {
  _SettingsButtonWeb(this._js);
  final WebAppJS _js;
  ButtonJS get _btn => _js.settingsButton;

  @override
  bool get isVisible => _btn.isVisible;
  @override
  late final Stream<void> onClick = _signal(_js, 'settingsButtonClicked');
  @override
  void show() {
    guardJs(() => _btn.show());
  }

  @override
  void hide() {
    guardJs(() => _btn.hide());
  }
}

final class _BottomButtonWeb extends BottomButton {
  _BottomButtonWeb(WebAppJS js, this._btn, String clickEvent)
    : onClick = _signal(js, clickEvent);
  final BottomButtonJS _btn;

  @override
  String get type => _btn.type;
  @override
  String get text => _btn.text;
  @override
  Color? get color => ThemeParams.parseHexColor(_btn.color);
  @override
  Color? get textColor => ThemeParams.parseHexColor(_btn.textColor);
  @override
  bool get isVisible => _btn.isVisible;
  @override
  bool get isActive => _btn.isActive;
  @override
  bool get hasShineEffect => _btn.hasShineEffect;
  @override
  SecondaryButtonPosition? get position => switch (_btn.position) {
    'left' => SecondaryButtonPosition.left,
    'right' => SecondaryButtonPosition.right,
    'top' => SecondaryButtonPosition.top,
    'bottom' => SecondaryButtonPosition.bottom,
    _ => null,
  };
  @override
  bool get isProgressVisible => _btn.isProgressVisible;
  @override
  String? get iconCustomEmojiId => jsStringOrNull(_btn.iconCustomEmojiId);
  @override
  final Stream<void> onClick;

  @override
  void setText(String text) {
    guardJs(() => _btn.setText(text));
  }

  @override
  void show() {
    guardJs(() => _btn.show());
  }

  @override
  void hide() {
    guardJs(() => _btn.hide());
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
  _HapticsWeb(this._js);
  final WebAppJS _js;
  HapticFeedbackJS get _h => _js.hapticFeedback;

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

final class _CloudStorageWeb extends CloudStorage {
  _CloudStorageWeb(this._js);
  final WebAppJS _js;
  CloudStorageJS get _s => _js.cloudStorage;

  @override
  Future<void> setItem(String key, String value) =>
      jsStorageCallback((cb) => _s.setItem(key, value, cb), (_, _) {});
  @override
  Future<String?> getItem(String key) => jsStorageCallback(
    (cb) => _s.getItem(key, cb),
    (r, _) => jsStringOrNull(r),
  );
  @override
  Future<Map<String, String>> getItems(List<String> keys) => jsStorageCallback(
    (cb) => _s.getItems(jsStringArray(keys), cb),
    (r, _) => dartMap(r).map((k, v) => MapEntry(k, v?.toString() ?? '')),
  );
  @override
  Future<void> removeItem(String key) =>
      jsStorageCallback((cb) => _s.removeItem(key, cb), (_, _) {});
  @override
  Future<void> removeItems(List<String> keys) => jsStorageCallback(
    (cb) => _s.removeItems(jsStringArray(keys), cb),
    (_, _) {},
  );
  @override
  Future<List<String>> getKeys() => jsStorageCallback(
    (cb) => _s.getKeys(cb),
    (r, _) => switch (r.dartify()) {
      List<Object?> l => [for (final k in l) k.toString()],
      _ => const <String>[],
    },
  );
}

final class _DeviceStorageWeb extends DeviceStorage {
  _DeviceStorageWeb(this._js);
  final WebAppJS _js;
  DeviceStorageJS get _s => _js.deviceStorage;

  @override
  Future<void> setItem(String key, String value) =>
      jsStorageCallback((cb) => _s.setItem(key, value, cb), (_, _) {});
  @override
  Future<String?> getItem(String key) => jsStorageCallback(
    (cb) => _s.getItem(key, cb),
    (r, _) => jsStringOrNull(r),
  );
  @override
  Future<void> removeItem(String key) =>
      jsStorageCallback((cb) => _s.removeItem(key, cb), (_, _) {});
  @override
  Future<void> clear() => jsStorageCallback((cb) => _s.clear(cb), (_, _) {});
}

final class _SecureStorageWeb extends SecureStorage {
  _SecureStorageWeb(this._js);
  final WebAppJS _js;
  SecureStorageJS get _s => _js.secureStorage;

  @override
  Future<void> setItem(String key, String value) =>
      jsStorageCallback((cb) => _s.setItem(key, value, cb), (_, _) {});
  @override
  Future<SecureStorageItem> getItem(String key) => jsStorageCallback(
    (cb) => _s.getItem(key, cb),
    (r, canRestore) => SecureStorageItem(
      value: jsStringOrNull(r),
      canRestore:
          !canRestore.isUndefinedOrNull && (canRestore as JSBoolean).toDart,
    ),
  );
  @override
  Future<String?> restoreItem(String key) => jsStorageCallback(
    (cb) => _s.restoreItem(key, cb),
    (r, _) => jsStringOrNull(r),
  );
  @override
  Future<void> removeItem(String key) =>
      jsStorageCallback((cb) => _s.removeItem(key, cb), (_, _) {});
  @override
  Future<void> clear() => jsStorageCallback((cb) => _s.clear(cb), (_, _) {});
}

// -----------------------------------------------------------------------------
// Biometrics, location, sensors

final class _BiometricsWeb extends BiometricManager {
  _BiometricsWeb(this._js);
  final WebAppJS _js;
  BiometricManagerJS get _b => _js.biometricManager;

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
  late final Stream<void> onUpdated = _signal(_js, 'biometricManagerUpdated');

  @override
  Future<void> init() =>
      jsCallback<void>((complete) => _b.init((() => complete(null)).toJS));
  @override
  Future<bool> requestAccess([
    BiometricParams params = const BiometricParams(),
  ]) => jsCallback<bool>(
    (complete) => _b.requestAccess(
      jsObject(params.toJson()),
      ((JSBoolean ok) => complete(ok.toDart)).toJS,
    ),
  );
  @override
  Future<BiometricAuthResult> authenticate([
    BiometricParams params = const BiometricParams(),
  ]) => jsCallback<BiometricAuthResult>(
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
  Future<bool> updateBiometricToken(String token) => jsCallback<bool>(
    (complete) => _b.updateBiometricToken(
      token,
      ((JSBoolean ok) => complete(ok.toDart)).toJS,
    ),
  );
  @override
  void openSettings() {
    guardJs(() => _b.openSettings());
  }
}

final class _LocationWeb extends LocationManager {
  _LocationWeb(this._js);
  final WebAppJS _js;
  LocationManagerJS get _l => _js.locationManager;

  @override
  bool get isInited => _l.isInited;
  @override
  bool get isLocationAvailable => _l.isLocationAvailable;
  @override
  bool get isAccessRequested => _l.isAccessRequested;
  @override
  bool get isAccessGranted => _l.isAccessGranted;
  @override
  late final Stream<void> onUpdated = _signal(_js, 'locationManagerUpdated');

  @override
  Future<void> init() =>
      jsCallback<void>((complete) => _l.init((() => complete(null)).toJS));
  @override
  Future<LocationData?> getLocation() => jsCallback<LocationData?>(
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

final class _SensorWeb extends MotionSensor {
  _SensorWeb(WebAppJS js, this._s, String prefix)
    : onChanged = _event(js, '${prefix}Changed', (_) => _read(_s)),
      onFailed = _event(
        js,
        '${prefix}Failed',
        (p) => dartMap(p)['error']?.toString() ?? 'UNKNOWN',
      );
  final SensorJS _s;

  static Vector3 _read(SensorJS s) =>
      Vector3(jsDouble(s.x), jsDouble(s.y), jsDouble(s.z));

  @override
  bool get isStarted => _s.isStarted;
  @override
  Vector3 get value => _read(_s);
  @override
  final Stream<Vector3> onChanged;
  @override
  final Stream<String> onFailed;
  @override
  Future<bool> start([SensorParams params = const SensorParams()]) =>
      jsCallback<bool>(
        (complete) => _s.start(
          jsObject(params.toJson()),
          ((JSBoolean ok) => complete(ok.toDart)).toJS,
        ),
      );
  @override
  Future<bool> stop() => jsCallback<bool>(
    (complete) => _s.stop(((JSBoolean ok) => complete(ok.toDart)).toJS),
  );
}

final class _DeviceOrientationWeb extends DeviceOrientation {
  _DeviceOrientationWeb(this._js)
    : onChanged = _event(
        _js,
        'deviceOrientationChanged',
        (_) => _read(_js.deviceOrientation),
      ),
      onFailed = _event(
        _js,
        'deviceOrientationFailed',
        (p) => dartMap(p)['error']?.toString() ?? 'UNKNOWN',
      );
  final WebAppJS _js;
  DeviceOrientationJS get _d => _js.deviceOrientation;

  static OrientationData _read(DeviceOrientationJS d) => OrientationData(
    absolute: d.absolute,
    alpha: jsDouble(d.alpha),
    beta: jsDouble(d.beta),
    gamma: jsDouble(d.gamma),
  );

  @override
  bool get isStarted => _d.isStarted;
  @override
  OrientationData get value => _read(_d);
  @override
  final Stream<OrientationData> onChanged;
  @override
  final Stream<String> onFailed;
  @override
  Future<bool> start([
    DeviceOrientationParams params = const DeviceOrientationParams(),
  ]) => jsCallback<bool>(
    (complete) => _d.start(
      jsObject(params.toJson()),
      ((JSBoolean ok) => complete(ok.toDart)).toJS,
    ),
  );
  @override
  Future<bool> stop() => jsCallback<bool>(
    (complete) => _d.stop(((JSBoolean ok) => complete(ok.toDart)).toJS),
  );
}
