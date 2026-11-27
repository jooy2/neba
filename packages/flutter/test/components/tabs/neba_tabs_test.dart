// NebaTabs: the suite the React package runs on Tabs, asked the way Flutter
// asks it — the tab bar and tabs a screen reader hears, which panel is built,
// where the focus and the arrow keys go, the rectangle the indicator is laid
// out at, the bar's overflow and its fade, and what the wheel does over it.

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/scroll_fade.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/internal/tile.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  const List<Widget> basic = <Widget>[
    NebaTab<String>(value: 'overview', child: Text('Overview')),
    NebaTab<String>(value: 'usage', child: Text('Usage')),
    NebaTab<String>(value: 'billing', child: Text('Billing')),
    NebaTabPanel<String>(value: 'overview', child: Text('What this project is.')),
    NebaTabPanel<String>(value: 'usage', child: Text('How much you used.')),
    NebaTabPanel<String>(value: 'billing', child: Text('What you owe.')),
  ];

  Future<void> pump(
    WidgetTester tester,
    Widget tabs, {
    double width = 400,
    TextDirection direction = TextDirection.ltr,
    bool disableAnimations = false,
  }) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: width, child: tabs),
        ),
        textDirection: direction,
        disableAnimations: disableAnimations,
      ),
    );
  }

  Finder tab(String label) {
    return find.ancestor(of: find.text(label), matching: find.byType(NebaTab<String>));
  }

  FocusNode nodeOf(WidgetTester tester, String label) => Focus.of(tester.element(find.text(label)));

  /// The indicator: the first child the run lays out.
  Rect tileRect(WidgetTester tester) {
    final Finder tile = find.descendant(
      of: find.byType(NebaTileRun),
      matching: find.byWidgetPredicate(
        (Widget widget) =>
            widget is NebaSheet ||
            (widget is Align &&
                widget.child is SizedBox &&
                (widget.child! as SizedBox).child is DecoratedBox),
      ),
    );

    return tester.getRect(tile.first);
  }

  Matcher aTab(String label, {required bool selected, bool enabled = true}) {
    return matchesSemantics(
      label: label,
      role: SemanticsRole.tab,
      hasSelectedState: true,
      isSelected: selected,
      hasEnabledState: true,
      isEnabled: enabled,
      isFocusable: true,
      hasTapAction: enabled,
      hasFocusAction: true,
    );
  }

  group('rendering', () {
    testWidgets('is a tab bar of tabs, the chosen one selected', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaTabs<String>(semanticLabel: 'Project', defaultValue: 'usage', children: basic),
      );

      final SemanticsNode bar = tester.getSemantics(
        find.descendant(of: find.byType(NebaTabs<String>), matching: find.byType(NebaTileRun)),
      );
      expect(bar.getSemanticsData().role, SemanticsRole.tabBar);
      expect(bar.label, 'Project');
      expect(bar.childrenCount, 3);

      expect(tester.getSemantics(tab('Usage')), aTab('Usage', selected: true));
      expect(tester.getSemantics(tab('Overview')), aTab('Overview', selected: false));
      semantics.dispose();
    });

    testWidgets('puts the panels under the bar rather than in it', (WidgetTester tester) async {
      await pump(tester, const NebaTabs<String>(defaultValue: 'overview', children: basic));

      expect(
        find.descendant(of: find.byType(NebaTileRun), matching: find.text('What this project is.')),
        findsNothing,
      );
      expect(
        tester.getTopLeft(find.text('What this project is.')).dy,
        tester.getBottomLeft(find.byType(NebaTileRun)).dy + 1 + 16,
      );
    });

    testWidgets('shows only the chosen panel, and builds no other', (WidgetTester tester) async {
      await pump(tester, const NebaTabs<String>(defaultValue: 'usage', children: basic));

      expect(find.text('How much you used.'), findsOneWidget);
      expect(find.text('What this project is.', skipOffstage: false), findsNothing);
    });

    testWidgets('names a panel after its tab, as a tab panel', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaTabs<String>(defaultValue: 'usage', children: basic));

      final SemanticsNode panel = tester.getSemantics(
        find.ancestor(of: find.text('How much you used.'), matching: find.byType(Semantics)).first,
      );
      expect(panel.getSemanticsData().role, SemanticsRole.tabPanel);
      expect(panel.label, 'Usage');
      semantics.dispose();
    });

    testWidgets('reflects a changed label on rebuild', (WidgetTester tester) async {
      Widget build(String label) {
        return NebaTabs<String>(
          defaultValue: 'a',
          children: <Widget>[
            NebaTab<String>(value: 'a', child: Text(label)),
            const NebaTabPanel<String>(value: 'a', child: Text('Body')),
          ],
        );
      }

      await pump(tester, build('Before'));
      await pump(tester, build('After'));

      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    });

    testWidgets('fails loudly when a tab is used outside a set', (WidgetTester tester) async {
      await pump(tester, const NebaTab<String>(value: 'a', child: Text('Lost')));

      expect(tester.takeException(), isA<FlutterError>());
    });
  });

  group('choosing', () {
    testWidgets('switches the panel when a tab is pressed', (WidgetTester tester) async {
      await pump(tester, const NebaTabs<String>(defaultValue: 'overview', children: basic));

      await tester.tap(find.text('Billing'));
      await tester.pumpAndSettle();

      expect(find.text('What you owe.'), findsOneWidget);
      expect(find.text('What this project is.', skipOffstage: false), findsNothing);
    });

    // The indicator already travels; the content under it changed in a single
    // frame. Only the arriving panel fades, so the two are never laid out
    // together.
    testWidgets('fades the arriving panel up, and nothing on the first frame', (
      WidgetTester tester,
    ) async {
      double opacityOf(String text) {
        return tester
            .widget<FadeTransition>(
              find.ancestor(of: find.text(text), matching: find.byType(FadeTransition)).first,
            )
            .opacity
            .value;
      }

      await pump(tester, const NebaTabs<String>(defaultValue: 'overview', children: basic));

      expect(opacityOf('What this project is.'), 1);

      await tester.tap(find.text('Billing'));
      await tester.pump();
      await tester.pump(NebaScale.duration ~/ 4);

      expect(opacityOf('What you owe.'), greaterThan(0));
      expect(opacityOf('What you owe.'), lessThan(1));
      expect(find.text('What this project is.', skipOffstage: false), findsNothing);

      await tester.pumpAndSettle();

      expect(opacityOf('What you owe.'), 1);
    });

    testWidgets('reports the chosen value', (WidgetTester tester) async {
      final List<String?> reported = <String?>[];

      await pump(
        tester,
        NebaTabs<String>(defaultValue: 'overview', onValueChange: reported.add, children: basic),
      );

      await tester.tap(find.text('Billing'));
      await tester.pump();
      await tester.tap(find.text('Billing'));
      await tester.pump();

      expect(reported, <String>['billing']);
    });

    testWidgets('follows a controlled value and nothing else', (WidgetTester tester) async {
      final List<String?> reported = <String?>[];

      await pump(
        tester,
        NebaTabs<String>(value: 'overview', onValueChange: reported.add, children: basic),
      );

      await tester.tap(find.text('Billing'));
      await tester.pumpAndSettle();

      expect(reported, <String>['billing']);
      expect(find.text('What this project is.'), findsOneWidget);

      await pump(
        tester,
        NebaTabs<String>(value: 'billing', onValueChange: reported.add, children: basic),
      );
      await tester.pumpAndSettle();

      expect(find.text('What you owe.'), findsOneWidget);
    });

    testWidgets('does not choose a disabled tab, and greys it', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaTabs<String>(
          defaultValue: 'a',
          children: <Widget>[
            NebaTab<String>(value: 'a', child: Text('Overview')),
            NebaTab<String>(value: 'b', disabled: true, child: Text('Usage')),
            NebaTabPanel<String>(value: 'a', child: Text('First')),
            NebaTabPanel<String>(value: 'b', child: Text('Second')),
          ],
        ),
      );

      await tester.tap(find.text('Usage'));
      await tester.pumpAndSettle();

      expect(find.text('First'), findsOneWidget);
      expect(
        DefaultTextStyle.of(tester.element(find.text('Usage'))).style.color,
        tokens.disabledFg,
      );
      expect(
        tester.getSemantics(tab('Usage')),
        matchesSemantics(
          label: 'Usage',
          role: SemanticsRole.tab,
          hasSelectedState: true,
          hasEnabledState: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('inks the chosen tab in the accent and the rest muted', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTabs<String>(color: NebaColor.success, defaultValue: 'usage', children: basic),
      );

      Color? ink(String label) => DefaultTextStyle.of(tester.element(find.text(label))).style.color;

      expect(ink('Usage'), tokens.roles(NebaColor.success).accent);
      expect(ink('Overview'), tokens.mutedFg);
    });
  });

  group('keepMounted', () {
    testWidgets('keeps one panel built while hidden when it says so', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTabs<String>(
          defaultValue: 'a',
          children: <Widget>[
            NebaTab<String>(value: 'a', child: Text('Overview')),
            NebaTab<String>(value: 'b', child: Text('Usage')),
            NebaTabPanel<String>(value: 'a', child: Text('First')),
            NebaTabPanel<String>(value: 'b', keepMounted: true, child: Text('Second')),
          ],
        ),
      );

      expect(find.text('Second'), findsNothing);
      expect(find.text('Second', skipOffstage: false), findsOneWidget);
    });

    testWidgets('keeps every panel built, hidden, when the set says so', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTabs<String>(defaultValue: 'overview', keepMounted: true, children: basic),
      );

      expect(find.text('How much you used.', skipOffstage: false), findsOneWidget);
      expect(find.text('How much you used.'), findsNothing);
      expect(find.text('What this project is.'), findsOneWidget);

      await tester.tap(find.text('Billing'));
      await tester.pumpAndSettle();

      expect(find.text('What you owe.'), findsOneWidget);
      expect(find.text('What this project is.'), findsNothing);
      expect(find.text('What this project is.', skipOffstage: false), findsOneWidget);
    });

    testWidgets('lets a panel of its own say otherwise', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTabs<String>(
          defaultValue: 'a',
          keepMounted: true,
          children: <Widget>[
            NebaTab<String>(value: 'a', child: Text('Overview')),
            NebaTab<String>(value: 'b', child: Text('Usage')),
            NebaTabPanel<String>(value: 'a', child: Text('First')),
            NebaTabPanel<String>(value: 'b', keepMounted: false, child: Text('Second')),
          ],
        ),
      );

      expect(find.text('Second', skipOffstage: false), findsNothing);
    });

    testWidgets('keeps a kept panel\'s state through being switched away from', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTabs<String>(
          defaultValue: 'a',
          keepMounted: true,
          children: <Widget>[
            NebaTab<String>(value: 'a', child: Text('Note')),
            NebaTab<String>(value: 'b', child: Text('Other')),
            NebaTabPanel<String>(
              value: 'a',
              child: NebaTextField(label: Text('Leave it with'), placeholder: 'Who'),
            ),
            NebaTabPanel<String>(value: 'b', child: Text('Second')),
          ],
        ),
      );

      await tester.enterText(find.byType(EditableText), 'The porter');
      await tester.tap(find.text('Other'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Note'));
      await tester.pumpAndSettle();

      expect(find.text('The porter'), findsOneWidget);
    });
  });

  group('the keyboard', () {
    // The whole bar is one stop in the focus order, and the arrow keys walk
    // it. That is the difference between a tab bar and a row of buttons.
    testWidgets('makes the bar one stop in the focus order, at the chosen tab', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTabs<String>(defaultValue: 'usage', children: basic));

      expect(nodeOf(tester, 'Usage').skipTraversal, isFalse);
      expect(nodeOf(tester, 'Overview').skipTraversal, isTrue);
      expect(nodeOf(tester, 'Billing').skipTraversal, isTrue);
    });

    testWidgets('walks the tabs with the arrow keys and chooses with Enter', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTabs<String>(defaultValue: 'overview', children: basic));

      nodeOf(tester, 'Overview').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(nodeOf(tester, 'Usage').hasPrimaryFocus, isTrue);
      // Not chosen on the arrow alone.
      expect(find.text('What this project is.'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.text('How much you used.'), findsOneWidget);
    });

    testWidgets('chooses on the arrow when activateOnFocus is set', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTabs<String>(defaultValue: 'overview', activateOnFocus: true, children: basic),
      );

      nodeOf(tester, 'Overview').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(find.text('How much you used.'), findsOneWidget);
    });

    testWidgets('goes to the ends with Home and End, and wraps unless told not to', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTabs<String>(defaultValue: 'overview', children: basic));

      nodeOf(tester, 'Overview').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(nodeOf(tester, 'Billing').hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(nodeOf(tester, 'Overview').hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(nodeOf(tester, 'Overview').hasPrimaryFocus, isTrue);

      await pump(
        tester,
        const NebaTabs<String>(defaultValue: 'overview', loopFocus: false, children: basic),
      );
      nodeOf(tester, 'Overview').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(nodeOf(tester, 'Overview').hasPrimaryFocus, isTrue);
    });

    testWidgets('reaches a disabled tab without choosing it', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTabs<String>(
          defaultValue: 'a',
          activateOnFocus: true,
          children: <Widget>[
            NebaTab<String>(value: 'a', child: Text('Overview')),
            NebaTab<String>(value: 'b', disabled: true, child: Text('Usage')),
            NebaTabPanel<String>(value: 'a', child: Text('First')),
            NebaTabPanel<String>(value: 'b', child: Text('Second')),
          ],
        ),
      );

      nodeOf(tester, 'Overview').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(nodeOf(tester, 'Usage').hasPrimaryFocus, isTrue);
      expect(find.text('First'), findsOneWidget);
    });

    testWidgets('follows the reading direction across a right-to-left bar', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTabs<String>(defaultValue: 'overview', children: basic),
        direction: TextDirection.rtl,
      );

      expect(
        tester.getCenter(find.text('Overview')).dx,
        greaterThan(tester.getCenter(find.text('Usage')).dx),
      );

      nodeOf(tester, 'Overview').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(nodeOf(tester, 'Usage').hasPrimaryFocus, isTrue);
    });

    testWidgets('moves onto the vertical arrows down a vertical bar', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTabs<String>(
          defaultValue: 'overview',
          orientation: NebaOrientation.vertical,
          children: basic,
        ),
      );

      nodeOf(tester, 'Overview').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(nodeOf(tester, 'Overview').hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(nodeOf(tester, 'Usage').hasPrimaryFocus, isTrue);
    });

    testWidgets('takes the focus on a press, with no ring after it', (WidgetTester tester) async {
      await pump(tester, const NebaTabs<String>(defaultValue: 'overview', children: basic));

      await tester.tap(find.text('Usage'));
      await tester.pump();
      await tester.pump();

      expect(nodeOf(tester, 'Usage').hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.pump();

      expect(nodeOf(tester, 'Billing').hasPrimaryFocus, isTrue);
    });

    testWidgets('draws its focus ring inside the tab', (WidgetTester tester) async {
      await pump(tester, const NebaTabs<String>(defaultValue: 'overview', children: basic));

      final NebaFocusRing ring = tester.widget<NebaFocusRing>(
        find.descendant(of: tab('Overview'), matching: find.byType(NebaFocusRing)),
      );
      expect(ring.offset, -focusRingWidth);
      expect(ring.color, primary.ring);
    });

    testWidgets('scrolls a tab the arrows reach into view', (WidgetTester tester) async {
      await pump(
        tester,
        NebaTabs<String>(
          defaultValue: 't0',
          children: <Widget>[
            for (int i = 0; i < 12; i++) NebaTab<String>(value: 't$i', child: Text('Section $i')),
          ],
        ),
        width: 240,
      );

      nodeOf(tester, 'Section 0').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();

      final Rect bar = tester.getRect(find.byType(NebaTabs<String>));
      expect(tester.getRect(find.text('Section 11')).right, lessThanOrEqualTo(bar.right));
    });
  });

  group('the indicator', () {
    testWidgets('sits under the chosen tab, along the bottom of an outline bar', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTabs<String>(defaultValue: 'usage', children: basic));

      final Rect usage = tester.getRect(tab('Usage'));
      final Rect line = tileRect(tester);
      final Finder bar = find.descendant(
        of: find.byType(NebaTileRun),
        matching: find.byType(DecoratedBox),
      );

      expect(line, usage);
      final Rect drawn = tester.getRect(
        find.descendant(of: find.byType(NebaTileRun), matching: find.byType(DecoratedBox)).first,
      );
      expect(drawn.height, 2);
      expect(drawn.bottom, usage.bottom);
      expect(drawn.width, usage.width);
      expect(
        (tester.widget<DecoratedBox>(bar.first).decoration as BoxDecoration).color,
        primary.accent,
      );
    });

    testWidgets('slides to the next tab by its rectangle, never by a transform', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTabs<String>(defaultValue: 'overview', children: basic));

      final Rect from = tester.getRect(tab('Overview'));
      final Rect to = tester.getRect(tab('Billing'));

      await tester.tap(find.text('Billing'));
      await tester.pump();
      await tester.pump(NebaScale.duration ~/ 2);

      final Rect halfway = tileRect(tester);
      expect(halfway.left, greaterThan(from.left));
      expect(halfway.left, lessThan(to.left));
      expect(
        find.descendant(of: find.byType(NebaTabs<String>), matching: find.byType(Transform)),
        findsNothing,
      );

      await tester.pumpAndSettle();
      expect(tileRect(tester), to);
    });

    testWidgets('runs down the end edge of a vertical bar', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTabs<String>(
          defaultValue: 'usage',
          orientation: NebaOrientation.vertical,
          children: basic,
        ),
      );

      final Rect usage = tester.getRect(tab('Usage'));
      final Rect drawn = tester.getRect(
        find.descendant(of: find.byType(NebaTileRun), matching: find.byType(DecoratedBox)).first,
      );

      expect(drawn.width, 2);
      expect(drawn.right, usage.right);
      expect(drawn.height, usage.height);
    });

    testWidgets('fills the chosen tab with a tile in a trough when solid', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTabs<String>(variant: NebaVariant.solid, defaultValue: 'usage', children: basic),
      );

      final List<NebaSheet> sheets = tester
          .widgetList<NebaSheet>(
            find.descendant(of: find.byType(NebaTabs<String>), matching: find.byType(NebaSheet)),
          )
          .toList();
      final NebaSheet trough = sheets.firstWhere((NebaSheet sheet) => sheet.fill == tokens.panel);
      final NebaSheet tile = sheets.firstWhere(
        (NebaSheet sheet) => sheet.fill == tokens.panelPress,
      );

      expect(trough.plate, NebaPlate.glass);
      expect(tile.elevation, 1);
      expect(tileRect(tester), tester.getRect(tab('Usage')));
      // The trough's padding around the tabs.
      expect(
        tester.getTopLeft(tab('Overview')) - tester.getTopLeft(find.byType(NebaTabs<String>)),
        const Offset(4, 4),
      );
    });
  });

  group('orientation', () {
    testWidgets('runs horizontally with a rule under the bar', (WidgetTester tester) async {
      await pump(tester, const NebaTabs<String>(defaultValue: 'overview', children: basic));

      expect(tester.getCenter(tab('Usage')).dy, tester.getCenter(tab('Overview')).dy);

      final Container rule = tester.widget<Container>(
        find.ancestor(of: find.byType(NebaTileRun), matching: find.byType(Container)).first,
      );
      expect(
        (rule.decoration! as BoxDecoration).border,
        Border(bottom: BorderSide(color: primary.line)),
      );
    });

    testWidgets('puts the panel beside a vertical bar that runs its whole height', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTabs<String>(
          defaultValue: 'overview',
          orientation: NebaOrientation.vertical,
          children: <Widget>[
            NebaTab<String>(value: 'overview', child: Text('Overview')),
            NebaTab<String>(value: 'usage', child: Text('Usage')),
            NebaTabPanel<String>(
              value: 'overview',
              child: SizedBox(height: 200, child: Text('Tall')),
            ),
          ],
        ),
      );

      final Rect overview = tester.getRect(tab('Overview'));
      final Rect usage = tester.getRect(tab('Usage'));
      final Rect panel = tester.getRect(find.text('Tall'));
      final Container rule = tester.widget<Container>(
        find.ancestor(of: find.byType(NebaTileRun), matching: find.byType(Container)).first,
      );

      expect(usage.top, overview.bottom);
      // Every tab as wide as the widest.
      expect(usage.width, overview.width);
      expect(panel.left, overview.right + 1 + 16);
      expect(
        tester
            .getSize(
              find.ancestor(of: find.byType(NebaTileRun), matching: find.byType(Container)).first,
            )
            .height,
        200,
      );
      expect(
        (rule.decoration! as BoxDecoration).border,
        BorderDirectional(end: BorderSide(color: primary.line)),
      );
    });
  });

  group('more tabs than room', () {
    final List<Widget> crowded = <Widget>[
      for (int i = 0; i < 12; i++) NebaTab<String>(value: 't$i', child: Text('Section $i')),
      const NebaTabPanel<String>(value: 't0', child: Text('The first one.')),
    ];

    NebaEdgeFade fade(WidgetTester tester) =>
        tester.widget<NebaEdgeFade>(find.byType(NebaEdgeFade));

    testWidgets('stays one line, scrolls, and fades the end with more beyond it', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaTabs<String>(defaultValue: 't0', children: crowded), width: 240);
      await tester.pump();

      expect(
        tester.getCenter(find.text('Section 11')).dy,
        tester.getCenter(find.text('Section 0')).dy,
      );
      expect(fade(tester).horizontal, (false, true));
      expect(fade(tester).vertical, (false, false));

      final ScrollController controller = tester
          .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
          .controller!;
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();

      expect(fade(tester).horizontal, (true, false));
    });

    testWidgets('fades nothing on a bar that fits', (WidgetTester tester) async {
      await pump(tester, const NebaTabs<String>(defaultValue: 'overview', children: basic));
      await tester.pump();

      expect(fade(tester).horizontal, (false, false));
    });

    testWidgets('scrolls a vertical bar down its length', (WidgetTester tester) async {
      await pump(
        tester,
        NebaTabs<String>(
          defaultValue: 't0',
          orientation: NebaOrientation.vertical,
          children: crowded,
        ),
      );

      expect(
        tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView)).scrollDirection,
        Axis.vertical,
      );
    });

    testWidgets('wraps when it is told to, and stops scrolling', (WidgetTester tester) async {
      await pump(
        tester,
        NebaTabs<String>(defaultValue: 't0', overflow: NebaTabsOverflow.wrap, children: crowded),
        width: 240,
      );

      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(
        tester.getTopLeft(find.text('Section 11')).dy,
        greaterThan(tester.getBottomLeft(find.text('Section 0')).dy),
      );
    });

    // The cap is in rows, and a row is the control height ladder; the rule
    // under an outline bar is counted into it.
    testWidgets('caps a wrapping bar at the rows it was given, and scrolls past them', (
      WidgetTester tester,
    ) async {
      Finder box() {
        return find.ancestor(of: find.byType(NebaTileRun), matching: find.byType(Container)).first;
      }

      await pump(
        tester,
        NebaTabs<String>(
          defaultValue: 't0',
          overflow: NebaTabsOverflow.wrap,
          lines: 2,
          children: crowded,
        ),
        width: 240,
      );
      await tester.pump();

      expect(tester.getSize(box()).height, 2 * 32 + 1);
      expect(
        tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView)).scrollDirection,
        Axis.vertical,
      );
      expect(fade(tester).vertical, (false, true));

      await pump(
        tester,
        NebaTabs<String>(
          defaultValue: 't0',
          variant: NebaVariant.text,
          overflow: NebaTabsOverflow.wrap,
          lines: 2,
          children: crowded,
        ),
        width: 240,
      );

      expect(
        tester
            .getSize(
              find
                  .ancestor(of: find.byType(NebaTileRun), matching: find.byType(ConstrainedBox))
                  .first,
            )
            .height,
        2 * 32,
      );
    });

    testWidgets('ignores lines on a bar that does not wrap', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTabs<String>(defaultValue: 'overview', lines: 2, children: basic),
      );

      final Rect bar = tester.getRect(
        find.ancestor(of: find.byType(NebaTileRun), matching: find.byType(Container)).first,
      );
      expect(bar.height, 32 + 1);
    });

    // The bottom of the bar is the bottom of the chosen tab only while there
    // is one row.
    testWidgets('puts the indicator on the line its tab is on when the bar wraps', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaTabs<String>(defaultValue: 't11', overflow: NebaTabsOverflow.wrap, children: crowded),
        width: 240,
      );

      final Rect chosen = tester.getRect(
        find.ancestor(of: find.text('Section 11'), matching: find.byType(NebaTab<String>)),
      );
      final Rect drawn = tester.getRect(
        find.descendant(of: find.byType(NebaTileRun), matching: find.byType(DecoratedBox)).first,
      );

      expect(drawn.bottom, chosen.bottom);
      expect(drawn.left, chosen.left);
    });
  });

  group('style', () {
    testWidgets('takes its size and its density from the set', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTabs<String>(
          size: NebaSize.xl,
          density: NebaDensity.compact,
          defaultValue: 'overview',
          children: basic,
        ),
      );

      expect(tester.getSize(tab('Overview')).height, 48);
      expect(
        tester.getTopLeft(find.text('Overview')).dx - tester.getTopLeft(tab('Overview')).dx,
        16,
      );
    });

    testWidgets('shares the bar between the tabs when fullWidth', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTabs<String>(defaultValue: 'overview', fullWidth: true, children: basic),
        width: 600,
      );

      final double width = tester.getSize(find.byType(NebaTabs<String>)).width;
      for (final String label in <String>['Overview', 'Usage', 'Billing']) {
        expect(tester.getSize(tab(label)).width, closeTo(width / 3, 0.01));
      }
    });

    testWidgets('centres a label by default and moves it with align, not the tab', (
      WidgetTester tester,
    ) async {
      Widget build(NebaAlign align) {
        return NebaTabs<String>(
          orientation: NebaOrientation.vertical,
          align: align,
          defaultValue: 'overview',
          children: const <Widget>[
            NebaTab<String>(value: 'overview', child: Text('Overview')),
            NebaTab<String>(value: 'members', child: Text('Members and roles')),
          ],
        );
      }

      await pump(tester, build(NebaAlign.center));
      final Rect centred = tester.getRect(tab('Overview'));
      final double middle = tester.getCenter(find.text('Overview')).dx;
      expect(middle, closeTo(centred.center.dx, 0.01));

      await pump(tester, build(NebaAlign.start));
      expect(tester.getRect(tab('Overview')), centred);
      expect(tester.getTopLeft(find.text('Overview')).dx, centred.left + 16);

      await pump(tester, build(NebaAlign.end));
      expect(tester.getTopRight(find.text('Overview')).dx, centred.right - 16);
    });

    testWidgets('fades nothing and draws no tile when nothing is chosen', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTabs<String>(children: basic));

      expect(find.text('What this project is.', skipOffstage: false), findsNothing);
      expect(tileRect(tester).size, Size.zero);
    });
  });

  // A wheel is turned onto a horizontal bar that overflows, and held at its
  // ends while the pointer is over it; a bar that fits takes nothing.
  group('the wheel', () {
    late ScrollController page;

    setUp(() => page = ScrollController());
    tearDown(() => page.dispose());

    Future<void> onPage(WidgetTester tester, Widget tabs) {
      return tester.pumpWidget(
        host(
          SingleChildScrollView(
            controller: page,
            child: Column(
              children: <Widget>[
                SizedBox(width: 240, child: tabs),
                const SizedBox(height: 2000),
              ],
            ),
          ),
        ),
      );
    }

    List<Widget> crowded() {
      return <Widget>[
        for (int i = 0; i < 12; i++) NebaTab<String>(value: 't$i', child: Text('Section $i')),
      ];
    }

    double bar(WidgetTester tester) {
      return tester
          .widget<SingleChildScrollView>(
            find.descendant(
              of: find.byType(NebaTabs<String>),
              matching: find.byType(SingleChildScrollView),
            ),
          )
          .controller!
          .offset;
    }

    Future<void> roll(WidgetTester tester, Offset delta) async {
      final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

      await tester.sendEventToBinding(mouse.hover(tester.getCenter(find.text('Section 0'))));
      await tester.sendEventToBinding(mouse.scroll(delta));
      await tester.pumpAndSettle();
    }

    testWidgets('turns a wheel rolled down the page into travel along the bar', (
      WidgetTester tester,
    ) async {
      await onPage(tester, NebaTabs<String>(defaultValue: 't0', children: crowded()));
      await roll(tester, const Offset(0, 120));

      expect(bar(tester), 120);
      expect(page.offset, 0);
    });

    // The bar is at its start, so there is nothing behind it, and the page
    // still does not get the wheel while the pointer is over the bar.
    testWidgets('holds the wheel at the end of the bar', (WidgetTester tester) async {
      await onPage(tester, NebaTabs<String>(defaultValue: 't0', children: crowded()));
      await roll(tester, const Offset(0, -120));

      expect(bar(tester), 0);
      expect(page.offset, 0);
    });

    testWidgets('holds nothing on a bar that fits', (WidgetTester tester) async {
      await onPage(
        tester,
        const NebaTabs<String>(
          defaultValue: 't0',
          children: <Widget>[NebaTab<String>(value: 't0', child: Text('Section 0'))],
        ),
      );
      await roll(tester, const Offset(0, 120));

      expect(page.offset, 120);
    });

    testWidgets('leaves the wheel to the page when it is turned off', (WidgetTester tester) async {
      await onPage(tester, NebaTabs<String>(defaultValue: 't0', wheel: false, children: crowded()));
      await roll(tester, const Offset(0, 120));

      expect(bar(tester), 0);
      expect(page.offset, 120);
    });

    testWidgets('lets a sideways wheel scroll the bar itself', (WidgetTester tester) async {
      await onPage(tester, NebaTabs<String>(defaultValue: 't0', children: crowded()));
      await roll(tester, const Offset(60, 0));

      expect(bar(tester), 60);
      expect(page.offset, 0);
    });
  });
}
