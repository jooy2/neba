// NebaFloatingActionButton: the suite the React package runs on
// FloatingActionButton, asked the way Flutter asks it — the button a screen
// reader hears and whether it says the dial is open, the corner it sits in
// and the insets it keeps clear of, the dial opened by a press or a mouse and
// put away by Escape, a press outside or an action, the focus given back, and
// the opacity the dial arrives in — rather than the classes and the custom
// properties it writes.

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  /// [fab] over an 800 by 600 region, as a floating button is meant to be put:
  /// in a `Stack` over what it floats over.
  Future<void> pump(
    WidgetTester tester,
    Widget fab, {
    EdgeInsets padding = EdgeInsets.zero,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: const Size(800, 600), padding: padding),
        child: Directionality(
          textDirection: textDirection,
          child: Stack(
            children: <Widget>[
              const Positioned.fill(child: SizedBox(key: Key('page'))),
              fab,
            ],
          ),
        ),
      ),
    );
  }

  Finder button(String label) => find.bySemanticsLabel(label);

  Rect trigger(WidgetTester tester) {
    return tester.getRect(
      find
          .descendant(of: find.byType(NebaFloatingActionButton), matching: find.byType(NebaSheet))
          .first,
    );
  }

  /// A dial of two actions, which hover does not open.
  NebaFloatingActionButton dial({
    bool? open,
    bool defaultOpen = false,
    ValueChanged<bool>? onOpenChange,
    bool closeOnAction = true,
    bool showLabels = true,
    NebaCorner corner = NebaCorner.bottomEnd,
    VoidCallback? onCopy,
  }) {
    return NebaFloatingActionButton(
      label: 'Share',
      openOnHover: false,
      open: open,
      defaultOpen: defaultOpen,
      onOpenChange: onOpenChange,
      closeOnAction: closeOnAction,
      showLabels: showLabels,
      corner: corner,
      children: <NebaFloatingAction>[
        NebaFloatingAction(label: 'Copy link', icon: const Text('C'), onPressed: onCopy),
        const NebaFloatingAction(label: 'Email', icon: Text('E')),
      ],
    );
  }

  /// The focus node of the action whose glyph is [glyph].
  FocusNode actionFocus(WidgetTester tester, String glyph) {
    return Focus.of(tester.element(find.text(glyph)));
  }

  /// The focus node of the button itself.
  FocusNode buttonFocus(WidgetTester tester) {
    return Focus.of(
      tester.element(
        find
            .descendant(of: find.byType(NebaFloatingActionButton), matching: find.byType(NebaGlyph))
            .first,
      ),
    );
  }

  bool shown(String label) => find
      .byWidgetPredicate((Widget widget) {
        return widget is NebaFloatingAction && widget.label == label;
      })
      .evaluate()
      .isNotEmpty;

  group('rendering', () {
    testWidgets('is a button named by its label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaFloatingActionButton(label: 'Compose', onPressed: () {}));

      expect(
        tester.getSemantics(button('Compose')),
        matchesSemantics(
          label: 'Compose',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('draws a plus when it is given no glyph', (WidgetTester tester) async {
      await pump(tester, NebaFloatingActionButton(label: 'Compose', onPressed: () {}));

      expect(tester.widget<NebaGlyph>(find.byType(NebaGlyph)).parts, NebaGlyphs.plus);
    });

    testWidgets('is a disc a step up the ladder, two levels up the shadows', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaFloatingActionButton(label: 'Compose', onPressed: () {}));

      final NebaSheet sheet = tester.widget<NebaSheet>(find.byType(NebaSheet));
      expect(trigger(tester).size, const Size.square(40));
      expect(sheet.borderRadius, BorderRadius.circular(9999));
      expect(sheet.elevation, 2);
    });

    testWidgets('writes the label on a stadium when it is extended', (WidgetTester tester) async {
      await pump(
        tester,
        NebaFloatingActionButton(label: 'Compose', extended: true, onPressed: () {}),
      );

      expect(find.text('Compose'), findsOneWidget);
      expect(trigger(tester).width, greaterThan(trigger(tester).height));
      expect(
        tester.widget<NebaSheet>(find.byType(NebaSheet)).borderRadius,
        BorderRadius.circular(9999),
      );
    });

    testWidgets('reflects a changed label on rebuild', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaFloatingActionButton(label: 'Before', onPressed: () {}));
      await pump(tester, NebaFloatingActionButton(label: 'After', onPressed: () {}));

      expect(button('After'), findsOneWidget);
      expect(button('Before'), findsNothing);
      semantics.dispose();
    });
  });

  group('position', () {
    testWidgets('sits in the bottom end corner of what it floats over, 16 pixels in', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaFloatingActionButton(label: 'Compose', onPressed: () {}));

      expect(trigger(tester).bottomRight, const Offset(800 - 16, 600 - 16));
    });

    testWidgets('takes the corner and the offset it is given', (WidgetTester tester) async {
      await pump(
        tester,
        NebaFloatingActionButton(
          label: 'Compose',
          corner: NebaCorner.topStart,
          offset: 24,
          onPressed: () {},
        ),
      );

      expect(trigger(tester).topLeft, const Offset(24, 24));
    });

    testWidgets('turns its end corner round under RTL', (WidgetTester tester) async {
      await pump(
        tester,
        NebaFloatingActionButton(label: 'Compose', onPressed: () {}),
        textDirection: TextDirection.rtl,
      );

      expect(trigger(tester).bottomLeft, const Offset(16, 600 - 16));
    });

    testWidgets('adds the insets of its corner\'s edges when fixed, and only then', (
      WidgetTester tester,
    ) async {
      const EdgeInsets padding = EdgeInsets.fromLTRB(11, 47, 13, 34);

      await pump(
        tester,
        NebaFloatingActionButton(label: 'Compose', onPressed: () {}),
        padding: padding,
      );
      expect(trigger(tester).bottomRight, const Offset(800 - 16 - 13, 600 - 16 - 34));

      await pump(
        tester,
        NebaFloatingActionButton(
          label: 'Compose',
          position: NebaFloatingActionButtonPosition.absolute,
          onPressed: () {},
        ),
        padding: padding,
      );
      expect(trigger(tester).bottomRight, const Offset(800 - 16, 600 - 16));

      await pump(
        tester,
        NebaFloatingActionButton(label: 'Compose', safeArea: false, onPressed: () {}),
        padding: padding,
      );
      expect(trigger(tester).bottomRight, const Offset(800 - 16, 600 - 16));
    });

    testWidgets('is only the button in the flow when static', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          Center(
            child: NebaFloatingActionButton(
              label: 'Compose',
              position: NebaFloatingActionButtonPosition.static,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(NebaFloatingActionButton)), const Size.square(40));
    });

    testWidgets('lets a press beside it through to what is underneath', (
      WidgetTester tester,
    ) async {
      int presses = 0;

      await tester.pumpWidget(
        host(
          Stack(
            children: <Widget>[
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => presses++,
                  child: const SizedBox.expand(),
                ),
              ),
              NebaFloatingActionButton(label: 'Compose', onPressed: () {}),
            ],
          ),
        ),
      );
      await tester.tapAt(const Offset(100, 100));

      expect(presses, 1);
    });
  });

  group('on its own', () {
    testWidgets('calls onPressed when it is pressed', (WidgetTester tester) async {
      int presses = 0;

      await pump(tester, NebaFloatingActionButton(label: 'Compose', onPressed: () => presses++));
      await tester.tap(find.byType(NebaSheet));

      expect(presses, 1);
    });

    testWidgets('says nothing about a dial it does not have', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaFloatingActionButton(label: 'Compose', onPressed: () {}));

      expect(
        tester.getSemantics(button('Compose')),
        matchesSemantics(
          label: 'Compose',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('stops answering when disabled, or with nothing to do', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int presses = 0;

      await pump(
        tester,
        NebaFloatingActionButton(label: 'Compose', disabled: true, onPressed: () => presses++),
      );
      await tester.tap(find.byType(NebaSheet));
      expect(presses, 0);
      expect(
        tester.getSemantics(button('Compose')),
        matchesSemantics(label: 'Compose', isButton: true, hasEnabledState: true),
      );

      await pump(tester, const NebaFloatingActionButton(label: 'Compose'));
      expect(
        tester.getSemantics(button('Compose')),
        matchesSemantics(label: 'Compose', isButton: true, hasEnabledState: true),
      );
      semantics.dispose();
    });
  });

  group('the dial', () {
    testWidgets('starts closed and says so', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, dial());

      expect(
        tester.getSemantics(button('Share')),
        matchesSemantics(
          label: 'Share',
          isButton: true,
          hasExpandedState: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(shown('Copy link'), isFalse);
      semantics.dispose();
    });

    testWidgets('opens when the button is pressed, and says so', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, dial());
      await tester.tap(find.byType(NebaSheet).first);
      await tester.pumpAndSettle();

      expect(shown('Copy link'), isTrue);
      expect(
        tester.getSemantics(button('Share')),
        matchesSemantics(
          label: 'Share',
          isButton: true,
          hasExpandedState: true,
          isExpanded: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      // The glyph swaps for a ×.
      expect(
        tester
            .widget<NebaGlyph>(
              find.descendant(
                of: find.byType(NebaIconButton).first,
                matching: find.byType(NebaGlyph),
              ),
            )
            .parts,
        NebaGlyphs.close,
      );
      semantics.dispose();
    });

    testWidgets('reports the new state', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await pump(tester, dial(onOpenChange: changes.add));
      await tester.tap(find.byType(NebaSheet).first);

      expect(changes, <bool>[true]);
    });

    testWidgets('leaves a controlled dial where it was put', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await pump(tester, dial(open: false, onOpenChange: changes.add));
      await tester.tap(find.byType(NebaSheet).first);
      await tester.pumpAndSettle();

      expect(changes, <bool>[true]);
      expect(shown('Copy link'), isFalse);
    });

    testWidgets('fades in, and moves nothing', (WidgetTester tester) async {
      await pump(tester, dial());
      await tester.tap(find.byType(NebaSheet).first);
      await tester.pump();

      final FadeTransition fade = tester.widget<FadeTransition>(
        find.ancestor(of: find.text('Email'), matching: find.byType(FadeTransition)).first,
      );
      expect(fade.opacity.value, 0);
      final Rect before = tester.getRect(find.text('Email'));

      await tester.pump(NebaScale.duration ~/ 2);
      expect(fade.opacity.value, greaterThan(0));
      expect(fade.opacity.value, lessThan(1));
      expect(tester.getRect(find.text('Email')), before);

      await tester.pumpAndSettle();
      expect(fade.opacity.value, 1);
      expect(find.ancestor(of: find.text('Email'), matching: find.byType(Transform)), findsNothing);
    });

    testWidgets('fans up from a bottom corner and down from a top one', (
      WidgetTester tester,
    ) async {
      await pump(tester, dial(defaultOpen: true));
      await tester.pumpAndSettle();

      final Rect share = trigger(tester);
      expect(tester.getRect(find.bySemanticsLabel('Copy link')).bottom, lessThan(share.top));
      // The first action is the one nearest the button.
      expect(
        tester.getRect(find.bySemanticsLabel('Copy link')).top,
        greaterThan(tester.getRect(find.bySemanticsLabel('Email')).top),
      );

      await pump(tester, dial(defaultOpen: true, corner: NebaCorner.topEnd));
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.bySemanticsLabel('Copy link')).top,
        greaterThan(trigger(tester).bottom),
      );
    });

    testWidgets('puts each name on the inside of the corner', (WidgetTester tester) async {
      await pump(tester, dial(defaultOpen: true));
      await tester.pumpAndSettle();

      expect(
        tester.getRect(find.text('Copy link')).right,
        lessThan(tester.getRect(find.bySemanticsLabel('Copy link')).left),
      );

      await pump(tester, dial(defaultOpen: true, corner: NebaCorner.bottomStart));
      await tester.pumpAndSettle();

      expect(
        tester.getRect(find.text('Copy link')).left,
        greaterThan(tester.getRect(find.bySemanticsLabel('Copy link')).right),
      );
    });

    testWidgets('draws the actions a step down the ladder', (WidgetTester tester) async {
      await pump(tester, dial(defaultOpen: true));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.bySemanticsLabel('Copy link')), const Size.square(32));
    });

    testWidgets('runs an action and puts the dial away', (WidgetTester tester) async {
      int copies = 0;

      await pump(tester, dial(defaultOpen: true, onCopy: () => copies++));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Copy link'));
      await tester.pumpAndSettle();

      expect(copies, 1);
      expect(shown('Copy link'), isFalse);
    });

    testWidgets('gives the focus back to the button when an action closes the dial', (
      WidgetTester tester,
    ) async {
      await pump(tester, dial(defaultOpen: true));
      await tester.pumpAndSettle();

      actionFocus(tester, 'C').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(shown('Copy link'), isFalse);
      expect(buttonFocus(tester).hasPrimaryFocus, isTrue);
    });

    testWidgets('keeps the dial up when it was told to', (WidgetTester tester) async {
      await pump(tester, dial(defaultOpen: true, closeOnAction: false));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Copy link'));
      await tester.pumpAndSettle();

      expect(shown('Copy link'), isTrue);
    });

    testWidgets('draws each name beside its action, and stops when asked', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, dial(defaultOpen: true));
      await tester.pumpAndSettle();
      expect(find.text('Copy link'), findsOneWidget);
      // Heard once, on the button: the lozenge is pixels only.
      expect(find.bySemanticsLabel('Copy link'), findsOneWidget);

      await pump(tester, dial(defaultOpen: true, showLabels: false));
      await tester.pumpAndSettle();
      expect(find.text('Copy link'), findsNothing);
      expect(find.bySemanticsLabel('Copy link'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('will not open a dial it has no actions for', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaFloatingActionButton(label: 'Share', defaultOpen: true, onPressed: () {}),
      );

      expect(
        tester.getSemantics(button('Share')),
        matchesSemantics(
          label: 'Share',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(tester.widget<NebaGlyph>(find.byType(NebaGlyph)).parts, NebaGlyphs.plus);
      semantics.dispose();
    });

    testWidgets('closes on Escape and hands the focus back', (WidgetTester tester) async {
      await pump(tester, dial());
      await tester.tap(find.byType(NebaSheet).first);
      await tester.pumpAndSettle();

      actionFocus(tester, 'E').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(shown('Copy link'), isFalse);
      expect(buttonFocus(tester).hasPrimaryFocus, isTrue);
    });

    testWidgets('closes on Escape after a press that left the focus where it was', (
      WidgetTester tester,
    ) async {
      await pump(tester, dial());
      await tester.tap(find.byType(NebaSheet).first);
      await tester.pumpAndSettle();
      expect(shown('Copy link'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(shown('Copy link'), isFalse);
      expect(buttonFocus(tester).hasPrimaryFocus, isFalse);
    });

    testWidgets('closes on a press anywhere else, and not on one inside it', (
      WidgetTester tester,
    ) async {
      await pump(tester, dial(defaultOpen: true));
      await tester.pumpAndSettle();

      // Between the button and its first action is still the dial.
      final Rect share = trigger(tester);
      await tester.tapAt(Offset(share.center.dx, share.top - 4));
      await tester.pumpAndSettle();
      expect(shown('Copy link'), isTrue);

      await tester.tapAt(const Offset(100, 100));
      await tester.pumpAndSettle();
      expect(shown('Copy link'), isFalse);
    });

    testWidgets('puts the actions right after the button in the focus order', (
      WidgetTester tester,
    ) async {
      await pump(tester, dial(defaultOpen: true));
      await tester.pumpAndSettle();

      final FocusNode share = buttonFocus(tester);
      share.requestFocus();
      await tester.pump();
      share.nextFocus();
      await tester.pump();

      expect(actionFocus(tester, 'C').hasPrimaryFocus, isTrue);
    });
  });

  group('hover', () {
    testWidgets('opens on a mouse arriving and closes when it leaves', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaFloatingActionButton(
          label: 'Share',
          children: <NebaFloatingAction>[NebaFloatingAction(label: 'Copy link')],
        ),
      );

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(10, 10));
      await mouse.moveTo(trigger(tester).center);
      await tester.pumpAndSettle();
      expect(shown('Copy link'), isTrue);

      await mouse.moveTo(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(shown('Copy link'), isFalse);
      await mouse.removePointer();
    });

    // A mouse opened the dial on its way to the button, and the click that
    // followed shut it again.
    testWidgets('keeps a dial the mouse opened up when the button is then clicked', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaFloatingActionButton(
          label: 'Share',
          children: <NebaFloatingAction>[NebaFloatingAction(label: 'Copy link')],
        ),
      );

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(10, 10));
      await mouse.moveTo(trigger(tester).center);
      await tester.pumpAndSettle();

      await mouse.down(trigger(tester).center);
      await mouse.up();
      await tester.pumpAndSettle();
      expect(shown('Copy link'), isTrue);

      await mouse.down(trigger(tester).center);
      await mouse.up();
      await tester.pumpAndSettle();
      expect(shown('Copy link'), isFalse);
      await mouse.removePointer();
    });

    testWidgets('does not open for a finger', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaFloatingActionButton(
          label: 'Share',
          children: <NebaFloatingAction>[NebaFloatingAction(label: 'Copy link')],
        ),
      );

      // A tap is a finger: it opens the dial by pressing it, once.
      await tester.tap(find.byType(NebaSheet).first);
      await tester.pumpAndSettle();
      expect(shown('Copy link'), isTrue);

      await tester.tap(find.byType(NebaSheet).first);
      await tester.pumpAndSettle();
      expect(shown('Copy link'), isFalse);
    });
  });

  testWidgets('fails with a message outside a floating button', (WidgetTester tester) async {
    await tester.pumpWidget(host(const NebaFloatingAction(label: 'Copy link')));

    expect(tester.takeException(), isFlutterError);
  });

  testWidgets('draws the lozenge on the undyed panel', (WidgetTester tester) async {
    await pump(tester, dial(defaultOpen: true));
    await tester.pumpAndSettle();

    final NebaSheet lozenge = tester.widget<NebaSheet>(
      find.ancestor(of: find.text('Copy link'), matching: find.byType(NebaSheet)).first,
    );
    expect(lozenge.fill, tokens.panel);
    expect(lozenge.elevation, 1);
  });
}
