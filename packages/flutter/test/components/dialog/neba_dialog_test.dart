// NebaDialog: the suite the React package runs on Dialog, asked the way
// Flutter asks it — where the sheet is laid out and how it arrives, the sheet
// it is drawn on, where the focus goes and the semantics it builds — rather
// than the elements, the classes and the ARIA it writes.

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/sheet_close.dart';
import 'package:neba/src/internal/sheet_sections.dart';
import 'package:neba/src/internal/surface.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  /// [child] in an 800 × 600 window with an overlay to open into, and
  /// [padding] and [viewInsets] as the screen's insets and the keyboard.
  Widget scene(
    Widget child, {
    EdgeInsets padding = EdgeInsets.zero,
    EdgeInsets viewInsets = EdgeInsets.zero,
    bool disableAnimations = false,
  }) {
    return MediaQuery(
      data: MediaQueryData(
        size: const Size(800, 600),
        padding: padding,
        viewInsets: viewInsets,
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

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  /// The dialog's sheet: the one around [inside].
  Finder sheet([String inside = 'Body']) {
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

  group('rendering', () {
    testWidgets('builds nothing until it is open', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaDialog(triggerBuilder: _opener, title: Text('Delete'), child: Text('Body')),
        ),
      );

      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Delete'), findsNothing);
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('is a dialog named by its title, which is a heading at level 2', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          const NebaDialog(
            open: true,
            title: Text('Delete this workspace?'),
            description: Text('Every project inside it goes with it.'),
            child: Text('Body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final SemanticsNode dialog = tester.getSemantics(
        find.ancestor(of: find.text('Body'), matching: find.byType(FocusScope)).first,
      );

      expect(dialog.getSemanticsData().role, SemanticsRole.dialog);
      expect(dialog, matchesSemantics(scopesRoute: true, hasDismissAction: true));
      expect(
        tester.getSemantics(find.text('Delete this workspace?')),
        matchesSemantics(
          label: 'Delete this workspace?',
          isHeader: true,
          namesRoute: true,
          textDirection: TextDirection.ltr,
        ),
      );
      expect(
        tester.getSemantics(find.text('Delete this workspace?')).getSemanticsData().headingLevel,
        2,
      );
      expect(find.text('Every project inside it goes with it.'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('takes a name of its own when it has no title', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          const NebaDialog(
            open: true,
            showClose: false,
            semanticLabel: 'Preview',
            child: Text('Body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(
          find.ancestor(of: find.text('Body'), matching: find.byType(FocusScope)).first,
        ),
        matchesSemantics(
          label: 'Preview',
          scopesRoute: true,
          namesRoute: true,
          hasDismissAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('is an alert dialog when it is asked to be', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          const NebaDialog(
            open: true,
            role: SemanticsRole.alertDialog,
            title: Text('Ship it?'),
            child: Text('Body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester
            .getSemantics(
              find.ancestor(of: find.text('Body'), matching: find.byType(FocusScope)).first,
            )
            .getSemanticsData()
            .role,
        SemanticsRole.alertDialog,
      );
      semantics.dispose();
    });

    testWidgets('lays out the header, the body and the actions in that order', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          NebaDialog(
            open: true,
            title: const Text('Delete'),
            actions: <Widget>[NebaButton(onPressed: () {}, child: const Text('Confirm'))],
            child: const Text('Body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final double title = tester.getRect(find.text('Delete')).bottom;
      final Rect body = tester.getRect(find.text('Body'));
      final Rect action = tester.getRect(find.text('Confirm'));

      expect(body.top, greaterThan(title));
      expect(action.top, greaterThan(body.bottom));
      // End-aligned, inside the sheet's padding.
      expect(tester.getRect(sheet()).right - action.right, greaterThan(16));
      expect(tester.getRect(sheet()).right - action.right, lessThan(40));
    });

    testWidgets('sets the text it holds as a portal would, whatever is around it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          const DefaultTextStyle(
            style: TextStyle(fontWeight: FontWeight.w800, fontStyle: FontStyle.italic),
            child: NebaDialog(open: true, child: Text('Body')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final TextStyle style = tester
          .widget<RichText>(find.descendant(of: find.text('Body'), matching: find.byType(RichText)))
          .text
          .style!;

      expect(style.fontWeight, FontWeight.w400);
      expect(style.fontStyle, FontStyle.normal);
      expect(style.fontSize, NebaScale.sheetBodyText[NebaSize.md]);
      expect(style.color, tokens.fg);
    });
  });

  group('opening and closing', () {
    testWidgets('opens from its trigger and reports it', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        scene(
          NebaDialog(
            triggerBuilder: _opener,
            onOpenChange: changes.add,
            title: const Text('Delete'),
            child: const Text('Body'),
          ),
        ),
      );
      await open(tester);

      expect(find.text('Body'), findsOneWidget);
      expect(changes, <bool>[true]);
    });

    testWidgets('closes from the ×, which is named in the locale', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          const NebaDialog(
            triggerBuilder: _opener,
            locale: Locale('ko'),
            title: Text('Delete'),
            child: Text('Body'),
          ),
        ),
      );
      await open(tester);

      expect(find.bySemanticsLabel('닫기'), findsOneWidget);

      await tester.tap(find.byType(NebaSheetClose));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsNothing);
      semantics.dispose();
    });

    testWidgets('takes a word of its own for the ×', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(const NebaDialog(open: true, closeLabel: 'Dismiss dialog', child: Text('Body'))),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Dismiss dialog'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('leaves the × out when showClose is off', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(const NebaDialog(open: true, showClose: false, child: Text('Body'))),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NebaSheetClose), findsNothing);
    });

    testWidgets('closes from a NebaDialogClose in the actions', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        scene(
          NebaDialog(
            triggerBuilder: _opener,
            onOpenChange: changes.add,
            dismissible: false,
            actions: <Widget>[
              NebaDialogClose(
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

      // An answer, so it gets through even when the dialog is not dismissible.
      expect(find.text('Body'), findsNothing);
      expect(changes, <bool>[true, false]);
    });

    testWidgets('does nothing from a NebaDialogClose outside a dialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          NebaDialogClose(
            builder: (BuildContext context, VoidCallback close) {
              return NebaButton(onPressed: close, child: const Text('Cancel'));
            },
          ),
        ),
      );
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('honours a controlled open', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        scene(NebaDialog(open: true, onOpenChange: changes.add, child: const Text('Body'))),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NebaSheetClose));
      await tester.pumpAndSettle();

      // Reported, and left to the owner.
      expect(changes, <bool>[false]);
      expect(find.text('Body'), findsOneWidget);

      await tester.pumpWidget(
        scene(NebaDialog(open: false, onOpenChange: changes.add, child: const Text('Body'))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsNothing);
    });

    testWidgets('starts open from defaultOpen', (WidgetTester tester) async {
      await tester.pumpWidget(scene(const NebaDialog(defaultOpen: true, child: Text('Body'))));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('closes on Escape and on a press outside the sheet', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(const NebaDialog(triggerBuilder: _opener, child: Text('Body'))),
      );
      await open(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsNothing);

      await open(tester);
      await tester.tapAt(const Offset(20, 580));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsNothing);
    });

    testWidgets('stays open on a press on the sheet itself', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(const NebaDialog(triggerBuilder: _opener, child: Text('Body'))),
      );
      await open(tester);
      await tester.tap(find.text('Body'));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('stays open on Escape and the scrim when it is not dismissible', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        scene(
          NebaDialog(
            triggerBuilder: _opener,
            onOpenChange: changes.add,
            dismissible: false,
            child: const Text('Body'),
          ),
        ),
      );
      await open(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.tapAt(const Offset(20, 580));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsOneWidget);
      expect(changes, <bool>[true]);
    });
  });

  group('the page behind', () {
    Widget page(NebaModal modal, VoidCallback onPressed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          NebaDialog(triggerBuilder: _opener, modal: modal, child: const Text('Body')),
          const SizedBox(height: 480),
          NebaButton(onPressed: onPressed, child: const Text('Page')),
        ],
      );
    }

    testWidgets('keeps a press on the page from reaching it while modal', (
      WidgetTester tester,
    ) async {
      int pressed = 0;

      await tester.pumpWidget(scene(page(NebaModal.on, () => pressed++)));
      await open(tester);
      await tester.tap(find.text('Page'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(pressed, 0);
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('lets the press through and closes when it traps the focus only', (
      WidgetTester tester,
    ) async {
      int pressed = 0;

      await tester.pumpWidget(scene(page(NebaModal.trapFocus, () => pressed++)));
      await open(tester);
      await tester.tap(find.text('Page'));
      await tester.pumpAndSettle();

      expect(pressed, 1);
      expect(find.text('Body'), findsNothing);
    });
  });

  group('focus', () {
    testWidgets('holds the focus inside and gives it back on closing', (WidgetTester tester) async {
      final FocusNode trigger = FocusNode(debugLabel: 'trigger');
      addTearDown(trigger.dispose);

      await tester.pumpWidget(
        scene(
          NebaDialog(
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

    testWidgets('puts the focus on initialFocus and gives it to finalFocus', (
      WidgetTester tester,
    ) async {
      final FocusNode apply = FocusNode(debugLabel: 'apply');
      final FocusNode after = FocusNode(debugLabel: 'after');
      addTearDown(apply.dispose);
      addTearDown(after.dispose);

      Widget build(bool open) {
        return scene(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              NebaButton(focusNode: after, onPressed: () {}, child: const Text('After')),
              NebaDialog(
                open: open,
                initialFocus: apply,
                finalFocus: after,
                actions: <Widget>[
                  NebaButton(onPressed: () {}, child: const Text('Cancel')),
                  NebaButton(focusNode: apply, onPressed: () {}, child: const Text('Apply')),
                ],
                child: const Text('Body'),
              ),
            ],
          ),
        );
      }

      await tester.pumpWidget(build(false));
      await tester.pumpWidget(build(true));
      await tester.pumpAndSettle();

      expect(apply.hasFocus, isTrue);

      await tester.pumpWidget(build(false));
      await tester.pumpAndSettle();

      expect(after.hasFocus, isTrue);
    });
  });

  group('the sheet', () {
    testWidgets('floats on a level-3 shadow, undyed, with an edge in its family', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(const NebaDialog(open: true, color: NebaColor.danger, child: Text('Body'))),
      );
      await tester.pumpAndSettle();

      final NebaSheet drawn = tester.widget<NebaSheet>(sheet());

      expect(drawn.elevation, 3);
      expect(drawn.fill, tokens.panelPress);
      expect(drawn.edge, tokens.roles(NebaColor.danger).line);
      expect(drawn.plate, NebaPlate.glass);
      expect(drawn.borderRadius, BorderRadius.circular(tokens.radius[NebaSize.md]!));
    });

    testWidgets('is centred and capped at the width its size implies', (WidgetTester tester) async {
      for (final NebaSize size in NebaSize.values) {
        await tester.pumpWidget(
          scene(NebaDialog(open: true, size: size, child: const Text('Body'))),
        );
        await tester.pumpAndSettle();

        final Rect rect = tester.getRect(sheet());

        // xl reaches past an 800-pixel window, less its margin.
        final double room = 800 - 2 * NebaDialog.margin;

        expect(
          rect.width,
          NebaDialog.maxWidths[size]! < room ? NebaDialog.maxWidths[size] : room,
          reason: size.name,
        );
        expect(rect.center.dx, 400, reason: size.name);
        expect(rect.center.dy, 300, reason: size.name);

        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('never runs wider than the window less its margin', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(const NebaDialog(open: true, size: NebaSize.xl, child: Text('Body'))),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(sheet()).width, 800 - 2 * NebaDialog.margin);
    });

    testWidgets('takes an explicit width instead', (WidgetTester tester) async {
      await tester.pumpWidget(scene(const NebaDialog(open: true, width: 640, child: Text('Body'))));
      await tester.pumpAndSettle();

      expect(tester.getRect(sheet()).width, 640);
    });

    testWidgets('shrinks to what is on it when it is not full width', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaDialog(open: true, fullWidth: false, showClose: false, child: Text('Body')),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(sheet()).width, lessThan(NebaDialog.maxWidths[NebaSize.md]!));
      expect(
        tester.getRect(sheet()).width,
        greaterThanOrEqualTo(tester.getRect(find.text('Body')).width),
      );
    });

    testWidgets('fills the window with square corners when full screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(const NebaDialog(open: true, fullScreen: true, child: Text('Body'))),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(sheet()), const Rect.fromLTWH(0, 0, 800, 600));
      expect(tester.widget<NebaSheet>(sheet()).borderRadius, BorderRadius.zero);
    });

    testWidgets('is never taller than the window, and scrolls only its body', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          NebaDialog(
            open: true,
            title: const Text('Terms'),
            actions: <Widget>[NebaButton(onPressed: () {}, child: const Text('Accept'))],
            child: Column(children: <Widget>[for (int i = 0; i < 40; i++) Text('Clause $i')]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Rect rect = tester.getRect(sheet('Terms'));

      expect(rect.top, NebaDialog.margin);
      expect(rect.bottom, 600 - NebaDialog.margin);
      // The title and the actions are on the sheet, and the body scrolls
      // between them.
      expect(tester.getRect(find.text('Terms')).top, greaterThan(rect.top));
      expect(tester.getRect(find.text('Accept')).bottom, lessThan(rect.bottom));
      expect(
        find.ancestor(of: find.text('Clause 0'), matching: find.byType(SingleChildScrollView)),
        findsOneWidget,
      );
      expect(
        find.ancestor(of: find.text('Terms'), matching: find.byType(SingleChildScrollView)),
        findsNothing,
      );
    });

    testWidgets('keeps clear of the system insets and the keyboard', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaDialog(
            open: true,
            child: Column(children: <Widget>[for (int i = 0; i < 40; i++) Text('Line $i')]),
          ),
          padding: const EdgeInsets.only(top: 44),
          viewInsets: const EdgeInsets.only(bottom: 300),
        ),
      );
      await tester.pumpAndSettle();

      final Rect rect = tester.getRect(sheet('Line 0'));

      expect(rect.top, 44 + NebaDialog.margin);
      expect(rect.bottom, 600 - 300 - NebaDialog.margin);
    });

    testWidgets('keeps a full screen sheet’s contents clear of the insets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          const NebaDialog(
            open: true,
            fullScreen: true,
            title: Text('Editor'),
            child: Text('Body'),
          ),
          padding: const EdgeInsets.only(top: 44, bottom: 34),
        ),
      );
      await tester.pumpAndSettle();

      final double inset = NebaBox.padding[NebaDensity.standard]![NebaSize.md]!;

      expect(tester.getRect(sheet('Editor')).top, 0);
      expect(tester.getRect(find.text('Editor')).top, closeTo(44 + inset + 1, 1));
    });

    testWidgets('leaves room at the edges of the scrolling body and takes it back', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(const NebaDialog(open: true, title: Text('Delete'), child: Text('Body'))),
      );
      await tester.pumpAndSettle();

      final (double top, double bottom) = NebaSheetSections.scrollRoom[NebaSize.md]!;
      final SingleChildScrollView body = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );

      expect(body.padding, EdgeInsets.fromLTRB(16, top, 16, bottom));
      // Taken back: the body text sits a section gap below the title.
      expect(
        tester.getRect(find.text('Body')).top - tester.getRect(find.text('Delete')).bottom,
        closeTo(NebaScale.sheetSectionGap[NebaSize.md]!, 1),
      );
    });

    testWidgets('rules its sections with dividers, which give the body its padding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          NebaDialog(
            open: true,
            dividers: true,
            title: const Text('Delete'),
            actions: <Widget>[NebaButton(onPressed: () {}, child: const Text('Confirm'))],
            child: const Text('Body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Iterable<BoxDecoration> lines = tester
          .widgetList<Container>(find.descendant(of: sheet(), matching: find.byType(Container)))
          .map((Container container) => container.decoration)
          .whereType<BoxDecoration>()
          .where((BoxDecoration decoration) => decoration.border != null);

      expect(lines, hasLength(2));
      expect(
        tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView)).padding,
        const EdgeInsets.all(16),
      );
    });

    testWidgets('arrives in opacity alone, and never moves or scales', (WidgetTester tester) async {
      await tester.pumpWidget(scene(const NebaDialog(open: false, child: Text('Body'))));
      await tester.pumpWidget(scene(const NebaDialog(open: true, child: Text('Body'))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));

      final Rect midway = tester.getRect(sheet());
      final FadeTransition fade = tester.widget<FadeTransition>(
        find.ancestor(of: sheet(), matching: find.byType(FadeTransition)).first,
      );

      expect(fade.opacity.value, greaterThan(0));
      expect(fade.opacity.value, lessThan(1));

      await tester.pumpAndSettle();

      expect(tester.getRect(sheet()), midway);
      expect(
        find.ancestor(
          of: sheet(),
          matching: find.byWidgetPredicate(
            (Widget widget) =>
                widget is Transform ||
                widget is FractionalTranslation ||
                widget is ScaleTransition ||
                widget is SlideTransition,
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('arrives at once for a reader who asked for less motion', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          const NebaDialog(triggerBuilder: _opener, child: Text('Body')),
          disableAnimations: true,
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();

      final FadeTransition fade = tester.widget<FadeTransition>(
        find.ancestor(of: sheet(), matching: find.byType(FadeTransition)).first,
      );

      expect(fade.opacity.value, 1);
    });

    testWidgets('sets the title one step above the body in semibold', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaDialog(
            open: true,
            size: NebaSize.lg,
            title: Text('Delete'),
            description: Text('Gone for good.'),
            child: Text('Body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      TextStyle styleOf(String text) {
        return tester
            .widget<RichText>(find.descendant(of: find.text(text), matching: find.byType(RichText)))
            .text
            .style!;
      }

      expect(styleOf('Delete').fontSize, NebaScale.sheetTitleText[NebaSize.lg]);
      expect(styleOf('Delete').fontWeight, FontWeight.w600);
      expect(styleOf('Gone for good.').fontSize, NebaScale.metaText[NebaSize.lg]);
      expect(styleOf('Gone for good.').color, tokens.mutedFg);
      expect(styleOf('Body').fontSize, NebaScale.sheetBodyText[NebaSize.lg]);
    });

    testWidgets('takes its size and density from NebaProvider', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaProvider(
            defaults: NebaDefaults(size: NebaSize.sm, density: NebaDensity.compact),
            child: NebaDialog(open: true, child: Text('Body')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(sheet()).width, NebaDialog.maxWidths[NebaSize.sm]);
      expect(
        tester
            .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
            .padding!
            .horizontal,
        2 * NebaBox.padding[NebaDensity.compact]![NebaSize.sm]!,
      );
    });
  });
}

Widget _opener(BuildContext context, VoidCallback open) {
  return NebaButton(onPressed: open, child: const Text('Open'));
}
