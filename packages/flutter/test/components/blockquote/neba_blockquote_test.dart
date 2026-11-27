// NebaBlockquote: the suite the React package runs on Blockquote, asked the
// way Flutter asks it — the rule and the sheet it draws, the type, the mark,
// and the attribution a screen reader reads.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  Future<void> pump(WidgetTester tester, Widget quote) {
    return tester.pumpWidget(host(Center(child: SizedBox(width: 400, child: quote))));
  }

  TextStyle styleOf(WidgetTester tester, String text) {
    return tester
        .widget<RichText>(find.descendant(of: find.text(text), matching: find.byType(RichText)))
        .text
        .style!;
  }

  testWidgets('is a rule in the accent and no sheet by default', (WidgetTester tester) async {
    await pump(tester, const NebaBlockquote(child: Text('Less, but better.')));

    final BoxDecoration decoration =
        tester.widget<Container>(find.byType(Container)).decoration! as BoxDecoration;
    final BorderDirectional border = decoration.border! as BorderDirectional;

    expect(border.start, BorderSide(color: primary.accent, width: 2));
    expect(find.byType(NebaSheet), findsNothing);
  });

  testWidgets('lays an outline sheet behind the rule, square at its start', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      const NebaBlockquote(variant: NebaVariant.outline, child: Text('Less, but better.')),
    );

    final NebaSheet sheet = tester.widget<NebaSheet>(find.byType(NebaSheet));
    expect(sheet.edge, primary.line);
    expect(sheet.plate, NebaPlate.glass);
    expect(sheet.borderRadius.topLeft, Radius.zero);
    expect(sheet.borderRadius.topRight, const Radius.circular(14));
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, primary.accent);
  });

  testWidgets('sets the quote on its own scale', (WidgetTester tester) async {
    await pump(tester, const NebaBlockquote(size: NebaSize.lg, child: Text('Less, but better.')));

    expect(styleOf(tester, 'Less, but better.').fontSize, 17);
    expect(styleOf(tester, 'Less, but better.').height, 30 / 17);
  });

  testWidgets('opens with a mark twice the text size, or with none', (WidgetTester tester) async {
    await pump(tester, const NebaBlockquote(child: Text('Less, but better.')));
    expect(
      find.descendant(of: find.byType(NebaBlockquote), matching: find.byType(CustomPaint)),
      findsWidgets,
    );
    expect(
      tester.getSize(
        find.descendant(of: find.byType(ExcludeSemantics), matching: find.byType(SizedBox)).first,
      ),
      const Size.square(30),
    );

    await pump(tester, const NebaBlockquote(icon: null, child: Text('Less, but better.')));
    expect(
      find.descendant(of: find.byType(NebaBlockquote), matching: find.byType(CustomPaint)),
      findsNothing,
    );
  });

  testWidgets('attributes the quote after a dash a screen reader skips', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pump(
      tester,
      const NebaBlockquote(
        author: Text('Dieter Rams'),
        source: Text('Ten principles'),
        child: Text('Less, but better.'),
      ),
    );

    expect(find.text('— '), findsOneWidget);
    expect(find.bySemanticsLabel('Dieter Rams'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('—')), findsNothing);
    expect(styleOf(tester, 'Ten principles').color, tokens.mutedFg);
    expect(styleOf(tester, 'Dieter Rams').fontWeight, FontWeight.w500);
    semantics.dispose();
  });

  testWidgets('arrives by its transition', (WidgetTester tester) async {
    await pump(
      tester,
      const NebaBlockquote(transition: NebaTransition.fade(), child: Text('Less, but better.')),
    );

    expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, 0);
    await tester.pumpAndSettle();
    expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, 1);
  });
}
