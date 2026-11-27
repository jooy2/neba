// NebaIconButton: the suite the React package runs on IconButton, asked the
// way Flutter asks it — the footprint and the corners it draws, the name a
// screen reader hears, and what it keeps of the button it is.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  void noop() {}

  final Widget plus = NebaGlyph(NebaGlyphs.plus);

  Future<void> pump(WidgetTester tester, Widget button) {
    return tester.pumpWidget(host(Center(child: button)));
  }

  NebaSheet sheetOf(WidgetTester tester, [Finder? within]) {
    return tester.widget<NebaSheet>(
      within == null
          ? find.byType(NebaSheet)
          : find.descendant(of: within, matching: find.byType(NebaSheet)),
    );
  }

  testWidgets('is a disc as tall and as wide as a button of its size', (WidgetTester tester) async {
    const Map<NebaSize, double> heights = <NebaSize, double>{
      NebaSize.xs: 22,
      NebaSize.sm: 26,
      NebaSize.md: 32,
      NebaSize.lg: 40,
      NebaSize.xl: 48,
    };

    for (final MapEntry<NebaSize, double> entry in heights.entries) {
      await pump(
        tester,
        NebaIconButton(onPressed: noop, icon: plus, label: 'Add', size: entry.key),
      );

      expect(tester.getSize(find.byType(NebaSheet)), Size.square(entry.value));
      expect(sheetOf(tester).borderRadius, BorderRadius.circular(9999));
    }
  });

  testWidgets('is named by its label and can be pressed from a screen reader', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pump(tester, NebaIconButton(onPressed: noop, icon: plus, label: 'Add item'));

    expect(
      tester.getSemantics(find.byType(NebaIconButton)),
      matchesSemantics(
        label: 'Add item',
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

  testWidgets('calls onPressed on a tap', (WidgetTester tester) async {
    int pressed = 0;

    await pump(tester, NebaIconButton(onPressed: () => pressed += 1, icon: plus, label: 'Add'));
    await tester.tap(find.byType(NebaIconButton));

    expect(pressed, 1);
  });

  testWidgets('draws its glyph at 1.2 times the label size', (WidgetTester tester) async {
    await pump(tester, NebaIconButton(onPressed: noop, icon: plus, label: 'Add'));

    expect(tester.getSize(find.byType(NebaGlyph)), const Size.square(13 * 1.2));
  });

  testWidgets('puts the turning ring in the glyph\'s place while loading', (
    WidgetTester tester,
  ) async {
    await pump(tester, NebaIconButton(onPressed: noop, icon: plus, label: 'Add', loading: true));

    expect(find.byType(NebaSpinner), findsOneWidget);
    expect(
      find.byWidgetPredicate((Widget w) => w is NebaGlyph && identical(w.parts, NebaGlyphs.plus)),
      findsNothing,
    );
  });

  testWidgets('takes the button\'s variants, colours and disabled state', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      NebaIconButton(
        onPressed: noop,
        icon: plus,
        label: 'Delete',
        variant: NebaVariant.outline,
        color: NebaColor.danger,
      ),
    );
    expect(sheetOf(tester).edge, tokens.roles(NebaColor.danger).line);

    await pump(tester, NebaIconButton(onPressed: noop, icon: plus, label: 'Add', disabled: true));
    expect(sheetOf(tester).fill, tokens.disabledBg);
  });

  testWidgets('keeps the NebaProvider defaults around it', (WidgetTester tester) async {
    await tester.pumpWidget(
      host(
        Center(
          child: NebaProvider(
            defaults: const NebaDefaults(size: NebaSize.lg),
            child: NebaIconButton(onPressed: noop, icon: plus, label: 'Add'),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(NebaSheet)), const Size.square(40));
  });

  testWidgets('squares the corners that face a neighbour in a group', (WidgetTester tester) async {
    await pump(
      tester,
      NebaButtonGroup(
        size: NebaSize.sm,
        children: <Widget>[
          NebaButton(onPressed: noop, child: const Text('Deploy')),
          NebaIconButton(onPressed: noop, icon: plus, label: 'More'),
        ],
      ),
    );

    final NebaSheet disc = sheetOf(tester, find.byType(NebaIconButton));
    expect(
      disc.borderRadius,
      const BorderRadius.only(topRight: Radius.circular(9999), bottomRight: Radius.circular(9999)),
    );
    expect(
      tester.getSize(
        find.descendant(of: find.byType(NebaIconButton), matching: find.byType(NebaSheet)),
      ),
      const Size.square(26),
    );
  });
}
