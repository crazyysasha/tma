part of '../../twa.dart';

enum ImpactStyle { light, medium, heavy, rigid, soft }

enum NotificationType { success, warning, error }

final class HapticFeedback {
  /// A method tells that an impact occurred. The Telegram app may play the
  /// appropriate haptics based on style value passed. Style can be one of
  /// these values:
  ///
  /// - light, indicates a collision between small or lightweight UI objects,
  /// - medium, indicates a collision between medium-sized or medium-weight
  /// UI objects,
  /// - heavy, indicates a collision between large or heavyweight UI objects,
  /// - rigid, indicates a collision between hard or inflexible UI objects,
  /// - soft, indicates a collision between soft or flexible UI objects.
  final Function(ImpactStyle style) impactOccurred;

  final Function(NotificationType type) notificationOccurred;

  final Function() selectionChanged;

  HapticFeedback({
    required this.impactOccurred,
    required this.notificationOccurred,
    required this.selectionChanged,
  });

  @override
  String toString() {
    return 'HapticFeedback(impactOccurred: $impactOccurred, '
        'notificationOccurred: $notificationOccurred, '
        'selectionChanged: $selectionChanged)';
  }
}
