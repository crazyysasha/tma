import 'dart:ui' show Color;

/// Telegram theme colors (`ThemeParams`). Every field is optional because
/// older clients send only a subset.
final class ThemeParams {
  const ThemeParams({
    this.bgColor,
    this.textColor,
    this.hintColor,
    this.linkColor,
    this.buttonColor,
    this.buttonTextColor,
    this.secondaryBgColor,
    this.headerBgColor,
    this.bottomBarBgColor,
    this.accentTextColor,
    this.sectionBgColor,
    this.sectionHeaderTextColor,
    this.sectionSeparatorColor,
    this.subtitleTextColor,
    this.destructiveTextColor,
  });

  factory ThemeParams.fromJson(Map<String, Object?> json) {
    Color? c(String key) => parseHexColor(json[key]?.toString());
    return ThemeParams(
      bgColor: c('bg_color'),
      textColor: c('text_color'),
      hintColor: c('hint_color'),
      linkColor: c('link_color'),
      buttonColor: c('button_color'),
      buttonTextColor: c('button_text_color'),
      secondaryBgColor: c('secondary_bg_color'),
      headerBgColor: c('header_bg_color'),
      bottomBarBgColor: c('bottom_bar_bg_color'),
      accentTextColor: c('accent_text_color'),
      sectionBgColor: c('section_bg_color'),
      sectionHeaderTextColor: c('section_header_text_color'),
      sectionSeparatorColor: c('section_separator_color'),
      subtitleTextColor: c('subtitle_text_color'),
      destructiveTextColor: c('destructive_text_color'),
    );
  }

  static const empty = ThemeParams();

  final Color? bgColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? linkColor;
  final Color? buttonColor;
  final Color? buttonTextColor;
  final Color? secondaryBgColor;
  final Color? headerBgColor;
  final Color? bottomBarBgColor;
  final Color? accentTextColor;
  final Color? sectionBgColor;
  final Color? sectionHeaderTextColor;
  final Color? sectionSeparatorColor;
  final Color? subtitleTextColor;
  final Color? destructiveTextColor;

  /// Parses `#RRGGBB` or `#RGB` into a fully opaque [Color].
  static Color? parseHexColor(String? hex) {
    if (hex == null) return null;
    var h = hex.trim();
    if (h.startsWith('#')) h = h.substring(1);
    if (h.length == 3) h = h.split('').map((ch) => '$ch$ch').join();
    if (h.length != 6) return null;
    final value = int.tryParse(h, radix: 16);
    return value == null ? null : Color(0xFF000000 | value);
  }

  /// Formats a color as `#rrggbb`, the form Telegram accepts.
  static String toHex(Color color) {
    int ch(double v) => (v * 255).round() & 0xff;
    final rgb = (ch(color.r) << 16) | (ch(color.g) << 8) | ch(color.b);
    return '#${rgb.toRadixString(16).padLeft(6, '0')}';
  }

  Map<String, String> toJson() => {
        if (bgColor != null) 'bg_color': toHex(bgColor!),
        if (textColor != null) 'text_color': toHex(textColor!),
        if (hintColor != null) 'hint_color': toHex(hintColor!),
        if (linkColor != null) 'link_color': toHex(linkColor!),
        if (buttonColor != null) 'button_color': toHex(buttonColor!),
        if (buttonTextColor != null) 'button_text_color': toHex(buttonTextColor!),
        if (secondaryBgColor != null)
          'secondary_bg_color': toHex(secondaryBgColor!),
        if (headerBgColor != null) 'header_bg_color': toHex(headerBgColor!),
        if (bottomBarBgColor != null)
          'bottom_bar_bg_color': toHex(bottomBarBgColor!),
        if (accentTextColor != null) 'accent_text_color': toHex(accentTextColor!),
        if (sectionBgColor != null) 'section_bg_color': toHex(sectionBgColor!),
        if (sectionHeaderTextColor != null)
          'section_header_text_color': toHex(sectionHeaderTextColor!),
        if (sectionSeparatorColor != null)
          'section_separator_color': toHex(sectionSeparatorColor!),
        if (subtitleTextColor != null)
          'subtitle_text_color': toHex(subtitleTextColor!),
        if (destructiveTextColor != null)
          'destructive_text_color': toHex(destructiveTextColor!),
      };

  @override
  bool operator ==(Object other) =>
      other is ThemeParams && other.toJson().toString() == toJson().toString();

  @override
  int get hashCode => toJson().toString().hashCode;

  @override
  String toString() => 'ThemeParams(${toJson()})';
}
