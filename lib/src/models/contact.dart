import 'dart:convert';

import 'json.dart';

/// Phone contact shared through `requestContact`.
final class TelegramContact {
  const TelegramContact({
    required this.userId,
    required this.phoneNumber,
    required this.firstName,
    this.lastName,
  });

  factory TelegramContact.fromJson(Map<String, Object?> json) =>
      TelegramContact(
        userId: jsonInt(json['user_id']) ?? 0,
        phoneNumber: jsonString(json['phone_number']) ?? '',
        firstName: jsonString(json['first_name']) ?? '',
        lastName: jsonString(json['last_name']),
      );

  final int userId;
  final String phoneNumber;
  final String firstName;
  final String? lastName;

  @override
  bool operator ==(Object other) =>
      other is TelegramContact &&
      other.userId == userId &&
      other.phoneNumber == phoneNumber &&
      other.firstName == firstName &&
      other.lastName == lastName;

  @override
  int get hashCode => Object.hash(userId, phoneNumber, firstName, lastName);

  @override
  String toString() => 'TelegramContact(userId: $userId, phone: $phoneNumber)';
}

/// Parsed and signed contact payload. Like init data, [raw] is what the
/// backend must validate (same HMAC scheme, data-check-string built from
/// `contact` and `auth_date`).
final class ContactData {
  const ContactData({
    required this.raw,
    required this.contact,
    required this.authDate,
    required this.hash,
  });

  static ContactData? tryParse(String raw) {
    if (raw.isEmpty) return null;
    final Map<String, String> params;
    try {
      params = Uri.splitQueryString(raw);
    } on FormatException {
      return null;
    } on ArgumentError {
      // Malformed or truncated percent-encoding.
      return null;
    }
    final contactRaw = params['contact'];
    if (contactRaw == null) return null;
    Map<String, Object?>? contactJson;
    try {
      contactJson = jsonMap(jsonDecode(contactRaw));
    } on FormatException {
      return null;
    }
    if (contactJson == null) return null;
    final authDate = jsonInt(params['auth_date']) ?? 0;
    return ContactData(
      raw: raw,
      contact: TelegramContact.fromJson(contactJson),
      authDate: DateTime.fromMillisecondsSinceEpoch(
        authDate * 1000,
        isUtc: true,
      ),
      hash: params['hash'] ?? '',
    );
  }

  final String raw;
  final TelegramContact contact;
  final DateTime authDate;
  final String hash;

  @override
  String toString() => 'ContactData($contact, authDate: $authDate)';
}

enum ContactRequestStatus { sent, cancelled, unknown }

/// Outcome of `requestContact`.
final class ContactRequestResult {
  const ContactRequestResult({required this.status, this.data});

  const ContactRequestResult.cancelled()
    : status = ContactRequestStatus.cancelled,
      data = null;

  final ContactRequestStatus status;

  /// Present only when [status] is [ContactRequestStatus.sent] and the
  /// client managed to fetch the contact in time (the official SDK waits up
  /// to 3 seconds).
  final ContactData? data;

  bool get isSent => status == ContactRequestStatus.sent;

  @override
  String toString() => 'ContactRequestResult($status, $data)';
}
