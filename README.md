# tma

Type-safe Dart/Flutter bindings for the
[Telegram Mini Apps API](https://core.telegram.org/bots/webapps) (Bot API 10.1).

The package answers one question first and everything else second:
**is this app running inside Telegram?** Everything degrades gracefully when
it is not, so the same codebase runs inside Telegram, in a regular browser and
as a native mobile/desktop app.

```dart
import 'package:tma/tma.dart';

void main() {
  final tma = Tma.instance;        // detected once, cached forever
  tma.ready();                     // no-op outside Telegram

  if (tma.isAvailable) {
    final user = tma.initData?.user;             // parsed, but UNVERIFIED
    sendToBackend(tma.initDataRaw);              // validate the hash server-side
    tma.backButton.addListener(() => Navigator.pop(context));
  }
  runApp(const App());
}
```

## Setup

Add the official script to `web/index.html` **before** `flutter_bootstrap.js`:

```html
<script src="https://telegram.org/js/telegram-web-app.js?63"></script>
```

No platform folders or plugin registration are needed. On non-web targets the
package compiles to a stub.

## Detection

| Situation | `environment` | `isAvailable` | `unavailableReason` |
|---|---|---|---|
| Opened from a Telegram client | `telegram` | `true` | `null` |
| Opened in a browser, script loaded | `browser` | `false` | `notLaunchedFromTelegram` |
| Script tag missing | `browser` | `false` | `scriptMissing` |
| Android / iOS / desktop build | `native` | `false` | `nativePlatform` |

Detection relies on the SDK itself: Telegram passes `tgWebAppPlatform` and
`tgWebAppData` to the page, so `platform != 'unknown'` or a non-empty
`initData` proves a Telegram launch.

## Behaviour outside Telegram

* **Properties** return neutral values (`null`, `false`, `0`, empty). No fake
  users, no fake hashes.
* **Fire-and-forget methods** (`ready`, `expand`, `show`, haptics, colors)
  are silent no-ops.
* **Permission requests** (`requestWriteAccess`, `requestContact`,
  `shareMessage`, ...) resolve to `false` / cancelled.
* **Methods whose result is data produced by Telegram** (`openInvoice`,
  `showPopup`, `showConfirm`, `scanQr`, `readTextFromClipboard`,
  cloud/device/secure storage) throw `TmaUnavailableException`, so a missing
  integration never looks like a user decision. Failures of `Future` methods
  always arrive through the future, never as a synchronous throw.
* **Streams** are empty.

## Version guard

Every method checks the client's Bot API version before touching JavaScript and
throws `TmaUnsupportedException` with the required and current version. Errors
raised by the SDK itself (`WebAppPopupOpened`, `WebAppTgUrlInvalid`, ...)
surface as `TmaJsException`.

```dart
if (tma.isVersionAtLeast(const TmaVersion(8, 0))) tma.requestFullscreen();
```

## Events

All `onEvent` types are exposed as broadcast streams; the JavaScript listener
is attached on first subscription and removed on the last cancel.

```dart
tma.events.themeChanged.listen((_) => setState(() {}));
tma.events.viewportChanged.listen((e) { if (e.isStateStable) relayout(); });
tma.mainButton.onClick.listen((_) => submit());
```

## Coverage

`WebApp` properties and methods, `BackButton`, `MainButton`,
`SecondaryButton`, `SettingsButton`, `HapticFeedback`, `CloudStorage`,
`DeviceStorage`, `SecureStorage`, `BiometricManager`, `LocationManager`,
`Accelerometer`, `Gyroscope`, `DeviceOrientation`, every `WebApp` event as a
stream (35) plus sensor streams on the sensor objects,
`requestChat` (9.6), `hideKeyboard` (9.1), `chat_join_request_query_id` (10.1).

## Security notes

* `initData` is parsed for convenience only. **Always** validate
  `initDataRaw` on your backend
  ([how](https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app)),
  and reject stale `auth_date`.
* The same applies to `ContactData.raw` returned by `requestContact`.
* Never log `initDataRaw` or `hash` in production.

## Testing

Unit tests run on the VM (`flutter test`); the interop layer is covered by
browser tests against a fake `window.Telegram.WebApp`
(`flutter test --platform chrome test/web`).

```dart
Tma.debugOverride(const TmaUnavailable(
  environment: TmaEnvironment.browser,
  reason: TmaUnavailableReason.notLaunchedFromTelegram,
));
```

`Tma` is an abstract class, so a mock implementing only what a test needs can
be injected the same way.

## Browser preview with fake launch data

Open the page with Telegram-style hash parameters:

```
http://localhost:8080/#tgWebAppPlatform=weba&tgWebAppVersion=9.6&tgWebAppData=auth_date%3D1%26hash%3Dx
```
