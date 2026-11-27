import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/animate.dart';

import '../../support/host.dart';

void main() {
  /// What the glyph is handed, read back from inside it.
  IconThemeData? seen;
  TextStyle? seenText;

  final Widget probe = Builder(
    builder: (BuildContext context) {
      seen = IconTheme.of(context);
      seenText = DefaultTextStyle.of(context).style;

      return const SizedBox.expand();
    },
  );

  Future<void> pump(WidgetTester tester, Widget icon) {
    return tester.pumpWidget(
      host(
        Center(
          child: DefaultTextStyle(
            style: const TextStyle(color: Color(0xFF123456)),
            child: icon,
          ),
        ),
      ),
    );
  }

  testWidgets('sits in a square on the icon ladder and hands the glyph its size', (
    WidgetTester tester,
  ) async {
    for (final NebaSize size in NebaSize.values) {
      await pump(tester, NebaIcon(icon: probe, size: size));
      final double side = NebaScale.iconSize[size]!;

      expect(tester.getSize(find.byType(NebaIcon)), Size.square(side));
      expect(seen!.size, side);
      expect(seenText!.fontSize, side);
    }
  });

  testWidgets('takes the colour of the text around it, or its family\'s accent', (
    WidgetTester tester,
  ) async {
    await pump(tester, NebaIcon(icon: probe));
    expect(seen!.color, const Color(0xFF123456));

    await pump(tester, NebaIcon(icon: probe, color: NebaColor.danger));
    final NebaTokens tokens = NebaTheme.of(tester.element(find.byType(NebaIcon)));
    expect(seen!.color, tokens.roles(NebaColor.danger).accent);
    expect(seenText!.color, tokens.roles(NebaColor.danger).accent);
  });

  testWidgets('is silent unless it has a label, and then an image by that name', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pump(tester, const NebaIcon(icon: Text('A')));
    expect(find.bySemanticsLabel('A'), findsNothing);

    await pump(tester, const NebaIcon(icon: Text('A'), semanticLabel: 'Fast'));
    expect(
      tester.getSemantics(find.byType(NebaIcon)),
      matchesSemantics(isImage: true, label: 'Fast'),
    );
    expect(find.bySemanticsLabel('A'), findsNothing);

    semantics.dispose();
  });

  testWidgets('arrives by its transition', (WidgetTester tester) async {
    await pump(tester, NebaIcon(icon: probe, transition: const NebaTransition.fade()));

    expect(
      find.descendant(of: find.byType(NebaIcon), matching: find.byType(NebaEntrance)),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
  });
}
