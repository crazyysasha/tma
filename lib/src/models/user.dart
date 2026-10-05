import 'json.dart';

/// A Telegram user as received in init data (`WebAppUser`).
final class WebAppUser {
  const WebAppUser({
    required this.id,
    required this.firstName,
    this.isBot,
    this.lastName,
    this.username,
    this.languageCode,
    this.isPremium,
    this.addedToAttachmentMenu,
    this.allowsWriteToPm,
    this.photoUrl,
  });

  factory WebAppUser.fromJson(Map<String, Object?> json) => WebAppUser(
    id: jsonInt(json['id']) ?? 0,
    isBot: jsonBool(json['is_bot']),
    firstName: jsonString(json['first_name']) ?? '',
    lastName: jsonString(json['last_name']),
    username: jsonString(json['username']),
    languageCode: jsonString(json['language_code']),
    isPremium: jsonBool(json['is_premium']),
    addedToAttachmentMenu: jsonBool(json['added_to_attachment_menu']),
    allowsWriteToPm: jsonBool(json['allows_write_to_pm']),
    photoUrl: jsonString(json['photo_url']),
  );

  final int id;
  final bool? isBot;
  final String firstName;
  final String? lastName;
  final String? username;
  final String? languageCode;
  final bool? isPremium;
  final bool? addedToAttachmentMenu;
  final bool? allowsWriteToPm;
  final String? photoUrl;

  String get fullName =>
      lastName == null || lastName!.isEmpty
          ? firstName
          : '$firstName $lastName';

  Map<String, Object?> toJson() => {
    'id': id,
    if (isBot != null) 'is_bot': isBot,
    'first_name': firstName,
    if (lastName != null) 'last_name': lastName,
    if (username != null) 'username': username,
    if (languageCode != null) 'language_code': languageCode,
    if (isPremium != null) 'is_premium': isPremium,
    if (addedToAttachmentMenu != null)
      'added_to_attachment_menu': addedToAttachmentMenu,
    if (allowsWriteToPm != null) 'allows_write_to_pm': allowsWriteToPm,
    if (photoUrl != null) 'photo_url': photoUrl,
  };

  @override
  bool operator ==(Object other) =>
      other is WebAppUser &&
      other.id == id &&
      other.isBot == isBot &&
      other.firstName == firstName &&
      other.lastName == lastName &&
      other.username == username &&
      other.languageCode == languageCode &&
      other.isPremium == isPremium &&
      other.addedToAttachmentMenu == addedToAttachmentMenu &&
      other.allowsWriteToPm == allowsWriteToPm &&
      other.photoUrl == photoUrl;

  @override
  int get hashCode => Object.hash(
    id,
    isBot,
    firstName,
    lastName,
    username,
    languageCode,
    isPremium,
    addedToAttachmentMenu,
    allowsWriteToPm,
    photoUrl,
  );

  @override
  String toString() => 'WebAppUser(${toJson()})';
}
