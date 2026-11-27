// NebaFieldset: the suite the React package runs on Fieldset, asked the way
// Flutter asks it — the group's semantics, where the legend and the gaps land,
// and what a press does to each control inside a disabled one — rather than
// the elements, classes and attributes it writes.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget child, {NebaDefaults? defaults}) {
    final Widget placed = Overlay.wrap(
      child: Center(child: SizedBox(width: 320, child: child)),
    );

    return tester.pumpWidget(
      host(defaults == null ? placed : NebaProvider(defaults: defaults, child: placed)),
    );
  }

  TextStyle styleOf(WidgetTester tester, Finder text) {
    return tester.renderObject<RenderParagraph>(text).text.style!;
  }

  /// Whether the primary focus is [control] or something inside it.
  bool focusedIn(WidgetTester tester, Finder control) {
    final BuildContext? focused = FocusManager.instance.primaryFocus?.context;

    if (focused == null) {
      return false;
    }

    final Element root = tester.element(control);
    bool inside = identical(focused, root);

    focused.visitAncestorElements((Element element) {
      if (identical(element, root)) {
        inside = true;
      }

      return !inside;
    });

    return inside;
  }

  group('rendering', () {
    testWidgets('builds a group named by its legend', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaFieldset(
          legend: const Text('Billing address'),
          children: <Widget>[NebaTextField(label: const Text('Street'))],
        ),
      );

      expect(find.bySemanticsLabel('Billing address'), findsOneWidget);
      // The field keeps a node of its own inside the group.
      expect(find.bySemanticsLabel('Street'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('puts the description under the legend, read after the name', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaFieldset(
          legend: const Text('Billing address'),
          description: const Text('Where the card statement goes.'),
          children: <Widget>[NebaTextField(label: const Text('Street'))],
        ),
      );

      final Rect legend = tester.getRect(find.text('Billing address'));
      final Rect description = tester.getRect(find.text('Where the card statement goes.'));

      expect(description.top, legend.bottom + NebaScale.sheetHeaderGap[NebaSize.md]!);
      expect(styleOf(tester, find.text('Where the card statement goes.')).color, tokens.mutedFg);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Billing address')),
        matchesSemantics(label: 'Billing address', hint: 'Where the card statement goes.'),
      );

      semantics.dispose();
    });

    testWidgets('builds no legend when there is nothing to put in one', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaFieldset(children: <Widget>[NebaTextField(label: const Text('Street'))]),
      );

      // The field is the group's first part.
      expect(
        tester.getRect(find.byType(NebaTextField)).top,
        tester.getRect(find.byType(NebaFieldset)).top,
      );
    });

    testWidgets('sets the legend in the sheet title type, semibold', (WidgetTester tester) async {
      await pump(tester, const NebaFieldset(legend: Text('Address'), size: NebaSize.xl));

      final TextStyle style = styleOf(tester, find.text('Address'));

      expect(style.fontSize, NebaScale.sheetTitleText[NebaSize.xl]);
      expect(style.fontWeight, FontWeight.w600);
    });

    testWidgets('reflects a changed legend on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaFieldset(legend: Text('Before')));
      await pump(tester, const NebaFieldset(legend: Text('After')));

      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    });

    testWidgets('stretches its controls to its width', (WidgetTester tester) async {
      await pump(
        tester,
        NebaFieldset(children: <Widget>[NebaTextField(label: const Text('Street'))]),
      );

      expect(tester.getSize(find.byType(NebaTextField)).width, 320);
    });
  });

  group('spacing', () {
    double gapBetween(WidgetTester tester) {
      return tester.getRect(find.byType(NebaTextField).last).top -
          tester.getRect(find.byType(NebaTextField).first).bottom;
    }

    List<Widget> twoFields() {
      return <Widget>[
        NebaTextField(label: const Text('Street')),
        NebaTextField(label: const Text('City')),
      ];
    }

    testWidgets('stands the controls on the size ladder', (WidgetTester tester) async {
      await pump(
        tester,
        NebaFieldset(legend: const Text('Address'), size: NebaSize.xl, children: twoFields()),
      );

      expect(gapBetween(tester), NebaScale.sheetSectionGap[NebaSize.xl]);
      expect(
        tester.getRect(find.byType(NebaTextField).first).top -
            tester.getRect(find.text('Address')).bottom,
        NebaScale.sheetSectionGap[NebaSize.xl],
      );
    });

    testWidgets('stands them spacing apart instead, and keeps the legend on its size', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaFieldset(
          legend: const Text('Address'),
          size: NebaSize.xl,
          spacing: 2,
          children: twoFields(),
        ),
      );

      expect(gapBetween(tester), 8);
      expect(styleOf(tester, find.text('Address')).fontSize, NebaScale.sheetTitleText[NebaSize.xl]);
    });

    testWidgets("takes NebaProvider's spacing, and its own over it", (WidgetTester tester) async {
      const NebaDefaults defaults = NebaDefaults(spacing: 6);

      await pump(tester, NebaFieldset(children: twoFields()), defaults: defaults);
      expect(gapBetween(tester), 24);

      await pump(tester, NebaFieldset(spacing: 1, children: twoFields()), defaults: defaults);
      expect(gapBetween(tester), 4);
    });
  });

  group('disabled', () {
    /// One control of every kind a fieldset reaches, each calling `hit` when
    /// the press below lands, and where the press goes.
    final Map<String, (Widget Function(VoidCallback hit), Finder)> controls =
        <String, (Widget Function(VoidCallback hit), Finder)>{
          'NebaTextField': (
            (VoidCallback hit) => NebaTextField(label: const Text('Street')),
            find.byType(EditableText),
          ),
          'NebaNumberField': (
            (VoidCallback hit) => NebaNumberField(label: const Text('Quantity')),
            find.byType(EditableText),
          ),
          'NebaOtpField': (
            (VoidCallback hit) => NebaOtpField(label: const Text('Code')),
            find.byType(NebaOtpField),
          ),
          'NebaCombobox': (
            (VoidCallback hit) => NebaCombobox<String>(
              label: const Text('City'),
              items: const <NebaComboboxOption<String>>[
                NebaComboboxOption<String>(value: 'seoul', label: 'Seoul'),
              ],
            ),
            find.byType(EditableText),
          ),
          'NebaSelect': (
            (VoidCallback hit) => NebaSelect<String>(
              label: const Text('Country'),
              onOpenChange: (bool open) => hit(),
              items: const <NebaSelectOption<String>>[
                NebaSelectOption<String>(value: 'kr', label: Text('Korea')),
              ],
            ),
            find.byType(NebaSelect<String>),
          ),
          'NebaCheckbox': (
            (VoidCallback hit) =>
                NebaCheckbox(label: const Text('Save it'), onCheckedChange: (bool _) => hit()),
            find.text('Save it'),
          ),
          'NebaCheckboxGroup': (
            (VoidCallback hit) => NebaCheckboxGroup(
              label: const Text('Toppings'),
              onValueChange: (List<String> _) => hit(),
              children: const <Widget>[NebaCheckbox(value: 'cheese', label: Text('Cheese'))],
            ),
            find.text('Cheese'),
          ),
          'NebaRadioGroup': (
            (VoidCallback hit) => NebaRadioGroup<String>(
              label: const Text('Plan'),
              onValueChange: (String? _) => hit(),
              children: const <Widget>[NebaRadio<String>(value: 'team', label: Text('Team'))],
            ),
            find.text('Team'),
          ),
          'NebaSwitch': (
            (VoidCallback hit) =>
                NebaSwitch(label: const Text('Default'), onCheckedChange: (bool _) => hit()),
            find.text('Default'),
          ),
          'NebaSlider': (
            (VoidCallback hit) => NebaSlider(
              semanticLabel: 'Volume',
              defaultValue: 0,
              onValueChange: (double _) => hit(),
            ),
            find.byType(NebaSlider),
          ),
          'NebaRating': (
            // As wide as its stars, so a press on its middle lands on one.
            (VoidCallback hit) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: NebaRating(onValueChange: (double _) => hit()),
            ),
            find.byType(NebaRating),
          ),
          'NebaSegmentedButton': (
            (VoidCallback hit) => NebaSegmentedButton<String>(
              defaultValue: 'day',
              onValueChange: (String? _) => hit(),
              children: const <NebaSegment<String>>[
                NebaSegment<String>(value: 'day', child: Text('Day')),
                NebaSegment<String>(value: 'week', child: Text('Week')),
              ],
            ),
            find.text('Week'),
          ),
          'NebaToggle': (
            (VoidCallback hit) =>
                NebaToggle(onPressedChange: (bool _) => hit(), child: const Text('Bold')),
            find.text('Bold'),
          ),
          'NebaToggleGroup': (
            (VoidCallback hit) => NebaToggleGroup(
              onValueChange: (List<String> _) => hit(),
              children: const <Widget>[NebaToggle(value: 'left', child: Text('Left'))],
            ),
            find.text('Left'),
          ),
          'NebaButton': (
            (VoidCallback hit) => NebaButton(onPressed: hit, child: const Text('Save')),
            find.text('Save'),
          ),
          'NebaIconButton': (
            (VoidCallback hit) => NebaIconButton(
              onPressed: hit,
              label: 'Close',
              icon: const SizedBox.square(dimension: 12),
            ),
            find.byType(NebaIconButton),
          ),
        };

    for (final MapEntry<String, (Widget Function(VoidCallback hit), Finder)> entry
        in controls.entries) {
      testWidgets('${entry.key} answers outside one and not inside a disabled one', (
        WidgetTester tester,
      ) async {
        final (Widget Function(VoidCallback hit) build, Finder target) = entry.value;
        int hits = 0;
        Widget control() => build(() => hits++);

        Future<bool> press(bool disabled) async {
          hits = 0;
          FocusManager.instance.primaryFocus?.unfocus();
          await pump(tester, NebaFieldset(disabled: disabled, children: <Widget>[control()]));
          await tester.pump();
          await tester.tap(target.first, warnIfMissed: false);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));

          return hits > 0 || focusedIn(tester, find.byType(NebaFieldset));
        }

        expect(await press(false), isTrue, reason: 'a press reaches ${entry.key}');

        // A fresh tree, so nothing carries over from the enabled one.
        await tester.pumpWidget(const SizedBox());
        expect(await press(true), isFalse, reason: 'a disabled fieldset stops ${entry.key}');
      });
    }

    testWidgets('draws every field inside it disabled', (WidgetTester tester) async {
      await pump(
        tester,
        NebaFieldset(
          legend: const Text('Address'),
          disabled: true,
          children: <Widget>[
            NebaTextField(label: const Text('Street')),
            const NebaCheckbox(label: Text('Save it')),
            const NebaSwitch(label: Text('Default')),
            NebaSelect<String>(
              label: const Text('Country'),
              items: const <NebaSelectOption<String>>[
                NebaSelectOption<String>(value: 'kr', label: Text('Korea')),
              ],
            ),
          ],
        ),
      );

      for (final String text in <String>['Street', 'Save it', 'Default', 'Country']) {
        expect(styleOf(tester, find.text(text).first).color, tokens.disabledFg, reason: text);
      }
    });

    testWidgets('wins over a control that says it is not disabled', (WidgetTester tester) async {
      await pump(
        tester,
        NebaFieldset(
          disabled: true,
          children: <Widget>[NebaTextField(label: const Text('Street'), disabled: false)],
        ),
      );

      expect(styleOf(tester, find.text('Street')).color, tokens.disabledFg);
    });

    testWidgets('reaches the fields of a group nested inside it', (WidgetTester tester) async {
      await pump(
        tester,
        NebaFieldset(
          legend: const Text('Order'),
          disabled: true,
          children: <Widget>[
            NebaFieldset(
              legend: const Text('Shipping'),
              children: <Widget>[NebaTextField(label: const Text('Street'))],
            ),
          ],
        ),
      );

      expect(styleOf(tester, find.text('Street')).color, tokens.disabledFg);
    });

    testWidgets('leaves them alone when it is not, and lets them go again', (
      WidgetTester tester,
    ) async {
      Widget fieldset(bool disabled) {
        return NebaFieldset(
          disabled: disabled,
          children: <Widget>[NebaTextField(label: const Text('Street'))],
        );
      }

      await pump(tester, fieldset(false));
      expect(styleOf(tester, find.text('Street')).color, tokens.fg);

      await pump(tester, fieldset(true));
      expect(styleOf(tester, find.text('Street')).color, tokens.disabledFg);

      await pump(tester, fieldset(false));
      expect(styleOf(tester, find.text('Street')).color, tokens.fg);
    });
  });
}
