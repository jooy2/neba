// The path reader the glyphs are drawn with, against the shapes a browser
// draws for the same data.

import 'dart:ui' show Path, Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:neba/src/internal/svg_path.dart';

void main() {
  Matcher bounds(double left, double top, double right, double bottom) {
    return predicate<Path>((Path path) {
      final Rect rect = path.getBounds();

      return (rect.left - left).abs() < 0.01 &&
          (rect.top - top).abs() < 0.01 &&
          (rect.right - right).abs() < 0.01 &&
          (rect.bottom - bottom).abs() < 0.01;
    }, 'bounds of ($left, $top) to ($right, $bottom)');
  }

  test('reads relative movetos and linetos, and pairs after a moveto as linetos', () {
    // The ×: two diagonals, the second started with a relative moveto.
    expect(parseSvgPath('m4.5 4.5 7 7m0-7-7 7'), bounds(4.5, 4.5, 11.5, 11.5));
  });

  test('reads horizontal and vertical lines', () {
    expect(parseSvgPath('M8 3.5v9M3.5 8h9'), bounds(3.5, 3.5, 12.5, 12.5));
  });

  test('reads arcs, flags written with no separator included', () {
    // The spinner's arc: the upper right quarter of a circle about (8, 8).
    expect(parseSvgPath('M14.5 8A6.5 6.5 0 0 0 8 1.5'), bounds(8, 1.5, 14.5, 8));
    expect(parseSvgPath('M0 0a1 1 0 01 2 0').getBounds().width, closeTo(2, 0.01));
  });

  test('reads cubic and smooth cubic curves', () {
    final Path path = parseSvgPath('M0 0C0 10 10 10 10 0S20 -10 20 0');

    expect(path.getBounds().left, closeTo(0, 0.01));
    expect(path.getBounds().right, closeTo(20, 0.01));
    expect(path.getBounds().bottom, greaterThan(5));
    expect(path.getBounds().top, lessThan(-5));
  });

  test('reads quadratic curves and closes a path back to its start', () {
    final Path path = parseSvgPath('M0 0Q5 10 10 0T20 0Z');

    expect(path.getBounds().right, closeTo(20, 0.01));
    expect(path.getBounds().bottom, greaterThan(4));
  });

  test('refuses what it cannot read rather than drawing part of it', () {
    expect(() => parseSvgPath('1 1'), throwsFormatException);
    expect(() => parseSvgPath('M0'), throwsFormatException);
    expect(() => parseSvgPath('M0 0 X1 1'), throwsFormatException);
  });
}
