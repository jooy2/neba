// NebaDatePicker: the suite the React package runs on DatePicker, asked the
// way Flutter asks it — the shell and the popup it builds, the width it lays
// out, the semantics it builds and what a press and a key do — rather than
// the elements, the classes and the ARIA it writes. The calendar's own keys
// and cells are tested with NebaCalendar.

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/calendar.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/notch.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles danger = tokens.roles(NebaColor.danger);
  final DateTime day = DateTime(2026, 7, 27);

  // At the top of a window tall enough for the calendar under it.
  Future<void> pump(WidgetTester tester, Widget picker) {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    return tester.pumpWidget(
      host(
        Overlay.wrap(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(padding: const EdgeInsets.only(top: 40), child: picker),
          ),
        ),
        height: 900,
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Finder shellSheet() =>
      find.descendant(of: find.byType(NebaFieldShell), matching: find.byType(NebaSheet));

  Finder cell(String label) => find.bySemanticsLabel(label);

  SemanticsData triggerData(WidgetTester tester) {
    return tester.getSemantics(find.byType(NebaFieldWidth)).getSemanticsData();
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byType(NebaFieldShell));
    await settle(tester);
  }

  FocusNode triggerNode(WidgetTester tester) {
    return Focus.of(
      tester.element(
        find.descendant(of: find.byType(NebaFieldShell), matching: find.byType(Row)).at(1),
      ),
    );
  }

  bool calendarOpen() => find.byType(NebaCalendarGrid).evaluate().isNotEmpty;

  group('rendering', () {
    testWidgets('is a button named by its label that says the day it holds', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaDatePicker(label: const Text('Ships on'), defaultValue: day));

      expect(
        tester.getSemantics(find.byType(NebaFieldWidth)),
        matchesSemantics(
          label: 'Ships on',
          value: 'Jul 27, 2026',
          isButton: true,
          hasExpandedState: true,
          isFocusable: true,
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      semantics.dispose();
    });

    testWidgets('shows the placeholder while nothing is chosen, muted', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaDatePicker(placeholder: Text('Pick a day')));

      expect(
        DefaultTextStyle.of(tester.element(find.text('Pick a day'))).style.color,
        tokens.mutedFg,
      );
    });

    testWidgets('writes the chosen day at the unit, or by a format', (WidgetTester tester) async {
      await pump(tester, NebaDatePicker(defaultValue: day));
      expect(find.text('Jul 27, 2026'), findsOneWidget);

      await pump(
        tester,
        NebaDatePicker(
          key: const Key('month'),
          defaultValue: day,
          granularity: NebaDateGranularity.month,
        ),
      );
      expect(find.text('July 2026'), findsOneWidget);

      await pump(
        tester,
        NebaDatePicker(
          key: const Key('year'),
          defaultValue: day,
          granularity: NebaDateGranularity.year,
        ),
      );
      expect(find.text('2026'), findsOneWidget);

      await pump(
        tester,
        NebaDatePicker(
          key: const Key('format'),
          defaultValue: day,
          format: (DateTime date) => '${date.day}/${date.month}',
        ),
      );
      expect(find.text('27/7'), findsOneWidget);
    });

    testWidgets('reads the description after its name, and reflects a changed label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaDatePicker(label: Text('Ships on'), description: Text('Local time.')),
      );
      expect(triggerData(tester).hint, 'Local time.');

      await pump(
        tester,
        const NebaDatePicker(label: Text('Delivered'), description: Text('Local time.')),
      );
      expect(triggerData(tester).label, 'Delivered');

      semantics.dispose();
    });

    testWidgets('builds nothing of the calendar until it is open', (WidgetTester tester) async {
      await pump(tester, const NebaDatePicker());

      expect(calendarOpen(), isFalse);
    });

    testWidgets('wears a calendar glyph, or none', (WidgetTester tester) async {
      await pump(tester, const NebaDatePicker());
      expect(find.byType(NebaFieldAdornment), findsOneWidget);

      await pump(tester, const NebaDatePicker(showStartIcon: false));
      expect(find.byType(NebaFieldAdornment), findsNothing);
    });
  });

  group('choosing a day', () {
    testWidgets('opens the calendar on the month of the value, in its sheet', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaDatePicker(defaultValue: day));
      await open(tester);

      expect(calendarOpen(), isTrue);
      expect(find.text('July'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(NebaFieldWidth)),
        matchesSemantics(
          value: 'Jul 27, 2026',
          isButton: true,
          hasExpandedState: true,
          isExpanded: true,
          isFocusable: true,
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      final NebaSheet sheet = tester.widget<NebaSheet>(
        find.descendant(of: find.byType(NebaCalendarSheet), matching: find.byType(NebaSheet)).first,
      );
      expect(sheet.elevation, 3);
      expect(sheet.fill, tokens.panelPress);

      semantics.dispose();
    });

    testWidgets('reports the day that was pressed and closes', (WidgetTester tester) async {
      final List<DateTime?> reported = <DateTime?>[];

      await pump(tester, NebaDatePicker(defaultMonth: day, onValueChange: reported.add));
      await open(tester);
      await tester.tap(cell('Wednesday, July 15, 2026'));
      await settle(tester);

      expect(reported, <DateTime?>[DateTime(2026, 7, 15)]);
      expect(calendarOpen(), isFalse);
      expect(find.text('Jul 15, 2026'), findsOneWidget);
    });

    testWidgets('stays open when closeOnSelect is off', (WidgetTester tester) async {
      await pump(tester, NebaDatePicker(defaultMonth: day, closeOnSelect: false));
      await open(tester);
      await tester.tap(cell('Wednesday, July 15, 2026'));
      await settle(tester);

      expect(calendarOpen(), isTrue);
    });

    testWidgets('keeps the time of day the value already carried', (WidgetTester tester) async {
      DateTime? chosen;

      await pump(
        tester,
        NebaDatePicker(
          defaultValue: DateTime(2026, 7, 27, 9, 30),
          onValueChange: (DateTime? value) => chosen = value,
        ),
      );
      await open(tester);
      await tester.tap(cell('Wednesday, July 15, 2026'));
      await settle(tester);

      expect(chosen, DateTime(2026, 7, 15, 9, 30));
    });

    testWidgets('leaves a controlled value alone until the caller changes it', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaDatePicker(value: day, onValueChange: (DateTime? _) {}));
      await open(tester);
      await tester.tap(cell('Wednesday, July 15, 2026'));
      await settle(tester);

      expect(find.text('Jul 27, 2026'), findsOneWidget);
    });

    testWidgets('opens the calendar on the chosen month again after browsing away', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaDatePicker(defaultValue: day));
      await open(tester);
      await tester.tap(find.bySemanticsLabel('Next month'));
      await settle(tester);
      expect(find.text('August'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      await open(tester);

      expect(find.text('July'), findsOneWidget);
    });
  });

  group('reaching another month and year', () {
    testWidgets('opens the month grid and the year grid and picks from them', (
      WidgetTester tester,
    ) async {
      DateTime? chosen;

      await pump(
        tester,
        NebaDatePicker(defaultMonth: day, onValueChange: (DateTime? value) => chosen = value),
      );
      await open(tester);
      await tester.tap(find.text('2026'));
      await settle(tester);
      await tester.tap(cell('2019'));
      await settle(tester);
      await tester.tap(cell('March 2019'));
      await settle(tester);
      await tester.tap(cell('Thursday, March 14, 2019'));
      await settle(tester);

      expect(chosen, DateTime(2019, 3, 14));
    });
  });

  group('granularity', () {
    testWidgets('opens on the month grid and commits the 1st of the month', (
      WidgetTester tester,
    ) async {
      DateTime? chosen;

      await pump(
        tester,
        NebaDatePicker(
          defaultMonth: day,
          granularity: NebaDateGranularity.month,
          onValueChange: (DateTime? value) => chosen = value,
        ),
      );
      await open(tester);

      expect(find.text('Mar'), findsOneWidget);

      await tester.tap(cell('March 2026'));
      await settle(tester);

      expect(chosen, DateTime(2026, 3));
      expect(find.text('March 2026'), findsOneWidget);
    });

    testWidgets('opens on the year grid and commits the 1st of January', (
      WidgetTester tester,
    ) async {
      DateTime? chosen;

      await pump(
        tester,
        NebaDatePicker(
          defaultMonth: day,
          granularity: NebaDateGranularity.year,
          onValueChange: (DateTime? value) => chosen = value,
        ),
      );
      await open(tester);
      await tester.tap(cell('2024'));
      await settle(tester);

      expect(chosen, DateTime(2024));
    });

    testWidgets('still climbs to the year grid, and comes back without committing', (
      WidgetTester tester,
    ) async {
      final List<DateTime?> reported = <DateTime?>[];

      await pump(
        tester,
        NebaDatePicker(
          defaultMonth: day,
          granularity: NebaDateGranularity.month,
          onValueChange: reported.add,
        ),
      );
      await open(tester);
      await tester.tap(find.text('2026'));
      await settle(tester);
      await tester.tap(cell('2019'));
      await settle(tester);

      expect(reported, isEmpty);
      expect(cell('March 2019'), findsOneWidget);
    });

    testWidgets('names the footer shortcut after the unit and commits it', (
      WidgetTester tester,
    ) async {
      DateTime? chosen;
      final DateTime now = DateTime.now();

      await pump(
        tester,
        NebaDatePicker(
          granularity: NebaDateGranularity.month,
          onValueChange: (DateTime? value) => chosen = value,
        ),
      );
      await open(tester);
      await tester.tap(find.text('This month'));
      await settle(tester);

      expect(chosen, DateTime(now.year, now.month));
    });

    testWidgets('reads the bounds at the unit, so a month a minimum starts inside stays open', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaDatePicker(
          defaultMonth: DateTime(2026, 3),
          granularity: NebaDateGranularity.month,
          minDate: DateTime(2026, 3, 15),
        ),
      );
      await open(tester);

      Matcher monthCell(String label, {required bool enabled, bool focused = false}) {
        return matchesSemantics(
          label: label,
          isButton: true,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: enabled,
          isFocusable: true,
          isFocused: focused,
          hasTapAction: enabled,
          hasFocusAction: true,
        );
      }

      expect(
        tester.getSemantics(cell('March 2026')),
        monthCell('March 2026', enabled: true, focused: true),
      );
      expect(
        tester.getSemantics(cell('February 2026')),
        monthCell('February 2026', enabled: false),
      );

      semantics.dispose();
    });

    testWidgets('hands shouldDisableDate the 1st of each month, and only at that unit', (
      WidgetTester tester,
    ) async {
      final List<DateTime> asked = <DateTime>[];

      await pump(
        tester,
        NebaDatePicker(
          defaultMonth: day,
          granularity: NebaDateGranularity.month,
          shouldDisableDate: (DateTime date) {
            asked.add(date);
            return false;
          },
        ),
      );
      await open(tester);

      expect(asked, isNotEmpty);
      expect(asked.every((DateTime date) => date.day == 1), isTrue);
    });
  });

  group('states', () {
    testWidgets('empties the value through the ×, without opening', (WidgetTester tester) async {
      final List<DateTime?> reported = <DateTime?>[];

      await pump(
        tester,
        NebaDatePicker(defaultValue: day, clearable: true, onValueChange: reported.add),
      );
      await tester.tap(find.bySemanticsLabel('Clear'));
      await settle(tester);

      expect(reported, <DateTime?>[null]);
      expect(find.text('Jul 27, 2026'), findsNothing);
      expect(calendarOpen(), isFalse);
      expect(find.bySemanticsLabel('Clear'), findsNothing);
    });

    testWidgets('empties the value from the footer, and closes', (WidgetTester tester) async {
      final List<DateTime?> reported = <DateTime?>[];

      await pump(
        tester,
        NebaDatePicker(defaultValue: day, clearable: true, onValueChange: reported.add),
      );
      await open(tester);
      await tester.tap(find.text('Clear'));
      await settle(tester);

      expect(reported, <DateTime?>[null]);
      expect(calendarOpen(), isFalse);
    });

    testWidgets('does not open when read-only, and keeps the focus', (WidgetTester tester) async {
      await pump(tester, NebaDatePicker(defaultValue: day, readOnly: true));
      await tester.tap(find.byType(NebaFieldShell));
      await settle(tester);

      expect(calendarOpen(), isFalse);
      expect(triggerNode(tester).canRequestFocus, isTrue);
    });

    testWidgets('does not open when disabled, and leaves the focus order', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaDatePicker(defaultValue: day, disabled: true));
      await tester.tap(find.byType(NebaFieldShell));
      await settle(tester);

      expect(calendarOpen(), isFalse);
      expect(find.byType(ExcludeFocus), findsWidgets);
    });

    testWidgets('turns the family over to danger with an error', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaDatePicker(label: Text('Ships on'), error: Text('A date is required.')),
      );

      expect(tester.widget<NebaSheet>(shellSheet().first).edge, danger.line);
      expect(triggerData(tester).validationResult, SemanticsValidationResult.invalid);
      expect(triggerData(tester).hint, 'A date is required.');

      semantics.dispose();
    });
  });

  group('keyboard', () {
    testWidgets('opens on Enter with the chosen day focused, and Escape gives the focus back', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaDatePicker(defaultValue: day));
      triggerNode(tester).requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      expect(calendarOpen(), isTrue);
      expect(
        FocusManager.instance.primaryFocus?.rect,
        tester.getRect(cell('Monday, July 27, 2026')),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(
        FocusManager.instance.primaryFocus?.rect,
        tester.getRect(cell('Tuesday, August 4, 2026')),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      expect(calendarOpen(), isFalse);
      expect(triggerNode(tester).hasPrimaryFocus, isTrue);
    });

    testWidgets('chooses with Space and moves on from the grid', (WidgetTester tester) async {
      DateTime? chosen;

      await pump(
        tester,
        NebaDatePicker(defaultValue: day, onValueChange: (DateTime? value) => chosen = value),
      );
      triggerNode(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await settle(tester);

      expect(chosen, DateTime(2026, 7, 26));
      expect(calendarOpen(), isFalse);
      expect(triggerNode(tester).hasPrimaryFocus, isTrue);
    });
  });

  group('width', () {
    testWidgets('holds one width whatever day it holds', (WidgetTester tester) async {
      await pump(tester, NebaDatePicker(defaultValue: DateTime(2026, 5, 1)));
      final double may = tester.getSize(shellSheet().first).width;

      await pump(
        tester,
        NebaDatePicker(key: const Key('second'), defaultValue: DateTime(2026, 9, 28)),
      );

      expect(tester.getSize(shellSheet().first).width, may);
    });

    testWidgets('reserves room for the placeholder too', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaDatePicker(placeholder: Text('Pick a departure date, any date at all')),
      );
      final double empty = tester.getSize(shellSheet().first).width;

      await pump(tester, const NebaDatePicker(key: Key('bare')));

      expect(empty, greaterThan(tester.getSize(shellSheet().first).width));
    });

    testWidgets('reserves the width without putting the dates on the screen', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaDatePicker(defaultValue: day));

      expect(find.text('Sep 28, 2027'), findsNothing);
      expect(find.text('Jul 27, 2026'), findsOneWidget);
    });

    testWidgets('stretches to the container when full width', (WidgetTester tester) async {
      await pump(tester, const SizedBox(width: 500, child: NebaDatePicker(fullWidth: true)));

      expect(tester.getSize(shellSheet().first).width, 500);
    });
  });

  group('label placement', () {
    testWidgets('names the trigger from a notched label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaDatePicker(labelPlacement: NebaLabelPlacement.notch, label: Text('Ships on')),
      );

      expect(find.byType(NebaNotch), findsOneWidget);
      expect(triggerData(tester).label, 'Ships on');

      semantics.dispose();
    });

    testWidgets('keeps a floating label in the notch beside the calendar glyph', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaDatePicker(labelPlacement: NebaLabelPlacement.float, label: Text('Ships on')),
      );

      expect(tester.widget<NebaNotch>(find.byType(NebaNotch)).resting, isFalse);
    });

    testWidgets('lets a floating label rest once the glyph is taken away, until it opens', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaDatePicker(
          labelPlacement: NebaLabelPlacement.float,
          label: const Text('Ships on'),
          showStartIcon: false,
          defaultMonth: day,
        ),
      );
      await settle(tester);

      bool resting() => tester.widget<NebaNotch>(find.byType(NebaNotch)).resting;

      expect(resting(), isTrue);

      await open(tester);

      expect(resting(), isFalse);
    });
  });
}
