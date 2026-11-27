// NebaCollapsible: the suite the React package runs on Collapsible, asked the
// way Flutter asks it — the button a screen reader hears as expanded or
// collapsed, the state it keeps or is given, the panel's height on its way
// open and shut, and what stays built while it is closed.

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
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

  Future<void> pump(WidgetTester tester, Widget collapsible, {bool disableAnimations = false}) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: 400, child: collapsible),
        ),
        disableAnimations: disableAnimations,
      ),
    );
  }

  /// The trigger's own node: the one that is a button.
  Finder trigger() {
    return find
        .descendant(of: find.byType(NebaDisclosureHeader), matching: find.byType(Semantics))
        .first;
  }

  Finder body(String text) => find.text(text, skipOffstage: false);

  Finder panel() => find.byType(NebaDisclosurePanel);

  /// A trigger that can be pressed, [expanded] or not.
  Matcher live(String label, {required bool expanded}) {
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

  group('rendering', () {
    testWidgets('is a button named by its title, collapsed', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCollapsible(title: Text('Advanced'), child: Text('Body')));

      expect(tester.getSemantics(trigger()), live('Advanced', expanded: false));
      semantics.dispose();
    });

    testWidgets('draws a subtitle under the title, muted', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCollapsible(title: Text('Advanced'), subtitle: Text('Rarely needed')),
      );

      expect(find.text('Rarely needed'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Rarely needed')).dy,
        greaterThan(tester.getBottomLeft(find.text('Advanced')).dy - 0.01),
      );
      expect(
        DefaultTextStyle.of(tester.element(find.text('Rarely needed'))).style.color,
        tokens.mutedFg,
      );
    });

    // A title that is a question lost its end on a narrow screen when it was
    // always cut to one line.
    testWidgets('wraps the title and the subtitle unless lines cuts them', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaCollapsible(title: Text('Advanced'), subtitle: Text('Rarely needed')),
      );

      DefaultTextStyle styleOf(String text) => DefaultTextStyle.of(tester.element(find.text(text)));

      expect(styleOf('Advanced').maxLines, isNull);
      expect(styleOf('Rarely needed').maxLines, isNull);

      await pump(
        tester,
        const NebaCollapsible(title: Text('Advanced'), subtitle: Text('Rarely needed'), lines: 1),
      );

      expect(styleOf('Advanced').maxLines, 1);
      expect(styleOf('Advanced').overflow, TextOverflow.ellipsis);
      expect(styleOf('Rarely needed').maxLines, 1);
    });

    testWidgets('sets the title on the sheet title ladder, in semibold', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCollapsible(size: NebaSize.lg, title: Text('Advanced')));

      final TextStyle style = DefaultTextStyle.of(tester.element(find.text('Advanced'))).style;
      expect(style.fontSize, NebaScale.sheetTitleText[NebaSize.lg]);
      expect(style.fontWeight, FontWeight.w600);
    });

    testWidgets('starts closed, with the body built but not shown', (WidgetTester tester) async {
      await pump(tester, const NebaCollapsible(title: Text('Advanced'), child: Text('Body')));

      expect(find.text('Body'), findsNothing);
      expect(body('Body'), findsOneWidget);
      expect(tester.getSize(panel()).height, 0);
    });

    testWidgets('leaves a closed panel unbuilt when it is not kept', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCollapsible(title: Text('Advanced'), keepMounted: false, child: Text('Body')),
      );

      expect(body('Body'), findsNothing);
    });

    testWidgets('shows the body when it starts open', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaCollapsible(title: Text('Advanced'), defaultOpen: true, child: Text('Body')),
      );

      expect(find.text('Body'), findsOneWidget);
      expect(tester.getSemantics(trigger()), live('Advanced', expanded: true));
      semantics.dispose();
    });

    testWidgets('reflects a changed title on rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaCollapsible(title: Text('Before')));
      await pump(tester, const NebaCollapsible(title: Text('After')));

      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    });

    testWidgets('sets the body in the sheet body type, muted, padded below and at the sides', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaCollapsible(title: Text('Advanced'), defaultOpen: true, child: Text('Body')),
      );

      final TextStyle style = DefaultTextStyle.of(tester.element(find.text('Body'))).style;
      expect(style.fontSize, NebaScale.sheetBodyText[NebaSize.md]);
      expect(style.color, tokens.mutedFg);

      final Rect sheet = tester.getRect(find.byType(NebaCollapsible));
      final Rect text = tester.getRect(find.text('Body'));
      // The hairline takes a pixel, then a box's padding at md.
      expect(text.left - sheet.left, 17);
      expect(sheet.bottom - text.bottom, 17);
      expect(text.top, tester.getRect(find.byType(NebaDisclosureHeader)).bottom);
    });
  });

  group('folding', () {
    testWidgets('opens when the trigger is pressed and closes on a second press', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCollapsible(title: Text('Advanced'), child: Text('Body')));

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsOneWidget);
      expect(tester.getSemantics(trigger()), live('Advanced', expanded: true));

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsNothing);
      expect(tester.getSemantics(trigger()), live('Advanced', expanded: false));
      semantics.dispose();
    });

    testWidgets('opens from the keyboard', (WidgetTester tester) async {
      await pump(tester, const NebaCollapsible(title: Text('Advanced'), child: Text('Body')));

      Focus.of(tester.element(find.text('Advanced'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('reports the new state', (WidgetTester tester) async {
      final List<bool> reported = <bool>[];

      await pump(
        tester,
        NebaCollapsible(title: const Text('Advanced'), onOpenChange: reported.add),
      );

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Advanced'));

      expect(reported, <bool>[true, false]);
    });

    testWidgets('leaves a controlled collapsible where it was put', (WidgetTester tester) async {
      final List<bool> reported = <bool>[];

      await pump(
        tester,
        NebaCollapsible(
          title: const Text('Advanced'),
          open: false,
          onOpenChange: reported.add,
          child: const Text('Body'),
        ),
      );

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      expect(reported, <bool>[true]);
      expect(find.text('Body'), findsNothing);

      await pump(
        tester,
        NebaCollapsible(
          title: const Text('Advanced'),
          open: true,
          onOpenChange: reported.add,
          child: const Text('Body'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('stops answering when it is disabled, and looks it', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<bool> reported = <bool>[];

      await pump(
        tester,
        NebaCollapsible(
          title: const Text('Advanced'),
          disabled: true,
          onOpenChange: reported.add,
          child: const Text('Body'),
        ),
      );

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.text('Advanced')));
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      expect(reported, isEmpty);
      expect(find.text('Body'), findsNothing);
      expect(
        DefaultTextStyle.of(tester.element(find.text('Advanced'))).style.color,
        tokens.disabledFg,
      );
      // No wash under the pointer on a trigger that does not answer.
      final DecoratedBox wash = tester.widget<DecoratedBox>(
        find
            .descendant(of: find.byType(NebaDisclosureHeader), matching: find.byType(DecoratedBox))
            .first,
      );
      expect((wash.decoration as BoxDecoration).color, edgeless);

      expect(
        tester.getSemantics(trigger()),
        matchesSemantics(
          label: 'Advanced',
          isButton: true,
          hasEnabledState: true,
          hasExpandedState: true,
        ),
      );
      semantics.dispose();
      await mouse.removePointer();
    });

    testWidgets('washes the trigger under the pointer and inks it once open', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCollapsible(title: Text('Advanced'), child: Text('Body')));

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.text('Advanced')));
      await tester.pumpAndSettle();

      final DecoratedBox wash = tester.widget<DecoratedBox>(
        find
            .descendant(of: find.byType(NebaDisclosureHeader), matching: find.byType(DecoratedBox))
            .first,
      );
      expect((wash.decoration as BoxDecoration).color, primary.soft);
      expect(DefaultTextStyle.of(tester.element(find.text('Advanced'))).style.color, tokens.fg);

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      expect(
        DefaultTextStyle.of(tester.element(find.text('Advanced'))).style.color,
        primary.onTint,
      );
      await mouse.removePointer();
    });

    testWidgets('keeps what a closed panel holds through being folded away', (
      WidgetTester tester,
    ) async {
      final TextEditingController controller = TextEditingController();
      addTearDown(controller.dispose);

      Widget field({required bool keepMounted}) {
        return NebaCollapsible(
          title: const Text('Note'),
          keepMounted: keepMounted,
          child: NebaTextField(label: const Text('Leave it with'), placeholder: 'Who'),
        );
      }

      await pump(tester, field(keepMounted: true));
      await tester.tap(find.text('Note'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'The porter');
      await tester.tap(find.text('Note'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Note'));
      await tester.pumpAndSettle();

      expect(find.text('The porter'), findsOneWidget);

      await pump(tester, field(keepMounted: false));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'The porter');
      await tester.tap(find.text('Note'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Note'));
      await tester.pumpAndSettle();

      expect(find.text('The porter'), findsNothing);
    });

    testWidgets('takes a closed panel out of the focus order and the semantics tree', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaCollapsible(
          title: const Text('Advanced'),
          child: NebaButton(onPressed: () {}, child: const Text('Inside')),
        ),
      );

      expect(find.semantics.byLabel('Inside'), findsNothing);
      expect(
        Focus.of(tester.element(find.text('Inside', skipOffstage: false))).canRequestFocus,
        isFalse,
      );

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      expect(find.semantics.byLabel('Inside'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('the panel on its way', () {
    testWidgets('opens to the height of what it holds, without moving it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaCollapsible(
          title: Text('Advanced'),
          child: SizedBox(height: 120, child: Text('Body')),
        ),
      );

      await tester.tap(find.text('Advanced'));
      await tester.pump();
      final double top = tester.getTopLeft(find.text('Body')).dy;
      await tester.pump(NebaScale.duration ~/ 2);

      final double halfway = tester.getSize(panel()).height;
      expect(halfway, greaterThan(0));
      expect(halfway, lessThan(136));
      // A window opening onto the body: the body is where it ends up from the
      // first frame.
      expect(tester.getTopLeft(find.text('Body')).dy, top);

      await tester.pumpAndSettle();

      expect(tester.getSize(panel()).height, 136);
      expect(tester.getTopLeft(find.text('Body')).dy, top);
    });

    testWidgets('turns back from where it is when reversed halfway', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCollapsible(
          title: Text('Advanced'),
          child: SizedBox(height: 120, child: Text('Body')),
        ),
      );

      await tester.tap(find.text('Advanced'));
      await tester.pump();
      await tester.pump(NebaScale.duration ~/ 2);
      final double halfway = tester.getSize(panel()).height;

      await tester.tap(find.text('Advanced'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      expect(tester.getSize(panel()).height, closeTo(halfway, 2));

      await tester.pumpAndSettle();

      expect(tester.getSize(panel()).height, 0);
    });

    testWidgets('opens in one frame for a reader who asked for less motion', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaCollapsible(
          title: Text('Advanced'),
          child: SizedBox(height: 120, child: Text('Body')),
        ),
        disableAnimations: true,
      );

      await tester.tap(find.text('Advanced'));
      await tester.pump();
      await tester.pump();

      expect(tester.getSize(panel()).height, 136);
    });

    // Nothing is transformed on the way: the height is a layout, and the
    // chevron is a glyph, which is the one thing allowed to turn.
    testWidgets('transforms nothing but the chevron', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCollapsible(
          title: Text('Advanced'),
          subtitle: Text('Rarely needed'),
          child: Text('Body'),
        ),
      );

      await tester.tap(find.text('Advanced'));
      await tester.pump(NebaScale.duration ~/ 2);

      final Iterable<Transform> transforms = tester.widgetList<Transform>(
        find.descendant(of: find.byType(NebaCollapsible), matching: find.byType(Transform)),
      );
      final Iterable<Transform> turned = tester.widgetList<Transform>(
        find.descendant(of: find.byType(NebaDisclosureChevron), matching: find.byType(Transform)),
      );
      expect(transforms.length, turned.length);
      await tester.pumpAndSettle();
    });

    testWidgets('turns the chevron half a turn while open', (WidgetTester tester) async {
      await pump(tester, const NebaCollapsible(title: Text('Advanced')));

      AnimatedRotation rotation() => tester.widget<AnimatedRotation>(find.byType(AnimatedRotation));

      expect(rotation().turns, 0);

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      expect(rotation().turns, 0.5);
    });
  });

  group('slots', () {
    testWidgets('draws the chevron by default and drops it on request', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCollapsible(title: Text('Advanced')));

      expect(find.byType(NebaDisclosureChevron), findsOneWidget);

      await pump(tester, const NebaCollapsible(title: Text('Advanced'), indicator: false));

      expect(find.byType(NebaDisclosureChevron), findsNothing);
    });

    testWidgets('draws the start icon before the title, muted', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCollapsible(title: Text('Alerts'), startIcon: SizedBox.square(dimension: 8)),
      );

      final Finder icon = find.byWidgetPredicate(
        (Widget widget) => widget is SizedBox && widget.width == 8 && widget.height == 8,
      );
      expect(tester.getTopLeft(icon).dx, lessThan(tester.getTopLeft(find.text('Alerts')).dx));
      expect(IconTheme.of(tester.element(icon)).color, tokens.mutedFg);
    });

    // A header that both folds and holds a button has two things to press,
    // and one of them cannot be nested inside the other.
    testWidgets('keeps an action out of the trigger, so it can be pressed on its own', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<bool> reported = <bool>[];
      int pressed = 0;

      await pump(
        tester,
        NebaCollapsible(
          title: const Text('Notifications'),
          onOpenChange: reported.add,
          action: NebaButton(onPressed: () => pressed++, child: const Text('Manage')),
          child: const Text('Body'),
        ),
      );

      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();

      expect(pressed, 1);
      expect(reported, isEmpty);
      expect(tester.getSemantics(trigger()).label, 'Notifications');
      semantics.dispose();
    });

    testWidgets('lets a caller replace the header with a control of their own', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaCollapsible(
          variant: NebaVariant.text,
          triggerBuilder: (BuildContext context, bool open, VoidCallback? onToggle) {
            return NebaButton(onPressed: onToggle, child: Text(open ? 'Show less' : 'Show more'));
          },
          child: const Text('Body'),
        ),
      );

      expect(find.byType(NebaDisclosureHeader), findsNothing);
      expect(
        tester.getSemantics(find.byType(NebaButton)),
        matchesSemantics(
          label: 'Show more',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasExpandedState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      await tester.tap(find.text('Show more'));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsOneWidget);
      expect(find.text('Show less'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('hands a disabled caller trigger no callback', (WidgetTester tester) async {
      VoidCallback? handed = () {};

      await pump(
        tester,
        NebaCollapsible(
          disabled: true,
          triggerBuilder: (BuildContext context, bool open, VoidCallback? onToggle) {
            handed = onToggle;
            return const Text('Show more');
          },
        ),
      );

      expect(handed, isNull);
    });

    testWidgets('pads a caller trigger\'s panel on every side, and none when unpadded', (
      WidgetTester tester,
    ) async {
      Widget build({required bool padded}) {
        return NebaCollapsible(
          defaultOpen: true,
          padded: padded,
          triggerBuilder: (BuildContext context, bool open, VoidCallback? onToggle) {
            return const SizedBox(height: 20);
          },
          child: const Text('Body'),
        );
      }

      await pump(tester, build(padded: true));

      final double top = tester.getTopLeft(find.byType(NebaCollapsible)).dy;
      // The hairline, the trigger, then a box's padding at md.
      expect(tester.getTopLeft(find.text('Body')).dy - top, 1 + 20 + 16);

      await pump(tester, build(padded: false));

      expect(tester.getTopLeft(find.text('Body')).dy - top, 1 + 20);
    });
  });

  group('style', () {
    NebaSheet sheet(WidgetTester tester) {
      return tester.widget<NebaSheet>(
        find.descendant(of: find.byType(NebaCollapsible), matching: find.byType(NebaSheet)),
      );
    }

    testWidgets('is an outline sheet with a hairline in its family by default', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCollapsible(title: Text('Advanced')));

      expect(sheet(tester).fill, tokens.panel);
      expect(sheet(tester).edge, primary.line);
      expect(sheet(tester).elevation, 0);
    });

    testWidgets('keeps the sheet undyed while colouring the edge', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCollapsible(title: Text('Advanced'), color: NebaColor.success, elevation: 3),
      );

      expect(sheet(tester).fill, tokens.panel);
      expect(sheet(tester).edge, tokens.roles(NebaColor.success).line);
      expect(sheet(tester).elevation, 3);
    });

    testWidgets('draws a brighter sheet when solid and none when text', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCollapsible(variant: NebaVariant.solid, title: Text('A')));

      expect(sheet(tester).fill, tokens.panelHover);
      expect(sheet(tester).edge, isNull);

      await pump(tester, const NebaCollapsible(variant: NebaVariant.text, title: Text('A')));

      expect(find.byType(NebaSheet), findsNothing);
    });

    testWidgets('follows the provider\'s size and density', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(size: NebaSize.xl, density: NebaDensity.compact),
          child: NebaCollapsible(title: Text('Advanced')),
        ),
      );

      final Rect sheetRect = tester.getRect(find.byType(NebaCollapsible));
      // The hairline, then a compact box's padding at xl.
      expect(tester.getTopLeft(find.text('Advanced')).dx - sheetRect.left, 1 + 16);
    });

    // The sheet clips what is on it, and a ring two pixels off a trigger that
    // spans it would be cut off on three sides.
    testWidgets('draws the focus ring inside the trigger', (WidgetTester tester) async {
      await pump(tester, const NebaCollapsible(title: Text('Advanced')));

      final NebaFocusRing ring = tester.widget<NebaFocusRing>(find.byType(NebaFocusRing));
      expect(ring.offset, -focusRingWidth);
      expect(ring.color, primary.ring);
    });
  });
}
