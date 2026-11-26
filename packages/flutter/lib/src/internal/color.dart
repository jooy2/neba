/// The colour arithmetic the token sheet is written in.
///
/// The React package states every colour in `oklch()` and derives most of the
/// rest with `color-mix()`, so the Flutter tokens are computed the same way
/// rather than copied as hex: a token here is the CSS expression, evaluated.
/// `test/theme/tokens_parity_test.dart` reads the stylesheet and holds the two
/// to the same result.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:math' as math;
import 'dart:ui' show Color;

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
