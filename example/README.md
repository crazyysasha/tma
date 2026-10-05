# tma example

Runs in three modes without code changes:

* inside Telegram: full API;
* in a regular browser (`flutter run -d chrome`): `environment == browser`,
  `reason == notLaunchedFromTelegram`;
* on Android/iOS/desktop: `environment == native`.

To emulate a Telegram launch in a browser, open the page with launch
parameters in the hash, e.g.
`http://localhost:8080/#tgWebAppPlatform=weba&tgWebAppVersion=9.6&tgWebAppData=auth_date%3D1%26hash%3Dx`.
