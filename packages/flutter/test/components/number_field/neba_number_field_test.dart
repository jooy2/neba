// NebaNumberField: the suite the React package runs on NumberField, asked the
// way Flutter asks it — the shell, the semantics, the steppers and what a key,
// a press, the wheel and typing do to the number — rather than the elements
// and classes it writes.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/notch.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget field, {NebaDefaults? defaults}) {
    final Widget placed = Center(child: field);

    return tester.pumpWidget(
      host(defaults == null ? placed : NebaProvider(defaults: defaults, child: placed)),
    );
  }

  String textOf(WidgetTester tester) {
    return tester.widget<EditableText>(find.byType(EditableText)).controller.text;
  }

  bool hasFocus(WidgetTester tester) {
    return tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus;
  }

  Future<void> focus(WidgetTester tester) async {
    tester.widget<EditableText>(find.byType(EditableText)).focusNode.requestFocus();
    await tester.pump();
    await tester.pump();
  }

  Future<void> unfocus(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.pump();
  }

  Finder stepper(List<NebaGlyphPart> glyph) {
    return find.byWidgetPredicate((Widget widget) {
      return widget is NebaGlyph && identical(widget.parts, glyph);
    });
  }

  Finder plus() => stepper(NebaGlyphs.plus);

  Finder minus() => stepper(NebaGlyphs.minus);

  SemanticsData dataOf(WidgetTester tester) {
    return tester.getSemantics(find.byType(NebaNumberField)).getSemanticsData();
  }

  Future<void> roll(WidgetTester tester, double dy) async {
    final TestPointer pointer = TestPointer(1, PointerDeviceKind.mouse);

    await tester.sendEventToBinding(pointer.hover(tester.getCenter(find.byType(EditableText))));
    await tester.sendEventToBinding(pointer.scroll(Offset(0, dy)));
    await tester.pump();
  }

  Future<void> press(
    WidgetTester tester,
    LogicalKeyboardKey key, {
    LogicalKeyboardKey? holding,
  }) async {
    if (holding != null) {
      await tester.sendKeyDownEvent(holding);
    }

    await tester.sendKeyEvent(key);

    if (holding != null) {
      await tester.sendKeyUpEvent(holding);
    }

    await tester.pump();
  }

  group('rendering', () {
    testWidgets('is one text field named by its label, which steps up and down', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaNumberField(label: Text('Seats'), defaultValue: 3));

      expect(
        tester.getSemantics(find.byType(NebaNumberField)),
        matchesSemantics(
          label: 'Seats',
          value: '3',
          increasedValue: '4',
          decreasedValue: '2',
          isTextField: true,
          isFocusable: true,
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: true,
          hasIncreaseAction: true,
          hasDecreaseAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('steps an empty field without a value to promise', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaNumberField(label: Text('Seats')));

      final SemanticsData data = dataOf(tester);
      expect(data.value, '');
      expect(data.increasedValue, '');
      expect(data.hasAction(SemanticsAction.increase), isTrue);
      semantics.dispose();
    });

    testWidgets('shows the number it starts with, written plainly', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(defaultValue: 3));
      expect(textOf(tester), '3');

      await pump(tester, const NebaNumberField(key: ValueKey<int>(1), defaultValue: 72.5));
      expect(textOf(tester), '72.5');

      await pump(tester, const NebaNumberField(key: ValueKey<int>(2), defaultValue: 1 / 3));
      expect(textOf(tester), '0.333');
    });

    testWidgets('draws both steppers by default, at the end', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(label: Text('Seats')));

      expect(plus(), findsOneWidget);
      expect(minus(), findsOneWidget);
      final Rect field = tester.getRect(find.byType(EditableText));
      expect(tester.getRect(minus()).left, greaterThan(field.right));
      expect(tester.getRect(plus()).left, greaterThan(tester.getRect(minus()).right));
    });

    testWidgets('puts split steppers on either side of a centred number', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaNumberField(steppers: NebaNumberFieldSteppers.split, defaultValue: 2),
      );

      final Rect field = tester.getRect(find.byType(EditableText));
      expect(tester.getRect(minus()).right, lessThan(field.left));
      expect(tester.getRect(plus()).left, greaterThan(field.right));
      expect(tester.widget<EditableText>(find.byType(EditableText)).textAlign, TextAlign.center);
    });

    testWidgets('drops the steppers when asked', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(steppers: NebaNumberFieldSteppers.none));

      expect(plus(), findsNothing);
      expect(minus(), findsNothing);
    });

    testWidgets('keeps the steppers out of what a screen reader hears', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaNumberField(label: Text('Seats'), defaultValue: 3));

      expect(find.semantics.byFlag(SemanticsFlag.isButton), findsNothing);
      semantics.dispose();
    });

    testWidgets('reads the description and the error after its name', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaNumberField(
          label: Text('Seats'),
          description: Text('Up to twelve.'),
          error: Text('At least one seat.'),
        ),
      );

      expect(find.text('Up to twelve.'), findsOneWidget);
      expect(dataOf(tester).hint, 'Up to twelve.\nAt least one seat.');
      semantics.dispose();
    });

    testWidgets('reflects a changed label on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(label: Text('Before')));
      await pump(tester, const NebaNumberField(label: Text('After')));

      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    });

    testWidgets('never applies a transform', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(defaultValue: 3));
      await tester.tap(plus());
      await tester.pump();

      expect(
        find.descendant(of: find.byType(NebaNumberField), matching: find.byType(Transform)),
        findsNothing,
      );
    });
  });

  group('the steppers', () {
    testWidgets('step up and report a number', (WidgetTester tester) async {
      final List<double?> changes = <double?>[];
      final List<double?> commits = <double?>[];

      await pump(
        tester,
        NebaNumberField(defaultValue: 3, onValueChange: changes.add, onValueCommitted: commits.add),
      );
      await tester.tap(plus());
      await tester.pump();

      expect(changes, <double?>[4]);
      expect(commits, <double?>[4]);
      expect(textOf(tester), '4');
    });

    testWidgets('step down', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(defaultValue: 3));
      await tester.tap(minus());
      await tester.pump();

      expect(textOf(tester), '2');
    });

    testWidgets('step by the step they were given', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(defaultValue: 10, step: 5));
      await tester.tap(plus());
      await tester.pump();

      expect(textOf(tester), '15');
    });

    testWidgets('step an empty field to zero, held to the range', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(min: 1));
      await tester.tap(plus());
      await tester.pump();

      expect(textOf(tester), '1');
    });

    testWidgets('go grey and still at the end of the range they step towards', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<double?> changes = <double?>[];

      await pump(
        tester,
        NebaNumberField(
          label: const Text('Seats'),
          defaultValue: 1,
          min: 1,
          max: 2,
          onValueChange: changes.add,
        ),
      );
      await tester.pumpAndSettle();

      expect(IconTheme.of(tester.element(minus())).color, tokens.disabledFg);
      expect(IconTheme.of(tester.element(plus())).color, tokens.mutedFg);
      await tester.tap(minus());
      await tester.pump();
      expect(changes, isEmpty);
      expect(dataOf(tester).hasAction(SemanticsAction.decrease), isFalse);
      expect(dataOf(tester).hasAction(SemanticsAction.increase), isTrue);
      semantics.dispose();
    });

    testWidgets('repeat while held, after a pause, and commit on the release', (
      WidgetTester tester,
    ) async {
      final List<double?> commits = <double?>[];

      await pump(tester, NebaNumberField(defaultValue: 0, onValueCommitted: commits.add));

      final TestGesture gesture = await tester.startGesture(tester.getCenter(plus()));
      await tester.pump();
      expect(textOf(tester), '1');

      await tester.pump(const Duration(milliseconds: 399));
      expect(textOf(tester), '1');

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 60));
      expect(textOf(tester), '2');

      await tester.pump(const Duration(milliseconds: 120));
      expect(textOf(tester), '4');
      expect(commits, isEmpty);

      await gesture.up();
      await tester.pump(const Duration(milliseconds: 200));
      expect(textOf(tester), '4');
      expect(commits, <double?>[4]);
    });

    testWidgets('stop when the pointer leaves them while held', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(defaultValue: 0));

      final TestGesture gesture = await tester.startGesture(tester.getCenter(plus()));
      await tester.pump();
      await gesture.moveBy(const Offset(0, 60));
      await tester.pump(const Duration(seconds: 1));
      expect(textOf(tester), '1');

      await gesture.up();
    });

    testWidgets('stop at the end of the range while held', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(defaultValue: 0, max: 3));

      final TestGesture gesture = await tester.startGesture(tester.getCenter(plus()));
      await tester.pump(const Duration(seconds: 2));
      await gesture.up();
      await tester.pump();

      expect(textOf(tester), '3');
    });

    testWidgets('take what was typed before they step', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(defaultValue: 3));
      await tester.enterText(find.byType(EditableText), '10');
      await tester.tap(plus());
      await tester.pump();

      expect(textOf(tester), '11');
    });

    testWidgets('put the caret in the field when a mouse presses them', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaNumberField(defaultValue: 3));

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(plus()),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pump();

      expect(hasFocus(tester), isTrue);
    });

    testWidgets('leave the focus alone when a finger presses them', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(defaultValue: 3));
      await tester.tap(plus());
      await tester.pump();

      expect(hasFocus(tester), isFalse);
      expect(textOf(tester), '4');
    });
  });

  group('the keyboard', () {
    testWidgets('steps by step, largeStep with Shift and smallStep with Alt', (
      WidgetTester tester,
    ) async {
      final List<double?> commits = <double?>[];

      await pump(tester, NebaNumberField(defaultValue: 3, onValueCommitted: commits.add));
      await focus(tester);

      await press(tester, LogicalKeyboardKey.arrowUp);
      expect(textOf(tester), '4');

      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(textOf(tester), '3');

      await press(tester, LogicalKeyboardKey.arrowUp, holding: LogicalKeyboardKey.shiftLeft);
      expect(textOf(tester), '13');

      await press(tester, LogicalKeyboardKey.arrowDown, holding: LogicalKeyboardKey.altLeft);
      expect(textOf(tester), '12.9');
      expect(commits, <double?>[4, 3, 13, 12.9]);
    });

    testWidgets('cleans the noise a decimal step leaves', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(defaultValue: 0.2, step: 0.1));
      await focus(tester);
      await press(tester, LogicalKeyboardKey.arrowUp);

      expect(textOf(tester), '0.3');
    });

    testWidgets('goes to min and max on Home and End, when there are any', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaNumberField(defaultValue: 5, min: 1, max: 9));
      await focus(tester);

      await press(tester, LogicalKeyboardKey.home);
      expect(textOf(tester), '1');

      await press(tester, LogicalKeyboardKey.end);
      expect(textOf(tester), '9');

      await pump(tester, const NebaNumberField(key: ValueKey<int>(1), defaultValue: 5));
      await focus(tester);
      await press(tester, LogicalKeyboardKey.home);
      expect(textOf(tester), '5');
    });

    testWidgets('holds the value to the range', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(defaultValue: 4, max: 5));
      await focus(tester);
      await press(tester, LogicalKeyboardKey.arrowUp);
      await press(tester, LogicalKeyboardKey.arrowUp);

      expect(textOf(tester), '5');
    });

    testWidgets('lands on multiples of the step when it snaps', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(defaultValue: 3.7, snapOnStep: true));
      await focus(tester);
      await press(tester, LogicalKeyboardKey.arrowUp);
      expect(textOf(tester), '4');

      await press(tester, LogicalKeyboardKey.arrowDown);
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(textOf(tester), '2');
    });

    testWidgets('steps from what was typed', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(defaultValue: 3));
      await tester.enterText(find.byType(EditableText), '20');
      await press(tester, LogicalKeyboardKey.arrowUp);

      expect(textOf(tester), '21');
    });

    testWidgets('takes no step while read-only', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(defaultValue: 3, readOnly: true));
      await focus(tester);
      await press(tester, LogicalKeyboardKey.arrowUp);

      expect(textOf(tester), '3');
    });
  });

  group('typing', () {
    testWidgets('reports the number as it parses', (WidgetTester tester) async {
      final List<double?> changes = <double?>[];

      await pump(tester, NebaNumberField(onValueChange: changes.add));
      await tester.enterText(find.byType(EditableText), '42');

      expect(changes.last, 42);
    });

    testWidgets('keeps out characters no number is written with', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField());
      await tester.enterText(find.byType(EditableText), '4');
      await tester.enterText(find.byType(EditableText), '4a');

      expect(textOf(tester), '4');
    });

    testWidgets('takes a minus only where the range goes below zero', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(min: 0));
      await tester.enterText(find.byType(EditableText), '-3');
      expect(textOf(tester), '');

      await pump(tester, const NebaNumberField(key: ValueKey<int>(1)));
      await tester.enterText(find.byType(EditableText), '-3');
      expect(textOf(tester), '-3');
    });

    testWidgets('holds what was typed to the range, and writes it out on blur', (
      WidgetTester tester,
    ) async {
      final List<double?> changes = <double?>[];
      final List<double?> commits = <double?>[];

      await pump(
        tester,
        NebaNumberField(max: 20, onValueChange: changes.add, onValueCommitted: commits.add),
      );
      await tester.enterText(find.byType(EditableText), '50');
      expect(changes.last, 20);
      expect(textOf(tester), '50');

      await unfocus(tester);
      expect(textOf(tester), '20');
      expect(commits, <double?>[20]);
    });

    testWidgets('clears the value when the text is emptied', (WidgetTester tester) async {
      final List<double?> commits = <double?>[];

      await pump(tester, NebaNumberField(defaultValue: 3, onValueCommitted: commits.add));
      await tester.enterText(find.byType(EditableText), '');
      await unfocus(tester);

      expect(commits, <double?>[null]);
    });

    testWidgets('takes nothing while disabled', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaNumberField(label: Text('Seats'), defaultValue: 3, disabled: true),
      );
      await tester.tap(find.byType(EditableText), warnIfMissed: false);
      await tester.tap(plus(), warnIfMissed: false);
      await tester.pump();

      expect(hasFocus(tester), isFalse);
      expect(textOf(tester), '3');
      expect(
        tester.getSemantics(find.byType(NebaNumberField)),
        matchesSemantics(
          label: 'Seats',
          value: '3',
          isTextField: true,
          isFocusable: true,
          hasEnabledState: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('takes the steppers away while read-only', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(defaultValue: 3, readOnly: true));

      expect(plus(), findsNothing);
      expect(tester.widget<EditableText>(find.byType(EditableText)).readOnly, isTrue);
    });
  });

  group('value', () {
    testWidgets('shows a controlled value, and the next one it is given', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaNumberField(value: 2, onValueChange: (double? value) {}));
      expect(textOf(tester), '2');

      await pump(tester, NebaNumberField(value: 9, onValueChange: (double? value) {}));
      expect(textOf(tester), '9');
    });

    testWidgets('stays where the caller put it when the caller keeps it', (
      WidgetTester tester,
    ) async {
      final List<double?> changes = <double?>[];

      await pump(tester, NebaNumberField(value: 2, onValueChange: changes.add));
      await tester.tap(plus());
      await tester.pump();

      expect(changes, <double?>[3]);
      expect(textOf(tester), '2');
    });

    testWidgets('is cleared when a controlled value turns null', (WidgetTester tester) async {
      await pump(tester, NebaNumberField(value: 2, onValueChange: (double? value) {}));
      await pump(tester, NebaNumberField(onValueChange: (double? value) {}));

      expect(textOf(tester), '');
    });
  });

  group('the wheel', () {
    testWidgets('steps the value while the field holds the focus', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(defaultValue: 3));
      await focus(tester);

      await roll(tester, -20);
      expect(textOf(tester), '4');

      await roll(tester, 20);
      expect(textOf(tester), '3');
    });

    testWidgets('leaves the value alone while the field does not hold the focus', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaNumberField(defaultValue: 3));
      await roll(tester, -20);

      expect(textOf(tester), '3');
    });

    testWidgets('can be turned off', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(defaultValue: 3, wheel: false));
      await focus(tester);
      await roll(tester, -20);

      expect(textOf(tester), '3');
    });

    testWidgets('takes the wheel from a scroll view the field is in', (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        host(
          ListView(
            controller: controller,
            children: <Widget>[
              const NebaNumberField(defaultValue: 3),
              const SizedBox(height: 2000),
            ],
          ),
        ),
      );
      await focus(tester);
      await roll(tester, 40);

      expect(textOf(tester), '2');
      expect(controller.offset, 0);
    });
  });

  group('format', () {
    String dollars(double value) {
      final String whole = value.round().toString();
      final String grouped = whole.replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (Match match) => ',',
      );

      return '\$$grouped';
    }

    testWidgets('writes the value and still reports the number', (WidgetTester tester) async {
      final List<double?> changes = <double?>[];

      await pump(
        tester,
        NebaNumberField(defaultValue: 1240, format: dollars, onValueChange: changes.add),
      );
      expect(textOf(tester), r'$1,240');

      await tester.tap(plus());
      await tester.pump();
      expect(changes, <double?>[1241]);
      expect(textOf(tester), r'$1,241');
    });

    testWidgets('reads typed text back through parse', (WidgetTester tester) async {
      final List<double?> changes = <double?>[];

      await pump(
        tester,
        NebaNumberField(
          defaultValue: 0.075,
          format: (double value) => '${(value * 100).toStringAsFixed(1)}%',
          parse: (String text) {
            final double? number = double.tryParse(text.replaceAll('%', ''));

            return number == null ? null : number / 100;
          },
          onValueChange: changes.add,
        ),
      );
      expect(textOf(tester), '7.5%');

      await tester.enterText(find.byType(EditableText), '8%');
      expect(changes.last, 0.08);

      await unfocus(tester);
      expect(textOf(tester), '8.0%');
    });
  });

  group('the shell', () {
    testWidgets("is a text field's, as tall as a button of its size", (WidgetTester tester) async {
      for (final NebaSize size in NebaSize.values) {
        await pump(tester, NebaNumberField(size: size, density: NebaDensity.compact));

        expect(tester.getSize(find.byType(NebaSheet)).height, NebaScale.controlHeight[size]);
      }
    });

    testWidgets('gives up its padding on the side a stepper sits on', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField());
      NebaFieldShell shell() => tester.widget<NebaFieldShell>(find.byType(NebaFieldShell));

      expect(shell().paddingStart, NebaScale.paddingX[NebaDensity.standard]![NebaSize.md]);
      expect(shell().paddingEnd, 4);

      await pump(tester, const NebaNumberField(steppers: NebaNumberFieldSteppers.split));
      expect(shell().paddingStart, 4);
      expect(shell().paddingEnd, 4);

      await pump(tester, const NebaNumberField(steppers: NebaNumberFieldSteppers.none));
      expect(shell().paddingEnd, NebaScale.paddingX[NebaDensity.standard]![NebaSize.md]);
    });

    testWidgets('is a text field wide with its steppers beside it', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(steppers: NebaNumberFieldSteppers.none));
      final double bare = tester.getSize(find.byType(NebaSheet)).width;

      expect(bare, nebaFieldWidth(NebaSize.md, NebaDensity.standard));

      await pump(tester, const NebaNumberField());
      expect(tester.getSize(find.byType(NebaSheet)).width, greaterThan(bare));
    });

    testWidgets('stretches to the width it is given when full width', (WidgetTester tester) async {
      await pump(tester, const SizedBox(width: 500, child: NebaNumberField(fullWidth: true)));

      expect(tester.getSize(find.byType(NebaSheet)).width, 500);
    });

    testWidgets('keeps its sheet undyed and colours its edge', (WidgetTester tester) async {
      await pump(tester, const NebaNumberField(color: NebaColor.info));

      final NebaSheet sheet = tester.widget<NebaSheet>(find.byType(NebaSheet));
      expect(sheet.fill, tokens.panel);
      expect(sheet.edge, tokens.roles(NebaColor.info).line);
    });

    testWidgets('turns its family over to danger when there is an error', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaNumberField(color: NebaColor.success, error: Text('At least one seat.')),
      );

      expect(
        tester.widget<NebaFieldShell>(find.byType(NebaFieldShell)).roles,
        tokens.roles(NebaColor.danger),
      );
    });

    testWidgets('takes its size, variant and density from the provider', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaNumberField(),
        defaults: const NebaDefaults(
          size: NebaSize.lg,
          variant: NebaVariant.solid,
          density: NebaDensity.compact,
        ),
      );

      final NebaFieldShell shell = tester.widget<NebaFieldShell>(find.byType(NebaFieldShell));
      expect(shell.size, NebaSize.lg);
      expect(shell.variant, NebaVariant.solid);
      expect(shell.density, NebaDensity.compact);
    });
  });

  group('the screen reader', () {
    testWidgets('increases and decreases as the steppers do', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<double?> commits = <double?>[];

      await pump(
        tester,
        NebaNumberField(label: const Text('Seats'), defaultValue: 3, onValueCommitted: commits.add),
      );

      tester.semantics.increase(find.semantics.byLabel('Seats'));
      await tester.pump();
      expect(textOf(tester), '4');

      tester.semantics.decrease(find.semantics.byLabel('Seats'));
      tester.semantics.decrease(find.semantics.byLabel('Seats'));
      await tester.pump();
      expect(textOf(tester), '2');
      expect(commits, <double?>[4, 3, 2]);
      semantics.dispose();
    });
  });

  group('shortcuts', () {
    testWidgets('runs the entry whose combination was pressed', (WidgetTester tester) async {
      int sent = 0;

      await pump(
        tester,
        NebaNumberField(
          defaultValue: 3,
          shortcuts: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.enter): () => sent += 1,
          },
        ),
      );
      await focus(tester);
      await press(tester, LogicalKeyboardKey.enter);

      expect(sent, 1);
    });

    testWidgets('runs a binding on a stepping key and still steps', (WidgetTester tester) async {
      int up = 0;

      await pump(
        tester,
        NebaNumberField(
          defaultValue: 3,
          shortcuts: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.arrowUp): () => up += 1,
          },
        ),
      );
      await focus(tester);
      await press(tester, LogicalKeyboardKey.arrowUp);

      expect(up, 1);
      expect(textOf(tester), '4');
    });
  });

  group('label placement', () {
    testWidgets('puts a notched label on the edge, still naming the field', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaNumberField(labelPlacement: NebaLabelPlacement.notch, label: Text('Seats')),
      );

      expect(find.byType(NebaNotch), findsOneWidget);
      expect(dataOf(tester).label, 'Seats');
      semantics.dispose();
    });

    testWidgets('rests a floating label in the field while it is empty and idle', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaNumberField(labelPlacement: NebaLabelPlacement.float, label: Text('Seats')),
      );
      bool resting() => tester.widget<NebaNotch>(find.byType(NebaNotch)).resting;

      expect(resting(), isTrue);

      await focus(tester);
      await tester.pumpAndSettle();
      expect(resting(), isFalse);
    });

    testWidgets('keeps a floating label in the notch beside split steppers', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaNumberField(
          labelPlacement: NebaLabelPlacement.float,
          label: Text('Seats'),
          steppers: NebaNumberFieldSteppers.split,
        ),
      );

      expect(tester.widget<NebaNotch>(find.byType(NebaNotch)).resting, isFalse);
    });
  });
}
