// The colour arithmetic the tokens are computed with, against values a
// browser gives for the same CSS.

import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:neba/src/internal/color.dart';

void main() {
  /// Within one step of an 8-bit channel.
  Matcher near(int hex) {
    final Color expected = Color(hex);

    return predicate<Color>((Color actual) {
      const double step = 1.01 / 255;

      return (actual.a - expected.a).abs() < 0.005 &&
          (actual.r - expected.r).abs() < step &&
          (actual.g - expected.g).abs() < step &&
          (actual.b - expected.b).abs() < step;
    }, 'within one channel step of ${expected.toString()}');
  }

  group('oklch', () {
    test('reads white and black', () {
      expect(oklch(1, 0, 0), near(0xFFFFFFFF));
      expect(oklch(0, 0, 0), near(0xFF000000));
    });

    test('lands on the sRGB primaries at their published coordinates', () {
      expect(oklch(0.627955, 0.257683, 29.2339), near(0xFFFF0000));
      expect(oklch(0.86644, 0.294827, 142.4953), near(0xFF00FF00));
      expect(oklch(0.452014, 0.313214, 264.052), near(0xFF0000FF));
    });

    test('keeps the alpha it is given', () {
      expect(oklch(1, 0, 0, 0.5).a, closeTo(0.5, 1e-9));
    });

    test('clips a colour outside the gamut rather than wrapping it', () {
      final Color clipped = oklch(0.7, 0.4, 145);

      for (final double channel in <double>[clipped.r, clipped.g, clipped.b]) {
        expect(channel, inInclusiveRange(0, 1));
      }
    });
  });

  group('mixSrgb', () {
    test('lowers the alpha and keeps the colour when mixed into transparent', () {
      final Color mixed = mixSrgb(const Color(0xFF3366CC), 0.25, transparent);

      expect(mixed.a, closeTo(0.25, 1e-9));
      expect(mixed, near(0x403366CC));
    });

    test('mixes two opaque colours channel by channel', () {
      expect(mixSrgb(white, 0.5, const Color(0xFF000000)), near(0xFF808080));
    });

    test('takes all of the first colour at 100% and none at 0%', () {
      expect(mixSrgb(white, 1, transparent), near(0xFFFFFFFF));
      expect(mixSrgb(white, 0, transparent).a, 0);
    });
  });

  group('mixOklab', () {
    test('mixes through OKLab, which keeps a mid grey lighter than sRGB does', () {
      final Color mixed = mixOklab(white, 0.5, const Color(0xFF000000));

      expect(mixed, near(0xFF636363));
    });
  });

  test('turns a CSS shadow blur into a Flutter blur radius', () {
    expect(shadowBlurRadius(0), 0);
    expect(shadowBlurRadius(24), closeTo((12 - 0.5) / 0.57735, 1e-9));
  });

  test('measures contrast the way WCAG does', () {
    expect(contrastRatio(white, const Color(0xFF000000)), closeTo(21, 1e-6));
  });
}
