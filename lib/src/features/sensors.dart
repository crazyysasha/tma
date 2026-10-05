import '../models/params.dart';

/// `Telegram.WebApp.Accelerometer` / `Telegram.WebApp.Gyroscope`
/// (Bot API 8.0+).
abstract class MotionSensor {
  const MotionSensor();

  bool get isStarted;

  /// Last reading. Accelerometer: m/s². Gyroscope: rad/s.
  Vector3 get value;

  /// Emits a reading every `refreshRate`.
  Stream<Vector3> get onChanged;

  /// Emits an error code (for example `UNSUPPORTED`) if tracking failed.
  Stream<String> get onFailed;

  /// Resolves `true` if tracking started.
  Future<bool> start([SensorParams params = const SensorParams()]);
  Future<bool> stop();
}

/// `Telegram.WebApp.DeviceOrientation` (Bot API 8.0+).
abstract class DeviceOrientation {
  const DeviceOrientation();

  bool get isStarted;
  OrientationData get value;
  Stream<OrientationData> get onChanged;
  Stream<String> get onFailed;
  Future<bool> start(
      [DeviceOrientationParams params = const DeviceOrientationParams()]);
  Future<bool> stop();
}
