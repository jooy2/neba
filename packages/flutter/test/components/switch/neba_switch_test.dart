// NebaSwitch: the suite the React package runs on Switch, asked the way
// Flutter asks it — the switch a screen reader hears, the state it keeps or is
// handed, the side its label is on, the track it draws in each state, and the
// thumb that travels by its offset.

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  Future<void> pump(
    WidgetTester tester,
    Widget control, {
    TextDirection direction = TextDirection.ltr,
    bool highContrast = false,
  }) {
    return tester.pumpWidget(
      host(
        Center(child: control),
        textDirection: direction,
        highContrast: highContrast,
      ),
    );
  }

  Finder track() => find.descendant(of: find.byType(NebaSwitch), matching: find.byType(NebaSheet));

  NebaSheet trackOf(WidgetTester tester) => tester.widget<NebaSheet>(track());

  Finder thumb() {
    return find.descendant(
      of: find.byType(NebaSwitch),
      matching: find.byWidgetPredicate(
        (Widget widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      ),
    );
  }

  FocusNode nodeOf(WidgetTester tester) => Focus.of(tester.element(track()));

  Matcher heard(String label, {bool on = false, bool enabled = true, bool readOnly = false}) {
    return matchesSemantics(
      label: label,
      hasToggledState: true,
      isToggled: on,
      hasEnabledState: true,
      isEnabled: enabled,
      isReadOnly: readOnly,
      isFocusable: enabled,
      hasTapAction: enabled && !readOnly,
      hasFocusAction: enabled,
    );
  }

  group('rendering', () {
    testWidgets('is a switch named by its label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaSwitch(label: Text('Email alerts'), defaultChecked: true));

      expect(tester.getSemantics(find.byType(NebaSwitch)), heard('Email alerts', on: true));
      semantics.dispose();
    });

    testWidgets('takes its name from semanticLabel without a label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaSwitch(semanticLabel: 'Dark mode'));

      expect(tester.getSemantics(find.byType(NebaSwitch)), heard('Dark mode'));
      expect(tester.getSize(find.byType(NebaSwitch)), const Size(36, 20));
      semantics.dispose();
    });

    testWidgets('shows the description and reads it after the name', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaSwitch(label: Text('Alerts'), description: Text('Sent immediately.')),
      );

      expect(find.text('Sent immediately.'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(NebaSwitch)).getSemanticsData().hint,
        'Sent immediately.',
      );
      semantics.dispose();
    });

    testWidgets('reflects a changed label on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaSwitch(label: Text('Before')));
      await pump(tester, const NebaSwitch(label: Text('After')));

      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    });

    testWidgets('puts the label after the track, and before it on request', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSwitch(label: Text('Alerts')));
      expect(tester.getTopLeft(find.text('Alerts')).dx, tester.getTopRight(track()).dx + 10);

      await pump(
        tester,
        const NebaSwitch(label: Text('Alerts'), labelSide: NebaSwitchLabelSide.start),
      );
      expect(tester.getTopRight(find.text('Alerts')).dx + 10, tester.getTopLeft(track()).dx);
    });

    // A settings list: the labels take the slack, and every track lines up at
    // the end of the row.
    testWidgets('puts the track at the end of a row it is stretched across', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const SizedBox(
          width: 300,
          child: NebaSwitch(label: Text('Alerts'), labelSide: NebaSwitchLabelSide.start),
        ),
      );

      expect(tester.getTopRight(track()).dx, tester.getTopRight(find.byType(NebaSwitch)).dx);
      expect(
        tester.getTopLeft(find.text('Alerts')).dx,
        tester.getTopLeft(find.byType(NebaSwitch)).dx,
      );
    });
  });

  group('behaviour', () {
    testWidgets('turns on when its label is pressed, and off from its track', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];

      await pump(tester, NebaSwitch(label: const Text('Alerts'), onCheckedChange: changes.add));
      await tester.tap(find.text('Alerts'));
      await tester.pump();
      await tester.tap(track());
      await tester.pump();

      expect(changes, <bool>[true, false]);
    });

    testWidgets('flips on Space while it holds the focus', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await pump(tester, NebaSwitch(label: const Text('Alerts'), onCheckedChange: changes.add));
      nodeOf(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(changes, <bool>[true]);
    });

    testWidgets('follows a controlled checked', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaSwitch(label: const Text('Alerts'), checked: true, onCheckedChange: changes.add),
      );
      await tester.tap(find.text('Alerts'));
      await tester.pump();
      expect(changes, <bool>[false]);
      expect(tester.getSemantics(find.byType(NebaSwitch)), heard('Alerts', on: true));

      await pump(tester, const NebaSwitch(label: Text('Alerts'), checked: false));
      expect(tester.getSemantics(find.byType(NebaSwitch)), heard('Alerts'));
      semantics.dispose();
    });

    testWidgets('does not move when read-only', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaSwitch(label: const Text('Alerts'), readOnly: true, onCheckedChange: changes.add),
      );
      await tester.tap(find.text('Alerts'));
      await tester.tap(track());
      await tester.pump();

      expect(changes, isEmpty);
      expect(tester.getSemantics(find.byType(NebaSwitch)), heard('Alerts', readOnly: true));
      expect(find.ancestor(of: track(), matching: find.byType(ColorFiltered)), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('is out of reach and grey when disabled', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaSwitch(
          label: const Text('Alerts'),
          disabled: true,
          defaultChecked: true,
          onCheckedChange: changes.add,
        ),
      );
      await tester.tap(find.text('Alerts'));
      await tester.pump();

      expect(changes, isEmpty);
      expect(nodeOf(tester).canRequestFocus, isFalse);
      expect(
        tester.getSemantics(find.byType(NebaSwitch)),
        heard('Alerts', on: true, enabled: false),
      );
      expect(trackOf(tester).fill, tokens.disabledBg);
      expect(trackOf(tester).edge, tokens.disabledBorder);
      expect(trackOf(tester).blur, isFalse);
      expect(
        DefaultTextStyle.of(tester.element(find.text('Alerts'))).style.color,
        tokens.disabledFg,
      );
      semantics.dispose();
    });
  });

  group('style', () {
    testWidgets('fills with its colour family when on', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaSwitch(label: Text('Alerts'), color: NebaColor.success, defaultChecked: true),
      );

      expect(trackOf(tester).fill, tokens.roles(NebaColor.success).fill);
      expect(trackOf(tester).edge, edgeless);
    });

    testWidgets('turns the family over to danger when invalid', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final NebaColorRoles danger = tokens.roles(NebaColor.danger);

      await pump(
        tester,
        const NebaSwitch(
          label: Text('Alerts'),
          color: NebaColor.info,
          defaultChecked: true,
          error: Text('Pick one'),
        ),
      );

      expect(trackOf(tester).fill, danger.fill);
      expect(DefaultTextStyle.of(tester.element(find.text('Pick one'))).style.color, danger.accent);
      expect(
        tester.getSemantics(find.byType(NebaSwitch)).getSemanticsData().validationResult,
        SemanticsValidationResult.invalid,
      );
      semantics.dispose();
    });

    testWidgets('is a groove while off, laid on the page under reduced transparency', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSwitch(label: Text('Alerts')));
      expect(trackOf(tester).fill, tokens.groove);
      expect(trackOf(tester).edge, primary.line);

      await pump(tester, const NebaSwitch(label: Text('Alerts')), highContrast: true);
      final NebaTokens opaque = tokens.withReducedTransparency();
      expect(trackOf(tester).fill, Color.alphaBlend(opaque.groove, opaque.surface));
    });

    testWidgets('deepens under the pointer', (WidgetTester tester) async {
      await pump(tester, const NebaSwitch(label: Text('Alerts')));

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(track()));
      await tester.pump();

      expect(trackOf(tester).fill, tokens.grooveHover);
      expect(trackOf(tester).edge, primary.lineHover);
      await mouse.removePointer();
    });

    testWidgets('scales the track with size', (WidgetTester tester) async {
      await pump(tester, const NebaSwitch(label: Text('Alerts'), size: NebaSize.xl));

      expect(tester.getSize(track()), const Size(52, 28));
      expect(tester.getSize(thumb()), const Size.square(22));
    });

    // The track is taller than the line beside it from `md` up, and the row
    // makes room for it, half above and half below, so it stays centred on
    // the line and inside the row.
    testWidgets('makes room for a track taller than its line of text', (WidgetTester tester) async {
      await pump(tester, const NebaSwitch(label: Text('Alerts'), size: NebaSize.xl));

      final double line = NebaScale.controlText[NebaSize.xl]! * 1.4;
      expect(tester.getTopLeft(track()).dy, tester.getTopLeft(find.byType(NebaSwitch)).dy);
      expect(tester.getSize(find.byType(NebaSwitch)).height, moreOrLessEquals(28, epsilon: 0.5));
      expect(
        tester.getCenter(track()).dy,
        moreOrLessEquals(tester.getTopLeft(find.text('Alerts')).dy + line / 2),
      );

      // At `sm` the track fits inside the line, and the row is the line.
      await pump(tester, const NebaSwitch(label: Text('Alerts'), size: NebaSize.sm));
      expect(
        tester.getSize(find.byType(NebaSwitch)).height,
        moreOrLessEquals(NebaScale.controlText[NebaSize.sm]! * 1.4, epsilon: 0.5),
      );
    });

    testWidgets('wears no plate on the track, on or off, and stays frosted', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSwitch(label: Text('Alerts'), defaultChecked: true));

      expect(trackOf(tester).plate, NebaPlate.none);
      expect(trackOf(tester).blur, isTrue);
      expect(trackOf(tester).texture, isTrue);
    });

    testWidgets('gives the thumb the page’s surface and one level of shadow', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSwitch(label: Text('Alerts'), defaultChecked: true));

      final BoxDecoration decoration =
          tester.widget<DecoratedBox>(thumb()).decoration as BoxDecoration;
      expect(decoration.color, tokens.surface);
      expect(decoration.boxShadow, tokens.elevation(1));
    });

    // An inline start rather than a transform, so on and off swap ends right
    // to left, and the thumb stands as far from each end.
    testWidgets('moves the thumb by its offset, to the end of the line', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSwitch(label: Text('Alerts')));
      expect(tester.getTopLeft(thumb()).dx - tester.getTopLeft(track()).dx, 3);

      await tester.tap(find.text('Alerts'));
      await tester.pump();
      await tester.pump(NebaScale.duration ~/ 4);
      final double halfway = tester.getTopLeft(thumb()).dx - tester.getTopLeft(track()).dx;
      expect(halfway, greaterThan(3));
      expect(halfway, lessThan(19));

      await tester.pump(NebaScale.duration);
      expect(tester.getTopRight(track()).dx - tester.getTopRight(thumb()).dx, 3);
      expect(
        find.descendant(of: find.byType(NebaSwitch), matching: find.byType(Transform)),
        findsNothing,
      );

      await pump(
        tester,
        const NebaSwitch(label: Text('Alerts'), checked: true),
        direction: TextDirection.rtl,
      );
      await tester.pump(NebaScale.duration);
      expect(tester.getTopLeft(thumb()).dx - tester.getTopLeft(track()).dx, 3);
    });
  });
}
