// NebaToggle: the suite the React package runs on Toggle, asked the way
// Flutter asks it — the state it keeps or is handed, the sheet it draws off
// and on, and the semantics it reports.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  Future<void> pump(WidgetTester tester, Widget toggle) {
    return tester.pumpWidget(host(Center(child: toggle)));
  }

  NebaSheet sheetOf(WidgetTester tester) => tester.widget<NebaSheet>(find.byType(NebaSheet));

  group('rendering', () {
    testWidgets('is a button that says whether it is on', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaToggle(child: Text('Bold')));

      expect(
        tester.getSemantics(find.byType(NebaToggle)),
        matchesSemantics(
          label: 'Bold',
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          hasSelectedState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      await tester.tap(find.text('Bold'));
      await tester.pump();
      expect(
        tester.getSemantics(find.byType(NebaToggle)),
        matchesSemantics(
          label: 'Bold',
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          hasSelectedState: true,
          isSelected: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('can still be pressed and focused from a screen reader with a semanticLabel', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaToggle(semanticLabel: 'Grid', startIcon: SizedBox.square(dimension: 10)),
      );

      expect(
        tester.getSemantics(find.byType(NebaToggle)),
        matchesSemantics(
          label: 'Grid',
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          hasSelectedState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('goes square with no label', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaToggle(semanticLabel: 'Grid', startIcon: SizedBox.square(dimension: 10)),
      );

      expect(tester.getSize(find.byType(NebaSheet)), const Size.square(32));
    });

    testWidgets('reflects a changed label on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaToggle(child: Text('Bold')));
      await pump(tester, const NebaToggle(child: Text('Italic')));

      expect(find.text('Italic'), findsOneWidget);
    });
  });

  group('state', () {
    testWidgets('turns on and off again when pressed, and on Enter', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await pump(tester, NebaToggle(onPressedChange: changes.add, child: const Text('Bold')));
      await tester.tap(find.text('Bold'));
      await tester.pump();
      expect(sheetOf(tester).edge, primary.lineHover);

      Focus.of(tester.element(find.text('Bold'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(changes, <bool>[true, false]);
      expect(sheetOf(tester).edge, tokens.border);
    });

    testWidgets('starts on when told to', (WidgetTester tester) async {
      await pump(tester, const NebaToggle(defaultPressed: true, child: Text('Bold')));

      expect(sheetOf(tester).fill, primary.panelPress);
    });

    testWidgets('stays where a controlled value puts it', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaToggle(pressed: false, onPressedChange: changes.add, child: const Text('Bold')),
      );
      await tester.tap(find.text('Bold'));
      await tester.pump();

      expect(changes, <bool>[true]);
      expect(sheetOf(tester).fill, tokens.panel);
    });

    testWidgets('does nothing while disabled', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaToggle(disabled: true, onPressedChange: changes.add, child: const Text('Bold')),
      );
      await tester.tap(find.text('Bold'), warnIfMissed: false);

      expect(changes, isEmpty);
      expect(sheetOf(tester).edge, tokens.disabledBorder);
    });
  });

  group('style props', () {
    testWidgets('is neutral while off and its colour family while on', (WidgetTester tester) async {
      final NebaColorRoles success = tokens.roles(NebaColor.success);

      await pump(tester, const NebaToggle(color: NebaColor.success, child: Text('Grid')));
      expect(sheetOf(tester).fill, tokens.panel);
      expect(sheetOf(tester).edge, tokens.border);

      await pump(
        tester,
        const NebaToggle(color: NebaColor.success, pressed: true, child: Text('Grid')),
      );
      expect(sheetOf(tester).fill, success.panelPress);
      expect(sheetOf(tester).edge, success.lineHover);

      await pump(
        tester,
        const NebaToggle(
          variant: NebaVariant.solid,
          color: NebaColor.success,
          pressed: true,
          child: Text('Grid'),
        ),
      );
      expect(sheetOf(tester).fill, success.fill);

      await pump(tester, const NebaToggle(variant: NebaVariant.solid, child: Text('Grid')));
      expect(sheetOf(tester).fill, tokens.panelHover);

      await pump(
        tester,
        const NebaToggle(variant: NebaVariant.text, pressed: true, child: Text('Grid')),
      );
      expect(sheetOf(tester).fill, primary.softHover);
    });

    testWidgets('keeps its depth when it goes on', (WidgetTester tester) async {
      await pump(tester, const NebaToggle(elevation: 2, child: Text('Grid')));
      expect(sheetOf(tester).elevation, 2);

      await pump(tester, const NebaToggle(elevation: 2, pressed: true, child: Text('Grid')));
      expect(sheetOf(tester).elevation, 2);
    });

    testWidgets('takes the size a group sets, and its own over it', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaToggleGroup(
          size: NebaSize.sm,
          children: <Widget>[
            NebaToggle(value: 'a', child: Text('A')),
            NebaToggle(value: 'b', size: NebaSize.lg, child: Text('B')),
          ],
        ),
      );

      Size sizeOf(String label) {
        return tester.getSize(
          find.ancestor(of: find.text(label), matching: find.byType(NebaSheet)),
        );
      }

      expect(sizeOf('A').height, 26);
      expect(sizeOf('B').height, 40);
    });

    testWidgets('never applies a transform', (WidgetTester tester) async {
      await pump(tester, const NebaToggle(child: Text('Bold')));

      final TestGesture press = await tester.startGesture(tester.getCenter(find.text('Bold')));
      await tester.pump();
      expect(
        find.descendant(of: find.byType(NebaToggle), matching: find.byType(Transform)),
        findsNothing,
      );
      await press.up();
    });
  });
}
