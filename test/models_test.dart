import 'dart:ui';

import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:flutter_test/flutter_test.dart';
import 'package:tma/tma.dart';

void main() {
  group('TmaVersion', () {
    test('parses and compares like the official SDK', () {
      expect(TmaVersion.parse('8.0'), const TmaVersion(8, 0));
      expect(TmaVersion.parse(' 9.6 '), const TmaVersion(9, 6));
      expect(TmaVersion.parse('7'), const TmaVersion(7, 0));
      expect(TmaVersion.parse('garbage'), TmaVersion.zero);
      expect(TmaVersion.parse('7.10') > TmaVersion.parse('7.9'), isTrue);
      expect(TmaVersion.parse('10.1') >= TmaVersion.parse('9.6'), isTrue);
      expect(TmaVersion.parse('6.9') < TmaVersion.parse('7.0'), isTrue);
    });
  });

  group('TmaClientPlatform', () {
    test('classifies known platforms and keeps raw value', () {
      expect(TmaClientPlatform.fromRaw('ios').isMobile, isTrue);
      expect(
        TmaClientPlatform.fromRaw('android_x').kind,
        TmaClientPlatformKind.androidX,
      );
      expect(TmaClientPlatform.fromRaw('tdesktop').isDesktop, isTrue);
      expect(TmaClientPlatform.fromRaw('weba').isWeb, isTrue);
      final future = TmaClientPlatform.fromRaw('visionos');
      expect(future.kind, TmaClientPlatformKind.other);
      expect(future.raw, 'visionos');
    });
  });

  group('ThemeParams', () {
    test('parses hex colors and round-trips', () {
      final t = ThemeParams.fromJson({
        'bg_color': '#ffffff',
        'text_color': '#000',
        'link_color': 'nope',
      });
      expect(t.bgColor, const Color(0xFFFFFFFF));
      expect(t.textColor, const Color(0xFF000000));
      expect(t.linkColor, isNull);
      expect(ThemeParams.toHex(const Color(0xFF1A2B3C)), '#1a2b3c');
    });
  });

  group('params toJson', () {
    test('PopupParams maps button types to SDK names', () {
      const p = PopupParams(
        message: 'Hi',
        title: 'T',
        buttons: [
          PopupButton(id: 'a', text: 'A'),
          PopupButton(id: 'b', type: PopupButtonType.destructive, text: 'B'),
          PopupButton(type: PopupButtonType.cancel),
        ],
      );
      expect(p.toJson(), {
        'message': 'Hi',
        'title': 'T',
        'buttons': [
          {'id': 'a', 'type': 'default', 'text': 'A'},
          {'id': 'b', 'type': 'destructive', 'text': 'B'},
          {'type': 'cancel'},
        ],
      });
    });

    test('StoryShareParams uses snake_case keys', () {
      const p = StoryShareParams(
        text: 'cap',
        widgetLink: StoryWidgetLink(url: 'https://x', name: 'X'),
      );
      expect(p.toJson(), {
        'text': 'cap',
        'widget_link': {'url': 'https://x', 'name': 'X'},
      });
    });

    test('BottomButtonParams encodes colors as hex', () {
      const p = BottomButtonParams(
        text: 'Go',
        color: Color(0xFF00FF00),
        position: SecondaryButtonPosition.top,
        hasShineEffect: true,
      );
      expect(p.toJson(), {
        'text': 'Go',
        'color': '#00ff00',
        'has_shine_effect': true,
        'position': 'top',
      });
    });

    test('HeaderColor and BarColor produce SDK values', () {
      expect(const HeaderColor.bg().toJs(), 'bg_color');
      expect(const HeaderColor.secondaryBg().toJs(), 'secondary_bg_color');
      expect(const HeaderColor.custom(Color(0xFF123456)).toJs(), '#123456');
      expect(const BarColor.bottomBarBg().toJs(), 'bottom_bar_bg_color');
    });

    test('enums decode unknown values safely', () {
      expect(InvoiceStatus.fromRaw('paid'), InvoiceStatus.paid);
      expect(InvoiceStatus.fromRaw('pending'), InvoiceStatus.pending);
      expect(InvoiceStatus.fromRaw('???'), InvoiceStatus.unknown);
      expect(HomeScreenStatus.fromRaw(null), HomeScreenStatus.unknown);
      expect(ChatType.fromRaw('sender'), ChatType.sender);
      expect(BiometricType.fromRaw('face'), BiometricType.face);
    });
  });

  group('SafeAreaInset', () {
    test('converts to EdgeInsets and adds', () {
      const a = SafeAreaInset(top: 10, bottom: 5);
      const b = SafeAreaInset(left: 1, right: 2);
      expect(
        (a + b).toEdgeInsets(),
        const EdgeInsets.only(top: 10, bottom: 5, left: 1, right: 2),
      );
      expect(
        SafeAreaInset.fromJson({'top': 44, 'bottom': '34'}),
        const SafeAreaInset(top: 44, bottom: 34),
      );
    });
  });
}
