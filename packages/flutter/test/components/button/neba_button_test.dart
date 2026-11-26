// NebaButton: the suite the React package runs on Button, asked the way
// Flutter asks it — the sheet, the size and the semantics it builds, and what
// a press and a key do — rather than the classes it writes.

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/glow.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  void noop() {}

  Future<void> pump(WidgetTester tester, Widget button, {NebaDefaults? defaults}) {
    final Widget placed = Center(child: button);

    return tester.pumpWidget(
      host(defaults == null ? placed : NebaProvider(defaults: defaults, child: placed)),
    );
  }

  NebaSheet sheetOf(WidgetTester tester) => tester.widget<NebaSheet>(find.byType(NebaSheet));

  Size sizeOf(WidgetTester tester) => tester.getSize(find.byType(NebaSheet));

  group('rendering', () {
    testWidgets('names itself with its label and is a button', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaButton(onPressed: noop, child: const Text('Save')));

      expect(
        tester.getSemantics(find.byType(NebaButton)),
        matchesSemantics(
          label: 'Save',
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('reflects a changed label on a rebuild', (WidgetTester tester) async {
      await pump(tester, NebaButton(onPressed: noop, child: const Text('Save')));
      await pump(tester, NebaButton(onPressed: noop, child: const Text('Saved')));

      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('never applies a transform, so the label cannot move', (WidgetTester tester) async {
      await pump(tester, NebaButton(onPressed: noop, child: const Text('Save')));

      final TestGesture press = await tester.startGesture(tester.getCenter(find.text('Save')));
      await tester.pump();

      expect(
        find.descendant(of: find.byType(NebaButton), matching: find.byType(Transform)),
        findsNothing,
      );
      await press.up();
    });
  });

  group('style props', () {
    testWidgets('is solid, primary and flat by default', (WidgetTester tester) async {
      await pump(tester, NebaButton(onPressed: noop, child: const Text('Save')));

      expect(sheetOf(tester).fill, tokens.roles(NebaColor.primary).fill);
      expect(sheetOf(tester).plate, NebaPlate.solid);
      expect(sheetOf(tester).edge, isNull);
      expect(sheetOf(tester).elevation, 0);
    });

    testWidgets('draws its colour family on the fill', (WidgetTester tester) async {
      for (final NebaColor color in NebaColor.values) {
        await pump(tester, NebaButton(onPressed: noop, color: color, child: const Text('Save')));

        expect(sheetOf(tester).fill, tokens.roles(color).fill, reason: color.name);
      }
    });

    testWidgets('draws a hairline for the outline variant only', (WidgetTester tester) async {
      await pump(
        tester,
        NebaButton(onPressed: noop, variant: NebaVariant.outline, child: const Text('Cancel')),
      );
      expect(sheetOf(tester).edge, tokens.roles(NebaColor.primary).line);
      expect(sheetOf(tester).fill, tokens.roles(NebaColor.primary).panel);
      expect(sheetOf(tester).plate, NebaPlate.glass);

      await pump(
        tester,
        NebaButton(onPressed: noop, variant: NebaVariant.text, child: const Text('Details')),
      );
      expect(sheetOf(tester).edge, isNull);
      expect(sheetOf(tester).fill, const Color(0x00000000));
      expect(sheetOf(tester).plate, NebaPlate.none);
    });

    testWidgets('changes height with size and not with density', (WidgetTester tester) async {
      const Map<NebaSize, double> heights = <NebaSize, double>{
        NebaSize.xs: 22,
        NebaSize.sm: 26,
        NebaSize.md: 32,
        NebaSize.lg: 40,
        NebaSize.xl: 48,
      };

      for (final MapEntry<NebaSize, double> entry in heights.entries) {
        for (final NebaDensity density in NebaDensity.values) {
          await pump(
            tester,
            NebaButton(
              onPressed: noop,
              size: entry.key,
              density: density,
              child: const Text('Save'),
            ),
          );

          expect(sizeOf(tester).height, entry.value, reason: '${entry.key.name} ${density.name}');
        }
      }
    });

    testWidgets('changes its inline padding with density', (WidgetTester tester) async {
      await pump(tester, NebaButton(onPressed: noop, child: const Text('Save')));
      final double standard = sizeOf(tester).width;

      await pump(
        tester,
        NebaButton(onPressed: noop, density: NebaDensity.compact, child: const Text('Save')),
      );

      // 16 a side against 10 a side at md.
      expect(standard - sizeOf(tester).width, 12);
    });

    testWidgets('takes its defaults from the provider, and its own over them', (
      WidgetTester tester,
    ) async {
      const NebaDefaults defaults = NebaDefaults(size: NebaSize.lg, variant: NebaVariant.outline);

      await pump(
        tester,
        NebaButton(onPressed: noop, child: const Text('Save')),
        defaults: defaults,
      );
      expect(sizeOf(tester).height, 40);
      expect(sheetOf(tester).plate, NebaPlate.glass);

      await pump(
        tester,
        NebaButton(onPressed: noop, variant: NebaVariant.solid, child: const Text('Save')),
        defaults: defaults,
      );
      expect(sheetOf(tester).plate, NebaPlate.solid);
    });

    testWidgets('goes up a level on hover and down one on a press', (WidgetTester tester) async {
      await pump(tester, NebaButton(onPressed: noop, elevation: 2, child: const Text('Save')));
      expect(sheetOf(tester).elevation, 2);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.text('Save')));
      addTearDown(mouse.removePointer);
      await tester.pump();
      expect(sheetOf(tester).elevation, 3);
      expect(sheetOf(tester).fill, tokens.roles(NebaColor.primary).fillHover);

      await mouse.down(tester.getCenter(find.text('Save')));
      await tester.pump();
      expect(sheetOf(tester).elevation, 1);
      expect(sheetOf(tester).fill, tokens.roles(NebaColor.primary).fillActive);
      expect(sheetOf(tester).pressed, isTrue);

      await mouse.up();
      await tester.pumpAndSettle();
    });

    testWidgets('lights up under the pointer only while it can be pressed', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaButton(onPressed: noop, child: const Text('Save')));
      expect(find.byType(NebaGlow), findsOneWidget);

      for (final NebaButton button in <NebaButton>[
        const NebaButton(onPressed: null, child: Text('Save')),
        NebaButton(onPressed: noop, loading: true, child: const Text('Save')),
        NebaButton(onPressed: noop, readOnly: true, child: const Text('Save')),
      ]) {
        await pump(tester, button);
        expect(find.byType(NebaGlow), findsNothing);
      }
    });

    testWidgets('stretches to the width it is given when fullWidth is set', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        SizedBox(
          width: 300,
          child: NebaButton(onPressed: noop, fullWidth: true, child: const Text('Save')),
        ),
      );

      expect(sizeOf(tester).width, 300);
    });

    testWidgets('goes square when it has no label', (WidgetTester tester) async {
      await pump(
        tester,
        NebaButton(onPressed: noop, semanticLabel: 'Add', startIcon: NebaGlyph(NebaGlyphs.plus)),
      );

      expect(sizeOf(tester), const Size(32, 32));
    });

    testWidgets('places startIcon before and endIcon after the label', (WidgetTester tester) async {
      await pump(
        tester,
        NebaButton(
          onPressed: noop,
          startIcon: const SizedBox(key: Key('start'), width: 10, height: 10),
          endIcon: const SizedBox(key: Key('end'), width: 10, height: 10),
          child: const Text('Save'),
        ),
      );

      final double start = tester.getCenter(find.byKey(const Key('start'))).dx;
      final double label = tester.getCenter(find.text('Save')).dx;
      final double end = tester.getCenter(find.byKey(const Key('end'))).dx;

      expect(start, lessThan(label));
      expect(end, greaterThan(label));
    });

    testWidgets('draws its icons at 1.2 times the label', (WidgetTester tester) async {
      await pump(
        tester,
        NebaButton(
          onPressed: noop,
          startIcon: NebaGlyph(NebaGlyphs.plus),
          child: const Text('New'),
        ),
      );

      expect(tester.getSize(find.byType(NebaGlyph)), Size.square(13 * 1.2));
    });
  });

  group('pressing', () {
    testWidgets('calls onPressed on a tap, and on Enter and Space', (WidgetTester tester) async {
      int pressed = 0;

      await pump(tester, NebaButton(onPressed: () => pressed += 1, child: const Text('Save')));

      await tester.tap(find.text('Save'));
      expect(pressed, 1);

      Focus.of(tester.element(find.text('Save'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(pressed, 3);
    });

    testWidgets('is disabled with no onPressed, or with disabled, and out of the focus order', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int pressed = 0;

      for (final NebaButton button in <NebaButton>[
        const NebaButton(onPressed: null, child: Text('Save')),
        NebaButton(onPressed: () => pressed += 1, disabled: true, child: const Text('Save')),
      ]) {
        await pump(tester, button);
        await tester.tap(find.text('Save'), warnIfMissed: false);

        expect(sheetOf(tester).fill, tokens.disabledBg);
        expect(Focus.of(tester.element(find.text('Save'))).canRequestFocus, isFalse);
        expect(
          tester.getSemantics(find.byType(NebaButton)),
          matchesSemantics(label: 'Save', isButton: true, hasEnabledState: true),
        );
      }

      expect(pressed, 0);
      semantics.dispose();
    });

    testWidgets('keeps a disabled button focusable when asked, and still unpressable', (
      WidgetTester tester,
    ) async {
      int pressed = 0;

      await pump(
        tester,
        NebaButton(
          onPressed: () => pressed += 1,
          disabled: true,
          focusableWhenDisabled: true,
          child: const Text('Next'),
        ),
      );

      final FocusNode node = Focus.of(tester.element(find.text('Next')));
      expect(node.canRequestFocus, isTrue);

      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.tap(find.text('Next'));
      expect(pressed, 0);
    });

    testWidgets('keeps the focus and swaps in a turning ring while loading, and does not fire', (
      WidgetTester tester,
    ) async {
      int pressed = 0;

      await pump(
        tester,
        NebaButton(
          onPressed: () => pressed += 1,
          loading: true,
          startIcon: const SizedBox(key: Key('start'), width: 10, height: 10),
          child: const Text('Saving'),
        ),
      );

      expect(find.byType(NebaSpinner), findsOneWidget);
      expect(find.byKey(const Key('start')), findsNothing);
      // Unchanged at rest: a busy button is not a disabled one.
      expect(sheetOf(tester).fill, tokens.roles(NebaColor.primary).fill);

      final FocusNode node = Focus.of(tester.element(find.text('Saving')));
      expect(node.canRequestFocus, isTrue);

      await tester.tap(find.text('Saving'));
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(pressed, 0);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('keeps its colour but goes flat and desaturated when read-only', (
      WidgetTester tester,
    ) async {
      int pressed = 0;

      await pump(
        tester,
        NebaButton(
          onPressed: () => pressed += 1,
          readOnly: true,
          elevation: 2,
          child: const Text('Locked'),
        ),
      );

      expect(sheetOf(tester).fill, tokens.roles(NebaColor.primary).fill);
      expect(sheetOf(tester).elevation, 0);
      expect(find.byType(ColorFiltered), findsOneWidget);
      expect(Focus.of(tester.element(find.text('Locked'))).canRequestFocus, isTrue);

      await tester.tap(find.text('Locked'));
      expect(pressed, 0);
    });

    testWidgets('takes its name from semanticLabel over the label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaButton(onPressed: noop, semanticLabel: 'Add', startIcon: NebaGlyph(NebaGlyphs.plus)),
      );

      expect(find.bySemanticsLabel('Add'), findsOneWidget);
      semantics.dispose();
    });
  });
}
