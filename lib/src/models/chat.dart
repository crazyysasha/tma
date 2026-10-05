import 'json.dart';

/// Type of the chat a Mini App was launched from.
enum ChatType {
  sender,
  private,
  group,
  supergroup,
  channel,
  unknown;

  static ChatType fromRaw(String? raw) => switch (raw) {
    'sender' => sender,
    'private' => private,
    'group' => group,
    'supergroup' => supergroup,
    'channel' => channel,
    _ => unknown,
  };
}

/// A chat as received in init data (`WebAppChat`).
final class WebAppChat {
  const WebAppChat({
    required this.id,
    required this.type,
    required this.title,
    this.username,
    this.photoUrl,
  });

  factory WebAppChat.fromJson(Map<String, Object?> json) => WebAppChat(
    id: jsonInt(json['id']) ?? 0,
    type: ChatType.fromRaw(jsonString(json['type'])),
    title: jsonString(json['title']) ?? '',
    username: jsonString(json['username']),
    photoUrl: jsonString(json['photo_url']),
  );

  final int id;
  final ChatType type;
  final String title;
  final String? username;
  final String? photoUrl;

  Map<String, Object?> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    if (username != null) 'username': username,
    if (photoUrl != null) 'photo_url': photoUrl,
  };

  @override
  bool operator ==(Object other) =>
      other is WebAppChat &&
      other.id == id &&
      other.type == type &&
      other.title == title &&
      other.username == username &&
      other.photoUrl == photoUrl;

  @override
  int get hashCode => Object.hash(id, type, title, username, photoUrl);

  @override
  String toString() => 'WebAppChat(${toJson()})';
}
