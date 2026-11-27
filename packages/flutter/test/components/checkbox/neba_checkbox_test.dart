// NebaCheckbox: the suite the React package runs on Checkbox, asked the way
// Flutter asks it — the checkbox a screen reader hears, the state it keeps or
// is handed, the sheet it draws in each state, the mark drawn along its length,
// and where the square sits against the label beside it.

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/choice.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  Future<void> pump(WidgetTester tester, Widget checkbox, {bool disableAnimations = false}) {
    return tester.pumpWidget(host(Center(child: checkbox), disableAnimations: disableAnimations));
  }

  Finder sheet() => find.descendant(of: find.byType(NebaTick), matching: find.byType(NebaSheet));

  NebaSheet sheetOf(WidgetTester tester) => tester.widget<NebaSheet>(sheet());

  FocusNode nodeOf(WidgetTester tester) => Focus.of(tester.element(sheet()));

  NebaTickMarkPainter markOf(WidgetTester tester) {
    final CustomPaint paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(NebaTickMark),
        matching: find.byWidgetPredicate(
          (Widget widget) => widget is CustomPaint && widget.painter is NebaTickMarkPainter,
        ),
      ),
    );

    return paint.painter! as NebaTickMarkPainter;
  }

  SemanticsData dataOf(WidgetTester tester) {
    return tester.getSemantics(find.byType(NebaCheckbox)).getSemanticsData();
  }

  /// A checkbox as a screen reader hears it.
  Matcher heard(String label, {bool checked = false, bool readOnly = false, bool enabled = true}) {
    return matchesSemantics(
      label: label,
      hasCheckedState: true,
      isChecked: checked,
      isReadOnly: readOnly,
      hasEnabledState: true,
      isEnabled: enabled,
      isFocusable: enabled,
      hasTapAction: enabled && !readOnly,
      hasFocusAction: enabled,
    );
  }

  Matcher checkedAs(String label, {required bool checked}) => heard(label, checked: checked);

  TextStyle styleOf(WidgetTester tester, String text) {
    return DefaultTextStyle.of(tester.element(find.text(text))).style;
  }

  group('rendering', () {
    testWidgets('is a checkbox named by its label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCheckbox(label: Text('Remember me')));

      expect(
        tester.getSemantics(find.byType(NebaCheckbox)),
        matchesSemantics(
          label: 'Remember me',
          hasCheckedState: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('takes its name from semanticLabel without a label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCheckbox(semanticLabel: 'Select row', defaultChecked: true));

      expect(
        tester.getSemantics(find.byType(NebaCheckbox)),
        matchesSemantics(
          label: 'Select row',
          hasCheckedState: true,
          isChecked: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      // The square alone on its line, with no gap for a label that is not
      // there.
      expect(
        tester.getSize(find.byType(NebaCheckbox)),
        Size(18, NebaScale.controlText[NebaSize.md]! * 1.4),
      );
      semantics.dispose();
    });

    testWidgets('shows the description under the label and reads it after the name', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaCheckbox(label: Text('Emails'), description: Text('About once a week.')),
      );

      expect(find.text('About once a week.'), findsOneWidget);
      expect(dataOf(tester).hint, 'About once a week.');
      expect(
        tester.getTopLeft(find.text('About once a week.')).dy,
        greaterThan(tester.getBottomLeft(find.text('Emails')).dy),
      );
      expect(styleOf(tester, 'About once a week.').color, tokens.mutedFg);
      expect(styleOf(tester, 'About once a week.').fontSize, NebaScale.metaText[NebaSize.md]);
      semantics.dispose();
    });

    testWidgets('reflects a changed label on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaCheckbox(label: Text('Before')));
      await pump(tester, const NebaCheckbox(label: Text('After')));

      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    });
  });

  group('behaviour', () {
    testWidgets('ticks when its label is pressed, and when its square is', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaCheckbox(label: const Text('Remember me'), onCheckedChange: changes.add),
      );
      await tester.tap(find.text('Remember me'));
      await tester.pump();
      await tester.tap(sheet());
      await tester.pump();

      expect(changes, <bool>[true, false]);
    });

    testWidgets('ticks on Space and Enter', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaCheckbox(label: const Text('Remember me'), onCheckedChange: changes.add),
      );
      nodeOf(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(changes, <bool>[true, false]);
    });

    testWidgets('takes a press on the gap beside the square, and none on the description', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaCheckbox(
          label: const Text('Emails'),
          description: const Text('About once a week.'),
          onCheckedChange: changes.add,
        ),
      );

      final Rect square = tester.getRect(sheet());
      await tester.tapAt(square.centerRight + const Offset(4, 0));
      await tester.pump();
      expect(changes, <bool>[true]);

      await tester.tap(find.text('About once a week.'));
      await tester.pump();
      expect(changes, <bool>[true]);
    });

    testWidgets('keeps its own state from defaultChecked', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCheckbox(label: Text('Remember me'), defaultChecked: true));
      expect(
        tester.getSemantics(find.byType(NebaCheckbox)),
        checkedAs('Remember me', checked: true),
      );

      await tester.tap(find.text('Remember me'));
      await tester.pump();
      expect(
        tester.getSemantics(find.byType(NebaCheckbox)),
        checkedAs('Remember me', checked: false),
      );
      semantics.dispose();
    });

    testWidgets('follows a controlled checked and reports the opposite', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaCheckbox(label: const Text('Remember me'), checked: true, onCheckedChange: changes.add),
      );
      await tester.tap(find.text('Remember me'));
      await tester.pump();

      // Still ticked: the caller has not passed the new state back.
      expect(changes, <bool>[false]);
      expect(
        tester.getSemantics(find.byType(NebaCheckbox)),
        checkedAs('Remember me', checked: true),
      );

      await pump(tester, const NebaCheckbox(label: Text('Remember me'), checked: false));
      expect(
        tester.getSemantics(find.byType(NebaCheckbox)),
        checkedAs('Remember me', checked: false),
      );
      semantics.dispose();
    });

    testWidgets('is out of reach and grey when disabled', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaCheckbox(
          label: const Text('Remember me'),
          disabled: true,
          defaultChecked: true,
          onCheckedChange: changes.add,
        ),
      );
      await tester.tap(find.text('Remember me'));
      await tester.tap(sheet());
      await tester.pump();

      expect(changes, isEmpty);
      expect(nodeOf(tester).canRequestFocus, isFalse);
      expect(
        tester.getSemantics(find.byType(NebaCheckbox)),
        heard('Remember me', checked: true, enabled: false),
      );
      expect(sheetOf(tester).fill, tokens.disabledBg);
      expect(sheetOf(tester).edge, tokens.disabledBorder);
      expect(sheetOf(tester).blur, isFalse);
      expect(styleOf(tester, 'Remember me').color, tokens.disabledFg);
      await tester.pump(NebaScale.duration);
      expect(markOf(tester).color, tokens.disabledFg);
      semantics.dispose();
    });

    testWidgets('does not tick when read-only, and keeps its place in the focus order', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaCheckbox(
          label: const Text('Remember me'),
          readOnly: true,
          onCheckedChange: changes.add,
        ),
      );
      await tester.tap(find.text('Remember me'));
      await tester.tap(sheet());
      await tester.pump();
      nodeOf(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(changes, isEmpty);
      expect(nodeOf(tester).hasFocus, isTrue);
      nodeOf(tester).unfocus();
      await tester.pump();
      expect(tester.getSemantics(find.byType(NebaCheckbox)), heard('Remember me', readOnly: true));
      expect(find.ancestor(of: sheet(), matching: find.byType(ColorFiltered)), findsOneWidget);
      semantics.dispose();
    });

    // A read-only tick is the same tick, desaturated: a read-only mix is a
    // filled box with a dash on it, not a dash on an empty box.
    testWidgets('fills a read-only mixed state the way it fills an editable one', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCheckbox(label: Text('All'), indeterminate: true));
      final Color editable = sheetOf(tester).fill;

      await pump(
        tester,
        const NebaCheckbox(label: Text('All'), indeterminate: true, readOnly: true),
      );

      expect(editable, primary.fill);
      expect(sheetOf(tester).fill, editable);
    });

    testWidgets('reports a mixed state and draws a dash', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCheckbox(label: Text('All'), indeterminate: true));

      expect(
        tester.getSemantics(find.byType(NebaCheckbox)),
        matchesSemantics(
          label: 'All',
          hasCheckedState: true,
          isCheckStateMixed: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(markOf(tester).shape, NebaTickMarkShape.dash);
      expect(markOf(tester).drawn, 1);
      semantics.dispose();
    });

    testWidgets('reports ticked from a mixed box that is pressed', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaCheckbox(label: const Text('All'), indeterminate: true, onCheckedChange: changes.add),
      );
      await tester.tap(find.text('All'));

      expect(changes, <bool>[true]);
    });
  });

  group('validation', () {
    testWidgets('shows the error under the row and reads it after the name', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final NebaColorRoles danger = tokens.roles(NebaColor.danger);

      await pump(
        tester,
        const NebaCheckbox(label: Text('Terms'), error: Text('You have to agree.')),
      );

      expect(dataOf(tester).hint, 'You have to agree.');
      expect(dataOf(tester).validationResult, SemanticsValidationResult.invalid);
      expect(styleOf(tester, 'You have to agree.').color, danger.accent);
      // Under the whole row, from the square's edge.
      expect(tester.getTopLeft(find.text('You have to agree.')).dx, tester.getTopLeft(sheet()).dx);
      expect(
        tester.getTopLeft(find.text('You have to agree.')).dy,
        moreOrLessEquals(tester.getBottomLeft(find.text('Terms')).dy + 4, epsilon: 0.5),
      );
      semantics.dispose();
    });

    testWidgets('turns the colour family over to danger when invalid', (WidgetTester tester) async {
      final NebaColorRoles danger = tokens.roles(NebaColor.danger);

      await pump(
        tester,
        const NebaCheckbox(
          label: Text('Terms'),
          color: NebaColor.success,
          defaultChecked: true,
          error: Text('Required'),
        ),
      );

      expect(sheetOf(tester).fill, danger.fill);
    });

    testWidgets('can be made invalid without a message', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCheckbox(label: Text('Terms'), invalid: true));

      expect(dataOf(tester).validationResult, SemanticsValidationResult.invalid);
      expect(sheetOf(tester).edge, tokens.roles(NebaColor.danger).line);
      expect(find.byType(IntrinsicWidth), findsNothing);
      semantics.dispose();
    });
  });

  group('style', () {
    testWidgets('fills with its colour family when ticked, and rings in it', (
      WidgetTester tester,
    ) async {
      final NebaColorRoles success = tokens.roles(NebaColor.success);

      await pump(
        tester,
        const NebaCheckbox(label: Text('Tick'), color: NebaColor.success, defaultChecked: true),
      );

      expect(sheetOf(tester).fill, success.fill);
      expect(sheetOf(tester).edge, edgeless);
      expect(tester.widget<NebaTick>(find.byType(NebaTick)).roles.ring, success.ring);
      await tester.pump(NebaScale.duration);
      expect(markOf(tester).color, success.onSolid);
    });

    testWidgets('keeps the sheet undyed until it is ticked', (WidgetTester tester) async {
      await pump(tester, const NebaCheckbox(label: Text('Tick'), color: NebaColor.success));

      expect(sheetOf(tester).fill, tokens.panel);
      expect(sheetOf(tester).edge, tokens.roles(NebaColor.success).line);
    });

    testWidgets('deepens under the pointer and lands a press at once', (WidgetTester tester) async {
      await pump(tester, const NebaCheckbox(label: Text('Tick')));

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(sheet()));
      await tester.pump();
      expect(sheetOf(tester).fill, tokens.panelHover);
      expect(sheetOf(tester).edge, primary.lineHover);

      await mouse.down(tester.getCenter(sheet()));
      await tester.pump();
      expect(sheetOf(tester).pressed, isTrue);

      await mouse.up();
      await tester.pump();
      expect(sheetOf(tester).fill, primary.fillHover);
      await mouse.removePointer();
    });

    testWidgets('scales the square with size, from the provider too', (WidgetTester tester) async {
      await pump(tester, const NebaCheckbox(label: Text('Tick'), size: NebaSize.xl));
      expect(tester.getSize(sheet()), const Size.square(24));

      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(size: NebaSize.xs),
          child: NebaCheckbox(label: Text('Tick')),
        ),
      );
      expect(tester.getSize(sheet()), const Size.square(14));
      expect(
        tester.widget<NebaSheet>(sheet()).borderRadius,
        BorderRadius.circular(NebaScale.tickRadius[NebaSize.xs]!),
      );
    });

    // The plate is light on a cut edge at 32 pixels and a bevel at 18. A tick
    // keeps the acrylic and drops the highlight.
    testWidgets('wears no plate, ticked or not, and stays frosted', (WidgetTester tester) async {
      await pump(tester, const NebaCheckbox(label: Text('Tick')));
      expect(sheetOf(tester).plate, NebaPlate.none);
      expect(sheetOf(tester).blur, isTrue);
      expect(sheetOf(tester).texture, isTrue);

      await tester.tap(find.text('Tick'));
      await tester.pump();
      expect(sheetOf(tester).plate, NebaPlate.none);
      expect(sheetOf(tester).elevation, 0);
    });

    testWidgets('centres the square on the label’s first line, however many it wraps to', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const SizedBox(
          width: 200,
          child: NebaCheckbox(label: Text('A label long enough to wrap onto more lines')),
        ),
      );

      final double text = NebaScale.controlText[NebaSize.md]!;
      final Rect label = tester.getRect(find.text('A label long enough to wrap onto more lines'));

      expect(label.height, greaterThan(text * 1.4 * 2));
      expect(tester.getCenter(sheet()).dy, moreOrLessEquals(label.top + text * 1.4 / 2));
      expect(styleOf(tester, 'A label long enough to wrap onto more lines').height, 1.4);
      // The gap between the two, CSS `gap-2`.
      expect(label.left - tester.getRect(sheet()).right, 8);
    });

    // The box answered a press in colour and the mark in it answered not at
    // all. It is drawn along its own length now, and fades as it goes.
    testWidgets('draws the mark along its length rather than switching it on', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCheckbox(label: Text('Tick')));
      expect(markOf(tester).drawn, 0);

      await tester.tap(find.text('Tick'));
      await tester.pump();
      await tester.pump(NebaScale.duration ~/ 4);
      final double halfway = markOf(tester).drawn;
      expect(halfway, greaterThan(0));
      expect(halfway, lessThan(1));
      expect(markOf(tester).shape, NebaTickMarkShape.check);

      await tester.pump(NebaScale.duration);
      expect(markOf(tester).drawn, 1);

      // And taken back the same way, as a tick still.
      await tester.tap(find.text('Tick'));
      await tester.pump();
      await tester.pump(NebaScale.duration ~/ 4);
      expect(markOf(tester).drawn, lessThan(1));
      expect(markOf(tester).shape, NebaTickMarkShape.check);
      await tester.pump(NebaScale.duration);
      expect(markOf(tester).drawn, 0);
    });

    testWidgets('is there at once when built ticked, or under reduced motion', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCheckbox(label: Text('Tick'), defaultChecked: true));
      expect(markOf(tester).drawn, 1);

      await tester.pumpWidget(const SizedBox());
      await pump(tester, const NebaCheckbox(label: Text('Tick')), disableAnimations: true);
      await tester.tap(find.text('Tick'));
      await tester.pump();
      await tester.pump();
      expect(markOf(tester).drawn, 1);
    });

    testWidgets('never applies a transform', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCheckbox(
          label: Text('Tick'),
          description: Text('Note'),
          error: Text('Bad'),
          indeterminate: true,
        ),
      );

      expect(
        find.descendant(of: find.byType(NebaCheckbox), matching: find.byType(Transform)),
        findsNothing,
      );
    });

    testWidgets('rings for keyboard focus in its family', (WidgetTester tester) async {
      await pump(tester, const NebaCheckbox(label: Text('Tick'), color: NebaColor.info));
      nodeOf(tester).requestFocus();
      await tester.pump();
      await tester.pump(NebaScale.duration);

      expect(nodeOf(tester).hasPrimaryFocus, isTrue);
      expect(
        tester.widget<NebaTick>(find.byType(NebaTick)).roles.ring,
        tokens.roles(NebaColor.info).ring,
      );
    });
  });
}
