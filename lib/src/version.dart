/// A Bot API version such as `8.0` or `9.6`, comparable like the official
/// `isVersionAtLeast` helper in `telegram-web-app.js`.
final class TmaVersion implements Comparable<TmaVersion> {
  const TmaVersion(this.major, [this.minor = 0]);

  /// Parses `"8.0"`, `"9.6"`, `" 7 "`; invalid parts are treated as 0.
  factory TmaVersion.parse(String raw) {
    final parts = raw.trim().split('.');
    int at(int i) => i < parts.length ? (int.tryParse(parts[i]) ?? 0) : 0;
    return TmaVersion(at(0), at(1));
  }

  /// Version reported when Telegram is not available at all.
  static const zero = TmaVersion(0, 0);

  final int major;
  final int minor;

  bool operator >=(TmaVersion other) => compareTo(other) >= 0;
  bool operator >(TmaVersion other) => compareTo(other) > 0;
  bool operator <=(TmaVersion other) => compareTo(other) <= 0;
  bool operator <(TmaVersion other) => compareTo(other) < 0;

  @override
  int compareTo(TmaVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    return minor.compareTo(other.minor);
  }

  @override
  bool operator ==(Object other) =>
      other is TmaVersion && other.major == major && other.minor == minor;

  @override
  int get hashCode => Object.hash(major, minor);

  @override
  String toString() => '$major.$minor';
}
