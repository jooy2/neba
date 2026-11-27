import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget statistic) {
    return tester.pumpWidget(host(Center(child: SizedBox(width: 400, child: statistic))));
  }

  NebaChip chipOf(WidgetTester tester) => tester.widget<NebaChip>(find.byType(NebaChip));

  group('figure', () {
    testWidgets('writes a number grouped, with its prefix and unit beside it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaStatistic(
          label: Text('Revenue'),
          value: 48210,
          prefix: Text(r'$'),
          unit: Text('/ month'),
        ),
      );

      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('48,210'), findsOneWidget);
      expect(find.text(r'$'), findsOneWidget);
      expect(find.text('/ month'), findsOneWidget);
    });

    testWidgets('writes a number by its format, and a string as it is', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaStatistic(value: 0.041, format: (num v) => '${(v * 100).toStringAsFixed(1)}%'),
      );
      expect(find.text('4.1%'), findsOneWidget);

      await pump(tester, const NebaStatistic(value: '99.98%', previousValue: 99));
      expect(find.text('99.98%'), findsOneWidget);
      expect(find.byType(NebaChip), findsNothing);
    });

    testWidgets('sets the figure on its step of the ladder', (WidgetTester tester) async {
      await pump(tester, const NebaStatistic(value: 7, size: NebaSize.lg));

      final RichText figure = tester.widget<RichText>(
        find.descendant(of: find.text('7'), matching: find.byType(RichText)).first,
      );
      expect(figure.text.style!.fontSize, NebaStatistic.valueText[NebaSize.lg]!.$1);
    });
  });

  group('change', () {
    testWidgets('writes the change as a percentage, green when it went the good way', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaStatistic(value: 3120, previousValue: 2740));

      expect(find.text('+13.9%'), findsOneWidget);
      expect(chipOf(tester).color, NebaColor.success);
    });

    testWidgets('turns red for an increase when lower is better', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaStatistic(
          value: 412,
          previousValue: 366,
          betterWhen: NebaStatisticBetterWhen.down,
        ),
      );

      expect(find.text('+12.6%'), findsOneWidget);
      expect(chipOf(tester).color, NebaColor.danger);
    });

    testWidgets('writes an amount, both, or nothing when asked', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaStatistic(
          value: 7,
          previousValue: 12,
          delta: NebaStatisticDelta.absolute,
          betterWhen: NebaStatisticBetterWhen.down,
        ),
      );
      expect(find.text('-5'), findsOneWidget);
      expect(chipOf(tester).color, NebaColor.success);

      await pump(
        tester,
        const NebaStatistic(value: 188, previousValue: 160, delta: NebaStatisticDelta.both),
      );
      expect(find.text('+17.5% · +28'), findsOneWidget);

      await pump(
        tester,
        const NebaStatistic(value: 188, previousValue: 160, delta: NebaStatisticDelta.none),
      );
      expect(find.byType(NebaChip), findsNothing);
    });

    testWidgets('is flat and secondary when nothing moved, by as much as it is written', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaStatistic(value: 1284, previousValue: 1284));
      expect(find.text('0%'), findsOneWidget);
      expect(chipOf(tester).color, NebaColor.secondary);

      expect(NebaStatistic.changeOf(value: 100.0001, previousValue: 100)!.direction, 0);
    });

    testWidgets('falls back to an amount from a previous value of zero', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaStatistic(value: 5, previousValue: 0));

      expect(find.text('+5'), findsOneWidget);
    });

    testWidgets('writes an absolute change in the figure\'s own format', (
      WidgetTester tester,
    ) async {
      expect(
        NebaStatistic.changeOf(
          value: 0.041,
          previousValue: 0.036,
          delta: NebaStatisticDelta.both,
          format: (num v) => '${(v * 100).toStringAsFixed(1)}%',
        )!.text,
        '+13.9% · +0.5%',
      );
    });
  });

  group('layout', () {
    testWidgets('lines its parts up by align', (WidgetTester tester) async {
      await pump(tester, const NebaStatistic(value: 7, align: NebaAlign.center));

      final Column column = tester.widget<Column>(
        find.descendant(of: find.byType(NebaStatistic), matching: find.byType(Column)).first,
      );
      expect(column.crossAxisAlignment, CrossAxisAlignment.center);
    });

    testWidgets('holds anything of the caller\'s own under the rest', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaStatistic(value: 188, child: SizedBox(key: Key('own'), height: 4)),
      );

      expect(find.byKey(const Key('own')), findsOneWidget);
      expect(
        tester.getTopLeft(find.byKey(const Key('own'))).dy,
        greaterThan(tester.getBottomLeft(find.text('188')).dy),
      );
    });
  });
}
