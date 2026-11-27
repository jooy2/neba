// NebaDivider: the suite the React package runs on Divider, asked the way
// Flutter asks it — how long and how thick the rule is laid out, where its
// label sits, and what a screen reader hears.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(host(Center(child: child)));
  }

  Iterable<ColoredBox> rules(WidgetTester tester) => tester.widgetList<ColoredBox>(
    find.descendant(of: find.byType(NebaDivider), matching: find.byType(ColoredBox)),
  );

  Iterable<Rect> ruleRects(WidgetTester tester) => tester
      .elementList(find.descendant(of: find.byType(NebaDivider), matching: find.byType(ColoredBox)))
      .map((Element e) => tester.getRect(find.byElementPredicate((Element x) => x == e)));

  testWidgets('runs the width it is given, one pixel thick, in the primary line', (
    WidgetTester tester,
  ) async {
    await pump(tester, const SizedBox(width: 300, child: NebaDivider()));

    expect(ruleRects(tester).single.size, const Size(300, 1));
    expect(rules(tester).single.color, tokens.roles(NebaColor.primary).line);
  });

  testWidgets('takes no room along an axis with no limit, and never throws', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[Text('a'), NebaDivider(), Text('b')],
      ),
    );

    expect(tester.takeException(), isNull);
    expect(ruleRects(tester).single.width, 0);
  });

  testWidgets('stretches a vertical rule to the height of its row', (WidgetTester tester) async {
    await pump(
      tester,
      const SizedBox(
        height: 40,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Draft'),
            NebaDivider(orientation: NebaOrientation.vertical),
            Text('Edited'),
          ],
        ),
      ),
    );

    expect(ruleRects(tester).single.size, const Size(1, 40));
  });

  testWidgets('takes a length, a thickness and a colour', (WidgetTester tester) async {
    await pump(tester, const NebaDivider(length: 120, thickness: 2, color: NebaColor.success));

    expect(ruleRects(tester).single.size, const Size(120, 2));
    expect(rules(tester).single.color, tokens.roles(NebaColor.success).line);
  });

  testWidgets('breaks around a label in the middle', (WidgetTester tester) async {
    await pump(tester, const SizedBox(width: 300, child: NebaDivider(child: Text('OR'))));

    final List<Rect> parts = ruleRects(tester).toList();
    final Rect label = tester.getRect(find.text('OR'));

    expect(parts, hasLength(2));
    expect(parts.first.width, moreOrLessEquals(parts.last.width));
    expect(parts.first.right, lessThan(label.left));
    expect(parts.last.left, greaterThan(label.right));
    expect(label.center.dy, moreOrLessEquals(parts.first.center.dy, epsilon: 0.5));
  });

  testWidgets('leaves a short stub on the near side of an off-centre label', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      const SizedBox(
        width: 300,
        child: NebaDivider(textAlign: NebaAlign.start, child: Text('Recent')),
      ),
    );
    expect(ruleRects(tester).first.width, NebaDivider.stub);

    await pump(
      tester,
      const SizedBox(
        width: 300,
        child: NebaDivider(textAlign: NebaAlign.end, child: Text('Archived')),
      ),
    );
    expect(ruleRects(tester).last.width, NebaDivider.stub);
  });

  testWidgets('sets the label on the meta scale in muted ink', (WidgetTester tester) async {
    await pump(
      tester,
      const SizedBox(
        width: 300,
        child: NebaDivider(size: NebaSize.xl, child: Text('OR')),
      ),
    );

    final TextStyle style = tester.widget<RichText>(find.byType(RichText)).text.style!;
    expect(style.fontSize, 14);
    expect(style.color, tokens.mutedFg);
  });

  testWidgets('turns a vertical label with the rule', (WidgetTester tester) async {
    await pump(
      tester,
      const SizedBox(
        height: 120,
        child: NebaDivider(orientation: NebaOrientation.vertical, child: Text('AND')),
      ),
    );

    final Rect label = tester.getRect(find.byType(RotatedBox));
    expect(label.height, greaterThan(label.width));
  });

  testWidgets('names itself after a Text label, and says nothing without one', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pump(tester, const SizedBox(width: 300, child: NebaDivider(child: Text('OR'))));
    expect(find.bySemanticsLabel('OR'), findsOneWidget);

    semantics.dispose();
  });
}
