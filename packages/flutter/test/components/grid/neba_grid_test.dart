// NebaGridContainer and NebaGrid: the column arithmetic, the wrapping, the
// growing and the alignment, measured on the laid-out boxes. The React suite
// checks the CSS slots that produce these numbers; here the numbers are what
// the layout computes.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  // 1000 wide with an 8-pixel gutter: one column plus one gutter is 84.
  const double width = 1000;
  const double gap = 8;
  const double track = (width + gap) / 12;

  Future<void> pump(
    WidgetTester tester,
    NebaGridContainer grid, {
    TextDirection textDirection = TextDirection.ltr,
  }) {
    tester.view.physicalSize = const Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    return tester.pumpWidget(
      host(
        Align(alignment: Alignment.topLeft, child: grid),
        width: width,
        height: 800,
        textDirection: textDirection,
      ),
    );
  }

  Widget block(String key, {double height = 20, double? width}) {
    return SizedBox(key: Key(key), height: height, width: width);
  }

  Rect rectOf(WidgetTester tester, String key) => tester.getRect(find.byKey(Key(key)));

  testWidgets('gives an item every column of the row when it names no span', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      NebaGridContainer(padded: false, children: <Widget>[NebaGrid(child: block('a'))]),
    );

    expect(rectOf(tester, 'a').width, width);
  });

  testWidgets('divides a row so that the gutters line up', (WidgetTester tester) async {
    await pump(
      tester,
      NebaGridContainer(
        padded: false,
        children: <Widget>[
          NebaGrid(span: const NebaGridSpan.columns(6), child: block('a')),
          NebaGrid(span: const NebaGridSpan.columns(6), child: block('b')),
        ],
      ),
    );

    expect(rectOf(tester, 'a').width, closeTo(track * 6 - gap, 1e-9));
    expect(rectOf(tester, 'b').left, closeTo(track * 6, 1e-9));
    expect(rectOf(tester, 'b').top, 0);
  });

  testWidgets('wraps a row that is full, with the row gutter between rows', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      NebaGridContainer(
        padded: false,
        rowSpacing: 4,
        children: <Widget>[
          NebaGrid(span: const NebaGridSpan.columns(8), child: block('a')),
          NebaGrid(span: const NebaGridSpan.columns(8), child: block('b')),
        ],
      ),
    );

    expect(rectOf(tester, 'b').left, 0);
    expect(rectOf(tester, 'b').top, 20 + 16);
  });

  testWidgets('keeps everything on one row when it does not wrap', (WidgetTester tester) async {
    await pump(
      tester,
      NebaGridContainer(
        padded: false,
        wrap: false,
        children: <Widget>[
          NebaGrid(span: const NebaGridSpan.columns(8), child: block('a')),
          NebaGrid(span: const NebaGridSpan.columns(8), child: block('b')),
        ],
      ),
    );

    expect(rectOf(tester, 'b').top, 0);
  });

  testWidgets('puts whole columns of margin before an offset item', (WidgetTester tester) async {
    await pump(
      tester,
      NebaGridContainer(
        padded: false,
        children: <Widget>[
          NebaGrid(span: const NebaGridSpan.columns(4), offset: 4, child: block('a')),
        ],
      ),
    );

    expect(rectOf(tester, 'a').left, closeTo(track * 4, 1e-9));
  });

  testWidgets('sizes an auto item to its content and grows a grow item into the rest', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      NebaGridContainer(
        padded: false,
        children: <Widget>[
          NebaGrid(span: NebaGridSpan.auto, child: block('a', width: 120)),
          NebaGrid(span: NebaGridSpan.grow, child: block('b', width: 100)),
        ],
      ),
    );

    expect(rectOf(tester, 'a').width, 120);
    expect(rectOf(tester, 'b').left, 120 + gap);
    expect(rectOf(tester, 'b').right, width);
  });

  testWidgets('places a row\'s leftover space by justifyContent', (WidgetTester tester) async {
    Future<Rect> place(NebaJustifyContent justify) async {
      await pump(
        tester,
        NebaGridContainer(
          padded: false,
          justifyContent: justify,
          children: <Widget>[NebaGrid(span: const NebaGridSpan.columns(4), child: block('a'))],
        ),
      );

      return rectOf(tester, 'a');
    }

    final double itemWidth = track * 4 - gap;

    expect((await place(NebaJustifyContent.start)).left, 0);
    expect((await place(NebaJustifyContent.center)).left, closeTo((width - itemWidth) / 2, 1e-9));
    expect((await place(NebaJustifyContent.end)).right, closeTo(width, 1e-9));
  });

  testWidgets('stretches items to the row by default, and lets one sit otherwise', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      NebaGridContainer(
        padded: false,
        children: <Widget>[
          NebaGrid(span: const NebaGridSpan.columns(4), child: block('tall', height: 60)),
          NebaGrid(
            span: const NebaGridSpan.columns(4),
            child: Container(key: const Key('short')),
          ),
          NebaGrid(
            span: const NebaGridSpan.columns(4),
            alignSelf: NebaAlignSelf.end,
            child: block('end'),
          ),
        ],
      ),
    );

    expect(rectOf(tester, 'short').height, 60);
    expect(rectOf(tester, 'end').top, 40);
  });

  testWidgets('centres items across the row when asked', (WidgetTester tester) async {
    await pump(
      tester,
      NebaGridContainer(
        padded: false,
        alignItems: NebaAlignItems.center,
        children: <Widget>[
          NebaGrid(span: const NebaGridSpan.columns(6), child: block('tall', height: 60)),
          NebaGrid(span: const NebaGridSpan.columns(6), child: block('short')),
        ],
      ),
    );

    expect(rectOf(tester, 'short').top, 20);
  });

  testWidgets('runs from the right under RTL', (WidgetTester tester) async {
    await pump(
      tester,
      NebaGridContainer(
        padded: false,
        children: <Widget>[
          NebaGrid(span: const NebaGridSpan.columns(6), child: block('a')),
          NebaGrid(span: const NebaGridSpan.columns(6), child: block('b')),
        ],
      ),
      textDirection: TextDirection.rtl,
    );

    expect(rectOf(tester, 'a').right, closeTo(width, 1e-9));
    expect(rectOf(tester, 'b').left, closeTo(0, 1e-9));
  });

  testWidgets('divides by its own column count and its own gutters', (WidgetTester tester) async {
    await pump(
      tester,
      NebaGridContainer(
        padded: false,
        columns: 4,
        columnSpacing: 0,
        children: <Widget>[
          NebaGrid(span: const NebaGridSpan.columns(1), child: block('a')),
          NebaGrid(span: const NebaGridSpan.columns(3), child: block('b')),
        ],
      ),
    );

    expect(rectOf(tester, 'a').width, 250);
    expect(rectOf(tester, 'b').left, 250);
  });

  testWidgets('pads itself on the box steps, and lets a plain child be its own width', (
    WidgetTester tester,
  ) async {
    await pump(tester, NebaGridContainer(children: <Widget>[block('plain', width: 50)]));

    expect(rectOf(tester, 'plain').topLeft, const Offset(16, 16));
    expect(rectOf(tester, 'plain').width, 50);
  });
}
