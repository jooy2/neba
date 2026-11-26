// NebaFlex: a row or a column with a gutter, measured on the laid-out boxes.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    NebaFlex flex, {
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return tester.pumpWidget(
      host(
        Align(alignment: Alignment.topLeft, child: flex),
        textDirection: textDirection,
      ),
    );
  }

  Widget block(String key, {double width = 40, double? height = 20}) {
    return SizedBox(key: Key(key), width: width, height: height);
  }

  Rect rectOf(WidgetTester tester, String key) => tester.getRect(find.byKey(Key(key)));

  testWidgets('runs a row with the gutter on the spacing scale', (WidgetTester tester) async {
    await pump(
      tester,
      NebaFlex(
        spacing: 2,
        alignItems: NebaAlignItems.start,
        children: <Widget>[block('a'), block('b')],
      ),
    );

    expect(rectOf(tester, 'b').left, 40 + 8);
    expect(rectOf(tester, 'b').top, 0);
  });

  testWidgets('runs a column, and reverses either', (WidgetTester tester) async {
    await pump(
      tester,
      NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 1,
        alignItems: NebaAlignItems.start,
        children: <Widget>[block('a'), block('b')],
      ),
    );
    expect(rectOf(tester, 'b').top, 20 + 4);

    await pump(
      tester,
      NebaFlex(
        reverse: true,
        alignItems: NebaAlignItems.start,
        inline: true,
        children: <Widget>[block('a'), block('b')],
      ),
    );
    expect(rectOf(tester, 'a').left, greaterThan(rectOf(tester, 'b').left));
  });

  testWidgets('stretches its children to the thickest one by default', (WidgetTester tester) async {
    await pump(
      tester,
      NebaFlex(
        children: <Widget>[
          block('tall', height: 60),
          SizedBox(key: const Key('free'), width: 40, child: Container()),
        ],
      ),
    );

    expect(rectOf(tester, 'free').height, 60);
  });

  testWidgets('distributes what is left and aligns across the row', (WidgetTester tester) async {
    await pump(
      tester,
      NebaFlex(
        justifyContent: NebaJustifyContent.spaceBetween,
        alignItems: NebaAlignItems.center,
        children: <Widget>[block('a', height: 60), block('b')],
      ),
    );

    expect(rectOf(tester, 'b').right, 800);
    expect(rectOf(tester, 'b').top, 20);
  });

  testWidgets('wraps onto a new run with the other gutter between runs', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      NebaFlex(
        wrap: true,
        columnSpacing: 0,
        rowSpacing: 2,
        children: <Widget>[block('a', width: 500), block('b', width: 500)],
      ),
    );

    expect(rectOf(tester, 'b').left, 0);
    expect(rectOf(tester, 'b').top, 20 + 8);
  });

  testWidgets('is as wide as it may be as a block, and as its children inline', (
    WidgetTester tester,
  ) async {
    await pump(tester, NebaFlex(alignItems: NebaAlignItems.start, children: <Widget>[block('a')]));
    expect(tester.getSize(find.byType(NebaFlex)).width, 800);

    await pump(
      tester,
      NebaFlex(inline: true, alignItems: NebaAlignItems.start, children: <Widget>[block('a')]),
    );
    expect(tester.getSize(find.byType(NebaFlex)).width, 40);
  });

  testWidgets('starts from the right under RTL', (WidgetTester tester) async {
    await pump(
      tester,
      NebaFlex(alignItems: NebaAlignItems.start, children: <Widget>[block('a')]),
      textDirection: TextDirection.rtl,
    );

    expect(rectOf(tester, 'a').right, 800);
  });
}
