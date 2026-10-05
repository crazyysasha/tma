import '../models/params.dart';

/// `Telegram.WebApp.HapticFeedback` (Bot API 6.1+).
abstract class HapticFeedback {
  const HapticFeedback();
  void impactOccurred(HapticImpactStyle style);
  void notificationOccurred(HapticNotificationType type);
  void selectionChanged();
}
