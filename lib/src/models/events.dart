import 'params.dart';

/// Payload of `viewportChanged`.
final class ViewportChangedEvent {
  const ViewportChangedEvent({required this.isStateStable});

  /// `true` once the resize animation finished and `viewportStableHeight`
  /// is final.
  final bool isStateStable;
}

/// Payload of `invoiceClosed`.
final class InvoiceClosedEvent {
  const InvoiceClosedEvent({required this.url, required this.status});
  final String url;
  final InvoiceStatus status;
}

/// Payload of `popupClosed`.
final class PopupClosedEvent {
  const PopupClosedEvent({this.buttonId});

  /// Id of the pressed button, `null` if the popup was dismissed.
  final String? buttonId;
}

/// Payload of `qrTextReceived`.
final class QrTextReceivedEvent {
  const QrTextReceivedEvent({required this.data});
  final String data;
}

/// Payload of `clipboardTextReceived`.
final class ClipboardTextReceivedEvent {
  const ClipboardTextReceivedEvent({this.data});

  /// `null` if access was denied or the clipboard was empty.
  final String? data;
}

/// Payload of `writeAccessRequested`.
final class WriteAccessRequestedEvent {
  const WriteAccessRequestedEvent({required this.allowed});
  final bool allowed;
}

/// Payload of `homeScreenChecked`.
final class HomeScreenCheckedEvent {
  const HomeScreenCheckedEvent({required this.status});
  final HomeScreenStatus status;
}

/// Payload of any `*Failed` event carrying an `error` string.
final class FailedEvent {
  const FailedEvent({required this.error});

  /// Reads the `error` field, `UNKNOWN` when Telegram sent none.
  factory FailedEvent.fromPayload(Map<String, Object?> payload) =>
      FailedEvent(error: payload['error']?.toString() ?? 'UNKNOWN');

  final String error;
}

/// Payload of `biometricAuthRequested`.
final class BiometricAuthRequestedEvent {
  const BiometricAuthRequestedEvent({
    required this.isAuthenticated,
    this.token,
  });
  final bool isAuthenticated;
  final String? token;
}

/// Payload of `biometricTokenUpdated`.
final class BiometricTokenUpdatedEvent {
  const BiometricTokenUpdatedEvent({required this.isUpdated});
  final bool isUpdated;
}

/// Payload of `fileDownloadRequested`.
final class FileDownloadRequestedEvent {
  const FileDownloadRequestedEvent({required this.accepted});
  final bool accepted;
}
