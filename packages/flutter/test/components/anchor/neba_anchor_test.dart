import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  final List<GlobalKey> keys = List<GlobalKey>.generate(4, (int i) => GlobalKey(debugLabel: 's$i'));
  const List<String> names = <String>['Install', 'Setup', 'Tailwind', 'Dark mode'];

  /// Four 300-pixel sections in a 200-pixel view, and the list beside them.
  Widget page({
    ScrollController? controller,
    GlobalKey? active,
    ValueChanged<GlobalKey?>? onActiveChange,
    double offset = 0,
    bool rail = true,
    double section = 300,
  }) {
    return host(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 300,
            height: 200,
            child: SingleChildScrollView(
              controller: controller,
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < keys.length; i++)
                    SizedBox(
                      height: section,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(names[i], key: keys[i]),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: NebaAnchor(
              activeTarget: active,
              onActiveChange: onActiveChange,
              offset: offset,
              rail: rail,
              items: <NebaAnchorItem>[
                for (int i = 0; i < keys.length; i++)
                  NebaAnchorItem(
                    target: keys[i],
                    label: Text('row ${names[i]}'),
                    depth: i == 2 ? 1 : 0,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The colour a row's label is drawn in.
  Color? inkOf(WidgetTester tester, String name) {
    return tester
        .widget<RichText>(
          find.descendant(of: find.text('row $name'), matching: find.byType(RichText)),
        )
        .text
        .style
        ?.color;
  }

  testWidgets('marks the heading the reader has scrolled into, and the last at the end', (
    WidgetTester tester,
  ) async {
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);
    final List<GlobalKey?> reports = <GlobalKey?>[];

    await tester.pumpWidget(page(controller: controller, onActiveChange: reports.add));
    await tester.pumpAndSettle();
    expect(reports.last, keys[0]);

    controller.jumpTo(320);
    await tester.pumpAndSettle();
    expect(reports.last, keys[1]);

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(reports.last, keys[3]);

    final NebaTokens tokens = NebaTheme.of(tester.element(find.byType(NebaAnchor)));
    expect(inkOf(tester, 'Dark mode'), tokens.roles(NebaColor.primary).accent);
    expect(inkOf(tester, 'Install'), tokens.mutedFg);
  });

  testWidgets('counts a heading as reached at the offset below the top', (
    WidgetTester tester,
  ) async {
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);
    final List<GlobalKey?> reports = <GlobalKey?>[];

    await tester.pumpWidget(page(controller: controller, onActiveChange: reports.add, offset: 50));
    await tester.pumpAndSettle();

    // Setup's top is 40 below the top: past the 50-pixel line.
    controller.jumpTo(260);
    await tester.pumpAndSettle();
    expect(reports.last, keys[1]);
  });

  testWidgets('scrolls a pressed row\'s heading to the offset', (WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(page(controller: controller, offset: 20));
    await tester.pumpAndSettle();

    await tester.tap(find.text('row Tailwind'));
    await tester.pumpAndSettle();

    expect(controller.offset, 600 - 20);
  });

  testWidgets('marks the row the caller says, and goes on reporting', (WidgetTester tester) async {
    final List<GlobalKey?> reports = <GlobalKey?>[];

    await tester.pumpWidget(page(active: keys[2], onActiveChange: reports.add));
    await tester.pumpAndSettle();

    final NebaTokens tokens = NebaTheme.of(tester.element(find.byType(NebaAnchor)));
    expect(inkOf(tester, 'Tailwind'), tokens.roles(NebaColor.primary).accent);
    expect(inkOf(tester, 'Install'), tokens.mutedFg);
    expect(reports.last, keys[0]);
  });

  testWidgets('marks the first heading when there is nothing to scroll', (
    WidgetTester tester,
  ) async {
    final List<GlobalKey?> reports = <GlobalKey?>[];

    await tester.pumpWidget(page(onActiveChange: reports.add, section: 40));
    await tester.pumpAndSettle();

    expect(reports.last, keys[0]);
  });

  testWidgets('indents a row by its depth, inside the rail or out of it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(page());
    await tester.pumpAndSettle();
    final double flat = tester.getTopLeft(find.text('row Setup')).dx;
    final double deep = tester.getTopLeft(find.text('row Tailwind')).dx;
    expect(deep - flat, NebaAnchor.indent[NebaSize.md]);

    await tester.pumpWidget(page(rail: false));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('row Tailwind')).dx -
          tester.getTopLeft(find.text('row Setup')).dx,
      NebaAnchor.indent[NebaSize.md],
    );
  });

  testWidgets('is a named list of links with the reader\'s marked', (WidgetTester tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await tester.pumpWidget(page());
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('On this page'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('row Install')),
      matchesSemantics(
        isLink: true,
        isSelected: true,
        hasSelectedState: true,
        label: 'row Install',
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );

    semantics.dispose();
  });
}
