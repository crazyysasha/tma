import 'models/events.dart';
import 'models/params.dart';

/// Produces the stream for one `Telegram.WebApp` event type. [decode] turns
/// the event payload (an empty map when Telegram sends none) into a value.
typedef TmaEventSource =
    Stream<T> Function<T>(
      String type,
      T Function(Map<String, Object?> payload) decode,
    );

/// Broadcast streams for every `Telegram.WebApp.onEvent` event type.
///
/// The table of events lives only here; implementations differ only in the
/// [TmaEventSource] they pass in. On the web, subscribing attaches a
/// JavaScript listener and cancelling the last subscription detaches it.
/// Outside Telegram ([TmaEvents.none]) all streams are empty.
///
/// A custom source is handy in tests:
///
/// ```dart
/// final controller = StreamController<Map<String, Object?>>.broadcast();
/// final events = TmaEvents(
///   <T>(type, decode) => controller.stream.map(decode),
/// );
/// ```
final class TmaEvents {
  TmaEvents(this._source);

  /// Events of an app that is not running inside Telegram: every stream is
  /// empty and completes immediately.
  static final TmaEvents none = TmaEvents(
    <T>(_, _) => const Stream<Never>.empty(),
  );

  final TmaEventSource _source;

  Stream<void> _signal(String type) => _source<void>(type, _ignore);

  Stream<FailedEvent> _failed(String type) =>
      _source(type, FailedEvent.fromPayload);

  static void _ignore(Map<String, Object?> _) {}

  late final Stream<void> activated = _signal('activated');
  late final Stream<void> deactivated = _signal('deactivated');
  late final Stream<void> themeChanged = _signal('themeChanged');
  late final Stream<ViewportChangedEvent> viewportChanged = _source(
    'viewportChanged',
    (p) => ViewportChangedEvent(isStateStable: p['isStateStable'] == true),
  );
  late final Stream<void> safeAreaChanged = _signal('safeAreaChanged');
  late final Stream<void> contentSafeAreaChanged = _signal(
    'contentSafeAreaChanged',
  );
  late final Stream<void> mainButtonClicked = _signal('mainButtonClicked');
  late final Stream<void> secondaryButtonClicked = _signal(
    'secondaryButtonClicked',
  );
  late final Stream<void> backButtonClicked = _signal('backButtonClicked');
  late final Stream<void> settingsButtonClicked = _signal(
    'settingsButtonClicked',
  );
  late final Stream<InvoiceClosedEvent> invoiceClosed = _source(
    'invoiceClosed',
    (p) => InvoiceClosedEvent(
      url: p['url']?.toString() ?? '',
      status: InvoiceStatus.fromRaw(p['status']?.toString()),
    ),
  );
  late final Stream<PopupClosedEvent> popupClosed = _source(
    'popupClosed',
    (p) => PopupClosedEvent(buttonId: p['button_id']?.toString()),
  );
  late final Stream<QrTextReceivedEvent> qrTextReceived = _source(
    'qrTextReceived',
    (p) => QrTextReceivedEvent(data: p['data']?.toString() ?? ''),
  );
  late final Stream<void> scanQrPopupClosed = _signal('scanQrPopupClosed');
  late final Stream<ClipboardTextReceivedEvent> clipboardTextReceived = _source(
    'clipboardTextReceived',
    (p) => ClipboardTextReceivedEvent(data: p['data']?.toString()),
  );
  late final Stream<WriteAccessRequestedEvent> writeAccessRequested = _source(
    'writeAccessRequested',
    (p) => WriteAccessRequestedEvent(allowed: p['status'] == 'allowed'),
  );
  late final Stream<void> contactRequested = _signal('contactRequested');
  late final Stream<void> fullscreenChanged = _signal('fullscreenChanged');
  late final Stream<FailedEvent> fullscreenFailed = _failed('fullscreenFailed');
  late final Stream<void> homeScreenAdded = _signal('homeScreenAdded');
  late final Stream<HomeScreenCheckedEvent> homeScreenChecked = _source(
    'homeScreenChecked',
    (p) => HomeScreenCheckedEvent(
      status: HomeScreenStatus.fromRaw(p['status']?.toString()),
    ),
  );
  late final Stream<void> emojiStatusSet = _signal('emojiStatusSet');
  late final Stream<FailedEvent> emojiStatusFailed = _failed(
    'emojiStatusFailed',
  );
  late final Stream<void> emojiStatusAccessRequested = _signal(
    'emojiStatusAccessRequested',
  );
  late final Stream<void> shareMessageSent = _signal('shareMessageSent');
  late final Stream<FailedEvent> shareMessageFailed = _failed(
    'shareMessageFailed',
  );
  late final Stream<FileDownloadRequestedEvent> fileDownloadRequested = _source(
    'fileDownloadRequested',
    (p) => FileDownloadRequestedEvent(accepted: p['status'] == 'downloading'),
  );
  late final Stream<void> locationManagerUpdated = _signal(
    'locationManagerUpdated',
  );
  late final Stream<void> locationRequested = _signal('locationRequested');
  late final Stream<void> biometricManagerUpdated = _signal(
    'biometricManagerUpdated',
  );
  late final Stream<BiometricAuthRequestedEvent> biometricAuthRequested =
      _source(
        'biometricAuthRequested',
        (p) => BiometricAuthRequestedEvent(
          isAuthenticated: p['isAuthenticated'] == true,
          token: p['biometricToken']?.toString(),
        ),
      );
  late final Stream<BiometricTokenUpdatedEvent> biometricTokenUpdated = _source(
    'biometricTokenUpdated',
    (p) => BiometricTokenUpdatedEvent(isUpdated: p['isUpdated'] == true),
  );
  late final Stream<void> requestedChatSent = _signal('requestedChatSent');
  late final Stream<FailedEvent> requestedChatFailed = _failed(
    'requestedChatFailed',
  );

  /// Raw access to any event type, including ones added to Telegram after
  /// this package was released.
  Stream<T> custom<T>(
    String type,
    T Function(Map<String, Object?> payload) decode,
  ) => _source(type, decode);
}
