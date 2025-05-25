import 'package:twa/src/models/safe_area_inset.dart';

import '../twa.dart';

abstract class TwaInterface {
  bool get isSupported;

  WebAppInitData get initData;

  WebAppInitDataUnsafe get initDataUnsafe;

  String get version;

  String get platform;

  SafeAreaInset get safeAreaInset;

  SafeAreaInset get contentSafeAreaInset;

  LocationManager get locationManager;

  Future<RequestContactResult> requestContact();

  Future<bool> requestWriteAccess();

  void disableVerticalSwipes();

  void requestFullscreen();

  void exitFullscreen();

  void ready();

  void close();

  Future<bool> shareMessage(String messageId);
}
