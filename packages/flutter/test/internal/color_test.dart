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

  // What a ColorPicker computes with, the React package's color.test.ts. The
  // invariant it is built around is that HSV never leaves: a round trip
  // through RGB loses the hue of every grey.
  group('the picker conversions', () {
    test('round-trip a colour through RGB and back', () {
      final ({int r, int g, int b}) rgb = hsvToRgb(const NebaHsv(210, 60, 80));
      final NebaHsv back = rgbToHsv(rgb.r, rgb.g, rgb.b);

      expect(back.h, closeTo(210, 0.5));
      expect(back.s, closeTo(60, 0.5));
      expect(back.v, closeTo(80, 0.5));
    });

    test('lose the hue of a grey, which is why HSV never leaves', () {
      final NebaHsv black = rgbToHsv(0, 0, 0);

      expect(black.s, 0);
      expect(black.v, 0);

      final ({int r, int g, int b}) dark = hsvToRgb(const NebaHsv(275, 0, 0));

      expect(rgbToHsv(dark.r, dark.g, dark.b).h, isNot(275));
    });

    test('read the three primaries at the hues they are', () {
      expect(rgbToHsv(255, 0, 0).h, closeTo(0, 1e-5));
      expect(rgbToHsv(0, 255, 0).h, closeTo(120, 1e-5));
      expect(rgbToHsv(0, 0, 255).h, closeTo(240, 1e-5));
    });

    test('round-trip through HSL as well', () {
      final ({double h, double s, double l}) hsl = rgbToHsl(40, 160, 210);
      final ({int r, int g, int b}) back = hslToRgb(hsl.h, hsl.s, hsl.l);

      expect(back, (r: 40, g: 160, b: 210));
    });

    test('hold the ends of the value axis', () {
      expect(hsvToRgb(const NebaHsv(0, 0, 100)), (r: 255, g: 255, b: 255));
      expect(hsvToRgb(const NebaHsv(0, 100, 0)), (r: 0, g: 0, b: 0));
    });
  });

  group('parseCssColor', () {
    test('reads a hex colour, with or without the hash, long or short', () {
      expect(parseCssColor('#ff0000')?.hsv.h, closeTo(0, 1e-5));
      expect(parseCssColor('ff0000')?.hsv.h, closeTo(0, 1e-5));
      expect(parseCssColor('#f00'), parseCssColor('#ff0000'));
    });

    test('reads an eight-digit hex as a colour with an alpha', () {
      expect(parseCssColor('#ff000080')?.alpha, closeTo(0.5, 0.01));
    });

    test('reads the functional forms', () {
      expect(parseCssColor('rgb(255, 0, 0)')?.hsv.h, closeTo(0, 1e-5));
      expect(parseCssColor('rgba(255, 0, 0, 0.5)')?.alpha, closeTo(0.5, 1e-5));
      expect(parseCssColor('hsl(120, 100%, 50%)')?.hsv.h, closeTo(120, 1e-5));
      expect(parseCssColor('rgb(255 0 0 / .5)')?.alpha, closeTo(0.5, 1e-5));
    });

    test('reads an rgb channel written as a percentage as a share of 255', () {
      final NebaColorValue red = parseCssColor('rgb(100% 0% 0%)')!;

      expect(formatCssColor(red.hsv, red.alpha, NebaColorFormat.hex), '#ff0000');

      final NebaColorValue mixed = parseCssColor('rgba(50%, 128, 0%, 50%)')!;

      expect(formatCssColor(mixed.hsv, 1, NebaColorFormat.hex), '#808000');
      expect(mixed.alpha, closeTo(0.5, 1e-5));
    });

    test('does not care about case or surrounding space', () {
      expect(parseCssColor('  #FF0000  ')?.hsv.h, closeTo(0, 1e-5));
      expect(parseCssColor('RGB(255, 0, 0)')?.hsv.h, closeTo(0, 1e-5));
    });

    test('answers null for something it does not read', () {
      expect(parseCssColor(''), isNull);
      expect(parseCssColor('rebeccapurple'), isNull);
      expect(parseCssColor('rgb(1, 2)'), isNull);
      expect(parseCssColor('rgb(a, b, c)'), isNull);
      expect(parseCssColor('not a colour'), isNull);
      expect(parseCssColor('#12'), isNull);
    });
  });

  group('formatCssColor', () {
    const NebaHsv red = NebaHsv(0, 100, 100);

    test('writes each of the three notations', () {
      expect(formatCssColor(red, 1, NebaColorFormat.hex), '#ff0000');
      expect(formatCssColor(red, 1, NebaColorFormat.rgb), 'rgb(255, 0, 0)');
      expect(formatCssColor(red, 1, NebaColorFormat.hsl), 'hsl(0, 100%, 50%)');
    });

    test('writes the alpha only when there is one, to two decimals at most', () {
      expect(formatCssColor(red, 0.5, NebaColorFormat.hex), '#ff000080');
      expect(formatCssColor(red, 0.5, NebaColorFormat.rgb), 'rgba(255, 0, 0, 0.5)');
      expect(formatCssColor(red, 0.5, NebaColorFormat.hsl), 'hsla(0, 100%, 50%, 0.5)');
      expect(formatCssColor(red, 0.333, NebaColorFormat.rgb), 'rgba(255, 0, 0, 0.33)');
      expect(formatCssColor(red, 0, NebaColorFormat.rgb), 'rgba(255, 0, 0, 0)');
    });

    test('round-trips back through the parser', () {
      for (final NebaColorFormat format in NebaColorFormat.values) {
        final String written = formatCssColor(const NebaHsv(210, 60, 80), 1, format);
        final NebaColorValue read = parseCssColor(written)!;

        expect(formatCssColor(read.hsv, read.alpha, format), written);
      }
    });
  });

  group('rgbToHex and hsvColor', () {
    test('pad a single digit and clamp a channel out of range', () {
      expect(rgbToHex(1, 2, 3), '#010203');
      expect(rgbToHex(300, -20, 0), '#ff0000');
    });

    test('paint the colour at its alpha', () {
      expect(hsvColor(const NebaHsv(0, 100, 100)), near(0xFFFF0000));
      expect(hsvColor(const NebaHsv(0, 100, 100), 0.4).a, closeTo(0.4, 1e-6));
    });
  });

  group('readableInk', () {
    const Color black = Color(0xFF000000);

    test('puts a dark tick on a light colour and a light one on a dark colour', () {
      expect(readableInk(const NebaHsv(60, 100, 100)), black);
      expect(readableInk(const NebaHsv(220, 100, 25)), white);
    });

    // Halfway is the wrong place for the crossover: a mid grey, an orange and
    // a green read under 3:1 in white and far better in black.
    test('chooses whichever ink contrasts more on a mid-tone swatch', () {
      for (final String hex in <String>['#9ca3af', '#f97316', '#22c55e']) {
        expect(readableInk(parseCssColor(hex)!.hsv), black, reason: hex);
      }

      expect(readableInk(parseCssColor('#2563eb')!.hsv), white);
    });
  });
}
