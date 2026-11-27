// NebaAccordion: the suite the React package runs on Accordion, asked the way
// Flutter asks it — the headings and buttons a screen reader hears, which
// sections are open and what the stack reports, what a section takes from the
// stack, and the sheet and rules it is drawn with.

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/disclosure.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  Future<void> pump(WidgetTester tester, Widget accordion) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: 400, child: accordion),
        ),
      ),
    );
  }

  /// The button of the section titled [title].
  Finder button(String title) {
    return find
        .descendant(
          of: find.ancestor(of: find.text(title), matching: find.byType(NebaDisclosureHeader)),
          matching: find.byWidgetPredicate(
            (Widget widget) => widget is Semantics && widget.properties.button == true,
          ),
        )
        .first;
  }

  /// The heading around the button of the section titled [title].
  Finder heading(String title) {
    return find
        .descendant(
          of: find.ancestor(of: find.text(title), matching: find.byType(NebaDisclosureHeader)),
          matching: find.byWidgetPredicate(
            (Widget widget) => widget is Semantics && widget.properties.header == true,
          ),
        )
        .first;
  }

  Matcher section(String label, {required bool expanded}) {
    return matchesSemantics(
      label: label,
      isButton: true,
      hasEnabledState: true,
      isEnabled: true,
      hasExpandedState: true,
      isExpanded: expanded,
      isFocusable: true,
      hasTapAction: true,
      hasFocusAction: true,
    );
  }

  const List<Widget> two = <Widget>[
    NebaAccordionItem<String>(value: 'billing', title: Text('Billing'), child: Text('How')),
    NebaAccordionItem<String>(value: 'regions', title: Text('Regions'), child: Text('Where')),
  ];

  group('rendering', () {
    testWidgets('is a button per section, each inside a level-three heading', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaAccordion<String>(children: two));

      expect(tester.getSemantics(button('Billing')), section('Billing', expanded: false));
      expect(tester.getSemantics(button('Regions')), section('Regions', expanded: false));

      final SemanticsNode header = tester.getSemantics(heading('Billing'));
      expect(header, matchesSemantics(isHeader: true));
      expect(header.getSemanticsData().headingLevel, 3);
      semantics.dispose();
    });

    testWidgets('puts each header at the level the accordion was given', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaAccordion<String>(headingLevel: 2, children: two));

      expect(tester.getSemantics(heading('Regions')).getSemanticsData().headingLevel, 2);
      semantics.dispose();
    });

    testWidgets('draws a subtitle under the title', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAccordion<String>(
          children: <Widget>[
            NebaAccordionItem<String>(title: Text('Billing'), subtitle: Text('Invoices and cards')),
          ],
        ),
      );

      expect(find.text('Invoices and cards'), findsOneWidget);
    });

    testWidgets('shows the section that starts open', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaAccordion<String>(defaultValue: <String>['billing'], children: two),
      );

      expect(tester.getSemantics(button('Billing')), section('Billing', expanded: true));
      expect(find.text('How'), findsOneWidget);
      expect(find.text('Where'), findsNothing);
      semantics.dispose();
    });

    testWidgets('reflects a changed title on rebuild', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAccordion<String>(
          children: <Widget>[NebaAccordionItem<String>(title: Text('A'))],
        ),
      );
      await pump(
        tester,
        const NebaAccordion<String>(
          children: <Widget>[NebaAccordionItem<String>(title: Text('B'))],
        ),
      );

      expect(find.text('B'), findsOneWidget);
      expect(find.text('A'), findsNothing);
    });

    testWidgets('lets a title wrap until it is told how many lines to keep', (
      WidgetTester tester,
    ) async {
      const String question = 'What happens to my data when I close my account?';

      await pump(
        tester,
        const NebaAccordion<String>(
          children: <Widget>[NebaAccordionItem<String>(title: Text(question))],
        ),
      );

      expect(DefaultTextStyle.of(tester.element(find.text(question))).maxLines, isNull);

      await pump(
        tester,
        const NebaAccordion<String>(
          children: <Widget>[NebaAccordionItem<String>(lines: 2, title: Text(question))],
        ),
      );

      final DefaultTextStyle style = DefaultTextStyle.of(tester.element(find.text(question)));
      expect(style.maxLines, 2);
      expect(style.overflow, TextOverflow.ellipsis);
    });

    testWidgets('fails loudly when a section is used outside an accordion', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaAccordionItem<String>(title: Text('Lost')));

      expect(tester.takeException(), isA<FlutterError>());
    });
  });

  group('folding', () {
    testWidgets('opens a section when its header is pressed', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaAccordion<String>(children: two));

      await tester.tap(find.text('Billing'));
      await tester.pumpAndSettle();

      expect(tester.getSemantics(button('Billing')), section('Billing', expanded: true));
      expect(find.text('How'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('keeps a closed section built, and drops it when told not to', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaAccordion<String>(children: two));

      expect(find.text('How'), findsNothing);
      expect(find.text('How', skipOffstage: false), findsOneWidget);

      await pump(tester, const NebaAccordion<String>(keepMounted: false, children: two));

      expect(find.text('How', skipOffstage: false), findsNothing);
    });

    testWidgets('reports which sections are open', (WidgetTester tester) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(tester, NebaAccordion<String>(onValueChange: reported.add, children: two));

      await tester.tap(find.text('Billing'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Billing'));
      await tester.pumpAndSettle();

      expect(reported, <List<String>>[
        <String>['billing'],
        <String>[],
      ]);
    });

    // Closing the last one as you open the next is the whole reason an
    // accordion is not just a stack of collapsibles.
    testWidgets('closes the open section when another is opened', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<List<String>> reported = <List<String>>[];

      await pump(
        tester,
        NebaAccordion<String>(
          defaultValue: const <String>['billing'],
          onValueChange: reported.add,
          children: two,
        ),
      );

      await tester.tap(find.text('Regions'));
      await tester.pumpAndSettle();

      expect(tester.getSemantics(button('Billing')), section('Billing', expanded: false));
      expect(tester.getSemantics(button('Regions')), section('Regions', expanded: true));
      expect(reported.single, <String>['regions']);
      semantics.dispose();
    });

    testWidgets('keeps both open when multiple is set', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<List<String>> reported = <List<String>>[];

      await pump(
        tester,
        NebaAccordion<String>(
          multiple: true,
          defaultValue: const <String>['billing'],
          onValueChange: reported.add,
          children: two,
        ),
      );

      await tester.tap(find.text('Regions'));
      await tester.pumpAndSettle();

      expect(tester.getSemantics(button('Billing')), section('Billing', expanded: true));
      expect(tester.getSemantics(button('Regions')), section('Regions', expanded: true));
      expect(reported.single, <String>['billing', 'regions']);
      semantics.dispose();
    });

    testWidgets('follows a controlled value and nothing else', (WidgetTester tester) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(
        tester,
        NebaAccordion<String>(value: const <String>[], onValueChange: reported.add, children: two),
      );

      await tester.tap(find.text('Billing'));
      await tester.pumpAndSettle();

      expect(reported.single, <String>['billing']);
      expect(find.text('How'), findsNothing);

      await pump(
        tester,
        NebaAccordion<String>(
          value: const <String>['billing'],
          onValueChange: reported.add,
          children: two,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('How'), findsOneWidget);
    });

    testWidgets('opens a section with no value, and leaves it out of what it reports', (
      WidgetTester tester,
    ) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(
        tester,
        NebaAccordion<String>(
          multiple: true,
          defaultValue: const <String>['billing'],
          onValueChange: reported.add,
          children: const <Widget>[
            NebaAccordionItem<String>(value: 'billing', title: Text('Billing'), child: Text('How')),
            NebaAccordionItem<String>(title: Text('Unnamed'), child: Text('Body')),
            NebaAccordionItem<String>(title: Text('Other'), child: Text('Else')),
          ],
        ),
      );

      await tester.tap(find.text('Unnamed'));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsOneWidget);
      // Named by its place, so its neighbour with no value stays shut.
      expect(find.text('Else'), findsNothing);
      expect(reported.single, <String>['billing']);
    });

    testWidgets('does not fold a disabled section, and the rest keep working', (
      WidgetTester tester,
    ) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(
        tester,
        NebaAccordion<String>(
          onValueChange: reported.add,
          children: const <Widget>[
            NebaAccordionItem<String>(
              value: 'billing',
              title: Text('Billing'),
              disabled: true,
              child: Text('How'),
            ),
            NebaAccordionItem<String>(
              value: 'regions',
              title: Text('Regions'),
              child: Text('Where'),
            ),
          ],
        ),
      );

      await tester.tap(find.text('Billing'));
      await tester.pumpAndSettle();

      expect(reported, isEmpty);
      expect(find.text('How'), findsNothing);

      await tester.tap(find.text('Regions'));
      await tester.pumpAndSettle();

      expect(find.text('Where'), findsOneWidget);
    });

    testWidgets('does not fold anything when the whole accordion is disabled', (
      WidgetTester tester,
    ) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(
        tester,
        NebaAccordion<String>(disabled: true, onValueChange: reported.add, children: two),
      );

      await tester.tap(find.text('Billing'));
      await tester.pumpAndSettle();

      expect(reported, isEmpty);
      expect(find.text('How'), findsNothing);
    });

    testWidgets('looks disabled, whether the section or the accordion is', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const Column(
          children: <Widget>[
            NebaAccordion<String>(
              children: <Widget>[NebaAccordionItem<String>(title: Text('Section'), disabled: true)],
            ),
            NebaAccordion<String>(
              disabled: true,
              children: <Widget>[NebaAccordionItem<String>(title: Text('Whole'))],
            ),
            NebaAccordion<String>(
              children: <Widget>[NebaAccordionItem<String>(title: Text('Open'))],
            ),
          ],
        ),
      );

      Color? ink(String text) => DefaultTextStyle.of(tester.element(find.text(text))).style.color;

      expect(ink('Section'), tokens.disabledFg);
      expect(ink('Whole'), tokens.disabledFg);
      expect(ink('Open'), tokens.fg);
    });
  });

  group('the action beside the header', () {
    // A header that both folds and holds a button has two things to press,
    // and one of them cannot be nested inside the other.
    testWidgets('keeps the action out of the folding area', (WidgetTester tester) async {
      int pressed = 0;

      await pump(
        tester,
        NebaAccordion<String>(
          children: <Widget>[
            NebaAccordionItem<String>(
              value: 'billing',
              title: const Text('Billing'),
              action: NebaButton(onPressed: () => pressed++, child: const Text('Manage')),
              child: const Text('How'),
            ),
          ],
        ),
      );

      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();

      expect(pressed, 1);
      expect(find.text('How'), findsNothing);
    });

    testWidgets('leaves the action out of the heading and its name', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaAccordion<String>(
          children: <Widget>[
            NebaAccordionItem<String>(
              value: 'billing',
              title: const Text('Billing'),
              action: NebaButton(onPressed: () {}, child: const Text('Manage')),
            ),
          ],
        ),
      );

      expect(tester.getSemantics(button('Billing')).label, 'Billing');
      expect(find.descendant(of: heading('Billing'), matching: find.text('Manage')), findsNothing);
      semantics.dispose();
    });
  });

  group('what a section inherits', () {
    double inset(WidgetTester tester, String title) {
      return tester.getTopLeft(find.text(title)).dx -
          tester.getTopLeft(find.byType(NebaAccordion<String>)).dx;
    }

    testWidgets('takes its size from the accordion', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAccordion<String>(
          size: NebaSize.xl,
          children: <Widget>[NebaAccordionItem<String>(title: Text('Billing'))],
        ),
      );

      // The hairline, then a box's padding at xl.
      expect(inset(tester, 'Billing'), 1 + 24);
    });

    testWidgets('takes its density from the accordion', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAccordion<String>(
          density: NebaDensity.compact,
          children: <Widget>[NebaAccordionItem<String>(title: Text('Billing'))],
        ),
      );

      expect(inset(tester, 'Billing'), 1 + 10);
    });

    // A section cannot be a floating tile and a ruled line at the same time.
    testWidgets('squares the sections off when the accordion is ruled', (
      WidgetTester tester,
    ) async {
      NebaDisclosureHeader header() {
        return tester.widget<NebaDisclosureHeader>(find.byType(NebaDisclosureHeader));
      }

      await pump(
        tester,
        const NebaAccordion<String>(
          dividers: false,
          children: <Widget>[NebaAccordionItem<String>(title: Text('Billing'))],
        ),
      );

      expect(header().borderRadius, BorderRadius.circular(tokens.radius[NebaSize.sm]!));
      // A hair of padding inside the sheet keeps a tile off its edge.
      expect(inset(tester, 'Billing'), 1 + 4 + 16);

      await pump(
        tester,
        const NebaAccordion<String>(
          children: <Widget>[NebaAccordionItem<String>(title: Text('Billing'))],
        ),
      );

      expect(header().borderRadius, BorderRadius.zero);
    });

    // A ruled accordion clips what is on it, and a ring outside a header that
    // spans it would be cut off.
    testWidgets('draws the focus ring inside the edge only when ruled', (
      WidgetTester tester,
    ) async {
      NebaFocusRing ring() => tester.widget<NebaFocusRing>(find.byType(NebaFocusRing));

      await pump(
        tester,
        const NebaAccordion<String>(
          children: <Widget>[NebaAccordionItem<String>(title: Text('Billing'))],
        ),
      );

      expect(ring().offset, -focusRingWidth);
      expect(ring().color, primary.ring);

      await pump(
        tester,
        const NebaAccordion<String>(
          dividers: false,
          children: <Widget>[NebaAccordionItem<String>(title: Text('Billing'))],
        ),
      );

      expect(ring().offset, focusRingOffset);
    });
  });

  group('style', () {
    NebaSheet sheet(WidgetTester tester) {
      return tester.widget<NebaSheet>(
        find.descendant(of: find.byType(NebaAccordion<String>), matching: find.byType(NebaSheet)),
      );
    }

    testWidgets('is an outline sheet, undyed, with an edge in its family', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaAccordion<String>(color: NebaColor.success, elevation: 3, children: two),
      );

      expect(sheet(tester).fill, tokens.panel);
      expect(sheet(tester).edge, tokens.roles(NebaColor.success).line);
      expect(sheet(tester).elevation, 3);
    });

    testWidgets('rules between the sections and not above the first', (WidgetTester tester) async {
      await pump(tester, const NebaAccordion<String>(children: two));

      List<Border> rules() {
        return <Border>[
          for (final Container container in tester.widgetList<Container>(
            find.descendant(
              of: find.byType(NebaAccordion<String>),
              matching: find.byType(Container),
            ),
          ))
            if (container.decoration case BoxDecoration(border: final Border border)) border,
        ];
      }

      expect(rules(), <Border>[Border(top: BorderSide(color: primary.line))]);

      await pump(tester, const NebaAccordion<String>(dividers: false, children: two));

      expect(rules(), isEmpty);
    });

    testWidgets('washes a header under the pointer and inks an open one', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaAccordion<String>(children: two));

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.text('Billing')));
      await tester.tap(find.text('Billing'));
      await tester.pumpAndSettle();

      final DecoratedBox wash = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.ancestor(
                of: find.text('Billing'),
                matching: find.byType(NebaDisclosureHeader),
              ),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect((wash.decoration as BoxDecoration).color, primary.soft);
      expect(DefaultTextStyle.of(tester.element(find.text('Billing'))).style.color, primary.onTint);
      expect(DefaultTextStyle.of(tester.element(find.text('Regions'))).style.color, tokens.fg);
      await mouse.removePointer();
    });

    // The panel's height moves, which moves no text relative to the panel it
    // is in. Nothing but the chevrons is ever transformed.
    testWidgets('never transforms anything but a chevron', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAccordion<String>(defaultValue: <String>['billing'], children: two),
      );

      await tester.tap(find.text('Regions'));
      await tester.pump(const Duration(milliseconds: 80));

      final int all = tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byType(NebaAccordion<String>),
              matching: find.byType(Transform),
            ),
          )
          .length;
      final int turned = tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byType(NebaDisclosureChevron),
              matching: find.byType(Transform),
            ),
          )
          .length;
      expect(all, turned);
      await tester.pumpAndSettle();
    });
  });
}
