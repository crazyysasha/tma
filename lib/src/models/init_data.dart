import 'dart:convert';

import 'chat.dart';
import 'json.dart';
import 'user.dart';

/// Parsed `Telegram.WebApp.initData`.
///
/// Nothing here is verified. Treat every field as untrusted user input until
/// your backend validates [raw] with the bot token (HMAC-SHA-256 over
/// the data-check-string, see
/// https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app)
/// or with Telegram's Ed25519 public key for third-party validation using
/// [signature]. Send [raw] to the server as-is; do not re-serialize it.
final class WebAppInitData {
  const WebAppInitData({
    required this.raw,
    required this.authDate,
    required this.hash,
    this.queryId,
    this.chatJoinRequestQueryId,
    this.user,
    this.receiver,
    this.chat,
    this.chatType,
    this.chatInstance,
    this.startParam,
    this.canSendAfter,
    this.signature,
  });

  /// Parses the query-string form Telegram puts into `initData`.
  ///
  /// Returns `null` for an empty string. Decoding happens per key/value pair
  /// (the same way the official SDK does it), so `&` or `=` inside a user
  /// name or JSON payload are handled correctly.
  static WebAppInitData? tryParse(String raw) {
    if (raw.isEmpty) return null;
    final Map<String, String> params;
    try {
      params = Uri.splitQueryString(raw);
    } on FormatException {
      return null;
    }

    Map<String, Object?>? object(String key) {
      final value = params[key];
      if (value == null) return null;
      try {
        return jsonMap(jsonDecode(value));
      } on FormatException {
        return null;
      }
    }

    final userJson = object('user');
    final receiverJson = object('receiver');
    final chatJson = object('chat');
    final authDateSeconds = jsonInt(params['auth_date']);
    final canSendAfterSeconds = jsonInt(params['can_send_after']);

    return WebAppInitData(
      raw: raw,
      queryId: params['query_id'],
      chatJoinRequestQueryId: params['chat_join_request_query_id'],
      user: userJson == null ? null : WebAppUser.fromJson(userJson),
      receiver: receiverJson == null ? null : WebAppUser.fromJson(receiverJson),
      chat: chatJson == null ? null : WebAppChat.fromJson(chatJson),
      chatType: params.containsKey('chat_type')
          ? ChatType.fromRaw(params['chat_type'])
          : null,
      chatInstance: params['chat_instance'],
      startParam: params['start_param'],
      canSendAfter: canSendAfterSeconds == null
          ? null
          : Duration(seconds: canSendAfterSeconds),
      authDate: authDateSeconds == null
          ? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)
          : DateTime.fromMillisecondsSinceEpoch(authDateSeconds * 1000,
              isUtc: true),
      hash: params['hash'] ?? '',
      signature: params['signature'],
    );
  }

  /// The exact string Telegram provided. Send this to your backend.
  final String raw;

  /// Unique identifier of the Mini App session, required for sending
  /// messages via `answerWebAppQuery`. Present only for apps launched from
  /// the attachment menu or inline mode.
  final String? queryId;

  /// Bot API 10.1+. Present when the app was launched from a chat join
  /// request.
  final String? chatJoinRequestQueryId;

  final WebAppUser? user;

  /// Chat partner of the current user when launched via attachment menu in a
  /// private chat with another user.
  final WebAppUser? receiver;

  /// The chat the app was launched from (group, supergroup or channel).
  final WebAppChat? chat;

  final ChatType? chatType;
  final String? chatInstance;
  final String? startParam;

  /// Time after which a message can be sent via `answerWebAppQuery`.
  final Duration? canSendAfter;

  /// When the form was opened. Use it to reject stale init data on the
  /// server.
  final DateTime authDate;

  /// HMAC hash for bot-side validation.
  final String hash;

  /// Bot API 8.0+. Ed25519 signature for third-party validation.
  final String? signature;

  /// Whether [authDate] is older than [maxAge]. This is a client-side
  /// convenience only; the real check belongs to the backend.
  bool isOlderThan(Duration maxAge, {DateTime? now}) =>
      (now ?? DateTime.now().toUtc()).difference(authDate) > maxAge;

  @override
  bool operator ==(Object other) => other is WebAppInitData && other.raw == raw;

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() => 'WebAppInitData(user: $user, chat: $chat, '
      'chatType: $chatType, startParam: $startParam, authDate: $authDate)';
}
