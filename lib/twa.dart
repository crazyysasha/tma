import 'dart:convert';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:twa/src/models/safe_area_inset.dart';

import 'src/twa_interface.dart';

import 'src/twa_fake.dart' if (dart.library.js) 'src/twa_web.dart';

part 'src/models/web_app_init_data.dart';
part 'src/models/web_app_init_data_unsafe.dart';
part 'src/models/web_app_user.dart';
part 'src/models/web_app_chat.dart';
part 'src/models/telegram_contact.dart';
part 'src/models/request_contact_result.dart';
part 'src/models/request_contact_result_response.dart';
part 'src/models/request_contact_result_response_unsafe.dart';
part 'src/models/location_data.dart';

part 'src/services/location_manager.dart';
part 'src/services/haptic_feedback.dart';

final TwaInterface _platform = createTwa();

class Twa extends TwaInterface {
  Twa._();
  static final Twa instance = Twa._();

  @override
  bool get isSupported => _platform.isSupported;

  @override
  WebAppInitData get initData => _platform.initData;

  @override
  WebAppInitDataUnsafe get initDataUnsafe => _platform.initDataUnsafe;

  @override
  String get version => _platform.version;

  @override
  String get platform => _platform.platform;

  @override
  SafeAreaInset get safeAreaInset => _platform.safeAreaInset;

  @override
  SafeAreaInset get contentSafeAreaInset => _platform.contentSafeAreaInset;

  @override
  LocationManager get locationManager => _platform.locationManager;

  @override
  HapticFeedback get hapticFeedback => _platform.hapticFeedback;

  @override
  double get viewportHeight => _platform.viewportHeight;
  @override
  double get viewportStableHeight => _platform.viewportStableHeight;

  @override
  Future<RequestContactResult> requestContact() {
    return _platform.requestContact();
  }

  @override
  Future<bool> requestWriteAccess() {
    return _platform.requestWriteAccess();
  }

  @override
  void disableVerticalSwipes() {
    return _platform.disableVerticalSwipes();
  }

  @override
  void requestFullscreen() {
    return _platform.requestFullscreen();
  }

  @override
  void exitFullscreen() {
    return _platform.exitFullscreen();
  }

  @override
  void ready() => _platform.ready();

  @override
  void close() => _platform.close();

  @override
  Future<bool> shareMessage(String messageId) {
    return _platform.shareMessage(messageId);
  }

  @override
  void openLink(String url, {bool tryInstantView = false}) {
    return _platform.openLink(url, tryInstantView: tryInstantView);
  }

  @override
  void openTelegramLink(String url, {bool forceRequest = false}) {
    return _platform.openTelegramLink(url, forceRequest: forceRequest);
  }

  @override
  void showScanQrPopup(String text, [Function(String result)? test]) {
    return _platform.showScanQrPopup(text, test);
  }

  @override
  VoidCallback onViewportChanged(Function() callback) {
    return _platform.onViewportChanged(callback);
  }

  @override
  void closeScanQrPopup() {
    return _platform.closeScanQrPopup();
  }
}
