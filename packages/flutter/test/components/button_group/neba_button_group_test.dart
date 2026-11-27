// NebaButtonGroup: the suite the React package runs on ButtonGroup, asked the
// way Flutter asks it — the corners each button draws, where each one lands,
// and what each one inherits — rather than the selectors it writes.

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  void noop() {}

  Future<void> pump(
    WidgetTester tester,
    Widget group, {
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return tester.pumpWidget(host(Center(child: group), textDirection: textDirection));
  }

  List<Widget> three() => <Widget>[
    NebaButton(onPressed: noop, child: const Text('Day')),
    NebaButton(onPressed: noop, child: const Text('Week')),
    NebaButton(onPressed: noop, child: const Text('Month')),
  ];

  NebaSheet sheetOf(WidgetTester tester, String label) {
    return tester.widget<NebaSheet>(
      find.ancestor(of: find.text(label), matching: find.byType(NebaSheet)),
    );
  }

  Rect rectOf(WidgetTester tester, String label) {
    return tester.getRect(find.ancestor(of: find.text(label), matching: find.byType(NebaSheet)));
  }

  const Radius round = Radius.circular(14);

  group('rendering', () {
    testWidgets('groups its buttons for a screen reader under the label it is given', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaButtonGroup(semanticLabel: 'Range', children: three()));

      expect(find.bySemanticsLabel('Range'), findsOneWidget);
      expect(find.bySemanticsLabel('Week'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('squares off the corners that face a neighbour', (WidgetTester tester) async {
      await pump(tester, NebaButtonGroup(children: three()));

      expect(
        sheetOf(tester, 'Day').borderRadius,
        const BorderRadius.only(topLeft: round, bottomLeft: round),
      );
      expect(sheetOf(tester, 'Week').borderRadius, BorderRadius.zero);
      expect(
        sheetOf(tester, 'Month').borderRadius,
        const BorderRadius.only(topRight: round, bottomRight: round),
      );
    });

    testWidgets('squares the other pair when vertical', (WidgetTester tester) async {
      await pump(tester, NebaButtonGroup(orientation: NebaOrientation.vertical, children: three()));

      expect(
        sheetOf(tester, 'Day').borderRadius,
        const BorderRadius.only(topLeft: round, topRight: round),
      );
      expect(
        sheetOf(tester, 'Month').borderRadius,
        const BorderRadius.only(bottomLeft: round, bottomRight: round),
      );
    });

    testWidgets('makes a vertical group as wide as its widest button', (WidgetTester tester) async {
      await pump(tester, NebaButtonGroup(orientation: NebaOrientation.vertical, children: three()));

      expect(rectOf(tester, 'Day').width, rectOf(tester, 'Month').width);
      expect(rectOf(tester, 'Week').top, rectOf(tester, 'Day').bottom);
    });

    testWidgets('starts from the right under a right-to-left direction', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaButtonGroup(children: three()), textDirection: TextDirection.rtl);

      expect(rectOf(tester, 'Day').left, greaterThan(rectOf(tester, 'Week').left));
      expect(
        sheetOf(tester, 'Day').borderRadius,
        const BorderRadius.only(topRight: round, bottomRight: round),
      );
    });

    testWidgets('shares one hairline between outline buttons, and only those', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaButtonGroup(variant: NebaVariant.outline, children: three()));
      expect(rectOf(tester, 'Week').left, rectOf(tester, 'Day').right - 1);

      await pump(tester, NebaButtonGroup(children: three()));
      expect(rectOf(tester, 'Week').left, rectOf(tester, 'Day').right);
    });

    testWidgets('divides the width evenly when full width', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          Center(
            child: SizedBox(width: 300, child: NebaButtonGroup(fullWidth: true, children: three())),
          ),
        ),
      );

      expect(rectOf(tester, 'Day').width, 100);
      expect(rectOf(tester, 'Week').width, 100);
      expect(rectOf(tester, 'Month').right - rectOf(tester, 'Day').left, 300);
    });

    testWidgets('keeps a button whose label needs more than an even share at its own width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          Center(
            child: SizedBox(
              width: 300,
              child: NebaButtonGroup(
                fullWidth: true,
                children: <Widget>[
                  NebaButton(onPressed: noop, child: const Text('A')),
                  NebaButton(onPressed: noop, child: const Text('A longer label')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final double long = rectOf(tester, 'A longer label').width;
      expect(long, greaterThan(150));
      expect(rectOf(tester, 'A').width, 300 - long);
    });

    testWidgets('puts the button under the pointer over its neighbours', (
      WidgetTester tester,
    ) async {
      final List<String> pressed = <String>[];

      await pump(
        tester,
        NebaButtonGroup(
          variant: NebaVariant.outline,
          children: <Widget>[
            NebaButton(onPressed: () => pressed.add('Day'), child: const Text('Day')),
            NebaButton(onPressed: () => pressed.add('Week'), child: const Text('Week')),
          ],
        ),
      );

      // The pixel the two outline buttons share.
      final Offset seam = Offset(
        rectOf(tester, 'Day').right - 0.5,
        rectOf(tester, 'Day').center.dy,
      );

      // At rest the later button lies over the earlier one.
      await tester.tapAt(seam);
      expect(pressed, <String>['Week']);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.text('Day')));
      await tester.pump();
      await mouse.moveTo(seam);
      await tester.pump();
      await mouse.down(seam);
      await mouse.up();
      await tester.pump();

      // Under the pointer, the earlier one comes forward.
      expect(pressed, <String>['Week', 'Day']);
      await mouse.removePointer();
    });
  });

  group('shared props', () {
    testWidgets('sets size, colour and density for every button in the set', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaButtonGroup(
          size: NebaSize.sm,
          color: NebaColor.success,
          density: NebaDensity.compact,
          children: three(),
        ),
      );

      for (final String label in <String>['Day', 'Week', 'Month']) {
        expect(rectOf(tester, label).height, 26, reason: label);
        expect(sheetOf(tester, label).fill, tokens.roles(NebaColor.success).fill, reason: label);
      }
    });

    testWidgets('sets the variant and the elevation for every button', (WidgetTester tester) async {
      await pump(
        tester,
        NebaButtonGroup(variant: NebaVariant.outline, elevation: 2, children: three()),
      );

      expect(sheetOf(tester, 'Week').plate, NebaPlate.glass);
      expect(sheetOf(tester, 'Week').elevation, 2);
    });

    testWidgets('lets a button override the group', (WidgetTester tester) async {
      await pump(
        tester,
        NebaButtonGroup(
          color: NebaColor.secondary,
          children: <Widget>[
            NebaButton(onPressed: noop, child: const Text('Copy')),
            NebaButton(onPressed: noop, color: NebaColor.danger, child: const Text('Delete')),
          ],
        ),
      );

      expect(sheetOf(tester, 'Copy').fill, tokens.roles(NebaColor.secondary).fill);
      expect(sheetOf(tester, 'Delete').fill, tokens.roles(NebaColor.danger).fill);
    });

    testWidgets('disables the whole set, unless a button says otherwise', (
      WidgetTester tester,
    ) async {
      int pressed = 0;

      await pump(
        tester,
        NebaButtonGroup(
          disabled: true,
          children: <Widget>[
            NebaButton(onPressed: () => pressed += 1, child: const Text('Day')),
            NebaButton(onPressed: () => pressed += 10, disabled: false, child: const Text('Week')),
          ],
        ),
      );
      await tester.tap(find.text('Day'), warnIfMissed: false);
      await tester.tap(find.text('Week'));

      expect(pressed, 10);
      expect(sheetOf(tester, 'Day').fill, tokens.disabledBg);
    });

    testWidgets('reaches a button that is not a direct child', (WidgetTester tester) async {
      await pump(
        tester,
        NebaButtonGroup(
          size: NebaSize.lg,
          children: <Widget>[
            Semantics(
              hint: 'Opens the editor',
              child: NebaButton(onPressed: noop, child: const Text('Edit')),
            ),
          ],
        ),
      );

      expect(rectOf(tester, 'Edit').height, 40);
    });

    testWidgets('leaves a button alone when the group sets nothing', (WidgetTester tester) async {
      await pump(tester, NebaButtonGroup(children: three()));

      expect(rectOf(tester, 'Day').height, 32);
      expect(sheetOf(tester, 'Day').fill, tokens.roles(NebaColor.primary).fill);
      expect(sheetOf(tester, 'Day').plate, NebaPlate.solid);
    });

    testWidgets('falls back to NebaProvider after the group', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          Center(
            child: NebaProvider(
              defaults: const NebaDefaults(size: NebaSize.xl, variant: NebaVariant.outline),
              child: NebaButtonGroup(size: NebaSize.sm, children: three()),
            ),
          ),
        ),
      );

      expect(rectOf(tester, 'Day').height, 26);
      expect(sheetOf(tester, 'Day').plate, NebaPlate.glass);
      expect(rectOf(tester, 'Week').left, rectOf(tester, 'Day').right - 1);
    });

    testWidgets('reflects a changed group argument on a rebuild', (WidgetTester tester) async {
      await pump(tester, NebaButtonGroup(size: NebaSize.sm, children: three()));
      await pump(tester, NebaButtonGroup(size: NebaSize.lg, children: three()));

      expect(rectOf(tester, 'Day').height, 40);
    });
  });
}
