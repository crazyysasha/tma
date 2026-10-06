@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tma/tma.dart';

void main() {
  // Tests run on the Dart VM, so the stub factory is used.
  tearDown(() => Tma.debugOverride(null));

  test('Tma.instance on the VM is unavailable with nativePlatform reason', () {
    final tma = Tma.instance;
    expect(tma.isAvailable, isFalse);
    expect(tma.environment, TmaEnvironment.native);
    expect(tma.unavailableReason, TmaUnavailableReason.nativePlatform);
    expect(identical(tma, Tma.instance), isTrue, reason: 'singleton');
  });

  test('properties return neutral values, never fake data', () {
    final tma = Tma.instance;
    expect(tma.initData, isNull);
    expect(tma.initDataRaw, '');
    expect(tma.version, TmaVersion.zero);
    expect(tma.platform, TmaClientPlatform.unknown);
    expect(tma.themeParams, ThemeParams.empty);
    expect(tma.safeAreaInset, SafeAreaInset.zero);
    expect(tma.isVersionAtLeast(const TmaVersion(6, 0)), isFalse);
    expect(tma.backButton.isVisible, isFalse);
    expect(tma.mainButton.text, '');
  });

  test('fire-and-forget methods are silent no-ops', () {
    final tma = Tma.instance;
    expect(() {
      tma.ready();
      tma.expand();
      tma.requestFullscreen();
      tma.backButton.show();
      tma.mainButton.setText('x');
      tma.hapticFeedback.impactOccurred(HapticImpactStyle.light);
      tma.openLink('https://example.com');
    }, returnsNormally);
  });

  test('permission requests resolve to false / cancelled', () async {
    final tma = Tma.instance;
    expect(await tma.requestWriteAccess(), isFalse);
    expect(await tma.shareMessage('id'), isFalse);
    expect((await tma.requestContact()).isSent, isFalse);
    expect(await tma.locationManager.getLocation(), isNull);
    expect(await tma.checkHomeScreenStatus(), HomeScreenStatus.unsupported);
  });

  test('data-returning methods throw TmaUnavailableException', () {
    final tma = Tma.instance;
    expect(
      tma.openInvoice('https://t.me/\$x'),
      throwsA(isA<TmaUnavailableException>()),
    );
    expect(
      tma.showPopup(const PopupParams(message: 'm')),
      throwsA(isA<TmaUnavailableException>()),
    );
    expect(tma.showConfirm('m'), throwsA(isA<TmaUnavailableException>()));
    expect(tma.scanQr(), throwsA(isA<TmaUnavailableException>()));
    expect(
      tma.cloudStorage.getItem('k'),
      throwsA(isA<TmaUnavailableException>()),
    );
  });

  test('event streams are empty and complete immediately', () async {
    final tma = Tma.instance;
    expect(await tma.events.themeChanged.isEmpty, isTrue);
    expect(await tma.backButton.onClick.isEmpty, isTrue);
    final cancel = tma.backButton.addListener(() {});
    expect(cancel, returnsNormally);
  });

  test('debugOverride replaces the instance', () {
    const fake = TmaUnavailable(
      environment: TmaEnvironment.browser,
      reason: TmaUnavailableReason.scriptMissing,
    );
    Tma.debugOverride(fake);
    expect(Tma.instance.unavailableReason, TmaUnavailableReason.scriptMissing);
    Tma.debugOverride(null);
    expect(Tma.instance.environment, TmaEnvironment.native);
  });
}
