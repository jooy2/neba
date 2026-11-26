// The acrylic sheet: what it draws, in which order of time, and what it leaves
// out for a reader who asked for less transparency.

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../support/host.dart';

void main() {
  Widget sheet(Color fill, {bool pressed = false, int elevation = 0, bool highContrast = false}) {
    return host(
      Center(
        child: NebaSheet(
          fill: fill,
          pressed: pressed,
          elevation: elevation,
          borderRadius: BorderRadius.circular(14),
          child: const SizedBox(width: 120, height: 32),
        ),
      ),
      highContrast: highContrast,
    );
  }

  /// The fill the sheet is painting right now, read off the colour tween.
  Color fillOf(WidgetTester tester) {
    final Iterable<TweenAnimationBuilder<Color?>> tweens = tester
        .widgetList<TweenAnimationBuilder<Color?>>(
          find.byWidgetPredicate((Widget widget) => widget is TweenAnimationBuilder<Color?>),
        );
    final TweenAnimationBuilder<Color?> fill = tweens.last;

    return (fill.tween as ColorTween).end!;
  }

  testWidgets('a press lands on the fill in zero time and the release drains it', (
    WidgetTester tester,
  ) async {
    const Color rest = Color(0xFF2050D0);
    const Color held = Color(0xFF102878);

    await tester.pumpWidget(sheet(rest));
    await tester.pumpWidget(sheet(held, pressed: true));
    expect(
      tester
          .widgetList<TweenAnimationBuilder<Color?>>(
            find.byWidgetPredicate((Widget widget) => widget is TweenAnimationBuilder<Color?>),
          )
          .map((TweenAnimationBuilder<Color?> tween) => tween.duration),
      everyElement(Duration.zero),
    );

    await tester.pumpWidget(sheet(rest));
    expect(fillOf(tester), rest);
    expect(
      tester
          .widgetList<TweenAnimationBuilder<Color?>>(
            find.byWidgetPredicate((Widget widget) => widget is TweenAnimationBuilder<Color?>),
          )
          .last
          .duration,
      NebaScale.durationFill,
    );
  });

  testWidgets('blurs the page behind, and stops blurring it for less transparency', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(sheet(const Color(0xE0FFFFFF)));
    expect(find.byType(BackdropFilter), findsOneWidget);

    await tester.pumpWidget(sheet(const Color(0xE0FFFFFF), highContrast: true));
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('casts the elevation ladder\'s shadow, and none at 0', (WidgetTester tester) async {
    List<BoxShadow>? shadowOf() {
      final AnimatedContainer box = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      return (box.decoration! as BoxDecoration).boxShadow;
    }

    await tester.pumpWidget(sheet(const Color(0xFF2050D0)));
    expect(shadowOf(), isEmpty);

    await tester.pumpWidget(sheet(const Color(0xFF2050D0), elevation: 2));
    expect(shadowOf(), NebaTokens.light().elevation(2));
  });

  test('saturates the backdrop with the CSS matrix, which is identity at 1', () {
    final List<double> identity = <double>[
      1, 0, 0, 0, 0, //
      0, 1, 0, 0, 0, //
      0, 0, 1, 0, 0, //
      0, 0, 0, 1, 0, //
    ];
    final List<double> matrix = saturationMatrix(1);

    for (int i = 0; i < identity.length; i++) {
      expect(matrix[i], closeTo(identity[i], 1e-9));
    }
  });

  test('runs the sheen along the CSS gradient line, corner to corner', () {
    final (Offset from, Offset to) = cssGradientEnds(const Size(200, 40), 148);
    final double length = (to - from).distance;
    final double angle = 148 * math.pi / 180;

    expect(length, closeTo((200 * math.sin(angle)).abs() + (40 * math.cos(angle)).abs(), 1e-9));
    // 148° runs from the top left toward the bottom right, mostly downward.
    expect(to.dy, greaterThan(from.dy));
    expect(to.dx, greaterThan(from.dx));
  });

  test('draws the same grain every time, at 12%', () {
    final Uint8List first = NebaGrain.pixels();
    final Uint8List second = NebaGrain.pixels();

    expect(first, second);
    expect(first[3], (0.12 * 255).round());
    expect(first.length, NebaGrain.size * NebaGrain.size * 4);
  });
}
