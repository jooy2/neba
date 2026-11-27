// NebaSlider: the suite the React package runs on Slider, asked the way
// Flutter asks it — the thumbs' semantics, where a press, a drag and a key
// take the value, the groove and the marks as laid out — rather than the
// inputs, attributes and classes it writes.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/progress.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  /// [slider] 400 pixels wide, or at its own size when [free].
  Future<void> pump(
    WidgetTester tester,
    Widget slider, {
    TextDirection textDirection = TextDirection.ltr,
    bool free = false,
  }) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topCenter,
          child: free ? Column(children: <Widget>[slider]) : SizedBox(width: 400, child: slider),
        ),
        textDirection: textDirection,
      ),
    );
  }

  Finder thumbs() {
    return find.descendant(of: find.byType(NebaSlider), matching: find.byType(NebaSheet));
  }

  Finder thumb(int index) => thumbs().at(index);

  Rect grooveOf(WidgetTester tester) => tester.getRect(find.byType(NebaGroove));

  NebaGroove groove(WidgetTester tester) => tester.widget<NebaGroove>(find.byType(NebaGroove));

  /// The point [share] of the way along the groove of a horizontal slider.
  Offset along(WidgetTester tester, double share) {
    final Rect rect = grooveOf(tester);

    return Offset(rect.left + rect.width * share, rect.center.dy);
  }

  SemanticsData dataOf(WidgetTester tester, int index) {
    return tester.getSemantics(thumb(index)).getSemanticsData();
  }

  Future<void> press(WidgetTester tester, LogicalKeyboardKey key, {bool shift = false}) async {
    if (shift) {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    }

    await tester.sendKeyEvent(key);

    if (shift) {
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    }

    await tester.pump();
  }

  Iterable<Rect> ticks(WidgetTester tester) {
    return find
        .descendant(of: find.byType(NebaSlider), matching: find.byType(ColoredBox))
        .evaluate()
        .where((Element element) => (element.widget as ColoredBox).color == tokens.border)
        .map((Element element) {
          final RenderBox box = element.renderObject! as RenderBox;

          return box.localToGlobal(Offset.zero) & box.size;
        });
  }

  /// A slider that follows its own value, as a caller holding it would.
  Widget held(double initial, {ValueChanged<double>? onCommitted, FocusNode? focusNode}) {
    double value = initial;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return NebaSlider(
          semanticLabel: 'Volume',
          value: value,
          focusNode: focusNode,
          onValueChange: (double next) => setState(() => value = next),
          onValueCommitted: onCommitted,
        );
      },
    );
  }

  group('rendering', () {
    testWidgets('is heard as a slider named by its label, with its value and its steps', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaSlider(
          label: Text('Volume'),
          description: Text('Applies to alerts too.'),
          defaultValue: 40,
        ),
      );

      expect(
        tester.getSemantics(thumb(0)),
        matchesSemantics(
          label: 'Volume',
          hint: 'Applies to alerts too.',
          value: '40',
          increasedValue: '41',
          decreasedValue: '39',
          textDirection: TextDirection.ltr,
          isSlider: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasFocusAction: true,
          hasIncreaseAction: true,
          hasDecreaseAction: true,
        ),
      );
      // The label and the description are said by the thumb, once.
      expect(find.bySemanticsLabel('Volume'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('is named by a semantic label when it has no label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaSlider(semanticLabel: 'Volume', defaultValue: 40));

      expect(dataOf(tester, 0).label, 'Volume');
      semantics.dispose();
    });

    testWidgets('steps on a screen reader’s increase and decrease, and stops at the ends', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<double> commits = <double>[];

      await pump(tester, held(99, onCommitted: commits.add));

      tester.semantics.increase(find.semantics.byLabel('Volume'));
      await tester.pump();
      expect(dataOf(tester, 0).value, '100');
      expect(commits, <double>[100]);
      expect(dataOf(tester, 0).hasAction(SemanticsAction.increase), isFalse);

      tester.semantics.decrease(find.semantics.byLabel('Volume'));
      await tester.pump();
      expect(dataOf(tester, 0).value, '99');
      semantics.dispose();
    });

    testWidgets('shows the value only when asked, written by format', (WidgetTester tester) async {
      await pump(tester, const NebaSlider(label: Text('Volume'), defaultValue: 40));
      expect(find.text('40'), findsNothing);

      await pump(
        tester,
        const NebaSlider(label: Text('Volume'), defaultValue: 40, showValue: true),
      );
      expect(find.text('40'), findsOneWidget);

      await pump(
        tester,
        NebaSlider(
          label: const Text('Volume'),
          defaultValue: 40,
          showValue: true,
          format: (double value) => '${value.round()} per cent',
        ),
      );
      expect(find.text('40 per cent'), findsOneWidget);
    });

    testWidgets('groups a long value by threes and is heard as it is written', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaSlider(semanticLabel: 'Seats', max: 5000, defaultValue: 1200, showValue: true),
      );

      expect(find.text('1,200'), findsOneWidget);
      expect(dataOf(tester, 0).value, '1,200');
      semantics.dispose();
    });

    testWidgets('fills the groove up to the value in the colour family', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSlider(defaultValue: 40, color: NebaColor.danger));
      await tester.pumpAndSettle();

      expect(groove(tester).fraction, closeTo(0.4, 1e-9));
      expect(groove(tester).start, 0);
      expect(groove(tester).fill, tokens.roles(NebaColor.danger).fill);
      expect(groove(tester).track, tokens.roles(NebaColor.danger).soft);
    });

    testWidgets('centres the thumb on the value, half of it past either end of the groove', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSlider());
      expect(tester.getCenter(thumb(0)).dx, grooveOf(tester).left);

      // A new slider, since an uncontrolled one keeps its own value.
      await pump(tester, NebaSlider(key: UniqueKey(), defaultValue: 100));
      expect(tester.getCenter(thumb(0)).dx, grooveOf(tester).right);
      expect(tester.getCenter(thumb(0)).dy, grooveOf(tester).center.dy);
    });

    testWidgets('grows the thumb, the groove and the strip with size', (WidgetTester tester) async {
      await pump(tester, const NebaSlider(size: NebaSize.xl));

      expect(tester.getSize(thumb(0)), const Size(24, 24));
      expect(grooveOf(tester).height, 10);

      await pump(tester, const NebaSlider(size: NebaSize.xs));

      expect(tester.getSize(thumb(0)), const Size(12, 12));
      expect(grooveOf(tester).height, 4);
      expect(tester.getSize(find.byType(NebaSlider)).height, 16);
    });

    testWidgets('takes its size from the provider', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(size: NebaSize.lg),
          child: NebaSlider(),
        ),
      );

      expect(tester.getSize(thumb(0)), const Size(20, 20));
    });

    testWidgets('takes 160 pixels where it is given no width', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[NebaSlider()]),
          ),
        ),
      );

      expect(grooveOf(tester).width, 160);
    });
  });

  group('pointer', () {
    testWidgets('moves the thumb to a press on the strip and commits once, on the release', (
      WidgetTester tester,
    ) async {
      final List<double> changes = <double>[];
      final List<double> commits = <double>[];

      await pump(
        tester,
        NebaSlider(
          defaultValue: 40,
          step: 5,
          onValueChange: changes.add,
          onValueCommitted: commits.add,
        ),
      );

      final TestGesture gesture = await tester.startGesture(along(tester, 0.72));
      await tester.pump();
      expect(changes, <double>[70]);
      expect(tester.getCenter(thumb(0)).dx, along(tester, 0.7).dx);

      await gesture.moveBy(Offset(grooveOf(tester).width * 0.1, 0));
      await tester.pump();
      expect(changes.last, 80);
      expect(commits, isEmpty);

      await gesture.up();
      await tester.pump();
      expect(commits, <double>[80]);
    });

    testWidgets('picks a thumb up where it was pressed, without a jump', (
      WidgetTester tester,
    ) async {
      final List<double> changes = <double>[];
      final List<double> commits = <double>[];

      await pump(
        tester,
        NebaSlider(defaultValue: 50, onValueChange: changes.add, onValueCommitted: commits.add),
      );

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(thumb(0)) + const Offset(5, 0),
      );
      await tester.pump();
      expect(changes, isEmpty);

      await gesture.moveBy(const Offset(40, 0));
      await tester.pump();
      expect(changes.last, 60);

      await gesture.up();
      expect(commits, <double>[60]);
    });

    testWidgets('commits nothing for a press that moved nothing', (WidgetTester tester) async {
      final List<double> commits = <double>[];

      await pump(tester, NebaSlider(defaultValue: 50, onValueCommitted: commits.add));
      await tester.tapAt(tester.getCenter(thumb(0)));

      expect(commits, isEmpty);
    });

    testWidgets('leaves the focus where it was', (WidgetTester tester) async {
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);

      await pump(tester, NebaSlider(focusNode: focus));
      await tester.tapAt(along(tester, 0.5));
      await tester.pump();

      expect(focus.hasFocus, isFalse);
    });

    testWidgets('lands a press on the step it is nearest, counted from min', (
      WidgetTester tester,
    ) async {
      final List<double> changes = <double>[];

      await pump(tester, NebaSlider(min: 1, max: 11, step: 2, onValueChange: changes.add));
      await tester.tapAt(along(tester, 0.48));

      expect(changes, <double>[5]);
    });

    testWidgets('runs from the right under a right-to-left direction', (WidgetTester tester) async {
      final List<double> changes = <double>[];

      await pump(tester, NebaSlider(onValueChange: changes.add), textDirection: TextDirection.rtl);

      expect(tester.getCenter(thumb(0)).dx, grooveOf(tester).right);

      await tester.tapAt(along(tester, 0.25));
      expect(changes, <double>[75]);
    });

    testWidgets('follows the caller’s value and stays put when it is not taken', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaSlider(value: 20, onValueChange: (double value) {}));
      expect(tester.getCenter(thumb(0)).dx, along(tester, 0.2).dx);

      await tester.tapAt(along(tester, 0.6));
      await tester.pump();
      expect(tester.getCenter(thumb(0)).dx, along(tester, 0.2).dx);

      await pump(tester, NebaSlider(value: 70, onValueChange: (double value) {}));
      expect(tester.getCenter(thumb(0)).dx, along(tester, 0.7).dx);
    });

    testWidgets('holds a value past either end to the range', (WidgetTester tester) async {
      await pump(tester, NebaSlider(value: 140, onValueChange: (double value) {}));

      expect(tester.getCenter(thumb(0)).dx, grooveOf(tester).right);
      expect(groove(tester).fraction, 1);
    });
  });

  group('keyboard', () {
    testWidgets('steps on the arrows, a large step with Shift and Page Up or Down', (
      WidgetTester tester,
    ) async {
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);
      final List<double> commits = <double>[];

      await pump(tester, held(40, focusNode: focus, onCommitted: commits.add));
      focus.requestFocus();
      await tester.pump();

      await press(tester, LogicalKeyboardKey.arrowRight);
      expect(commits.last, 41);

      await press(tester, LogicalKeyboardKey.arrowUp, shift: true);
      expect(commits.last, 51);

      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(commits.last, 50);

      await press(tester, LogicalKeyboardKey.pageDown);
      expect(commits.last, 40);

      await press(tester, LogicalKeyboardKey.pageUp);
      expect(commits.last, 50);

      await press(tester, LogicalKeyboardKey.arrowLeft, shift: true);
      expect(commits.last, 40);
    });

    testWidgets('goes to the ends on Home and End, and no further', (WidgetTester tester) async {
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);
      final List<double> commits = <double>[];

      await pump(tester, held(40, focusNode: focus, onCommitted: commits.add));
      focus.requestFocus();
      await tester.pump();

      await press(tester, LogicalKeyboardKey.home);
      expect(commits.last, 0);

      await press(tester, LogicalKeyboardKey.end);
      expect(commits.last, 100);

      await press(tester, LogicalKeyboardKey.arrowRight);
      expect(commits, <double>[0, 100]);
      expect(focus.hasFocus, isTrue);
    });

    testWidgets('steps from the step the value is nearest, with no decimal noise', (
      WidgetTester tester,
    ) async {
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);
      final List<double> changes = <double>[];

      await pump(
        tester,
        NebaSlider(
          focusNode: focus,
          min: 0,
          max: 1,
          step: 0.1,
          defaultValue: 0.23,
          onValueChange: changes.add,
        ),
      );
      focus.requestFocus();
      await tester.pump();

      await press(tester, LogicalKeyboardKey.arrowRight);
      await press(tester, LogicalKeyboardKey.arrowRight);

      expect(changes, <double>[0.3, 0.4]);
    });

    testWidgets('turns the arrows along the line round under a right-to-left direction', (
      WidgetTester tester,
    ) async {
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);
      final List<double> changes = <double>[];

      await pump(
        tester,
        NebaSlider(focusNode: focus, defaultValue: 50, onValueChange: changes.add),
        textDirection: TextDirection.rtl,
      );
      focus.requestFocus();
      await tester.pump();

      await press(tester, LogicalKeyboardKey.arrowRight);
      await press(tester, LogicalKeyboardKey.arrowUp);

      expect(changes, <double>[49, 50]);
    });

    testWidgets('rings the thumb on keyboard focus', (WidgetTester tester) async {
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);

      await pump(tester, NebaSlider(focusNode: focus));
      expect(tester.widget<NebaFocusRing>(find.byType(NebaFocusRing)).visible, isFalse);

      focus.requestFocus();
      await tester.pump();
      await tester.pump();

      expect(tester.widget<NebaFocusRing>(find.byType(NebaFocusRing)).visible, isTrue);
    });

    testWidgets('puts the focus on the thumb from a press on the label', (
      WidgetTester tester,
    ) async {
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);

      await pump(tester, NebaSlider(label: const Text('Volume'), focusNode: focus));
      await tester.tap(find.text('Volume'));
      await tester.pump();

      expect(focus.hasFocus, isTrue);
    });
  });

  group('range', () {
    testWidgets('draws a thumb per value and fills the groove between them', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSlider.range(defaultValues: <double>[80, 20]));

      expect(thumbs(), findsNWidgets(2));
      expect(tester.getCenter(thumb(0)).dx, along(tester, 0.2).dx);
      expect(tester.getCenter(thumb(1)).dx, along(tester, 0.8).dx);
      expect(groove(tester).start, closeTo(0.2, 1e-9));
      expect(groove(tester).fraction, closeTo(0.8, 1e-9));
    });

    testWidgets('runs from min to max when it is given no values', (WidgetTester tester) async {
      await pump(tester, const NebaSlider.range(showValue: true));

      expect(find.text('0 – 100'), findsOneWidget);
    });

    testWidgets('says which end of the range each thumb is, unless told otherwise', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaSlider.range(label: Text('Price'), defaultValues: <double>[20, 80]),
      );

      expect(dataOf(tester, 0).label, 'Price');
      expect(dataOf(tester, 0).value, '20 start range');
      expect(dataOf(tester, 1).value, '80 end range');

      await pump(
        tester,
        NebaSlider.range(
          label: const Text('Price'),
          defaultValues: const <double>[20, 80],
          thumbSemanticLabel: (int index) => index == 0 ? 'Minimum price' : 'Maximum price',
          thumbSemanticValue: (String formatted, double value, int index) => '$formatted dollars',
        ),
      );

      expect(dataOf(tester, 0).label, 'Minimum price');
      expect(dataOf(tester, 0).value, '20 dollars');
      expect(dataOf(tester, 1).label, 'Maximum price');
      expect(dataOf(tester, 1).value, '80 dollars');
      // Named per thumb, the label is read as text of its own.
      expect(find.bySemanticsLabel('Price'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('moves the thumb nearest a press on the strip', (WidgetTester tester) async {
      final List<List<double>> changes = <List<double>>[];

      await pump(
        tester,
        NebaSlider.range(defaultValues: const <double>[20, 80], onValuesChange: changes.add),
      );

      await tester.tapAt(along(tester, 0.6));
      await tester.tapAt(along(tester, 0.3));

      expect(changes, <List<double>>[
        <double>[20, 60],
        <double>[30, 60],
      ]);
    });

    testWidgets('pushes the other thumb along when one is dragged past it', (
      WidgetTester tester,
    ) async {
      final List<List<double>> commits = <List<double>>[];

      await pump(
        tester,
        NebaSlider.range(
          defaultValues: const <double>[20, 80],
          showValue: true,
          onValuesCommitted: commits.add,
        ),
      );

      final TestGesture gesture = await tester.startGesture(tester.getCenter(thumb(0)));
      await gesture.moveTo(along(tester, 0.9));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(commits, <List<double>>[
        <double>[90, 90],
      ]);
      expect(find.text('90 – 90'), findsOneWidget);
    });

    testWidgets('keeps a key from taking a thumb past its neighbour', (WidgetTester tester) async {
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);
      final List<List<double>> changes = <List<double>>[];

      await pump(
        tester,
        NebaSlider.range(
          focusNode: focus,
          defaultValues: const <double>[20, 80],
          onValuesChange: changes.add,
        ),
      );
      focus.requestFocus();
      await tester.pump();

      await press(tester, LogicalKeyboardKey.end);
      await press(tester, LogicalKeyboardKey.arrowRight);

      expect(changes, <List<double>>[
        <double>[80, 80],
      ]);
    });

    testWidgets('is a stop in the focus order per thumb, lowest first even upright', (
      WidgetTester tester,
    ) async {
      final FocusNode first = FocusNode();
      final FocusNode after = FocusNode();
      addTearDown(first.dispose);
      addTearDown(after.dispose);

      await tester.pumpWidget(
        host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              NebaSlider.range(
                focusNode: first,
                orientation: NebaOrientation.vertical,
                defaultValues: const <double>[20, 80],
              ),
              Focus(focusNode: after, child: const SizedBox.square(dimension: 10)),
            ],
          ),
        ),
      );
      first.requestFocus();
      await tester.pump();

      // Reading order would go from the low thumb at the bottom straight out
      // of the slider; the thumbs keep their own order instead.
      first.nextFocus();
      await tester.pump();
      expect(FocusManager.instance.primaryFocus, isNot(after));
      expect(FocusManager.instance.primaryFocus, isNot(first));

      FocusManager.instance.primaryFocus!.nextFocus();
      await tester.pump();
      expect(after.hasFocus, isTrue);
    });
  });

  group('disabled', () {
    testWidgets('takes no press, no key and no focus', (WidgetTester tester) async {
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);
      final List<double> changes = <double>[];

      await pump(
        tester,
        NebaSlider(focusNode: focus, defaultValue: 40, disabled: true, onValueChange: changes.add),
      );
      await tester.tapAt(along(tester, 0.8));
      focus.requestFocus();
      await tester.pump();
      await press(tester, LogicalKeyboardKey.arrowRight);

      expect(changes, isEmpty);
      expect(focus.hasFocus, isFalse);
    });

    testWidgets('shows it in the disabled tokens rather than by fading', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSlider(label: Text('Volume'), defaultValue: 40, disabled: true));
      await tester.pumpAndSettle();

      expect(groove(tester).track, tokens.disabledBg);
      expect(groove(tester).fill, tokens.disabledFg);
      expect(tester.widget<NebaSheet>(thumb(0)).edge, tokens.disabledBorder);
      expect(tester.widget<NebaSheet>(thumb(0)).elevation, 0);
      expect(find.byType(Opacity), findsNothing);
      expect(
        DefaultTextStyle.of(tester.element(find.text('Volume'))).style.color,
        tokens.disabledFg,
      );
    });
  });

  group('marks', () {
    const List<NebaSliderMark> levels = <NebaSliderMark>[
      NebaSliderMark(value: 1, label: Text('One')),
      NebaSliderMark(value: 250, label: Text('Some')),
      NebaSliderMark(value: 500, label: Text('Every')),
    ];

    testWidgets('draws none unless asked', (WidgetTester tester) async {
      await pump(tester, const NebaSlider(min: 1, max: 500));

      expect(ticks(tester), isEmpty);
    });

    testWidgets('sets each mark at its share of the range, the ends lined up inward', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSlider(min: 1, max: 500, marks: NebaSliderMarks(levels)));

      final Rect line = grooveOf(tester);
      final List<Rect> drawn = ticks(tester).toList();

      expect(drawn, hasLength(3));
      expect(drawn[0].left, line.left);
      expect(drawn[1].center.dx, closeTo(line.left + line.width * 249 / 499, 1e-6));
      expect(drawn[2].right, line.right);
      expect(tester.getRect(find.text('One')).left, line.left);
      expect(tester.getCenter(find.text('Some')).dx, closeTo(drawn[1].center.dx, 1e-6));
      expect(tester.getRect(find.text('Every')).right, line.right);
      // Under the strip, the tick first and the label under it.
      expect(drawn[1].top, greaterThan(line.bottom));
      expect(tester.getRect(find.text('Some')).top, drawn[1].bottom);
    });

    testWidgets('mirrors the marks under a right-to-left direction', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaSlider(min: 1, max: 500, marks: NebaSliderMarks(levels)),
        textDirection: TextDirection.rtl,
      );

      final Rect line = grooveOf(tester);

      expect(tester.getRect(find.text('One')).right, line.right);
      expect(tester.getRect(find.text('Every')).left, line.left);
    });

    testWidgets('measures a vertical slider’s marks from the bottom', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaSlider(
          orientation: NebaOrientation.vertical,
          min: 1,
          max: 500,
          marks: NebaSliderMarks(levels),
        ),
        free: true,
      );

      final Rect line = grooveOf(tester);
      final List<Rect> drawn = ticks(tester).toList();

      expect(drawn[0].bottom, line.bottom);
      expect(drawn[2].top, line.top);
      expect(tester.getRect(find.text('One')).bottom, line.bottom);
      expect(tester.getRect(find.text('Every')).top, line.top);
      expect(tester.getRect(find.text('Some')).left, drawn[1].right + 6);
    });

    testWidgets('takes a tick at every step when told to', (WidgetTester tester) async {
      await pump(tester, const NebaSlider(step: 25, marks: NebaSliderMarks.steps));

      expect(ticks(tester), hasLength(5));
    });

    testWidgets('keeps the tick at the top of a range stepped in tenths', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSlider(max: 0.6, step: 0.1, marks: NebaSliderMarks.steps));

      final List<Rect> drawn = ticks(tester).toList();

      expect(drawn, hasLength(7));
      expect(drawn.last.right, closeTo(grooveOf(tester).right, 1e-6));
    });

    testWidgets('draws none at all rather than a thousand of them', (WidgetTester tester) async {
      await pump(tester, const NebaSlider(step: 0.01, marks: NebaSliderMarks.steps));

      expect(ticks(tester), isEmpty);
    });

    testWidgets('keeps the marks from a screen reader', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaSlider(min: 1, max: 500, marks: NebaSliderMarks(levels)));

      expect(find.text('Some'), findsOneWidget);
      expect(find.bySemanticsLabel('Some'), findsNothing);
      semantics.dispose();
    });
  });

  group('vertical', () {
    testWidgets('runs up from the bottom, 160 pixels long where it is given no height', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaSlider(orientation: NebaOrientation.vertical, defaultValue: 25),
        free: true,
      );

      final Rect line = grooveOf(tester);

      expect(line.height, 160);
      expect(line.width, 6);
      expect(tester.getCenter(thumb(0)).dy, line.bottom - 40);
      expect(tester.getSize(find.byType(NebaSlider)).width, 20);
    });

    testWidgets('takes the height it is given', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const Center(
            child: SizedBox(
              height: 300,
              child: NebaSlider(
                orientation: NebaOrientation.vertical,
                label: Text('Low'),
                defaultValue: 50,
              ),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(NebaSlider)).height, 300);
      expect(grooveOf(tester).bottom, tester.getRect(find.byType(NebaSlider)).bottom);
    });

    testWidgets('moves on a press from the bottom, and up is more', (WidgetTester tester) async {
      final List<double> changes = <double>[];

      await pump(
        tester,
        NebaSlider(orientation: NebaOrientation.vertical, onValueChange: changes.add),
        free: true,
      );

      final Rect line = grooveOf(tester);
      await tester.tapAt(Offset(line.center.dx, line.bottom - line.height * 0.3));

      expect(changes, <double>[30]);
    });
  });

  group('look', () {
    testWidgets('wears a halo under the pointer and a wider one while dragged', (
      WidgetTester tester,
    ) async {
      final NebaColorRoles roles = tokens.roles(NebaColor.primary);

      BoxShadow halo() {
        final AnimatedContainer box = tester.widget<AnimatedContainer>(
          find.ancestor(of: thumb(0), matching: find.byType(AnimatedContainer)).first,
        );

        return (box.decoration! as BoxDecoration).boxShadow!.single;
      }

      await pump(tester, const NebaSlider(defaultValue: 50));
      expect(halo().color.a, 0);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(thumb(0)));
      await tester.pumpAndSettle();

      expect(halo().color, roles.soft);
      expect(halo().spreadRadius, 4);
      expect(tester.widget<NebaSheet>(thumb(0)).elevation, 2);

      await mouse.down(tester.getCenter(thumb(0)));
      await tester.pump();

      expect(halo().color, roles.softHover);
      expect(halo().spreadRadius, 6);

      await mouse.up();
      await tester.pumpAndSettle();
      expect(halo().spreadRadius, 4);
    });

    testWidgets('never changes the size of the thumb', (WidgetTester tester) async {
      await pump(tester, const NebaSlider(defaultValue: 50));

      final TestGesture gesture = await tester.startGesture(tester.getCenter(thumb(0)));
      await tester.pump();

      expect(tester.getSize(thumb(0)), const Size(16, 16));
      expect(find.byType(Transform), findsNothing);

      await gesture.up();
    });
  });
}
