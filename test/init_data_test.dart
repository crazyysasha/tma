import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tma/tma.dart';

String encode(Map<String, String> params) =>
    params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');

void main() {
  group('WebAppInitData.tryParse', () {
    test('returns null for empty string', () {
      expect(WebAppInitData.tryParse(''), isNull);
    });

    test('parses every documented field', () {
      final raw = encode({
        'query_id': 'AAHdF6IQAAAAAN0XohDhrOrc',
        'chat_join_request_query_id': 'JQ1',
        'user': jsonEncode({
          'id': 279058397,
          'first_name': 'Vladislav',
          'last_name': 'Kibenko',
          'username': 'vdkfrost',
          'language_code': 'ru',
          'is_premium': true,
          'allows_write_to_pm': true,
          'photo_url': 'https://t.me/i/userpic/320/x.jpg',
        }),
        'receiver': jsonEncode({'id': 1, 'first_name': 'R'}),
        'chat': jsonEncode({
          'id': -100123,
          'type': 'supergroup',
          'title': 'Dev chat',
          'username': 'devchat',
        }),
        'chat_type': 'supergroup',
        'chat_instance': '-3788475317572404878',
        'start_param': 'ref_abc',
        'can_send_after': '60',
        'auth_date': '1662771648',
        'signature': 'sig',
        'hash': 'c501b71e775f74ce10e377dea85a7ea24ecd640b223ea86dfe453e0eaed2e2b2',
      });

      final d = WebAppInitData.tryParse(raw)!;
      expect(d.raw, raw);
      expect(d.queryId, 'AAHdF6IQAAAAAN0XohDhrOrc');
      expect(d.chatJoinRequestQueryId, 'JQ1');
      expect(d.user!.id, 279058397);
      expect(d.user!.fullName, 'Vladislav Kibenko');
      expect(d.user!.isPremium, isTrue);
      expect(d.user!.photoUrl, 'https://t.me/i/userpic/320/x.jpg');
      expect(d.receiver!.firstName, 'R');
      expect(d.chat!.type, ChatType.supergroup);
      expect(d.chat!.title, 'Dev chat');
      expect(d.chatType, ChatType.supergroup);
      expect(d.chatInstance, '-3788475317572404878');
      expect(d.startParam, 'ref_abc');
      expect(d.canSendAfter, const Duration(seconds: 60));
      expect(d.authDate, DateTime.utc(2022, 9, 10, 1, 0, 48));
      expect(d.signature, 'sig');
      expect(d.hash, startsWith('c501b71e'));
    });

    test('survives & and = inside user name and JSON', () {
      final raw = encode({
        'user': jsonEncode({'id': 1, 'first_name': 'Tom & Jerry', 'last_name': 'a=b'}),
        'auth_date': '1',
        'hash': 'h',
      });
      final d = WebAppInitData.tryParse(raw)!;
      expect(d.user!.firstName, 'Tom & Jerry');
      expect(d.user!.lastName, 'a=b');
      expect(d.hash, 'h');
    });

    test('tolerates missing optional fields and garbage JSON', () {
      final d = WebAppInitData.tryParse('user=not-json&auth_date=5&hash=x')!;
      expect(d.user, isNull);
      expect(d.chatType, isNull);
      expect(d.authDate.millisecondsSinceEpoch, 5000);
    });

    test('isOlderThan compares against authDate', () {
      final d = WebAppInitData.tryParse('auth_date=1000&hash=x')!;
      final now = DateTime.fromMillisecondsSinceEpoch(1000 * 1000 + 3600 * 1000, isUtc: true);
      expect(d.isOlderThan(const Duration(minutes: 30), now: now), isTrue);
      expect(d.isOlderThan(const Duration(hours: 2), now: now), isFalse);
    });
  });

  group('ContactData.tryParse', () {
    test('parses contact payload', () {
      final raw = encode({
        'contact': jsonEncode({
          'user_id': 42,
          'phone_number': '+1000',
          'first_name': 'A',
          'last_name': 'B',
        }),
        'auth_date': '1700000000',
        'hash': 'abc',
      });
      final c = ContactData.tryParse(raw)!;
      expect(c.contact.userId, 42);
      expect(c.contact.phoneNumber, '+1000');
      expect(c.contact.lastName, 'B');
      expect(c.hash, 'abc');
      expect(c.raw, raw);
    });

    test('returns null without contact', () {
      expect(ContactData.tryParse('auth_date=1&hash=x'), isNull);
      expect(ContactData.tryParse(''), isNull);
    });
  });
}
