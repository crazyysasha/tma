@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:tma/tma.dart';

/// A `window.Telegram.WebApp` stand-in built from Dart. Records every SDK
/// call, keeps the callbacks the package hands over so tests can resolve
/// them, and tracks `onEvent`/`offEvent` registrations.
final class FakeWebApp {
  FakeWebApp({
    String platform = 'ios',
    String version = '9.6',
    String initData = '',
  }) {
    js = JSObject()
      ..['initData'] = initData.toJS
      ..['platform'] = platform.toJS
      ..['version'] = version.toJS
      ..['colorScheme'] = 'dark'.toJS
      ..['themeParams'] = {'bg_color': '#112233'}.jsify()
      ..['isExpanded'] = true.toJS
      ..['isActive'] = true.toJS
      ..['viewportHeight'] = 500.toJS
      ..['viewportStableHeight'] = 480.toJS
      ..['safeAreaInset'] = {'top': 10, 'bottom': 20}.jsify()
      ..['contentSafeAreaInset'] = {'top': 5}.jsify()
      ..['isClosingConfirmationEnabled'] = false.toJS
      ..['isVerticalSwipesEnabled'] = true.toJS
      ..['isFullscreen'] = false.toJS
      ..['isOrientationLocked'] = false.toJS
      ..['headerColor'] = '#112233'.toJS
      ..['backgroundColor'] = '#112233'.toJS
      ..['bottomBarColor'] = '#112233'.toJS
      ..['BackButton'] = _button('BackButton')
      ..['SettingsButton'] = _button('SettingsButton')
      ..['MainButton'] = _bottomButton('main')
      ..['SecondaryButton'] = _bottomButton('secondary')
      ..['HapticFeedback'] = JSObject()
      ..['CloudStorage'] = _storage('CloudStorage')
      ..['DeviceStorage'] = _storage('DeviceStorage')
      ..['SecureStorage'] = _storage('SecureStorage')
      ..['BiometricManager'] = _biometrics()
      ..['LocationManager'] = JSObject()
      ..['Accelerometer'] = _sensor('Accelerometer')
      ..['Gyroscope'] = JSObject()
      ..['DeviceOrientation'] = JSObject();

    js['onEvent'] = (JSString type, JSFunction cb) {
      handlers.putIfAbsent(type.toDart, () => []).add(cb);
    }.toJS;
    js['offEvent'] = (JSString type, JSFunction cb) {
      handlers[type.toDart]?.removeWhere((h) => h == cb);
    }.toJS;

    _record0('ready');
    _record0('expand');
    _record0('closeScanQrPopup');
    js['openLink'] = (JSString url, JSAny? options) {
      calls.add(('openLink', [url.toDart, options.dartify()]));
    }.toJS;
    js['requestWriteAccess'] = _withCallback('requestWriteAccess');
    js['openInvoice'] = (JSString url, JSFunction cb) {
      calls.add(('openInvoice', [url.toDart]));
      callbacks['openInvoice'] = cb;
    }.toJS;
    js['shareMessage'] = (JSString id, JSFunction cb) {
      calls.add(('shareMessage', [id.toDart]));
      callbacks['shareMessage'] = cb;
    }.toJS;
    js['requestChat'] = (JSAny id, JSFunction cb) {
      calls.add(('requestChat', [id.dartify()]));
      callbacks['requestChat'] = cb;
    }.toJS;
    js['showScanQrPopup'] = (JSAny? params, JSFunction cb) {
      calls.add(('showScanQrPopup', [params.dartify()]));
      callbacks['showScanQrPopup'] = cb;
    }.toJS;
    // A method that fails the way the real SDK does: by throwing a JS Error.
    js['showPopup'] = globalContext.callMethod(
      'eval'.toJS,
      "(function () { throw new Error('WebAppPopupOpened'); })".toJS,
    );
  }

  late final JSObject js;
  final calls = <(String, List<Object?>)>[];
  final callbacks = <String, JSFunction>{};
  final handlers = <String, List<JSFunction>>{};

  List<Object?>? call(String name) =>
      calls.where((c) => c.$1 == name).map((c) => c.$2).lastOrNull;

  int listeners(String type) => handlers[type]?.length ?? 0;

  /// Invokes the callback the package passed to [method] with exactly
  /// [args], the way the SDK does (no padding with `undefined`).
  void resolve(String method, [List<Object?> args = const []]) {
    _apply(callbacks.remove(method)!, args);
  }

  /// Dispatches [type] to every registered `onEvent` listener. Like the
  /// SDK, an event without [payload] is dispatched with no argument.
  void emit(String type, [Object? payload]) {
    final args = payload == null ? const <Object?>[] : [payload];
    for (final h in [...?handlers[type]]) {
      _apply(h, args);
    }
  }

  /// Installs this fake as `window.Telegram.WebApp` and resets detection.
  void install() {
    globalContext['Telegram'] = JSObject()..['WebApp'] = js;
    Tma.debugOverride(null);
  }

  void _record0(String name) {
    js[name] = (() => calls.add((name, const []))).toJS;
  }

  JSFunction _withCallback(String name) => (JSFunction cb) {
    calls.add((name, const []));
    callbacks[name] = cb;
  }.toJS;

  JSObject _button(String name) {
    final btn = JSObject()..['isVisible'] = false.toJS;
    // Real SDK methods are chainable: they return the button object.
    btn['show'] = () {
      calls.add(('$name.show', const []));
      btn['isVisible'] = true.toJS;
      return btn;
    }.toJS;
    btn['hide'] = () {
      calls.add(('$name.hide', const []));
      btn['isVisible'] = false.toJS;
      return btn;
    }.toJS;
    return btn;
  }

  JSObject _bottomButton(String type) {
    final btn = _button(type)
      ..['type'] = type.toJS
      ..['text'] = 'Continue'.toJS
      ..['color'] = '#2481cc'.toJS
      ..['textColor'] = '#ffffff'.toJS
      ..['isActive'] = true.toJS
      ..['hasShineEffect'] = false.toJS
      ..['isProgressVisible'] = false.toJS
      // The SDK initialises this to `false`, not to a string.
      ..['iconCustomEmojiId'] = false.toJS;
    btn['setParams'] = (JSAny params) {
      calls.add(('$type.setParams', [params.dartify()]));
      return btn;
    }.toJS;
    return btn;
  }

  /// Mirrors the SDK quirk: `init` returns without calling back when the
  /// manager is already initialised.
  JSObject _biometrics() {
    final b = JSObject()..['isInited'] = false.toJS;
    b['init'] = (JSFunction cb) {
      calls.add(('BiometricManager.init', const []));
      if ((b['isInited']! as JSBoolean).toDart) return;
      callbacks['BiometricManager.init'] = cb;
    }.toJS;
    return b;
  }

  JSObject _sensor(String name) {
    final s = JSObject()
      ..['isStarted'] = false.toJS
      ..['x'] = 1.5.toJS
      ..['y'] = null
      ..['z'] = (-2).toJS;
    s['start'] = (JSAny params, JSFunction cb) {
      calls.add(('$name.start', [params.dartify()]));
      callbacks['$name.start'] = cb;
    }.toJS;
    return s;
  }

  JSObject _storage(String name) {
    final s = JSObject();
    s['getItem'] = (JSString key, JSFunction cb) {
      calls.add(('$name.getItem', [key.toDart]));
      callbacks['$name.getItem'] = cb;
    }.toJS;
    s['setItem'] = (JSString key, JSString value, JSFunction cb) {
      calls.add(('$name.setItem', [key.toDart, value.toDart]));
      callbacks['$name.setItem'] = cb;
    }.toJS;
    return s;
  }
}

/// `f.apply(null, args)`: calls [f] with exactly `args.length` arguments.
final JSFunction _applyJs = globalContext.callMethod<JSFunction>(
  'eval'.toJS,
  '(function (f, args) { return f.apply(null, args); })'.toJS,
);

void _apply(JSFunction f, List<Object?> args) =>
    _applyJs.callAsFunction(null, f, args.jsify());

void uninstall() {
  globalContext['Telegram'] = null;
  Tma.debugOverride(null);
}

const sampleInitData =
    'user=%7B%22id%22%3A42%2C%22first_name%22%3A%22Tom%20%26%20Jerry%22%7D'
    '&start_param=ref1&auth_date=1700000000&hash=abc';

void main() {
  tearDown(uninstall);

  group('detection', () {
    test('scriptMissing when window.Telegram is absent', () {
      uninstall();
      final tma = Tma.instance;
      expect(tma.isAvailable, isFalse);
      expect(tma.environment, TmaEnvironment.browser);
      expect(tma.unavailableReason, TmaUnavailableReason.scriptMissing);
    });

    test('notLaunchedFromTelegram when the SDK has no launch params', () {
      FakeWebApp(platform: 'unknown', version: '6.0').install();
      expect(
        Tma.instance.unavailableReason,
        TmaUnavailableReason.notLaunchedFromTelegram,
      );
    });

    test('telegram when a platform is reported, init data parsed', () {
      FakeWebApp(initData: sampleInitData).install();
      final tma = Tma.instance;
      expect(tma.environment, TmaEnvironment.telegram);
      expect(tma.platform.kind, TmaClientPlatformKind.ios);
      expect(tma.version, const TmaVersion(9, 6));
      expect(tma.colorScheme, TmaColorScheme.dark);
      expect(tma.themeParams.bgColor, const Color(0xFF112233));
      expect(tma.viewportStableHeight, 480);
      expect(tma.safeAreaInset, const SafeAreaInset(top: 10, bottom: 20));
      expect(tma.initDataRaw, sampleInitData);
      expect(tma.initData!.user!.id, 42);
      expect(tma.initData!.user!.firstName, 'Tom & Jerry');
      expect(tma.initData!.startParam, 'ref1');
    });

    test('instance is cached until debugOverride(null)', () {
      final fake = FakeWebApp()..install();
      final first = Tma.instance;
      fake.js['version'] = '6.0'.toJS;
      expect(identical(Tma.instance, first), isTrue);
    });
  });

  group('parameters cross the boundary as real JS objects', () {
    test('openLink options', () {
      final fake = FakeWebApp()..install();
      Tma.instance.openLink(
        'https://example.com',
        tryInstantView: true,
        tryBrowser: OpenLinkBrowser.chrome,
      );
      expect(fake.call('openLink'), [
        'https://example.com',
        {'try_instant_view': true, 'try_browser': 'chrome'},
      ]);
    });

    test('mainButton.setParams encodes snake_case keys', () {
      final fake = FakeWebApp()..install();
      Tma.instance.mainButton.setParams(
        const BottomButtonParams(text: 'Go', hasShineEffect: true),
      );
      expect(fake.call('main.setParams'), [
        {'text': 'Go', 'has_shine_effect': true},
      ]);
    });

    test('requestChat forwards the string id', () {
      final fake = FakeWebApp()..install();
      Tma.instance.requestChat('AQAAAHdF6IQ');
      expect(fake.call('requestChat'), ['AQAAAHdF6IQ']);
    });
  });

  group('callbacks become futures', () {
    test('requestWriteAccess resolves with the callback value', () async {
      final fake = FakeWebApp()..install();
      final future = Tma.instance.requestWriteAccess();
      fake.resolve('requestWriteAccess', [true]);
      expect(await future, isTrue);
    });

    test('openInvoice maps every SDK status', () async {
      for (final (raw, status) in [
        ('paid', InvoiceStatus.paid),
        ('failed', InvoiceStatus.failed),
        ('pending', InvoiceStatus.pending),
        ('???', InvoiceStatus.unknown),
      ]) {
        final fake = FakeWebApp()..install();
        final future = Tma.instance.openInvoice('https://t.me/\$x');
        fake.resolve('openInvoice', [raw]);
        expect(await future, status, reason: raw);
        uninstall();
      }
    });

    test('unsupported client rejects the future instead of throwing', () async {
      FakeWebApp(version: '6.0').install();
      late Future<bool> future;
      expect(() => future = Tma.instance.shareMessage('m'), returnsNormally);
      final error = await future.then<Object?>(
        (_) => null,
        onError: (Object e) => e,
      );
      expect(error, isA<TmaUnsupportedException>());
      final e = error! as TmaUnsupportedException;
      expect(e.required, const TmaVersion(8, 0));
      expect(e.current, const TmaVersion(6, 0));
    });

    test('a JS Error thrown by the SDK rejects as TmaJsException', () async {
      FakeWebApp().install();
      await expectLater(
        Tma.instance.showPopup(const PopupParams(message: 'hi')),
        throwsA(
          isA<TmaJsException>().having(
            (e) => e.message,
            'message',
            'WebAppPopupOpened',
          ),
        ),
      );
    });

    test('storage node-style callbacks: value and error', () async {
      final fake = FakeWebApp()..install();
      final get = Tma.instance.cloudStorage.getItem('k');
      fake.resolve('CloudStorage.getItem', [null, 'v']);
      expect(await get, 'v');

      final failing = Tma.instance.deviceStorage.setItem('k', 'v');
      fake.resolve('DeviceStorage.setItem', ['KEY_INVALID', null]);
      await expectLater(
        failing,
        throwsA(
          isA<TmaJsException>().having(
            (e) => e.message,
            'message',
            'KEY_INVALID',
          ),
        ),
      );
    });
  });

  group('events', () {
    test(
      'listener attaches on first subscription, detaches on cancel',
      () async {
        final fake = FakeWebApp()..install();
        final received = <ViewportChangedEvent>[];
        expect(fake.listeners('viewportChanged'), 0);

        final sub = Tma.instance.events.viewportChanged.listen(received.add);
        await pumpEventQueue();
        expect(fake.listeners('viewportChanged'), 1);

        fake.emit('viewportChanged', {'isStateStable': true});
        await pumpEventQueue();
        expect(received.single.isStateStable, isTrue);

        await sub.cancel();
        expect(fake.listeners('viewportChanged'), 0);
      },
    );

    test('backButton.addListener fires and unsubscribes', () async {
      final fake = FakeWebApp()..install();
      var clicks = 0;
      final cancel = Tma.instance.backButton.addListener(() => clicks++);
      await pumpEventQueue();
      fake.emit('backButtonClicked');
      await pumpEventQueue();
      expect(clicks, 1);
      cancel();
      await pumpEventQueue();
      expect(fake.listeners('backButtonClicked'), 0);
    });
  });

  group('scanQr', () {
    test('resolves with the scanned text and removes its listener', () async {
      final fake = FakeWebApp()..install();
      final future = Tma.instance.scanQr(text: 'Scan');
      expect(fake.call('showScanQrPopup'), [
        {'text': 'Scan'},
      ]);
      expect(fake.listeners('scanQrPopupClosed'), 1);

      final result = fake.callbacks['showScanQrPopup']!.callAsFunction(
        null,
        'code-1'.toJS,
      );
      expect((result! as JSBoolean).toDart, isTrue, reason: 'closes popup');
      expect(await future, 'code-1');
      expect(fake.listeners('scanQrPopupClosed'), 0);
    });

    test('resolves null when the user dismisses the popup', () async {
      final fake = FakeWebApp()..install();
      final future = Tma.instance.scanQr();
      fake.emit('scanQrPopupClosed');
      expect(await future, isNull);
      expect(fake.listeners('scanQrPopupClosed'), 0);
    });
  });

  group('buttons', () {
    test('iconCustomEmojiId is null while the SDK holds false', () {
      FakeWebApp().install();
      expect(Tma.instance.mainButton.iconCustomEmojiId, isNull);
      expect(Tma.instance.mainButton.text, 'Continue');
      expect(Tma.instance.mainButton.color, const Color(0xFF2481CC));
    });

    test('void methods do not leak the chainable JS object', () {
      final fake = FakeWebApp()..install();
      final Object? Function() show = Tma.instance.backButton.show;
      expect(show(), isNull);
      expect(fake.call('BackButton.show'), isNotNull);
      expect(Tma.instance.backButton.isVisible, isTrue);
    });
  });

  group('version gate never leaves a future hanging', () {
    test('sub-object futures reject on an old client', () async {
      final fake = FakeWebApp(version: '7.0')..install();
      final tma = Tma.instance;
      await expectLater(
        tma.biometricManager.init(),
        throwsA(isA<TmaUnsupportedException>()),
      );
      await expectLater(
        tma.accelerometer.start(),
        throwsA(isA<TmaUnsupportedException>()),
      );
      await expectLater(
        tma.deviceStorage.getItem('k'),
        throwsA(
          isA<TmaUnsupportedException>().having(
            (e) => e.method,
            'method',
            'DeviceStorage.getItem',
          ),
        ),
      );
      expect(fake.call('BiometricManager.init'), isNull, reason: 'not called');
    });

    test('init resolves immediately when already initialised', () async {
      final fake = FakeWebApp()..install();
      fake.js['BiometricManager'] = (fake.js['BiometricManager']! as JSObject)
        ..['isInited'] = true.toJS;
      await Tma.instance.biometricManager.init().timeout(
        const Duration(seconds: 1),
      );
    });

    test('init resolves through the SDK callback otherwise', () async {
      final fake = FakeWebApp()..install();
      final future = Tma.instance.biometricManager.init();
      fake.resolve('BiometricManager.init');
      await future;
    });
  });

  group('sensors', () {
    test('start sends default params and reads values', () async {
      final fake = FakeWebApp()..install();
      final sensor = Tma.instance.accelerometer;
      final future = sensor.start();
      expect(fake.call('Accelerometer.start'), [
        {'refresh_rate': 1000},
      ]);
      fake.resolve('Accelerometer.start', [true]);
      expect(await future, isTrue);
      expect(sensor.value, const Vector3(1.5, 0, -2));
    });

    test('onChanged emits a fresh reading on accelerometerChanged', () async {
      final fake = FakeWebApp()..install();
      final readings = <Vector3>[];
      final sub = Tma.instance.accelerometer.onChanged.listen(readings.add);
      await pumpEventQueue();
      (fake.js['Accelerometer']! as JSObject)['x'] = 3.toJS;
      fake.emit('accelerometerChanged');
      await pumpEventQueue();
      expect(readings.single.x, 3);
      await sub.cancel();
    });
  });

  group('shared event streams', () {
    test('button onClick and events share one JS listener', () async {
      final fake = FakeWebApp()..install();
      final tma = Tma.instance;
      final a = tma.backButton.onClick.listen((_) {});
      final b = tma.events.backButtonClicked.listen((_) {});
      await pumpEventQueue();
      expect(fake.listeners('backButtonClicked'), 1);
      await a.cancel();
      expect(fake.listeners('backButtonClicked'), 1);
      await b.cancel();
      expect(fake.listeners('backButtonClicked'), 0);
    });

    test('custom events decode arbitrary payloads', () async {
      final fake = FakeWebApp()..install();
      final values = <String?>[];
      final sub = Tma.instance.events
          .custom('futureEvent', (p) => p['value'] as String?)
          .listen(values.add);
      await pumpEventQueue();
      fake.emit('futureEvent', {'value': 'x'});
      await pumpEventQueue();
      expect(values, ['x']);
      await sub.cancel();
    });
  });
}
