import '../environment.dart';
import '../tma.dart';
import '../tma_unavailable.dart';
import 'js_bindings.dart';
import 'tma_web.dart';

/// Decides whether the page runs inside Telegram.
///
/// 1. `window.Telegram.WebApp` must exist, otherwise the script tag is
///    missing from `index.html`.
/// 2. The SDK must have received launch parameters from Telegram. The
///    official script sets `platform` to `'unknown'` and leaves `initData`
///    empty when the page is opened in a regular browser, so either a
///    non-unknown platform or non-empty init data proves a Telegram launch.
Tma createTma() {
  final webApp = telegramGlobal?.webApp;
  if (webApp == null) {
    return const TmaUnavailable(
      environment: TmaEnvironment.browser,
      reason: TmaUnavailableReason.scriptMissing,
    );
  }
  final launched = webApp.platform != 'unknown' || webApp.initData.isNotEmpty;
  if (!launched) {
    return const TmaUnavailable(
      environment: TmaEnvironment.browser,
      reason: TmaUnavailableReason.notLaunchedFromTelegram,
    );
  }
  return TmaWeb(webApp);
}
