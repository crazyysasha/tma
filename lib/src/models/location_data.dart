import 'json.dart';

/// Result of `LocationManager.getLocation`.
final class LocationData {
  const LocationData({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.course,
    this.speed,
    this.horizontalAccuracy,
    this.verticalAccuracy,
    this.courseAccuracy,
    this.speedAccuracy,
  });

  factory LocationData.fromJson(Map<String, Object?> json) => LocationData(
    latitude: jsonDouble(json['latitude']) ?? 0,
    longitude: jsonDouble(json['longitude']) ?? 0,
    altitude: jsonDouble(json['altitude']),
    course: jsonDouble(json['course']),
    speed: jsonDouble(json['speed']),
    horizontalAccuracy: jsonDouble(json['horizontal_accuracy']),
    verticalAccuracy: jsonDouble(json['vertical_accuracy']),
    courseAccuracy: jsonDouble(json['course_accuracy']),
    speedAccuracy: jsonDouble(json['speed_accuracy']),
  );

  final double latitude;
  final double longitude;

  /// Meters above sea level.
  final double? altitude;

  /// Direction of movement in degrees, 0 = north.
  final double? course;

  /// Meters per second.
  final double? speed;
  final double? horizontalAccuracy;
  final double? verticalAccuracy;
  final double? courseAccuracy;
  final double? speedAccuracy;

  @override
  bool operator ==(Object other) =>
      other is LocationData &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.altitude == altitude &&
      other.course == course &&
      other.speed == speed &&
      other.horizontalAccuracy == horizontalAccuracy &&
      other.verticalAccuracy == verticalAccuracy &&
      other.courseAccuracy == courseAccuracy &&
      other.speedAccuracy == speedAccuracy;

  @override
  int get hashCode => Object.hash(
    latitude,
    longitude,
    altitude,
    course,
    speed,
    horizontalAccuracy,
    verticalAccuracy,
    courseAccuracy,
    speedAccuracy,
  );

  @override
  String toString() =>
      'LocationData(lat: $latitude, lng: $longitude, '
      'accuracy: $horizontalAccuracy)';
}
