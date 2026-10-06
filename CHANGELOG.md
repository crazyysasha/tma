## 1.2.0

* Fix (#2): callbacks handed to JavaScript failed when the SDK called them
  with fewer arguments than declared, and the SDK swallowed the error.
  Every event without data never reached Dart (button clicks,
  `themeChanged`, `activated`, safe-area and fullscreen changes, sensor
  readings, manager updates), `scanQr` hung when the scanner was closed, and
  `CloudStorage` / `DeviceStorage` futures never completed.
* All JS-facing callbacks are now built with `jsFn0`–`jsFn3` in
  `js_utils.dart`, whose parameters are optional; a test forbids converting
  function literals with `.toJS` anywhere else.
* Browser tests against the real `telegram-web-app.js` (downloaded at test
  time), playing the Telegram client through `TelegramWebviewProxy` and
  `Telegram.WebView.receiveEvent`. The fake SDK now calls callbacks with the
  SDK's exact arity.
* Requires Dart 3.13 and Flutter 3.47.

## 1.1.0

* `TmaEvents` is a concrete class built from a `TmaEventSource`; the event
  table exists once. `TmaEvents.none` replaces the stub implementation and
  `events.custom(type, decode)` reaches event types newer than this package.
* `BackButton` and `SettingsButton` are typedefs of the new `TmaButton`;
  `BottomButton` extends it, so `addListener` exists once.
* `MotionSensor` and `DeviceOrientation` are typedefs of the generic
  `Sensor<V, P>`; `start` takes an optional `P?`.
* Button click and manager update streams reuse the `events` streams, so one
  event type never gets a second JS listener.
* Fix: `BiometricManager`, `LocationManager`, sensors and storages are now
  version-gated. On old clients the SDK skipped the callback and the future
  never completed; it now rejects with `TmaUnsupportedException`.
* Fix: `BiometricManager.init` / `LocationManager.init` resolve immediately
  when already initialised (the SDK does not call back in that case).
* Internal: one `_Gate` handles version checks and error routing with
  constant `TmaVersion`s; sub-objects are created lazily; `initData` is
  parsed once.

## 1.0.1

* `requestChat` takes the `PreparedKeyboardButton.id` string, not an int.
* `openLink(tryBrowser:)` takes an `OpenLinkBrowser`, not a bool.
* `BottomButton.iconCustomEmojiId` is `null` while unset instead of a
  boolean leaking through the `String?` type.
* `WebAppInitData.tryParse`/`ContactData.tryParse` return `null` on
  malformed percent-encoding instead of throwing `ArgumentError`.
* Unsupported-version errors of `Future` methods reject the future instead
  of throwing synchronously.
* `scanQr` no longer leaks its `scanQrPopupClosed` listener.
* Outside Telegram `showAlert` is a no-op and `readTextFromClipboard`
  throws, matching the documented contract.
* Void methods no longer return the SDK's chainable JS object.
* `Tma.debugOverride` is no longer `@visibleForTesting`.
* Browser tests for the interop layer (`flutter test --platform chrome`).

## 1.0.0

Complete rewrite.

* Explicit environment detection: `Tma.instance.environment`, `isAvailable`,
  `unavailableReason`. The stub no longer returns fake data.
* Full Bot API 10.1 surface: all `WebApp` properties and methods, all
  sub-objects (buttons, haptics, cloud/device/secure storage, biometrics,
  location, sensors) and every `WebApp` event as a broadcast stream.
* Version guard before every call (`TmaUnsupportedException`); SDK errors
  surface as `TmaJsException`.
* Correct JS interop: parameters are passed as real JS objects (the previous
  `toJSBox` usage silently dropped `try_instant_view`, `force_request` and
  story params); `showScanQrPopup` receives a params object; `offClick` works;
  snake_case location/chat fields are read correctly.
* `InvoiceStatus` includes `failed` and `pending`; unknown values no longer
  hang the future.
* `initData` parsing decodes per key/value pair and keeps `raw` for
  server-side validation. Added `query_id`, `receiver`, `chat`,
  `can_send_after`, `chat_join_request_query_id`.
* Conditional import uses `dart.library.js_interop`, so `--wasm` builds get
  the real implementation instead of the stub.
* Unit tests for parsing, models and stub behaviour; example builds with
  dart2js and dart2wasm.

## 0.0.1

* Initial release for a single project.
