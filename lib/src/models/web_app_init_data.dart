part of '../../twa.dart';

final class WebAppInitData extends Equatable {
  // The user object
  final WebAppUser? user;

  // The chat type
  final String? chatType;

  // The chat instance
  final String? chatInstance;

  // The auth date
  final int? authDate;

  // The hash
  final String? hash;

  // The signature
  final String? signature;

  // The raw init data string
  final String? raw;

  final String? startParam;

  const WebAppInitData({
    required this.user,
    required this.chatType,
    required this.chatInstance,
    required this.authDate,
    required this.hash,
    required this.signature,
    required this.raw,
    required this.startParam,
  });

  const WebAppInitData.fake({
    this.user = const WebAppUser.fake(),
    this.chatType = 'fake',
    this.chatInstance = 'fake',
    this.authDate = 0,
    this.hash = 'fake',
    this.signature = 'fake',
    this.raw = 'fake',
    this.startParam = 'fake',
  });

  static WebAppInitData fromRawString(String raw) {
    final String str = Uri.decodeQueryComponent(raw);

    final Map<String, dynamic> json = {};

    for (final String pair in str.split('&')) {
      final List<String> keyValue = pair.split('=');
      if (keyValue.length == 2) {
        json[keyValue[0]] = keyValue[1];
      }
    }

    return WebAppInitData(
      user: switch (json['user']) {
        String str => WebAppUser.fromJson(jsonDecode(str)),
        Map<String, dynamic> map => WebAppUser.fromJson(map),
        _ => null,
      },
      chatInstance: json['chat_instance'] as String?,
      chatType: json['chat_type'] as String?,
      authDate: int.tryParse(json['auth_date'].toString()),
      signature: json['signature'] as String?,
      hash: json['hash'] as String?,
      startParam: json['start_param'] as String?,
      raw: raw,
    );
  }

  @override
  List<String> get props => [
    "user: $user",
    "chatType: $chatType",
    "chatInstance: $chatInstance",
    "authDate: $authDate",
    "hash: $hash",
    "signature: $signature",
    "startParam: $startParam",
    "raw: $raw",
  ];
}
