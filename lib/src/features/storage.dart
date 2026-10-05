/// `Telegram.WebApp.CloudStorage` (Bot API 6.9+). Up to 1024 keys per user,
/// keys 1-128 chars `[A-Za-z0-9_-]`, values 0-4096 chars.
abstract class CloudStorage {
  const CloudStorage();
  Future<void> setItem(String key, String value);
  Future<String?> getItem(String key);
  Future<Map<String, String>> getItems(List<String> keys);
  Future<void> removeItem(String key);
  Future<void> removeItems(List<String> keys);
  Future<List<String>> getKeys();
}

/// `Telegram.WebApp.DeviceStorage` (Bot API 9.0+). Persistent local storage
/// on the device, up to 5 MB per bot.
abstract class DeviceStorage {
  const DeviceStorage();
  Future<void> setItem(String key, String value);
  Future<String?> getItem(String key);
  Future<void> removeItem(String key);
  Future<void> clear();
}

/// Value returned by [SecureStorage.getItem].
final class SecureStorageItem {
  const SecureStorageItem({required this.value, required this.canRestore});

  /// `null` if the key is missing on this device.
  final String? value;

  /// `true` if the value exists on another device of the same user and can
  /// be fetched with [SecureStorage.restoreItem].
  final bool canRestore;
}

/// `Telegram.WebApp.SecureStorage` (Bot API 9.0+). Encrypted local storage
/// backed by the device keychain, up to 10 keys.
abstract class SecureStorage {
  const SecureStorage();
  Future<void> setItem(String key, String value);
  Future<SecureStorageItem> getItem(String key);

  /// Asks the user to restore a value stored on another device.
  Future<String?> restoreItem(String key);
  Future<void> removeItem(String key);
  Future<void> clear();
}
