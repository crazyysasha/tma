import '../models/params.dart';

/// `Telegram.WebApp.BiometricManager` (Bot API 7.2+).
abstract class BiometricManager {
  const BiometricManager();

  bool get isInited;
  bool get isBiometricAvailable;
  BiometricType get biometricType;
  bool get isAccessRequested;
  bool get isAccessGranted;
  bool get isBiometricTokenSaved;
  String get deviceId;

  /// Emits whenever any of the properties above change.
  Stream<void> get onUpdated;

  /// Must be called once before any other method.
  Future<void> init();
  Future<bool> requestAccess([BiometricParams params = const BiometricParams()]);
  Future<BiometricAuthResult> authenticate(
      [BiometricParams params = const BiometricParams()]);

  /// Pass an empty string to remove the token.
  Future<bool> updateBiometricToken(String token);
  void openSettings();
}
