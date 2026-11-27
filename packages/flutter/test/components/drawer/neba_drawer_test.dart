// NebaDrawer: the suite the React package runs on Drawer, asked the way
// Flutter asks it — where the panel is laid out and how it arrives, the sheet
// it is drawn on, where the focus goes and the semantics it builds — rather
// than the elements, the classes and the ARIA it writes.

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/modal.dart';
import 'package:neba/src/internal/sheet_close.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  /// [child] in an 800 × 600 window with an overlay to open into, and
  /// [padding] as the screen's insets.
  Widget scene(
    Widget child, {
    EdgeInsets padding = EdgeInsets.zero,
    bool disableAnimations = false,
    double width = 800,
  }) {
    return MediaQuery(
      data: MediaQueryData(
        size: Size(width, 600),
        padding: padding,
        disableAnimations: disableAnimations,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Overlay.wrap(
          child: Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    );
  }

  Widget opener(BuildContext context, VoidCallback open) {
    return NebaButton(onPressed: open, child: const Text('Open'));
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  /// The panel's sheet: the one around the body text.
  Finder panel([String inside = 'Body']) {
    return find.ancestor(of: find.text(inside), matching: find.byType(NebaSheet)).last;
  }

  /// Whether [node] belongs to what [within] finds.
  bool holds(FocusNode node, Finder within) {
    return find
        .ancestor(
          of: find.byElementPredicate((Element element) => element == node.context),
          matching: within,
        )
        .evaluate()
        .isNotEmpty;
  }

  NebaSheet sheetOf(WidgetTester tester, [String inside = 'Body']) {
    return tester.widget<NebaSheet>(panel(inside));
  }

  group('overlay', () {
    testWidgets('builds nothing of the panel until it is open', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaDrawer(triggerBuilder: _opener, title: Text('Workspace'), child: Text('Body')),
        ),
      );

      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Workspace'), findsNothing);
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('opens from its trigger and reports it', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        scene(
          NebaDrawer(
            triggerBuilder: opener,
            onOpenChange: changes.add,
            title: const Text('Workspace'),
            child: const Text('Body'),
          ),
        ),
      );
      await open(tester);

      expect(find.text('Workspace'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(changes, <bool>[true]);
    });

    testWidgets('is a dialog named by its title, which is a heading', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          const NebaDrawer(
            open: true,
            title: Text('Workspace'),
            description: Text('Everything this account can reach.'),
            child: Text('Body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final SemanticsNode dialog = tester.getSemantics(
        find.ancestor(of: find.text('Workspace'), matching: find.byType(FocusScope)).first,
      );

      expect(dialog.getSemanticsData().role, SemanticsRole.dialog);
      expect(dialog, matchesSemantics(scopesRoute: true, hasDismissAction: true));
      expect(
        tester.getSemantics(find.text('Workspace')),
        matchesSemantics(
          label: 'Workspace',
          isHeader: true,
          namesRoute: true,
          textDirection: TextDirection.ltr,
        ),
      );
      expect(tester.getSemantics(find.text('Workspace')).getSemanticsData().headingLevel, 2);
      expect(find.text('Everything this account can reach.'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('writes the title at the level it is given', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(const NebaDrawer(open: true, headingLevel: 3, title: Text('Filters'))),
      );
      await tester.pumpAndSettle();

      expect(tester.getSemantics(find.text('Filters')).getSemanticsData().headingLevel, 3);
      semantics.dispose();
    });

    testWidgets('takes a name of its own when it has no title', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(const NebaDrawer(open: true, semanticLabel: 'Filters', child: Text('Body'))),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(
          find.ancestor(of: find.text('Body'), matching: find.byType(FocusScope)).first,
        ),
        matchesSemantics(label: 'Filters', scopesRoute: true, hasDismissAction: true),
      );
      semantics.dispose();
    });

    testWidgets('lays out the body and the actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaDrawer(
            open: true,
            title: const Text('Regions'),
            actions: <Widget>[
              NebaButton(onPressed: () {}, child: const Text('Cancel')),
              NebaButton(onPressed: () {}, child: const Text('Apply')),
            ],
            child: const Text('Body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Rect sheet = tester.getRect(panel());
      final Rect body = tester.getRect(find.text('Body'));
      final Rect cancel = tester.getRect(find.text('Cancel'));
      final Rect apply = tester.getRect(find.text('Apply'));

      expect(body.top, greaterThan(tester.getRect(find.text('Regions')).bottom));
      // Held against the foot of the panel and end-aligned.
      expect(sheet.bottom - apply.bottom, lessThan(40));
      expect(apply.left, greaterThan(cancel.right));
      expect(sheet.right - apply.right, lessThan(40));
    });

    testWidgets('closes from a NebaDrawerClose', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaDrawer(
            triggerBuilder: opener,
            actions: <Widget>[
              NebaDrawerClose(
                builder: (BuildContext context, VoidCallback close) {
                  return NebaButton(onPressed: close, child: const Text('Cancel'));
                },
              ),
            ],
            child: const Text('Body'),
          ),
        ),
      );
      await open(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsNothing);
    });

    testWidgets('closes from the ×, which is named in the locale', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      registerNebaMessages('ko', ko);

      await tester.pumpWidget(
        scene(
          const NebaDrawer(
            triggerBuilder: _opener,
            locale: Locale('ko'),
            title: Text('Workspace'),
            child: Text('Body'),
          ),
        ),
      );
      await open(tester);

      final String word = ko.messages['action']!['close']!;

      expect(find.bySemanticsLabel(word), findsOneWidget);

      await tester.tap(find.byType(NebaSheetClose));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsNothing);
      semantics.dispose();
    });

    testWidgets('takes a word of its own for the ×', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(const NebaDrawer(open: true, closeLabel: 'Dismiss filters', child: Text('Body'))),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Dismiss filters'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('leaves the × out when showClose is off', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(const NebaDrawer(open: true, showClose: false, child: Text('Body'))),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NebaSheetClose), findsNothing);
    });

    testWidgets('honours a controlled open', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        scene(NebaDrawer(open: true, onOpenChange: changes.add, child: const Text('Body'))),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NebaSheetClose));
      await tester.pumpAndSettle();

      // Reported, and left to the owner.
      expect(changes, <bool>[false]);
      expect(find.text('Body'), findsOneWidget);

      await tester.pumpWidget(
        scene(NebaDrawer(open: false, onOpenChange: changes.add, child: const Text('Body'))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsNothing);
    });

    testWidgets('closes on Escape and on the scrim', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(const NebaDrawer(triggerBuilder: _opener, child: Text('Body'))),
      );
      await open(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsNothing);

      await open(tester);
      // The scrim, on the far side of the window from the left panel.
      await tester.tapAt(const Offset(760, 300));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsNothing);
    });

    testWidgets('stays open on Escape and the scrim when it is not dismissible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(const NebaDrawer(triggerBuilder: _opener, dismissible: false, child: Text('Body'))),
      );
      await open(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.tapAt(const Offset(760, 300));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('keeps a press on the scrim from reaching the page', (WidgetTester tester) async {
      int pressed = 0;

      await tester.pumpWidget(
        scene(
          Row(
            children: <Widget>[
              const NebaDrawer(triggerBuilder: _opener, child: Text('Body')),
              const SizedBox(width: 600),
              NebaButton(onPressed: () => pressed++, child: const Text('Page')),
            ],
          ),
        ),
      );
      await open(tester);
      await tester.tap(find.text('Page'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(pressed, 0);
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('lets the press through to the page and closes when it traps the focus only', (
      WidgetTester tester,
    ) async {
      int pressed = 0;

      await tester.pumpWidget(
        scene(
          Row(
            children: <Widget>[
              const NebaDrawer(
                triggerBuilder: _opener,
                modal: NebaModal.trapFocus,
                child: Text('Body'),
              ),
              const SizedBox(width: 600),
              NebaButton(onPressed: () => pressed++, child: const Text('Page')),
            ],
          ),
        ),
      );
      await open(tester);
      await tester.tap(find.text('Page'));
      await tester.pumpAndSettle();

      expect(pressed, 1);
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('holds the focus inside and gives it back on closing', (WidgetTester tester) async {
      final FocusNode trigger = FocusNode(debugLabel: 'trigger');
      addTearDown(trigger.dispose);

      await tester.pumpWidget(
        scene(
          NebaDrawer(
            triggerBuilder: (BuildContext context, VoidCallback open) {
              return NebaButton(focusNode: trigger, onPressed: open, child: const Text('Open'));
            },
            actions: <Widget>[NebaButton(onPressed: () {}, child: const Text('Apply'))],
            child: const Text('Body'),
          ),
        ),
      );
      trigger.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // The first thing in it that takes the focus, which is the ×.
      final FocusNode first = FocusManager.instance.primaryFocus!;

      expect(trigger.hasFocus, isFalse);
      expect(holds(first, find.byType(NebaSheetClose)), isTrue);

      // Round inside: past Apply, the focus comes back to the ×, not the page.
      first.nextFocus();
      await tester.pump();
      FocusManager.instance.primaryFocus!.nextFocus();
      await tester.pump();

      expect(FocusManager.instance.primaryFocus, first);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(trigger.hasFocus, isTrue);
    });

    testWidgets('floats, so it carries a shadow, and is undyed', (WidgetTester tester) async {
      await tester.pumpWidget(scene(const NebaDrawer(open: true, child: Text('Body'))));
      await tester.pumpAndSettle();

      final NebaSheet sheet = sheetOf(tester);

      expect(sheet.elevation, 3);
      expect(sheet.fill, tokens.panelPress);
      expect(sheet.edge, isNull);
      expect(sheet.plate, NebaPlate.glass);
    });

    testWidgets('comes in from the edge it is attached to', (WidgetTester tester) async {
      for (final (NebaSide side, Offset towards) in <(NebaSide, Offset)>[
        (NebaSide.left, const Offset(-1, 0)),
        (NebaSide.right, const Offset(1, 0)),
        (NebaSide.top, const Offset(0, -1)),
        (NebaSide.bottom, const Offset(0, 1)),
      ]) {
        await tester.pumpWidget(
          scene(NebaDrawer(side: side, open: false, child: const Text('Body'))),
        );
        await tester.pumpWidget(
          scene(NebaDrawer(side: side, open: true, child: const Text('Body'))),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 40));

        final Rect midway = tester.getRect(panel());

        await tester.pumpAndSettle();

        final Rect there = tester.getRect(panel());
        final Offset travelled = midway.topLeft - there.topLeft;

        // Not yet in place, and short of it towards the edge it comes from.
        expect(travelled.dx.sign, towards.dx.sign, reason: side.name);
        expect(travelled.dy.sign, towards.dy.sign, reason: side.name);
        expect(travelled.distance, greaterThan(0), reason: side.name);
        expect(midway.size, there.size, reason: side.name);

        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('arrives at once for a reader who asked for less motion', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          const NebaDrawer(triggerBuilder: _opener, child: Text('Body')),
          disableAnimations: true,
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();

      expect(tester.getRect(panel()).left, 0);
    });

    testWidgets('holds each panel clear of the insets of the edges it runs to', (
      WidgetTester tester,
    ) async {
      const EdgeInsets insets = EdgeInsets.fromLTRB(11, 47, 13, 34);
      const double inset = 16;

      for (final NebaSide side in NebaSide.values) {
        await tester.pumpWidget(
          scene(
            NebaDrawer(side: side, open: true, showClose: false, child: const Text('Body')),
            padding: insets,
          ),
        );
        await tester.pumpAndSettle();

        final Rect sheet = tester.getRect(panel());
        final Rect body = tester.getRect(find.text('Body'));

        // The sheet still reaches every edge it runs to.
        if (side != NebaSide.right) {
          expect(sheet.left, 0, reason: side.name);
        }

        if (side == NebaSide.top) {
          expect(body.top - sheet.top, 47 + inset, reason: side.name);
          expect(body.left - sheet.left, 11 + inset, reason: side.name);
        } else if (side == NebaSide.bottom) {
          expect(sheet.bottom, 600, reason: side.name);
          expect(body.left - sheet.left, 11 + inset, reason: side.name);
          expect(sheet.right - body.right, greaterThanOrEqualTo(13 + inset), reason: side.name);
        } else if (side == NebaSide.left) {
          expect(body.top - sheet.top, 47 + inset, reason: side.name);
          expect(body.left - sheet.left, 11 + inset, reason: side.name);
        } else {
          expect(body.top - sheet.top, 47 + inset, reason: side.name);
          // The edge facing the page keeps its hairline and no inset.
          expect(body.left - sheet.left, 1 + inset, reason: side.name);
        }
      }
    });

    testWidgets('takes no insets when safeArea is off', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaDrawer(open: true, safeArea: false, showClose: false, child: Text('Body')),
          padding: const EdgeInsets.fromLTRB(11, 47, 13, 34),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(find.text('Body')).top - tester.getRect(panel()).top, 16);
    });

    testWidgets('reads the screen insets where a SafeArea took them away', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          const SafeArea(child: NebaDrawer(open: true, showClose: false, child: Text('Body'))),
          padding: const EdgeInsets.only(top: 47),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(find.text('Body')).top - tester.getRect(panel()).top, 47 + 16);
    });

    testWidgets('builds a closed drawer only on opening by default', (WidgetTester tester) async {
      await tester.pumpWidget(scene(const NebaDrawer(open: false, child: Text('Body'))));

      expect(find.text('Body'), findsNothing);
    });

    testWidgets('keeps a closed drawer built, offstage, and its state with it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(const NebaDrawer(triggerBuilder: _opener, keepMounted: true, child: _Counter())),
      );

      expect(find.text('0', skipOffstage: false), findsOneWidget);
      expect(find.text('0'), findsNothing);

      await open(tester);
      await tester.tap(find.text('0'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('1'), findsNothing);
      expect(find.text('1', skipOffstage: false), findsOneWidget);

      await open(tester);

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('leaves the page usable while the kept drawer is closed', (
      WidgetTester tester,
    ) async {
      int pressed = 0;

      await tester.pumpWidget(
        scene(
          Row(
            children: <Widget>[
              const NebaDrawer(keepMounted: true, child: Text('Body')),
              NebaButton(onPressed: () => pressed++, child: const Text('Page')),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Page'));

      expect(pressed, 1);
    });
  });

  group('inline', () {
    testWidgets('is in the layout without being opened', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              NebaDrawer(mode: NebaDrawerMode.inline, title: Text('Projects'), child: Text('Body')),
              Expanded(child: Text('Page')),
            ],
          ),
        ),
      );

      expect(find.text('Body'), findsOneWidget);
      // The page is laid out around it.
      expect(tester.getRect(find.text('Page')).left, NebaDrawer.extents[NebaSize.md]);
      expect(tester.getRect(panel()).height, 600);
    });

    testWidgets('is not a dialog, and its title is a heading in the page', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          const NebaDrawer(
            mode: NebaDrawerMode.inline,
            title: Text('Projects'),
            headingLevel: 3,
            child: Text('Body'),
          ),
        ),
      );

      expect(find.byType(FocusScope), findsNothing);
      expect(find.byType(NebaModalLayer), findsNothing);
      expect(tester.getSemantics(find.text('Projects')).getSemanticsData().headingLevel, 3);
      expect(
        tester.getSemantics(find.text('Projects')),
        matchesSemantics(label: 'Projects', isHeader: true, textDirection: TextDirection.ltr),
      );
      semantics.dispose();
    });

    testWidgets('leaves the layout when it is closed', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const Row(
            children: <Widget>[
              NebaDrawer(mode: NebaDrawerMode.inline, open: false, child: Text('Body')),
              Text('Page'),
            ],
          ),
        ),
      );

      expect(find.text('Body'), findsNothing);
      expect(tester.getRect(find.text('Page')).left, 0);
    });

    testWidgets('draws no × by default, and reports a close from one asked for', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        host(const NebaDrawer(mode: NebaDrawerMode.inline, child: Text('Body'))),
      );

      expect(find.byType(NebaSheetClose), findsNothing);

      await tester.pumpWidget(
        host(
          NebaDrawer(
            mode: NebaDrawerMode.inline,
            showClose: true,
            open: true,
            onOpenChange: changes.add,
            child: const Text('Body'),
          ),
        ),
      );
      await tester.tap(find.byType(NebaSheetClose));
      await tester.pump();

      expect(changes, <bool>[false]);
    });

    testWidgets('closes an uncontrolled drawer from its ×', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const NebaDrawer(mode: NebaDrawerMode.inline, showClose: true, child: Text('Body'))),
      );
      await tester.tap(find.byType(NebaSheetClose));
      await tester.pump();

      expect(find.text('Body'), findsNothing);
    });

    testWidgets('builds no trigger, because there is nothing to open', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const NebaDrawer(mode: NebaDrawerMode.inline, triggerBuilder: _opener)),
      );

      expect(find.text('Open'), findsNothing);
    });

    testWidgets('sits flat on the page', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const NebaDrawer(mode: NebaDrawerMode.inline, child: Text('Body'))),
      );

      expect(sheetOf(tester).elevation, 0);
    });

    testWidgets('keeps a closed drawer built, out of the layout, with its state', (
      WidgetTester tester,
    ) async {
      Widget page({required bool open}) {
        return host(
          Row(
            children: <Widget>[
              NebaDrawer(
                mode: NebaDrawerMode.inline,
                open: open,
                keepMounted: true,
                child: const _Counter(),
              ),
              const Text('Page'),
            ],
          ),
        );
      }

      await tester.pumpWidget(page(open: true));
      await tester.tap(find.text('0'));
      await tester.pumpWidget(page(open: false));

      expect(find.text('1'), findsNothing);
      expect(find.text('1', skipOffstage: false), findsOneWidget);
      expect(tester.getRect(find.text('Page')).left, 0);

      await tester.pumpWidget(page(open: true));

      expect(find.text('1'), findsOneWidget);
    });
  });

  group('the sheet', () {
    Future<void> pumpInline(WidgetTester tester, NebaDrawer drawer) {
      return tester.pumpWidget(host(Align(alignment: Alignment.topLeft, child: drawer)));
    }

    testWidgets('hangs off the left and cuts its right corners by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(scene(const NebaDrawer(open: true, child: Text('Body'))));
      await tester.pumpAndSettle();

      final Rect sheet = tester.getRect(panel());
      final Radius r = Radius.circular(tokens.radius[NebaSize.md]!);

      expect(sheet, const Rect.fromLTWH(0, 0, 320, 600));
      expect(sheetOf(tester).borderRadius, BorderRadius.horizontal(right: r));
    });

    testWidgets('cuts the corners on the free edge whichever side it is', (
      WidgetTester tester,
    ) async {
      final Radius r = Radius.circular(tokens.radius[NebaSize.md]!);

      for (final (NebaSide side, BorderRadius radius) in <(NebaSide, BorderRadius)>[
        (NebaSide.right, BorderRadius.horizontal(left: r)),
        (NebaSide.top, BorderRadius.vertical(bottom: r)),
        (NebaSide.bottom, BorderRadius.vertical(top: r)),
      ]) {
        await pumpInline(
          tester,
          NebaDrawer(mode: NebaDrawerMode.inline, side: side, child: const Text('Body')),
        );

        expect(sheetOf(tester).borderRadius, radius, reason: side.name);
      }
    });

    testWidgets('squares every corner when rounded is off', (WidgetTester tester) async {
      await pumpInline(
        tester,
        const NebaDrawer(mode: NebaDrawerMode.inline, rounded: false, child: Text('Body')),
      );

      expect(sheetOf(tester).borderRadius, BorderRadius.zero);
    });

    testWidgets('moves the radius with size', (WidgetTester tester) async {
      await pumpInline(
        tester,
        const NebaDrawer(mode: NebaDrawerMode.inline, size: NebaSize.xl, child: Text('Body')),
      );

      expect(
        sheetOf(tester).borderRadius,
        BorderRadius.horizontal(right: Radius.circular(tokens.radius[NebaSize.xl]!)),
      );
    });

    testWidgets('takes a width off the size ladder on a side panel', (WidgetTester tester) async {
      for (final NebaSize size in NebaSize.values) {
        await tester.pumpWidget(
          scene(NebaDrawer(open: true, size: size, child: const Text('Body'))),
        );
        await tester.pumpAndSettle();

        expect(tester.getRect(panel()).width, NebaDrawer.extents[size], reason: size.name);
      }
    });

    testWidgets('is as tall as its content on a top or bottom panel, capped at the window', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(const NebaDrawer(open: true, side: NebaSide.bottom, child: Text('Body'))),
      );
      await tester.pumpAndSettle();

      final Rect short = tester.getRect(panel());

      expect(short.width, 800);
      expect(short.height, lessThan(200));
      expect(short.bottom, 600);

      await tester.pumpWidget(
        scene(
          const NebaDrawer(
            open: true,
            side: NebaSide.bottom,
            child: Column(children: <Widget>[Text('Body'), SizedBox(height: 2000)]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(panel()).height, 600 * NebaDrawer.maxCoverage);
      expect(tester.takeException(), isNull);
    });

    testWidgets('takes extent as a width on a side panel and a height on a top one', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(const NebaDrawer(open: true, extent: 420, child: Text('Body'))),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(panel()).width, 420);

      await tester.pumpWidget(
        scene(const NebaDrawer(open: true, side: NebaSide.top, extent: 300, child: Text('Body'))),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(panel()).height, 300);
    });

    testWidgets('never runs wider than the window', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(const NebaDrawer(open: true, size: NebaSize.xl, child: Text('Body')), width: 360),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(panel()).width, 360);
    });

    testWidgets('draws the hairline of the free edge in the colour family', (
      WidgetTester tester,
    ) async {
      await pumpInline(
        tester,
        const NebaDrawer(mode: NebaDrawerMode.inline, color: NebaColor.danger, child: Text('Body')),
      );

      final Finder edge = find.descendant(
        of: panel(),
        matching: find.byWidgetPredicate(
          (Widget widget) =>
              widget is CustomPaint &&
              widget.foregroundPainter.runtimeType.toString() == '_FreeEdgePainter',
        ),
      );

      expect(
        tester.renderObject(edge),
        paints..rrect(color: tokens.roles(NebaColor.danger).line, style: PaintingStyle.stroke),
      );
    });

    testWidgets('rules its sections when it is asked to', (WidgetTester tester) async {
      await pumpInline(
        tester,
        NebaDrawer(
          mode: NebaDrawerMode.inline,
          dividers: true,
          title: const Text('Regions'),
          actions: <Widget>[NebaButton(onPressed: () {}, child: const Text('Apply'))],
          child: const Text('Body'),
        ),
      );

      final Iterable<BoxDecoration> lines = tester
          .widgetList<Container>(find.descendant(of: panel(), matching: find.byType(Container)))
          .map((Container container) => container.decoration)
          .whereType<BoxDecoration>()
          .where((BoxDecoration decoration) => decoration.border != null);

      expect(lines, hasLength(2));
      expect(
        lines.every(
          (BoxDecoration decoration) =>
              (decoration.border! as Border).top.color == tokens.roles(NebaColor.primary).line,
        ),
        isTrue,
      );
    });

    testWidgets('sets the title one step above the body in semibold', (WidgetTester tester) async {
      await pumpInline(
        tester,
        const NebaDrawer(
          mode: NebaDrawerMode.inline,
          title: Text('Projects'),
          description: Text('Twelve active'),
          child: Text('Body'),
        ),
      );

      TextStyle styleOf(String text) {
        return tester
            .widget<RichText>(find.descendant(of: find.text(text), matching: find.byType(RichText)))
            .text
            .style!;
      }

      expect(styleOf('Projects').fontSize, NebaScale.sheetTitleText[NebaSize.md]);
      expect(styleOf('Projects').fontWeight, FontWeight.w600);
      expect(styleOf('Twelve active').fontSize, NebaScale.metaText[NebaSize.md]);
      expect(styleOf('Twelve active').color, tokens.mutedFg);
      expect(styleOf('Body').fontSize, NebaScale.sheetBodyText[NebaSize.md]);
    });
  });
}

Widget _opener(BuildContext context, VoidCallback open) {
  return NebaButton(onPressed: open, child: const Text('Open'));
}

/// A count that goes up on a press, to see whether state survives.
class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () => setState(() => _count++), child: Text('$_count'));
  }
}
