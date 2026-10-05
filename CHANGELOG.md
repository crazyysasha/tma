## 1.0.0

Complete rewrite.

* Explicit environment detection: `Tma.instance.environment`, `isAvailable`,
  `unavailableReason`. The stub no longer returns fake data.
* Full Bot API 10.1 surface: all `WebApp` properties and methods, all
  sub-objects (buttons, haptics, cloud/device/secure storage, biometrics,
  location, sensors) and all 45 events as broadcast streams.
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
