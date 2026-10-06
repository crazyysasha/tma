import 'create_tma_stub.dart'
    if (dart.library.js_interop) 'web/create_tma_web.dart'
    as tma_factory;
import 'environment.dart';
import 'features/button.dart';
import 'features/biometric_manager.dart';
import 'features/bottom_button.dart';
import 'features/haptic_feedback.dart';
import 'features/location_manager.dart';
import 'features/sensors.dart';
import 'features/storage.dart';
import 'models/contact.dart';
import 'models/init_data.dart';
import 'models/params.dart';
import 'models/safe_area_inset.dart';
import 'models/theme_params.dart';
import 'tma_events.dart';
import 'version.dart';

/// Entry point to the Telegram Mini Apps API.
///
/// Access it through [Tma.instance]. The instance is created lazily on first
/// access and never changes afterwards. Check [isAvailable] (or
/// [environment]) before relying on anything Telegram-specific:
///
/// ```dart
/// final tma = Tma.instance;
/// if (tma.isAvailable) {
///   tma.ready();
///   final user = tma.initData?.user;
/// }
/// ```
///
/// Behaviour when Telegram is **not** available ([isAvailable] is `false`):
///
/// * Properties return neutral values: `null`, `false`, `0`, empty. Flags
///   that are `true` by default in the SDK (`isActive`,
///   `isVerticalSwipesEnabled`) keep that default.
/// * Fire-and-forget methods (`ready`, `expand`, `show`, haptics,
///   `showAlert`...) do nothing and never fail.
/// * Permission and status requests resolve to the negative answer:
///   `false`, [ContactRequestStatus.cancelled], [HomeScreenStatus.unsupported],
///   `null` location.
/// * Methods whose result is data produced by Telegram (`openInvoice`,
///   `showPopup`, `showConfirm`, `scanQr`, `readTextFromClipboard`, every
///   `CloudStorage`/`DeviceStorage`/`SecureStorage` call) throw
///   [TmaUnavailableException] so that a missing integration never looks
///   like a user decision.
/// * Every failure of a `Future`-returning method is delivered through the
///   returned future, never thrown synchronously.
abstract class Tma {
  const Tma();

  static Tma? _instance;

  /// The single [Tma] for this app. Detects the environment on first access.
  static Tma get instance => _instance ??= tma_factory.createTma();

  /// Replaces [instance] with [tma], for tests and local previews. Pass
  /// `null` to go back to automatic detection on next access.
  static void debugOverride(Tma? tma) => _instance = tma;

  // ---------------------------------------------------------------------------
  // Environment

  /// `true` when the app runs inside a Telegram client and the SDK is loaded.
  bool get isAvailable => environment == TmaEnvironment.telegram;

  TmaEnvironment get environment;

  /// Why [isAvailable] is `false`; `null` when it is `true`.
  TmaUnavailableReason? get unavailableReason;

  /// Bot API version supported by the client. [TmaVersion.zero] when
  /// unavailable.
  TmaVersion get version;

  bool isVersionAtLeast(TmaVersion v) => version >= v;

  TmaClientPlatform get platform;

  // ---------------------------------------------------------------------------
  // Init data

  /// Raw `initData` string to send to your backend for validation. Empty
  /// when unavailable.
  String get initDataRaw;

  /// Parsed [initDataRaw]; `null` when empty or unparsable. Unverified.
  WebAppInitData? get initData;

  // ---------------------------------------------------------------------------
  // Appearance

  TmaColorScheme get colorScheme;
  ThemeParams get themeParams;
  bool get isActive;
  bool get isExpanded;
  double get viewportHeight;
  double get viewportStableHeight;
  SafeAreaInset get safeAreaInset;
  SafeAreaInset get contentSafeAreaInset;
  bool get isFullscreen;
  bool get isOrientationLocked;
  bool get isClosingConfirmationEnabled;
  bool get isVerticalSwipesEnabled;
  String get headerColor;
  String get backgroundColor;
  String get bottomBarColor;

  void setHeaderColor(HeaderColor color);
  void setBackgroundColor(BarColor color);
  void setBottomBarColor(BarColor color);
  void enableClosingConfirmation();
  void disableClosingConfirmation();
  void enableVerticalSwipes();
  void disableVerticalSwipes();
  void requestFullscreen();
  void exitFullscreen();
  void lockOrientation();
  void unlockOrientation();

  // ---------------------------------------------------------------------------
  // Lifecycle

  /// Tell Telegram the app is ready to be displayed. Call as early as
  /// possible; until then the user sees a loading placeholder.
  void ready();
  void expand();
  void close({bool returnBack = false});
  void hideKeyboard();

  // ---------------------------------------------------------------------------
  // Sub-objects

  TmaEvents get events;
  BackButton get backButton;
  BottomButton get mainButton;
  BottomButton get secondaryButton;
  SettingsButton get settingsButton;
  HapticFeedback get hapticFeedback;
  CloudStorage get cloudStorage;
  DeviceStorage get deviceStorage;
  SecureStorage get secureStorage;
  BiometricManager get biometricManager;
  LocationManager get locationManager;
  MotionSensor get accelerometer;
  MotionSensor get gyroscope;
  DeviceOrientation get deviceOrientation;

  // ---------------------------------------------------------------------------
  // Actions

  /// Sends data to the bot (keyboard-button Mini Apps only) and closes the
  /// app. Up to 4096 bytes.
  void sendData(String data);
  void switchInlineQuery(String query, {List<ChooseChatType>? chooseChatTypes});
  void openLink(
    String url, {
    bool tryInstantView = false,
    OpenLinkBrowser? tryBrowser,
  });
  void openTelegramLink(String url, {bool forceRequest = false});
  Future<InvoiceStatus> openInvoice(String url);
  void shareToStory(String mediaUrl, [StoryShareParams? params]);
  Future<bool> shareMessage(String preparedMessageId);
  Future<bool> setEmojiStatus(
    String customEmojiId, [
    EmojiStatusParams params = const EmojiStatusParams(),
  ]);
  Future<bool> requestEmojiStatusAccess();
  Future<bool> downloadFile(DownloadFileParams params);
  void addToHomeScreen();
  Future<HomeScreenStatus> checkHomeScreenStatus();

  /// Resolves with the id of the pressed button, `null` if dismissed.
  Future<String?> showPopup(PopupParams params);
  Future<void> showAlert(String message);
  Future<bool> showConfirm(String message);

  /// Opens the QR scanner and resolves with the first scanned text, closing
  /// the popup. Resolves `null` if the user closed the popup.
  Future<String?> scanQr({String? text});
  void closeScanQrPopup();
  Future<String?> readTextFromClipboard();
  Future<bool> requestWriteAccess();
  Future<ContactRequestResult> requestContact();

  /// Bot API 9.6+. Opens a dialog to pick or create a chat. [requestId] is
  /// the `id` of a `PreparedKeyboardButton` obtained from the Bot API method
  /// `savePreparedKeyboardButton`. Resolves `true` if the button was sent.
  Future<bool> requestChat(String requestId);
}
