@TestOn('browser')
library;

import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:tma/tma.dart';

/// The same script `example/web/index.html` loads. Telegram updates it in
/// place, so these tests also catch SDK changes that break the bindings.
const sdkUrl = 'https://telegram.org/js/telegram-web-app.js?63';

String? _sdkSource;
Object? _sdkError;

Future<String> _fetchSdk() async {
  final response = await globalContext
      .callMethod<JSPromise<JSObject>>('fetch'.toJS, sdkUrl.toJS)
      .toDart;
  if (!(response['ok']! as JSBoolean).toDart) {
    throw StateError('HTTP ${response['status']} for $sdkUrl');
  }
  final text = await response
      .callMethod<JSPromise<JSString>>('text'.toJS)
      .toDart;
  return text.toDart;
}

/// Plays the Telegram client for a freshly loaded copy of the real SDK.
///
/// Outgoing calls arrive through `window.TelegramWebviewProxy.postEvent`,
/// exactly as in the mobile clients; replies go back through
/// `Telegram.WebView.receiveEvent`, the entry point the clients call.
final class TelegramClient {
  TelegramClient._();

  final posted = <(String, Map<String, Object?>)>[];

  static TelegramClient launch({
    String platform = 'ios',
    String version = '9.6',
    String initData = 'auth_date=1700000000&hash=abc',
  }) {
    final client = TelegramClient._();
    final hash = Uri(
      queryParameters: {
        'tgWebAppPlatform': platform,
        'tgWebAppVersion': version,
        'tgWebAppData': initData,
        'tgWebAppThemeParams': jsonEncode({'bg_color': '#112233'}),
      },
    ).query;
    (globalContext['sessionStorage']! as JSObject).callMethod('clear'.toJS);
    (globalContext['location']! as JSObject)['hash'] = '#$hash'.toJS;
    globalContext['TelegramWebviewProxy'] = JSObject()
      ..['postEvent'] = (([JSString? type, JSString? data]) {
        final raw = data?.toDart ?? '';
        final decoded = raw.isEmpty ? null : jsonDecode(raw);
        client.posted.add((
          type?.toDart ?? '',
          decoded is Map<String, Object?> ? decoded : const {},
        ));
      }).toJS;
    globalContext.callMethod('eval'.toJS, _sdkSource!.toJS);
    Tma.debugOverride(null);
    return client;
  }

  /// Delivers a client event. Events without data are sent with no
  /// argument at all, as the clients do.
  void receive(String event, [Map<String, Object?>? data]) {
    final webView =
        (globalContext['Telegram']! as JSObject)['WebView']! as JSObject;
    if (data == null) {
      webView.callMethod('receiveEvent'.toJS, event.toJS);
    } else {
      webView.callMethod('receiveEvent'.toJS, event.toJS, data.jsify());
    }
  }

  /// Payload of the most recent outgoing call of [type].
  Map<String, Object?> sent(String type) {
    final match = posted.where((p) => p.$1 == type);
    expect(match, isNotEmpty, reason: 'SDK did not post $type');
    return match.last.$2;
  }
}

void main() {
  setUpAll(() async {
    try {
      _sdkSource = await _fetchSdk();
    } catch (e) {
      _sdkError = e;
    }
  });

  setUp(() {
    if (_sdkSource == null) {
      markTestSkipped('Could not download $sdkUrl: $_sdkError');
    }
  });

  tearDown(() {
    globalContext.delete('Telegram'.toJS);
    globalContext.delete('TelegramWebviewProxy'.toJS);
    Tma.debugOverride(null);
  });

  /// Skips the body when the SDK could not be downloaded.
  void sdkTest(String name, Future<void> Function() body) {
    test(name, () async {
      if (_sdkSource == null) return;
      await body();
    });
  }

  sdkTest('launch parameters are detected and parsed', () async {
    TelegramClient.launch(
      initData:
          'user=${Uri.encodeComponent(jsonEncode({'id': 7, 'first_name': 'A & B'}))}'
          '&auth_date=1700000000&hash=abc',
    );
    final tma = Tma.instance;
    expect(tma.environment, TmaEnvironment.telegram);
    expect(tma.version, const TmaVersion(9, 6));
    expect(tma.platform.kind, TmaClientPlatformKind.ios);
    expect(tma.initData!.user!.firstName, 'A & B');
    expect(tma.themeParams.bgColor, const Color(0xFF112233));
  });

  group('events without data reach Dart (issue #2)', () {
    for (final (name, clientEvent, stream) in [
      (
        'backButton.onClick',
        'back_button_pressed',
        (Tma t) => t.backButton.onClick,
      ),
      (
        'mainButton.onClick',
        'main_button_pressed',
        (Tma t) => t.mainButton.onClick,
      ),
      (
        'secondaryButton.onClick',
        'secondary_button_pressed',
        (Tma t) => t.secondaryButton.onClick,
      ),
      (
        'settingsButton.onClick',
        'settings_button_pressed',
        (Tma t) => t.settingsButton.onClick,
      ),
      (
        'events.scanQrPopupClosed',
        'scan_qr_popup_closed',
        (Tma t) => t.events.scanQrPopupClosed,
      ),
    ]) {
      sdkTest(name, () async {
        final client = TelegramClient.launch();
        var hits = 0;
        final sub = stream(Tma.instance).listen((_) => hits++);
        client.receive(clientEvent);
        await pumpEventQueue();
        expect(hits, 1);
        await sub.cancel();
      });
    }

    sdkTest('themeChanged, with the new theme readable', () async {
      final client = TelegramClient.launch();
      final tma = Tma.instance;
      var hits = 0;
      final sub = tma.events.themeChanged.listen((_) => hits++);
      client.receive('theme_changed', {
        'theme_params': {'bg_color': '#445566'},
      });
      await pumpEventQueue();
      expect(hits, 1);
      expect(tma.themeParams.bgColor, const Color(0xFF445566));
      await sub.cancel();
    });
  });

  sdkTest('viewportChanged delivers its payload', () async {
    final client = TelegramClient.launch();
    final tma = Tma.instance;
    final events = <ViewportChangedEvent>[];
    final sub = tma.events.viewportChanged.listen(events.add);
    client.receive('viewport_changed', {
      'height': 600,
      'is_state_stable': true,
      'is_expanded': true,
    });
    await pumpEventQueue();
    expect(events.single.isStateStable, isTrue);
    expect(tma.viewportStableHeight, 600);
    await sub.cancel();
  });

  group('scanQr', () {
    sdkTest('resolves null when the user closes the scanner', () async {
      final client = TelegramClient.launch();
      final future = Tma.instance.scanQr(text: 'Scan');
      expect(client.sent('web_app_open_scan_qr_popup'), {'text': 'Scan'});
      client.receive('scan_qr_popup_closed');
      expect(await future.timeout(const Duration(seconds: 1)), isNull);
    });

    sdkTest('resolves the text and asks the client to close', () async {
      final client = TelegramClient.launch();
      final future = Tma.instance.scanQr();
      client.receive('qr_text_received', {'data': 'code-1'});
      expect(await future, 'code-1');
      expect(client.sent('web_app_close_scan_qr_popup'), isEmpty);
    });
  });

  group('storages complete with the arity the SDK uses', () {
    sdkTest('CloudStorage setItem and getItem: (err, res)', () async {
      final client = TelegramClient.launch();
      final storage = Tma.instance.cloudStorage;

      final set = storage.setItem('k', 'v');
      final setReq = client.sent('web_app_invoke_custom_method');
      expect(setReq['method'], 'saveStorageValue');
      client.receive('custom_method_invoked', {
        'req_id': setReq['req_id'],
        'result': true,
      });
      await set.timeout(const Duration(seconds: 1));

      final get = storage.getItem('k');
      final getReq = client.sent('web_app_invoke_custom_method');
      expect(getReq['method'], 'getStorageValues');
      client.receive('custom_method_invoked', {
        'req_id': getReq['req_id'],
        'result': {'k': 'v'},
      });
      expect(await get.timeout(const Duration(seconds: 1)), 'v');
    });

    sdkTest('CloudStorage.getItem error: (err) only', () async {
      final client = TelegramClient.launch();
      final get = Tma.instance.cloudStorage.getItem('k');
      client.receive('custom_method_invoked', {
        'req_id': client.sent('web_app_invoke_custom_method')['req_id'],
        'error': 'KEY_INVALID',
      });
      await expectLater(
        get.timeout(const Duration(seconds: 1)),
        throwsA(
          isA<TmaJsException>().having(
            (e) => e.message,
            'message',
            'KEY_INVALID',
          ),
        ),
      );
    });

    sdkTest('DeviceStorage.getItem: (err, res)', () async {
      final client = TelegramClient.launch();
      final get = Tma.instance.deviceStorage.getItem('k');
      final req = client.sent('web_app_device_storage_get_key');
      expect(req['key'], 'k');
      client.receive('device_storage_key_received', {
        'req_id': req['req_id'],
        'value': 'v',
      });
      expect(await get.timeout(const Duration(seconds: 1)), 'v');
    });

    sdkTest('SecureStorage.getItem: (err, res, canRestore)', () async {
      final client = TelegramClient.launch();
      final get = Tma.instance.secureStorage.getItem('k');
      client.receive('secure_storage_key_received', {
        'req_id': client.sent('web_app_secure_storage_get_key')['req_id'],
        'value': null,
        'can_restore': true,
      });
      final item = await get.timeout(const Duration(seconds: 1));
      expect(item.value, isNull);
      expect(item.canRestore, isTrue);
    });
  });

  group('request/response methods', () {
    sdkTest('requestWriteAccess', () async {
      final client = TelegramClient.launch();
      final future = Tma.instance.requestWriteAccess();
      client.sent('web_app_request_write_access');
      client.receive('write_access_requested', {'status': 'allowed'});
      expect(await future, isTrue);
    });

    sdkTest('openInvoice maps the client status', () async {
      final client = TelegramClient.launch();
      final future = Tma.instance.openInvoice('https://t.me/\$abc');
      expect(client.sent('web_app_open_invoice'), {'slug': 'abc'});
      client.receive('invoice_closed', {'slug': 'abc', 'status': 'failed'});
      expect(await future, InvoiceStatus.failed);
    });

    sdkTest('showPopup returns the pressed button', () async {
      final client = TelegramClient.launch();
      final future = Tma.instance.showPopup(
        const PopupParams(
          message: 'Hi',
          buttons: [PopupButton(id: 'yes', text: 'Yes')],
        ),
      );
      expect(client.sent('web_app_open_popup')['message'], 'Hi');
      client.receive('popup_closed', {'button_id': 'yes'});
      expect(await future, 'yes');
    });

    sdkTest('showAlert completes when the popup closes', () async {
      final client = TelegramClient.launch();
      final future = Tma.instance.showAlert('Done');
      client.receive('popup_closed', {});
      await future.timeout(const Duration(seconds: 1));
    });
  });

  group('managers and sensors', () {
    sdkTest(
      'BiometricManager.init, then a second init resolves at once',
      () async {
        final client = TelegramClient.launch();
        final biometrics = Tma.instance.biometricManager;
        final init = biometrics.init();
        client.sent('web_app_biometry_get_info');
        client.receive('biometry_info_received', {
          'available': true,
          'type': 'face',
        });
        await init.timeout(const Duration(seconds: 1));
        expect(biometrics.isInited, isTrue);
        expect(biometrics.biometricType, BiometricType.face);
        await biometrics.init().timeout(const Duration(seconds: 1));
      },
    );

    sdkTest('accelerometer start and onChanged (event without data)', () async {
      final client = TelegramClient.launch();
      final sensor = Tma.instance.accelerometer;
      final readings = <Vector3>[];
      final sub = sensor.onChanged.listen(readings.add);

      final started = sensor.start();
      expect(client.sent('web_app_start_accelerometer'), {
        'refresh_rate': 1000,
      });
      client.receive('accelerometer_started');
      expect(await started, isTrue);

      client.receive('accelerometer_changed', {'x': 1, 'y': 2, 'z': 3});
      await pumpEventQueue();
      expect(readings.single, const Vector3(1, 2, 3));
      await sub.cancel();
    });

    sdkTest('an old client rejects instead of hanging', () async {
      TelegramClient.launch(version: '7.0');
      await expectLater(
        Tma.instance.biometricManager.init().timeout(
          const Duration(seconds: 1),
        ),
        throwsA(isA<TmaUnsupportedException>()),
      );
      await expectLater(
        Tma.instance.accelerometer.start().timeout(const Duration(seconds: 1)),
        throwsA(isA<TmaUnsupportedException>()),
      );
    });
  });
}
