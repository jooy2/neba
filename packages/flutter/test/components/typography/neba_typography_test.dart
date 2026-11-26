// NebaTypography: the suite the React package runs on Typography, asked the
// way Flutter asks it — the style the text is drawn in and the semantics it
// carries, rather than the element and the classes.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget text) {
    return tester.pumpWidget(host(Align(alignment: Alignment.topLeft, child: text)));
  }

  Text textOf(WidgetTester tester) => tester.widget<Text>(find.byType(Text));

  TextStyle styleOf(WidgetTester tester) => textOf(tester).style!;

  group('rendering', () {
    testWidgets('draws its text, as body by default', (WidgetTester tester) async {
      await pump(tester, const NebaTypography('Copy'));

      expect(find.text('Copy'), findsOneWidget);
      expect(styleOf(tester).fontSize, 13);
      expect(styleOf(tester).fontWeight, FontWeight.w400);
    });

    testWidgets('gives each level its own size, leading, tracking and weight', (
      WidgetTester tester,
    ) async {
      const Map<NebaTypographyLevel, (double, double, double, FontWeight)> expected =
          <NebaTypographyLevel, (double, double, double, FontWeight)>{
            NebaTypographyLevel.h1: (30, 1.2, -0.6, FontWeight.w600),
            NebaTypographyLevel.h2: (24, 1.25, -0.36, FontWeight.w600),
            NebaTypographyLevel.h3: (20, 1.3, -0.2, FontWeight.w600),
            NebaTypographyLevel.h4: (17, 1.41176, 0, FontWeight.w600),
            NebaTypographyLevel.h5: (15, 1.46667, 0, FontWeight.w600),
            NebaTypographyLevel.h6: (13, 1.53846, 0, FontWeight.w600),
            NebaTypographyLevel.lead: (17, 1.64706, 0, FontWeight.w400),
            NebaTypographyLevel.body: (13, 1.69231, 0, FontWeight.w400),
            NebaTypographyLevel.caption: (12, 1.5, 0, FontWeight.w400),
            NebaTypographyLevel.overline: (11, 1.45455, 0.88, FontWeight.w500),
          };

      for (final MapEntry<NebaTypographyLevel, (double, double, double, FontWeight)> entry
          in expected.entries) {
        await pump(tester, NebaTypography('Copy', level: entry.key));

        final TextStyle style = styleOf(tester);
        final (double size, double leading, double tracking, FontWeight weight) = entry.value;

        expect(style.fontSize, size, reason: entry.key.name);
        expect(style.height, leading, reason: entry.key.name);
        expect(style.letterSpacing, closeTo(tracking, 1e-9), reason: entry.key.name);
        expect(style.fontWeight, weight, reason: entry.key.name);
        expect(style.leadingDistribution, TextLeadingDistribution.even, reason: entry.key.name);
      }
    });

    testWidgets('draws an overline in capitals', (WidgetTester tester) async {
      await pump(tester, const NebaTypography('Changelog', level: NebaTypographyLevel.overline));

      expect(find.text('CHANGELOG'), findsOneWidget);
    });

    testWidgets('draws a rich span as given, on the level', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTypography.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(text: 'Plain and '),
              TextSpan(
                text: 'bold',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          level: NebaTypographyLevel.lead,
        ),
      );

      expect(find.text('Plain and bold', findRichText: true), findsOneWidget);
      expect(styleOf(tester).fontSize, 17);
    });
  });

  group('headings', () {
    testWidgets('makes h1 to h6 headings at their level, and nothing else one', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      for (final (NebaTypographyLevel level, int heading) in <(NebaTypographyLevel, int)>[
        (NebaTypographyLevel.h1, 1),
        (NebaTypographyLevel.h4, 4),
        (NebaTypographyLevel.h6, 6),
      ]) {
        await pump(tester, NebaTypography('Title', level: level));

        expect(
          tester.getSemantics(find.text('Title')),
          matchesSemantics(label: 'Title', isHeader: true),
          reason: level.name,
        );
        expect(
          tester.getSemantics(find.text('Title')).getSemanticsData().headingLevel,
          heading,
          reason: level.name,
        );
      }

      await pump(tester, const NebaTypography('Copy', level: NebaTypographyLevel.lead));
      expect(tester.getSemantics(find.text('Copy')), matchesSemantics(label: 'Copy'));
      semantics.dispose();
    });

    testWidgets('keeps the scale while headingLevel changes what is heard', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaTypography('Looks like one', level: NebaTypographyLevel.h3, headingLevel: 0),
      );
      expect(styleOf(tester).fontSize, 20);
      expect(
        tester.getSemantics(find.text('Looks like one')),
        matchesSemantics(label: 'Looks like one'),
      );

      await pump(tester, const NebaTypography('Is one', headingLevel: 2));
      expect(styleOf(tester).fontSize, 13);
      expect(
        tester.getSemantics(find.text('Is one')),
        matchesSemantics(label: 'Is one', isHeader: true),
      );
      expect(tester.getSemantics(find.text('Is one')).getSemanticsData().headingLevel, 2);
      semantics.dispose();
    });
  });

  group('colour', () {
    testWidgets('states no colour when no role is asked for, so it inherits', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTypography('Copy', level: NebaTypographyLevel.h2));

      expect(styleOf(tester).color, isNull);
    });

    testWidgets('takes the role\'s accent', (WidgetTester tester) async {
      for (final NebaColor color in NebaColor.values) {
        await pump(tester, NebaTypography('Copy', color: color));

        expect(styleOf(tester).color, tokens.roles(color).accent, reason: color.name);
      }
    });

    testWidgets('mutes the two quiet levels, unless a role is asked for', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTypography('Copy', level: NebaTypographyLevel.caption));
      expect(styleOf(tester).color, tokens.mutedFg);

      await pump(tester, const NebaTypography('Copy', level: NebaTypographyLevel.overline));
      expect(styleOf(tester).color, tokens.mutedFg);

      await pump(
        tester,
        const NebaTypography('Copy', level: NebaTypographyLevel.caption, color: NebaColor.danger),
      );
      expect(styleOf(tester).color, tokens.roles(NebaColor.danger).accent);
    });

    testWidgets('inherits the colour around it', (WidgetTester tester) async {
      const Color around = Color(0xFF123456);

      await pump(
        tester,
        const DefaultTextStyle(
          style: TextStyle(color: around),
          child: NebaTypography('Copy'),
        ),
      );

      final RichText drawn = tester.widget<RichText>(find.byType(RichText));
      expect(drawn.text.style!.color, around);
    });
  });

  group('weight, align, lines and gutter', () {
    testWidgets('takes the weight it is given over the level\'s', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTypography('Title', level: NebaTypographyLevel.h2, weight: FontWeight.w400),
      );

      expect(styleOf(tester).fontWeight, FontWeight.w400);
    });

    testWidgets('aligns its lines', (WidgetTester tester) async {
      await pump(tester, const NebaTypography('Copy', align: TextAlign.center));

      expect(textOf(tester).textAlign, TextAlign.center);
    });

    testWidgets('truncates to one line and clamps to more, with an ellipsis', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTypography('Copy'));
      expect(textOf(tester).maxLines, isNull);

      await pump(tester, const NebaTypography('Copy', lines: 1));
      expect(textOf(tester).maxLines, 1);
      expect(textOf(tester).overflow, TextOverflow.ellipsis);

      await pump(tester, const NebaTypography('Copy', lines: 7));
      expect(textOf(tester).maxLines, 7);
    });

    testWidgets('adds no space below unless asked, and the level\'s when it is', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTypography('Copy'));
      expect(find.byType(Padding), findsNothing);

      await pump(tester, const NebaTypography('Copy', gutter: true));
      expect(
        tester.widget<Padding>(find.byType(Padding)).padding,
        const EdgeInsets.only(bottom: 12),
      );

      await pump(tester, const NebaTypography('Copy', level: NebaTypographyLevel.h1, gutter: true));
      expect(
        tester.widget<Padding>(find.byType(Padding)).padding,
        const EdgeInsets.only(bottom: 16),
      );
    });
  });

  group('style', () {
    testWidgets('lays a style over the level, with the tracking in proportion', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTypography(
          '42',
          level: NebaTypographyLevel.h1,
          style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900),
        ),
      );

      expect(styleOf(tester).fontSize, 44);
      expect(styleOf(tester).fontWeight, FontWeight.w900);
      expect(styleOf(tester).height, 1.2);
      expect(styleOf(tester).letterSpacing, closeTo(-0.88, 1e-9));
    });

    testWidgets('takes an entrance', (WidgetTester tester) async {
      await pump(tester, const NebaTypography('Copy', transition: NebaTransition.fade()));

      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0);
      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
    });
  });
}
