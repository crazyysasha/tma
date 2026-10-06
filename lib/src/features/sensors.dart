import '../models/params.dart';

/// A device sensor exposed by Telegram (Bot API 8.0+): [MotionSensor] for
/// `Accelerometer` / `Gyroscope`, [DeviceOrientation] for
/// `DeviceOrientation`.
abstract class Sensor<V, P extends SensorParams> {
  const Sensor();

  bool get isStarted;

  /// Last reading. Accelerometer: m/s². Gyroscope: rad/s. Orientation:
  /// radians.
  V get value;

  /// Emits a reading every `refreshRate` while started.
  Stream<V> get onChanged;

  /// Emits an error code (for example `UNSUPPORTED`) if tracking failed.
  Stream<String> get onFailed;

  /// Resolves `true` if tracking started. [params] defaults to a 1 s
  /// refresh rate.
  Future<bool> start([P? params]);
  Future<bool> stop();
}

/// `Telegram.WebApp.Accelerometer` / `Telegram.WebApp.Gyroscope`.
typedef MotionSensor = Sensor<Vector3, SensorParams>;

/// `Telegram.WebApp.DeviceOrientation`.
typedef DeviceOrientation = Sensor<OrientationData, DeviceOrientationParams>;
