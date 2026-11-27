import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/glyphs.dart';

import '../../support/host.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget rating) {
    return tester.pumpWidget(host(Center(child: rating)));
  }

  /// How much of each star is filled, read off the cropping of its copy.
  List<double> fillsOf(WidgetTester tester) {
    return tester
        .widgetList<Align>(
          find.descendant(of: find.byType(NebaRating), matching: find.byType(Align)),
        )
        .where((Align align) => align.widthFactor != null)
        .map((Align align) => align.widthFactor!)
        .toList();
  }

  Offset starCenter(WidgetTester tester, int index) {
    return tester.getCenter(find.byType(NebaGlyph).at(index * 2));
  }

  testWidgets('fills as many stars as the score, a part of one for a fraction', (
    WidgetTester tester,
  ) async {
    await pump(tester, const NebaRating(value: 3.5, precision: 0.5));
    await tester.pumpAndSettle();

    expect(fillsOf(tester), <double>[1, 1, 1, 0.5, 0]);
  });

  testWidgets('chooses the score pressed, and clears it on a second press', (
    WidgetTester tester,
  ) async {
    final List<double> chosen = <double>[];

    await pump(tester, NebaRating(onValueChange: chosen.add));
    await tester.tapAt(starCenter(tester, 2));
    await tester.pump();
    await tester.tapAt(starCenter(tester, 2));
    await tester.pump();

    expect(chosen, <double>[3, 0]);
  });

  testWidgets('keeps a score when it is not clearable', (WidgetTester tester) async {
    final List<double> chosen = <double>[];

    await pump(tester, NebaRating(defaultValue: 3, clearable: false, onValueChange: chosen.add));
    await tester.tapAt(starCenter(tester, 2));

    expect(chosen, <double>[3]);
  });

  testWidgets('takes a half by the half of the star pressed', (WidgetTester tester) async {
    final List<double> chosen = <double>[];

    await pump(tester, NebaRating(precision: 0.5, onValueChange: chosen.add));
    final Rect star = tester.getRect(find.byType(NebaGlyph).at(2));
    await tester.tapAt(star.centerLeft + const Offset(2, 0));
    await tester.tapAt(star.centerRight - const Offset(2, 0));

    expect(chosen, <double>[1.5, 2]);
  });

  testWidgets('moves along on the arrow keys and wraps at the ends, as radios do', (
    WidgetTester tester,
  ) async {
    final FocusNode focus = FocusNode();
    addTearDown(focus.dispose);
    double score = 0;

    await pump(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => NebaRating(
          value: score,
          focusNode: focus,
          onValueChange: (double value) => setState(() => score = value),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(score, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(score, 2);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(score, 5);
  });

  testWidgets('shows the score the pointer would give before it is pressed', (
    WidgetTester tester,
  ) async {
    await pump(tester, const NebaRating(defaultValue: 1));
    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(starCenter(tester, 3));
    await tester.pumpAndSettle();

    expect(fillsOf(tester), <double>[1, 1, 1, 1, 0]);

    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(fillsOf(tester), <double>[1, 0, 0, 0, 0]);
  });

  testWidgets('does nothing while disabled, and draws in the disabled ink', (
    WidgetTester tester,
  ) async {
    final List<double> chosen = <double>[];

    await pump(tester, NebaRating(defaultValue: 2, disabled: true, onValueChange: chosen.add));
    await tester.tapAt(starCenter(tester, 4));
    expect(chosen, isEmpty);

    final NebaTokens tokens = NebaTheme.of(tester.element(find.byType(NebaRating)));
    expect(tester.widget<NebaGlyph>(find.byType(NebaGlyph).at(1)).color, tokens.disabledFg);
  });

  testWidgets('is a named set of radios, and a picture of its score when read-only', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pump(tester, const NebaRating(defaultValue: 2));
    expect(find.bySemanticsLabel('Rating'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('2 out of 5')),
      matchesSemantics(
        label: '2 out of 5',
        isInMutuallyExclusiveGroup: true,
        hasCheckedState: true,
        isChecked: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    // Every star is one named radio, with no second tap target of no name
    // under it.
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    await pump(tester, const NebaRating(value: 4.6, readOnly: true));
    expect(
      tester.getSemantics(find.byType(NebaRating)),
      matchesSemantics(isImage: true, label: '4.6 out of 5'),
    );

    semantics.dispose();
  });
}
