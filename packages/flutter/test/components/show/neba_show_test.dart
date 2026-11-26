// NebaShow: the suite the React package runs on Show, asked the way Flutter
// asks it. React can only check the classes it writes, because the widths are
// the stylesheet's; here the decision is the widget's, so each case pumps a
// window of a given width and looks at what was built.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child, {double width = 800}) {
    return tester.pumpWidget(host(child, width: width));
  }

  bool shown() => find.text('Content').evaluate().isNotEmpty;

  group('the window', () {
    testWidgets('is shown at and above the floor it was given, and not below it', (
      WidgetTester tester,
    ) async {
      const Widget show = NebaShow(above: NebaBreakpoint.md, child: Text('Content'));

      await pump(tester, show, width: 767);
      expect(shown(), isFalse);

      await pump(tester, show, width: 768);
      expect(shown(), isTrue);
    });

    testWidgets('stops at the ceiling it was given, which is exclusive', (
      WidgetTester tester,
    ) async {
      const Widget show = NebaShow(below: NebaBreakpoint.md, child: Text('Content'));

      await pump(tester, show, width: 767);
      expect(shown(), isTrue);

      await pump(tester, show, width: 768);
      expect(shown(), isFalse);
    });

    testWidgets('covers every width exactly once with the same breakpoint in a pair', (
      WidgetTester tester,
    ) async {
      for (final double width in <double>[320, 767, 768, 1400]) {
        await pump(
          tester,
          const Column(
            children: <Widget>[
              NebaShow(below: NebaBreakpoint.md, child: Text('Narrow')),
              NebaShow(above: NebaBreakpoint.md, child: Text('Wide')),
            ],
          ),
          width: width,
        );

        final int drawn =
            find.text('Narrow').evaluate().length + find.text('Wide').evaluate().length;
        expect(drawn, 1, reason: '$width');
      }
    });

    testWidgets('takes a floor and a ceiling together', (WidgetTester tester) async {
      const Widget show = NebaShow(
        above: NebaBreakpoint.sm,
        below: NebaBreakpoint.lg,
        child: Text('Content'),
      );

      await pump(tester, show, width: 639);
      expect(shown(), isFalse);
      await pump(tester, show, width: 640);
      expect(shown(), isTrue);
      await pump(tester, show, width: 1023);
      expect(shown(), isTrue);
      await pump(tester, show, width: 1024);
      expect(shown(), isFalse);
    });

    testWidgets('treats xs as a floor of zero, so always, and shows nothing below it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaShow(above: NebaBreakpoint.xs, child: Text('Content')),
        width: 1,
      );
      expect(shown(), isTrue);

      await pump(
        tester,
        const NebaShow(below: NebaBreakpoint.xs, child: Text('Content')),
        width: 4000,
      );
      expect(shown(), isFalse);

      await pump(tester, const NebaShow(child: Text('Content')));
      expect(shown(), isTrue);
    });

    testWidgets('follows a change of props, and a window that is resized', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaShow(above: NebaBreakpoint.md, child: Text('Content')));
      expect(shown(), isTrue);

      await pump(tester, const NebaShow(above: NebaBreakpoint.xl, child: Text('Content')));
      expect(shown(), isFalse);

      await pump(
        tester,
        const NebaShow(above: NebaBreakpoint.xl, child: Text('Content')),
        width: 1280,
      );
      expect(shown(), isTrue);
    });

    testWidgets('does not build what it hides', (WidgetTester tester) async {
      int built = 0;

      await pump(
        tester,
        NebaShow(
          above: NebaBreakpoint.lg,
          child: Builder(
            builder: (BuildContext context) {
              built += 1;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(built, 0);
    });
  });

  group('inside a container', () {
    testWidgets('leaves a shown cell a grid cell, with nothing in between', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaGridContainer(
          padded: false,
          children: <Widget>[
            NebaGrid(span: NebaGridSpan.columns(8), child: SizedBox(height: 20)),
            NebaShow(
              above: NebaBreakpoint.md,
              child: NebaGrid(span: NebaGridSpan.columns(4), child: Text('Content')),
            ),
          ],
        ),
      );

      expect(tester.takeException(), isNull);
      // Four of twelve columns of an 800-pixel row, less the gutter it shares.
      expect(tester.getSize(find.text('Content')).width, lessThanOrEqualTo(800 / 3));
      expect(
        tester.getTopLeft(find.text('Content')).dx,
        greaterThan(tester.getTopLeft(find.byType(SizedBox).first).dx),
      );
    });

    testWidgets('takes no cell and no gap in a grid while it is hidden', (
      WidgetTester tester,
    ) async {
      Widget grid(List<Widget> children) {
        return Center(child: NebaGridContainer(padded: false, spacing: 4, children: children));
      }

      const Widget cell = NebaGrid(span: NebaGridSpan.columns(12), child: SizedBox(height: 20));

      await pump(tester, grid(const <Widget>[cell]), width: 400);
      final double alone = tester.getSize(find.byType(NebaGridContainer)).height;

      await pump(
        tester,
        grid(const <Widget>[cell, NebaShow(above: NebaBreakpoint.md, child: cell)]),
        width: 400,
      );
      expect(tester.getSize(find.byType(NebaGridContainer)).height, alone);
    });

    testWidgets('takes no gap in a NebaFlex while it is hidden', (WidgetTester tester) async {
      Widget row(List<Widget> children) {
        return Center(child: NebaFlex(spacing: 4, inline: true, children: children));
      }

      const Widget item = SizedBox(width: 30, height: 20);

      await pump(tester, row(const <Widget>[item, item]), width: 400);
      final double two = tester.getSize(find.byType(NebaFlex)).width;

      await pump(
        tester,
        row(const <Widget>[item, NebaShow(above: NebaBreakpoint.md, child: item), item]),
        width: 400,
      );
      expect(tester.getSize(find.byType(NebaFlex)).width, two);

      await pump(
        tester,
        row(const <Widget>[item, NebaShow(above: NebaBreakpoint.md, child: item), item]),
        width: 800,
      );
      expect(tester.getSize(find.byType(NebaFlex)).width, two + 30 + 16);
    });
  });
}
