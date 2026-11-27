// NebaSources: the suite the React package runs on Sources, asked the way
// Flutter asks it — the heading that counts what it folds, the numbers drawn
// beside the rows, the rows that are links and the ones that are not, and the
// fold.

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/agent.dart';

import '../../support/host.dart';

void main() {
  final List<String> opened = <String>[];

  List<NebaSourceItem> items() {
    return <NebaSourceItem>[
      NebaSourceItem(
        title: const Text('Design language'),
        href: Uri.parse('https://example.com/design'),
        onPressed: () => opened.add('design'),
      ),
      NebaSourceItem(
        title: const Text('Breakpoints'),
        href: Uri.parse('https://example.com/breakpoints'),
        onPressed: () => opened.add('breakpoints'),
      ),
      const NebaSourceItem(title: Text('An unlinked note')),
    ];
  }

  setUp(opened.clear);

  Future<void> pump(WidgetTester tester, Widget sources) async {
    await tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: 480, child: sources),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder trigger() => find.byType(NebaFoldTrigger);

  /// Whether the heading is heard as expanded.
  void expectExpanded(WidgetTester tester, bool expanded) {
    expect(
      tester.getSemantics(find.descendant(of: trigger(), matching: find.byType(Semantics)).first),
      matchesSemantics(
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        isExpanded: expanded,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
  }

  List<int> numbers(WidgetTester tester) {
    return tester
        .widgetList<NebaCitationMark>(find.byType(NebaCitationMark, skipOffstage: false))
        .map((NebaCitationMark mark) => mark.index)
        .toList();
  }

  group('rendering', () {
    testWidgets('names itself when it was not given a name', (WidgetTester tester) async {
      await pump(tester, NebaSources(items: items()));

      expect(find.text('Sources'), findsOneWidget);
    });

    testWidgets('counts what it holds on the closed header', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaSources(items: items()));

      expect(find.text('3'), findsOneWidget);
      expect(
        tester
            .getSemantics(find.descendant(of: trigger(), matching: find.byType(Semantics)).first)
            .label,
        'Sources\n3',
      );
      semantics.dispose();
    });

    testWidgets('numbers the rows in the order they were given', (WidgetTester tester) async {
      await pump(tester, NebaSources(items: items(), defaultOpen: true));

      expect(numbers(tester), <int>[1, 2, 3]);
    });

    testWidgets('takes a number a source claims for itself', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaSources(
          defaultOpen: true,
          items: <NebaSourceItem>[
            NebaSourceItem(title: Text('One'), index: 4),
            NebaSourceItem(title: Text('Two'), index: 9),
          ],
        ),
      );

      expect(numbers(tester), <int>[4, 9]);
    });

    testWidgets('drops the numbers when it is asked to', (WidgetTester tester) async {
      await pump(tester, NebaSources(items: items(), defaultOpen: true, numbered: false));

      expect(numbers(tester), isEmpty);
    });

    testWidgets('is a list of its rows', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaSources(items: items(), defaultOpen: true));

      final Iterable<Semantics> roles = tester.widgetList<Semantics>(
        find.descendant(of: find.byType(NebaSources), matching: find.byType(Semantics)),
      );
      expect(roles.where((Semantics s) => s.properties.role == SemanticsRole.list), hasLength(1));
      expect(
        roles.where((Semantics s) => s.properties.role == SemanticsRole.listItem),
        hasLength(3),
      );
      semantics.dispose();
    });
  });

  group('links', () {
    testWidgets('links the rows that have something to do on a press', (WidgetTester tester) async {
      await pump(tester, NebaSources(items: items(), defaultOpen: true));

      expect(find.byType(NebaTextLink), findsNWidgets(2));
      await tester.tap(find.text('Breakpoints'));
      expect(opened, <String>['breakpoints']);
    });

    testWidgets('hands the address on to a screen reader', (WidgetTester tester) async {
      await pump(tester, NebaSources(items: items(), defaultOpen: true));

      expect(
        tester.widget<NebaTextLink>(find.byType(NebaTextLink).first).href,
        Uri.parse('https://example.com/design'),
      );
    });

    testWidgets('leaves a row without one as plain text', (WidgetTester tester) async {
      await pump(tester, NebaSources(items: items(), defaultOpen: true));

      expect(
        find.ancestor(of: find.text('An unlinked note'), matching: find.byType(NebaTextLink)),
        findsNothing,
      );
    });

    // An address in a search result was not written by the app's author.
    testWidgets('refuses an address whose scheme is not one of the four', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaSources(
          defaultOpen: true,
          items: <NebaSourceItem>[
            NebaSourceItem(
              title: const Text('Trouble'),
              href: Uri.parse('javascript:alert(1)'),
              onPressed: () {},
            ),
          ],
        ),
      );

      expect(find.byType(NebaTextLink), findsNothing);
    });

    testWidgets('says a link leaves the app', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaSources(
          defaultOpen: true,
          items: <NebaSourceItem>[
            NebaSourceItem(
              title: const Text('Away'),
              href: Uri.parse('https://example.com'),
              onPressed: () {},
              newTab: true,
            ),
          ],
        ),
      );

      expect(find.bySemanticsLabel(RegExp(r'Away[\s\S]*opens in a new tab')), findsOneWidget);
      semantics.dispose();
    });
  });

  group('folding', () {
    testWidgets('starts closed', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaSources(items: items()));

      expectExpanded(tester, false);
      expect(find.text('Breakpoints'), findsNothing);
      semantics.dispose();
    });

    testWidgets('keeps a folded list built, unless keepMounted is off', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaSources(items: items()));
      expect(find.text('Breakpoints', skipOffstage: false), findsOneWidget);

      await pump(tester, NebaSources(items: items(), keepMounted: false));
      expect(find.text('Breakpoints', skipOffstage: false), findsNothing);
    });

    testWidgets('opens when the heading is pressed', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<bool> changes = <bool>[];

      await pump(tester, NebaSources(items: items(), onOpenChange: changes.add));
      await tester.tap(trigger());
      await tester.pumpAndSettle();

      expectExpanded(tester, true);
      expect(find.text('Breakpoints'), findsOneWidget);
      expect(changes, <bool>[true]);
      semantics.dispose();
    });

    testWidgets('folds again when the heading is pressed a second time', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaSources(items: items(), defaultOpen: true));
      await tester.tap(trigger());
      await tester.pumpAndSettle();

      expectExpanded(tester, false);
      expect(find.text('Breakpoints'), findsNothing);
      semantics.dispose();
    });

    testWidgets('is not a disclosure at all when it was told not to be', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaSources(items: items(), collapsible: false));

      expect(trigger(), findsNothing);
      expect(find.text('Breakpoints'), findsOneWidget);
    });
  });

  group('its words', () {
    testWidgets('takes a heading of its own, or words of its own', (WidgetTester tester) async {
      await pump(tester, NebaSources(items: items(), title: const Text('Read more')));
      expect(find.text('Read more'), findsOneWidget);

      await pump(
        tester,
        NebaSources(items: items(), labels: const <String, String>{'title': 'Quellen'}),
      );
      expect(find.text('Quellen'), findsOneWidget);
    });
  });
}
