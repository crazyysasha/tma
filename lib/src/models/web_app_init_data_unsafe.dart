part of '../../twa.dart';

final class WebAppInitDataUnsafe extends WebAppInitData {
  const WebAppInitDataUnsafe({
    required super.user,
    required super.chatInstance,
    required super.chatType,
    required super.authDate,
    required super.signature,
    required super.hash,
    required super.startParam,
  }) : super(raw: "");

  const WebAppInitDataUnsafe.fake({
    super.user = const WebAppUser.fake(),
    super.chatInstance = 'fake',
    super.chatType = 'fake',
    super.authDate = 0,
    super.signature = 'fake',
    super.hash = 'fake',
    super.startParam = 'fake',
  }) : super.fake(raw: "unsafe-fake");
}
