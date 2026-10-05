import 'models/events.dart';

/// Broadcast streams for every `Telegram.WebApp.onEvent` event type.
///
/// Subscribing attaches a JavaScript listener, cancelling the last
/// subscription detaches it. Outside Telegram all streams are empty.
abstract class TmaEvents {
  const TmaEvents();

  Stream<void> get activated;
  Stream<void> get deactivated;
  Stream<void> get themeChanged;
  Stream<ViewportChangedEvent> get viewportChanged;
  Stream<void> get safeAreaChanged;
  Stream<void> get contentSafeAreaChanged;
  Stream<void> get mainButtonClicked;
  Stream<void> get secondaryButtonClicked;
  Stream<void> get backButtonClicked;
  Stream<void> get settingsButtonClicked;
  Stream<InvoiceClosedEvent> get invoiceClosed;
  Stream<PopupClosedEvent> get popupClosed;
  Stream<QrTextReceivedEvent> get qrTextReceived;
  Stream<void> get scanQrPopupClosed;
  Stream<ClipboardTextReceivedEvent> get clipboardTextReceived;
  Stream<WriteAccessRequestedEvent> get writeAccessRequested;
  Stream<void> get contactRequested;
  Stream<void> get fullscreenChanged;
  Stream<FailedEvent> get fullscreenFailed;
  Stream<void> get homeScreenAdded;
  Stream<HomeScreenCheckedEvent> get homeScreenChecked;
  Stream<void> get emojiStatusSet;
  Stream<FailedEvent> get emojiStatusFailed;
  Stream<void> get emojiStatusAccessRequested;
  Stream<void> get shareMessageSent;
  Stream<FailedEvent> get shareMessageFailed;
  Stream<FileDownloadRequestedEvent> get fileDownloadRequested;
  Stream<void> get locationManagerUpdated;
  Stream<void> get locationRequested;
  Stream<void> get biometricManagerUpdated;
  Stream<BiometricAuthRequestedEvent> get biometricAuthRequested;
  Stream<BiometricTokenUpdatedEvent> get biometricTokenUpdated;
  Stream<void> get requestedChatSent;
  Stream<FailedEvent> get requestedChatFailed;
}
