import '../models/location_data.dart';

/// `Telegram.WebApp.LocationManager` (Bot API 8.0+).
abstract class LocationManager {
  const LocationManager();

  bool get isInited;
  bool get isLocationAvailable;
  bool get isAccessRequested;
  bool get isAccessGranted;

  /// Emits whenever any of the properties above change.
  Stream<void> get onUpdated;

  /// Must be called once before [getLocation].
  Future<void> init();

  /// `null` when access was denied or location is unavailable.
  Future<LocationData?> getLocation();
  void openSettings();
}
