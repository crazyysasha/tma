import 'package:flutter/painting.dart' show EdgeInsets;

import 'json.dart';

/// Insets reported by `safeAreaInset` / `contentSafeAreaInset` (CSS pixels).
final class SafeAreaInset {
  const SafeAreaInset({
    this.top = 0,
    this.bottom = 0,
    this.left = 0,
    this.right = 0,
  });

  factory SafeAreaInset.fromJson(Map<String, Object?> json) => SafeAreaInset(
    top: jsonDouble(json['top']) ?? 0,
    bottom: jsonDouble(json['bottom']) ?? 0,
    left: jsonDouble(json['left']) ?? 0,
    right: jsonDouble(json['right']) ?? 0,
  );

  static const zero = SafeAreaInset();

  final double top;
  final double bottom;
  final double left;
  final double right;

  EdgeInsets toEdgeInsets() =>
      EdgeInsets.only(top: top, bottom: bottom, left: left, right: right);

  SafeAreaInset operator +(SafeAreaInset other) => SafeAreaInset(
    top: top + other.top,
    bottom: bottom + other.bottom,
    left: left + other.left,
    right: right + other.right,
  );

  @override
  bool operator ==(Object other) =>
      other is SafeAreaInset &&
      other.top == top &&
      other.bottom == bottom &&
      other.left == left &&
      other.right == right;

  @override
  int get hashCode => Object.hash(top, bottom, left, right);

  @override
  String toString() =>
      'SafeAreaInset(top: $top, bottom: $bottom, left: $left, right: $right)';
}
