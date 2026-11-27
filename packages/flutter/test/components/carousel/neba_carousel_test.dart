import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  Widget slide(String name, {double height = 120}) {
    return SizedBox(
      height: height,
      child: Center(child: Text(name)),
    );
  }

  Future<void> pump(WidgetTester tester, Widget carousel) async {
    await tester.pumpWidget(host(Center(child: SizedBox(width: 400, child: carousel))));
    await tester.pumpAndSettle();
  }

  /// Whether [name]'s slide is the one in the frame.
  bool showing(WidgetTester tester, String name) {
    final Rect frame = tester.getRect(find.byType(NebaCarousel));
    final Offset center = tester.getCenter(find.text(name));

    return center.dx > frame.left && center.dx < frame.right;
  }

  testWidgets('is as tall as its tallest slide and shows the first', (WidgetTester tester) async {
    await pump(
      tester,
      NebaCarousel(
        arrows: false,
        indicators: false,
        children: <Widget>[slide('A', height: 80), slide('B', height: 140)],
      ),
    );

    expect(tester.getSize(find.byType(NebaSheet)).height, closeTo(142, 0.5));
    expect(showing(tester, 'A'), isTrue);
    expect(showing(tester, 'B'), isFalse);
  });

  testWidgets('steps on and back with the arrows, and loops at the ends', (
    WidgetTester tester,
  ) async {
    final List<int> shown = <int>[];

    await pump(
      tester,
      NebaCarousel(
        onValueChange: shown.add,
        children: <Widget>[slide('A'), slide('B'), slide('C')],
      ),
    );

    await tester.tap(find.bySemanticsLabel('Next slide'));
    await tester.pumpAndSettle();
    expect(showing(tester, 'B'), isTrue);

    await tester.tap(find.bySemanticsLabel('Previous slide'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Previous slide'));
    await tester.pumpAndSettle();
    expect(showing(tester, 'C'), isTrue);
    expect(shown, <int>[1, 0, 2]);
  });

  testWidgets('holds at the ends without loop, its arrows disabled there', (
    WidgetTester tester,
  ) async {
    final List<int> shown = <int>[];

    await pump(
      tester,
      NebaCarousel(
        loop: false,
        onValueChange: shown.add,
        children: <Widget>[slide('A'), slide('B')],
      ),
    );

    final NebaIconButton back = tester.widget<NebaIconButton>(
      find.byWidgetPredicate((Widget w) => w is NebaIconButton && w.label == 'Previous slide'),
    );
    expect(back.disabled, isTrue);
    expect(back.focusableWhenDisabled, isTrue);
  });

  testWidgets('goes to a slide by its dot and by a swipe', (WidgetTester tester) async {
    final List<int> shown = <int>[];

    await pump(
      tester,
      NebaCarousel(
        arrows: false,
        onValueChange: shown.add,
        children: <Widget>[slide('A'), slide('B'), slide('C')],
      ),
    );

    await tester.tap(find.bySemanticsLabel('Slide 3 of 3'));
    await tester.pumpAndSettle();
    expect(showing(tester, 'C'), isTrue);

    await tester.fling(find.text('C'), const Offset(300, 0), 1000);
    await tester.pumpAndSettle();
    expect(showing(tester, 'B'), isTrue);
    expect(shown, <int>[2, 1]);
  });

  testWidgets('follows the value it is given', (WidgetTester tester) async {
    Widget carousel(int value) => NebaCarousel(
      value: value,
      arrows: false,
      indicators: false,
      children: <Widget>[slide('A'), slide('B'), slide('C')],
    );

    await pump(tester, carousel(0));
    await pump(tester, carousel(2));

    expect(showing(tester, 'C'), isTrue);
  });

  testWidgets('steps with the arrow keys when its strip holds the focus', (
    WidgetTester tester,
  ) async {
    await pump(tester, NebaCarousel(arrows: false, children: <Widget>[slide('A'), slide('B')]));

    Focus.of(tester.element(find.text('A'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();

    expect(showing(tester, 'B'), isTrue);
  });

  testWidgets('turns on its own, holds under the pointer, and stops on its button', (
    WidgetTester tester,
  ) async {
    final List<int> shown = <int>[];

    await pump(
      tester,
      NebaCarousel(
        autoPlay: true,
        interval: const Duration(seconds: 1),
        onValueChange: shown.add,
        children: <Widget>[slide('A'), slide('B'), slide('C')],
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(shown, <int>[1]);

    await tester.tap(find.bySemanticsLabel('Pause slide show'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(shown, <int>[1]);
    expect(find.bySemanticsLabel('Play slide show'), findsOneWidget);
  });

  testWidgets('is a named region of named slides that says which one shows', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pump(
      tester,
      NebaCarousel(
        semanticLabel: 'Highlights',
        arrows: false,
        indicators: false,
        children: <Widget>[slide('A'), slide('B')],
      ),
    );

    expect(find.bySemanticsLabel('Highlights'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Slide 1 of 2')), findsWidgets);

    semantics.dispose();
  });
}
