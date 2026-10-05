import 'environment.dart';
import 'tma.dart';
import 'tma_unavailable.dart';

/// Non-web targets have no JavaScript runtime and therefore no Telegram.
Tma createTma() => const TmaUnavailable(
      environment: TmaEnvironment.native,
      reason: TmaUnavailableReason.nativePlatform,
    );
