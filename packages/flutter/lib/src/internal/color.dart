/// The colour arithmetic the token sheet is written in.
///
/// The React package states every colour in `oklch()` and derives most of the
/// rest with `color-mix()`, so the Flutter tokens are computed the same way
/// rather than copied as hex: a token here is the CSS expression, evaluated.
/// `test/theme/tokens_parity_test.dart` reads the stylesheet and holds the two
/// to the same result.
///
/// It is also the arithmetic a ColorPicker computes a colour with, the React
/// package's `internal/color.ts`: HSV, RGB and HSL, the conversions between
/// them, one parser and one formatter. HSV is the model the picker's panel is
/// drawn in and it never leaves, because a round trip through RGB loses the
/// hue of every grey and the rail would snap to red in a corner.
///
/// The library talking to itself: nothing here is exported but
/// [NebaColorFormat], which `NebaColorPicker` exports with itself.
library;

import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show immutable;

/// The CSS `oklch(L C H / alpha)` colour, in sRGB.
///
/// [lightness] is a fraction, so CSS's `50%` is `0.5`. A colour outside the
/// sRGB gamut is clipped per channel, which is what a browser draws for one;
/// the token sheet keeps its chroma just inside the gamut, so nothing in it
/// is clipped in practice.
Color oklch(double lightness, double chroma, double hue, [double alpha = 1]) {
  final double radians = hue * math.pi / 180;

  return oklab(lightness, chroma * math.cos(radians), chroma * math.sin(radians), alpha);
}

/// The CSS `oklab(L a b / alpha)` colour, in sRGB.
Color oklab(double lightness, double a, double b, [double alpha = 1]) {
  final List<double> linear = _oklabToLinear(lightness, a, b);

  return Color.from(
    alpha: alpha.clamp(0, 1),
    red: _encode(linear[0]),
    green: _encode(linear[1]),
    blue: _encode(linear[2]),
  );
}

/// The CSS `rgb(r g b / alpha)` colour, with channels from 0 to 255.
Color rgb(int red, int green, int blue, [double alpha = 1]) {
  return Color.from(alpha: alpha, red: red / 255, green: green / 255, blue: blue / 255);
}

/// The CSS keyword `transparent`: black with no alpha.
const Color transparent = Color(0x00000000);

/// The CSS keyword `white`.
const Color white = Color(0xFFFFFFFF);

/// `color-mix(in srgb, first amount, second)`.
///
/// [amount] is the share of [first], as a fraction, and the rest is [second].
/// The mix is done on premultiplied channels, as CSS does it, so mixing into
/// `transparent` lowers the alpha without darkening the colour.
Color mixSrgb(Color first, double amount, Color second) {
  final double p = amount.clamp(0, 1);
  final double alpha = first.a * p + second.a * (1 - p);

  if (alpha == 0) {
    return transparent;
  }

  double channel(double a, double b) {
    return ((a * first.a * p + b * second.a * (1 - p)) / alpha).clamp(0, 1);
  }

  return Color.from(
    alpha: alpha,
    red: channel(first.r, second.r),
    green: channel(first.g, second.g),
    blue: channel(first.b, second.b),
  );
}

/// `color-mix(in oklab, first amount, second)`.
///
/// The same premultiplied mix as [mixSrgb], in OKLab, which is how the React
/// package mixes an accent into the text colour for ink on a tinted surface.
Color mixOklab(Color first, double amount, Color second) {
  final double p = amount.clamp(0, 1);
  final double alpha = first.a * p + second.a * (1 - p);

  if (alpha == 0) {
    return transparent;
  }

  final List<double> a = _toOklab(first);
  final List<double> b = _toOklab(second);

  double component(int index) {
    return (a[index] * first.a * p + b[index] * second.a * (1 - p)) / alpha;
  }

  return oklab(component(0), component(1), component(2), alpha);
}

/// The `blurRadius` of a [BoxShadow] that draws a CSS `box-shadow` blur of
/// [cssBlur] pixels.
///
/// CSS blurs a shadow with a standard deviation of half its blur radius;
/// Flutter turns a `blurRadius` into a standard deviation with
/// `radius * 0.57735 + 0.5`. Without the conversion every shadow comes out
/// harder-edged than its React twin.
double shadowBlurRadius(double cssBlur) {
  if (cssBlur <= 0) {
    return 0;
  }

  return math.max(0, (cssBlur / 2 - 0.5) / 0.57735);
}

/// A colour's relative luminance, as WCAG defines it.
double luminance(Color color) {
  return 0.2126 * _decode(color.r) + 0.7152 * _decode(color.g) + 0.0722 * _decode(color.b);
}

/// The WCAG contrast ratio between two opaque colours.
double contrastRatio(Color first, Color second) {
  final double a = luminance(first);
  final double b = luminance(second);

  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

List<double> _toOklab(Color color) {
  final double r = _decode(color.r);
  final double g = _decode(color.g);
  final double b = _decode(color.b);

  final double l = _cbrt(0.4122214708 * r + 0.5363015264 * g + 0.0514459929 * b);
  final double m = _cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b);
  final double s = _cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);

  return <double>[
    0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
    1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
    0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s,
  ];
}

List<double> _oklabToLinear(double lightness, double a, double b) {
  final double l = math.pow(lightness + 0.3963377774 * a + 0.2158037573 * b, 3).toDouble();
  final double m = math.pow(lightness - 0.1055613458 * a - 0.0638541728 * b, 3).toDouble();
  final double s = math.pow(lightness - 0.0894841775 * a - 1.2914855480 * b, 3).toDouble();

  return <double>[
    4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
    -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
  ];
}

double _cbrt(double value) {
  return value < 0 ? -math.pow(-value, 1 / 3).toDouble() : math.pow(value, 1 / 3).toDouble();
}

/// Linear light to the sRGB transfer curve, clipped to the gamut.
double _encode(double linear) {
  final double value = linear <= 0.0031308
      ? 12.92 * linear
      : 1.055 * math.pow(linear, 1 / 2.4).toDouble() - 0.055;

  return value.clamp(0, 1);
}

/// The sRGB transfer curve back to linear light.
double _decode(double encoded) {
  return encoded <= 0.04045 ? encoded / 12.92 : math.pow((encoded + 0.055) / 1.055, 2.4).toDouble();
}

// ----- What a ColorPicker computes with --------------------------------------

/// The three notations a colour picker writes a colour back out in.
enum NebaColorFormat {
  /// `#rrggbb`, or `#rrggbbaa` with an alpha.
  hex,

  /// `rgb(r, g, b)`, or `rgba(r, g, b, a)` with an alpha.
  rgb,

  /// `hsl(h, s%, l%)`, or `hsla(h, s%, l%, a)` with an alpha.
  hsl,
}

/// A colour in HSV: [h] in degrees, [s] and [v] as percentages. The model a
/// picker's panel is drawn in.
@immutable
class NebaHsv {
  /// The colour at hue [h], saturation [s] and value [v].
  const NebaHsv(this.h, this.s, this.v);

  /// The hue, in degrees.
  final double h;

  /// The saturation, from 0 to 100.
  final double s;

  /// The value, or brightness, from 0 to 100.
  final double v;

  @override
  bool operator ==(Object other) {
    return other is NebaHsv && other.h == h && other.s == s && other.v == v;
  }

  @override
  int get hashCode => Object.hash(h, s, v);

  @override
  String toString() => 'NebaHsv($h, $s, $v)';
}

/// A colour and how much of it there is: [alpha] from 0 to 1.
@immutable
class NebaColorValue {
  /// [hsv] at [alpha].
  const NebaColorValue(this.hsv, [this.alpha = 1]);

  /// The colour.
  final NebaHsv hsv;

  /// Its opacity, from 0 to 1.
  final double alpha;

  @override
  bool operator ==(Object other) {
    return other is NebaColorValue && other.hsv == hsv && other.alpha == alpha;
  }

  @override
  int get hashCode => Object.hash(hsv, alpha);
}

/// The spectrum a hue rail is drawn with: the six primaries and red again,
/// which is what lets 359° sit next to 0° on a line.
const List<Color> hueSpectrum = <Color>[
  Color(0xFFFF0000),
  Color(0xFFFFFF00),
  Color(0xFF00FF00),
  Color(0xFF00FFFF),
  Color(0xFF0000FF),
  Color(0xFFFF00FF),
  Color(0xFFFF0000),
];

/// Where each of [hueSpectrum]'s colours stands along the rail.
const List<double> hueSpectrumStops = <double>[0, 0.1666, 0.3333, 0.5, 0.6666, 0.8333, 1];

/// The swatches a picker shows when it was given none: a plain spectrum and
/// the greys rather than the library's semantic families, because a picker is
/// asked for a colour and not for a meaning.
const List<String> defaultSwatches = <String>[
  '#000000',
  '#4b5563',
  '#9ca3af',
  '#ffffff',
  '#ef4444',
  '#f97316',
  '#f59e0b',
  '#84cc16',
  '#22c55e',
  '#14b8a6',
  '#06b6d4',
  '#3b82f6',
  '#6366f1',
  '#8b5cf6',
  '#d946ef',
  '#ec4899',
];

/// Degrees, wrapped rather than clamped: 370 is 10, and -10 is 350.
double _wrapHue(double hue) {
  final double wrapped = hue % 360;

  return wrapped < 0 ? wrapped + 360 : wrapped;
}

/// JavaScript's `Math.round`, which takes a half up rather than away from
/// zero.
int _round(double value) => (value + 0.5).floor();

/// [hsv] in 0–255 channels, each rounded.
({int r, int g, int b}) hsvToRgb(NebaHsv hsv) {
  final double hue = _wrapHue(hsv.h) / 60;
  final double saturation = hsv.s.clamp(0, 100) / 100;
  final double value = hsv.v.clamp(0, 100) / 100;

  final double chroma = value * saturation;
  final double second = chroma * (1 - ((hue % 2) - 1).abs());
  final double base = value - chroma;

  final (double r, double g, double b) = switch (hue.floor() % 6) {
    0 => (chroma, second, 0.0),
    1 => (second, chroma, 0.0),
    2 => (0.0, chroma, second),
    3 => (0.0, second, chroma),
    4 => (second, 0.0, chroma),
    _ => (chroma, 0.0, second),
  };

  return (r: _round((r + base) * 255), g: _round((g + base) * 255), b: _round((b + base) * 255));
}

/// Channels from 0 to 255 in HSV. A grey comes back at hue 0, whatever hue
/// it was mixed at, which is why a picker never derives its model from RGB.
NebaHsv rgbToHsv(num r, num g, num b) {
  final double red = r.clamp(0, 255) / 255;
  final double green = g.clamp(0, 255) / 255;
  final double blue = b.clamp(0, 255) / 255;

  final double max = math.max(red, math.max(green, blue));
  final double min = math.min(red, math.min(green, blue));
  final double chroma = max - min;

  double hue = 0;

  if (chroma != 0) {
    if (max == red) {
      hue = ((green - blue) / chroma) % 6;
    } else if (max == green) {
      hue = (blue - red) / chroma + 2;
    } else {
      hue = (red - green) / chroma + 4;
    }
  }

  return NebaHsv(_wrapHue(hue * 60), max == 0 ? 0 : chroma / max * 100, max * 100);
}

/// Channels from 0 to 255 in HSL: `h` in degrees, `s` and `l` as percentages.
({double h, double s, double l}) rgbToHsl(num r, num g, num b) {
  final NebaHsv hsv = rgbToHsv(r, g, b);
  final double value = hsv.v / 100;
  final double saturation = hsv.s / 100;

  final double lightness = value * (1 - saturation / 2);
  final double divisor = math.min(lightness, 1 - lightness);

  return (h: hsv.h, s: divisor == 0 ? 0 : (value - lightness) / divisor * 100, l: lightness * 100);
}

/// An HSL colour in 0–255 channels, each rounded.
({int r, int g, int b}) hslToRgb(double h, double s, double l) {
  final double lightness = l.clamp(0, 100) / 100;
  final double saturation = s.clamp(0, 100) / 100;

  final double value = lightness + saturation * math.min(lightness, 1 - lightness);

  return hsvToRgb(NebaHsv(h, value == 0 ? 0 : 2 * (1 - lightness / value) * 100, value * 100));
}

final RegExp _hexPattern = RegExp(r'^#?([0-9a-f]{3,8})$', caseSensitive: false);
final RegExp _numberPattern = RegExp(r'-?[\d.]+%?');
final RegExp _leadingNumber = RegExp(r'^-?(\d+\.?\d*|\.\d+)');
final RegExp _functionalPattern = RegExp(r'^(rgba?|hsla?)\((.*)\)$');

NebaColorValue? _hexToColor(String hex) {
  final RegExpMatch? match = _hexPattern.firstMatch(hex.trim());

  if (match == null) {
    return null;
  }

  final String digits = match.group(1)!;
  // `#abc` and `#abcd` are `#aabbcc` and `#aabbccdd`, doubled rather than
  // read a second way.
  final String expanded = digits.length == 3 || digits.length == 4
      ? digits.split('').map((String digit) => '$digit$digit').join()
      : digits;

  if (expanded.length != 6 && expanded.length != 8) {
    return null;
  }

  int channel(int index) => int.parse(expanded.substring(index * 2, index * 2 + 2), radix: 16);

  return NebaColorValue(
    rgbToHsv(channel(0), channel(1), channel(2)),
    expanded.length == 8 ? channel(3) / 255 : 1,
  );
}

/// JavaScript's `parseFloat` on a token the number pattern matched: the
/// number it starts with, or `NaN`.
double _parseFloat(String token) {
  final RegExpMatch? match = _leadingNumber.firstMatch(token);

  return match == null ? double.nan : double.parse(match.group(0)!);
}

/// A CSS colour string, or `null` for one this does not read.
///
/// Hex in all four lengths, with or without the hash, and `rgb()`, `rgba()`,
/// `hsl()` and `hsla()` in the comma and the space syntax. Named colours and
/// `color()` are out, because a picker has to write back every value it
/// reads, and no point on the panel means `rebeccapurple`.
NebaColorValue? parseCssColor(String input) {
  final String source = input.trim().toLowerCase();

  if (source.isEmpty) {
    return null;
  }

  if (source.startsWith('#') || _hexPattern.hasMatch(source)) {
    return _hexToColor(source);
  }

  final RegExpMatch? functional = _functionalPattern.firstMatch(source);

  if (functional == null) {
    return null;
  }

  final String name = functional.group(1)!;
  final String body = functional.group(2)!;
  final List<String> tokens = <String>[
    for (final RegExpMatch match in _numberPattern.allMatches(body)) match.group(0)!,
  ];
  final List<double> numbers = <double>[for (final String token in tokens) _parseFloat(token)];

  if (numbers.length < 3 || numbers.any((double number) => number.isNaN)) {
    return null;
  }

  bool percent(int index) => tokens[index].endsWith('%');

  final double alpha = numbers.length <= 3
      ? 1
      : (percent(3) ? numbers[3] / 100 : numbers[3]).clamp(0, 1).toDouble();

  if (name.startsWith('rgb')) {
    // A channel may be a share of 255: `rgb(100% 0% 0%)` is red, and read as
    // a number it would be a dark red at 100 of 255.
    double channel(int index) => percent(index) ? numbers[index] * 2.55 : numbers[index];

    return NebaColorValue(rgbToHsv(channel(0), channel(1), channel(2)), alpha);
  }

  final ({int r, int g, int b}) rgb = hslToRgb(numbers[0], numbers[1], numbers[2]);

  return NebaColorValue(rgbToHsv(rgb.r, rgb.g, rgb.b), alpha);
}

String _hexPair(num value) {
  return _round(value.toDouble()).clamp(0, 255).toRadixString(16).padLeft(2, '0');
}

/// Channels from 0 to 255 as `#rrggbb`, with an alpha pair when [alpha] is
/// under 1. A channel out of range is clamped rather than written as
/// nonsense.
String rgbToHex(num r, num g, num b, [double alpha = 1]) {
  final String base = '#${_hexPair(r)}${_hexPair(g)}${_hexPair(b)}';

  return alpha >= 1 ? base : '$base${_hexPair(alpha * 255)}';
}

/// Two decimals at most and no trailing zero, as JavaScript writes a number:
/// `0.5`, not `0.50`.
String _alphaText(double alpha) {
  final double rounded = _round(alpha.clamp(0, 1) * 100) / 100;

  return rounded == rounded.roundToDouble() ? '${rounded.round()}' : '$rounded';
}

/// [hsv] at [alpha], written in [format], with the alpha left out of an
/// opaque colour: a caller who never asked for one should not meet
/// `rgba(…, 1)`.
String formatCssColor(NebaHsv hsv, double alpha, NebaColorFormat format) {
  final ({int r, int g, int b}) rgb = hsvToRgb(hsv);

  switch (format) {
    case NebaColorFormat.hex:
      return rgbToHex(rgb.r, rgb.g, rgb.b, alpha);
    case NebaColorFormat.rgb:
      final String channels = '${rgb.r}, ${rgb.g}, ${rgb.b}';

      return alpha >= 1 ? 'rgb($channels)' : 'rgba($channels, ${_alphaText(alpha)})';
    case NebaColorFormat.hsl:
      final ({double h, double s, double l}) hsl = rgbToHsl(rgb.r, rgb.g, rgb.b);
      final String channels = '${_round(hsl.h)}, ${_round(hsl.s)}%, ${_round(hsl.l)}%';

      return alpha >= 1 ? 'hsl($channels)' : 'hsla($channels, ${_alphaText(alpha)})';
  }
}

/// [hsv] at [alpha] as a colour to paint with, the React package's
/// `cssColor`: a swatch's, a rail's and a thumb's fill.
Color hsvColor(NebaHsv hsv, [double alpha = 1]) {
  final ({int r, int g, int b}) rgb = hsvToRgb(hsv);

  return Color.from(
    alpha: alpha.clamp(0, 1).toDouble(),
    red: rgb.r / 255,
    green: rgb.g / 255,
    blue: rgb.b / 255,
  );
}

/// Black or white, whichever contrasts more on [hsv]: the tick on a chosen
/// swatch. Measured by relative luminance, with the React package's 0.03928
/// threshold, so the crossover is near 0.18 rather than halfway and a mid
/// grey, an orange or a green takes black.
Color readableInk(NebaHsv hsv) {
  final ({int r, int g, int b}) rgb = hsvToRgb(hsv);

  double channel(int value) {
    final double scaled = value / 255;

    return scaled <= 0.03928 ? scaled / 12.92 : math.pow((scaled + 0.055) / 1.055, 2.4).toDouble();
  }

  final double light = 0.2126 * channel(rgb.r) + 0.7152 * channel(rgb.g) + 0.0722 * channel(rgb.b);
  final double onWhite = 1.05 / (light + 0.05);
  final double onBlack = (light + 0.05) / 0.05;

  return onBlack > onWhite ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
}
