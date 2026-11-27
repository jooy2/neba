// NebaDateTimePicker: the suite the React package runs on DateTimePicker,
// asked the way Flutter asks it. The calendar and the clock are tested with
// NebaCalendar and NebaTimePicker; this is what the two do together.

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/calendar.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/notch.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final DateTime julyHalfTwo = DateTime(2026, 7, 27, 14, 30);

  Future<void> pump(WidgetTester tester, Widget picker) {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    return tester.pumpWidget(
      host(
        Overlay.wrap(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(padding: const EdgeInsets.all(40), child: picker),
          ),
        ),
        width: 900,
        height: 900,
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byType(NebaFieldShell));
    await settle(tester);
  }

  Finder cell(String label) => find.bySemanticsLabel(label);

  Finder column(String name) => find.bySemanticsLabel(name);

  Finder row(String name, String label) {
    return find.descendant(of: column(name), matching: find.text(label));
  }

  Future<SemanticsNode> nodeOf(WidgetTester tester, String name, String label) async {
    await tester.ensureVisible(row(name, label));
    await tester.pump();

    return tester.getSemantics(row(name, label));
  }

  Matcher option(String label, {bool selected = false, bool enabled = true}) {
    return matchesSemantics(
      label: label,
      isButton: true,
      hasSelectedState: true,
      isSelected: selected,
      hasEnabledState: true,
      isEnabled: enabled,
      isFocusable: true,
      hasTapAction: enabled,
      hasFocusAction: true,
    );
  }

  Matcher dayCell(
    String label, {
    bool enabled = true,
    bool focused = false,
    bool selected = false,
  }) {
    return matchesSemantics(
      label: label,
      isButton: true,
      hasSelectedState: true,
      isSelected: selected,
      hasEnabledState: true,
      isEnabled: enabled,
      isFocusable: true,
      isFocused: focused,
      hasTapAction: enabled,
      hasFocusAction: true,
    );
  }

  bool popupOpen() => find.byType(NebaCalendarGrid).evaluate().isNotEmpty;

  group('rendering', () {
    testWidgets('is a button named by its label that says the day and the time', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaDateTimePicker(label: const Text('Runs at'), defaultValue: julyHalfTwo),
      );

      expect(
        tester.getSemantics(find.byType(NebaFieldWidth)),
        matchesSemantics(
          label: 'Runs at',
          value: 'Jul 27, 2026, 2:30 PM',
          isButton: true,
          hasExpandedState: true,
          isFocusable: true,
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
    });

    testWidgets('writes the day and the time in one string, or by a format', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaDateTimePicker(defaultValue: julyHalfTwo));
      expect(find.text('Jul 27, 2026, 2:30 PM'), findsOneWidget);

      await pump(
        tester,
        NebaDateTimePicker(
          key: const Key('format'),
          defaultValue: julyHalfTwo,
          format: (DateTime value) => '${value.day}/${value.month} ${value.hour}h',
        ),
      );
      expect(find.text('27/7 14h'), findsOneWidget);
    });

    testWidgets('wears the calendar glyph, not the clock', (WidgetTester tester) async {
      await pump(tester, const NebaDateTimePicker());

      expect(find.byType(NebaFieldAdornment), findsOneWidget);
    });

    testWidgets('opens a calendar and a clock in the same popup, at one height', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaDateTimePicker(defaultValue: julyHalfTwo));
      await open(tester);

      expect(find.byType(NebaCalendarGrid), findsOneWidget);
      expect(column('Hour'), findsOneWidget);
      // The hairline between them is as tall as the calendar.
      final Rect calendar = tester.getRect(find.byType(NebaCalendarGrid));
      final Rect line = tester.getRect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is ColoredBox && widget.color == tokens.roles(NebaColor.primary).line,
        ),
      );

      expect(line.width, 1);
      expect(line.height, calendar.height);
    });
  });

  group('choosing', () {
    testWidgets('changes the day and keeps the clock', (WidgetTester tester) async {
      final List<DateTime?> reported = <DateTime?>[];

      await pump(
        tester,
        NebaDateTimePicker(defaultValue: julyHalfTwo, onValueChange: reported.add),
      );
      await open(tester);
      await tester.tap(cell('Wednesday, July 15, 2026'));
      await settle(tester);

      expect(reported, <DateTime?>[DateTime(2026, 7, 15, 14, 30)]);
    });

    testWidgets('changes the clock and keeps the day', (WidgetTester tester) async {
      final List<DateTime?> reported = <DateTime?>[];

      await pump(
        tester,
        NebaDateTimePicker(defaultValue: julyHalfTwo, onValueChange: reported.add),
      );
      await open(tester);
      await tester.ensureVisible(row('Minute', '45'));
      await tester.pump();
      await tester.tap(row('Minute', '45'));
      await settle(tester);

      expect(reported, <DateTime?>[DateTime(2026, 7, 27, 14, 45)]);
    });

    testWidgets('writes a day chosen first at midnight, and a time onto today', (
      WidgetTester tester,
    ) async {
      final List<DateTime?> reported = <DateTime?>[];
      final DateTime today = DateTime.now();

      await pump(
        tester,
        NebaDateTimePicker(defaultMonth: DateTime(2026, 7), onValueChange: reported.add),
      );
      await open(tester);
      await tester.tap(cell('Wednesday, July 15, 2026'));
      await settle(tester);

      expect(reported.single, DateTime(2026, 7, 15));

      await pump(tester, NebaDateTimePicker(key: const Key('time'), onValueChange: reported.add));
      await open(tester);
      await tester.ensureVisible(row('Hour', '9'));
      await tester.pump();
      await tester.tap(row('Hour', '9'));
      await settle(tester);

      expect(reported.last, DateTime(today.year, today.month, today.day, 9));
    });

    testWidgets('opens on the chosen day, and Tab goes on from the grid to the hours', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaDateTimePicker(defaultValue: julyHalfTwo));
      await open(tester);

      Rect? focused() => FocusManager.instance.primaryFocus?.rect;
      Rect rowBox(String name, String label) => tester.getRect(
        find.ancestor(of: row(name, label), matching: find.byType(NebaInteractive)).first,
      );

      expect(focused(), tester.getRect(cell('Monday, July 27, 2026')));

      FocusManager.instance.primaryFocus!.nextFocus();
      await tester.pump();
      expect(focused(), rowBox('Hour', '2'));

      FocusManager.instance.primaryFocus!.nextFocus();
      await tester.pump();
      expect(focused(), rowBox('Minute', '30'));
    });

    testWidgets('stays open after a day is chosen, and closes on Done', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaDateTimePicker(defaultValue: julyHalfTwo));
      await open(tester);
      await tester.tap(cell('Wednesday, July 15, 2026'));
      await settle(tester);

      expect(popupOpen(), isTrue);

      await tester.tap(find.text('Done'));
      await settle(tester);

      expect(popupOpen(), isFalse);
    });

    testWidgets('closes on the day with closeOnSelect', (WidgetTester tester) async {
      await pump(tester, NebaDateTimePicker(defaultValue: julyHalfTwo, closeOnSelect: true));
      await open(tester);
      await tester.tap(cell('Wednesday, July 15, 2026'));
      await settle(tester);

      expect(popupOpen(), isFalse);
    });

    testWidgets('takes this moment from the footer and moves the calendar to it', (
      WidgetTester tester,
    ) async {
      DateTime? chosen;
      final DateTime now = DateTime.now();

      await pump(
        tester,
        NebaDateTimePicker(
          defaultValue: DateTime(2019, 3, 14, 9),
          onValueChange: (DateTime? value) => chosen = value,
        ),
      );
      await open(tester);
      await tester.tap(find.text('Now'));
      await settle(tester);

      expect(chosen?.year, now.year);
      expect(chosen?.month, now.month);
      expect(chosen?.day, now.day);
      expect(chosen?.second, 0);
      expect(popupOpen(), isTrue);
      expect(
        cell(NebaDateNames.english.write(NebaDateNames.english.fullDate, now)),
        findsOneWidget,
      );
    });
  });

  group('bounds', () {
    testWidgets('moves a moment chosen before minDate up to the bound', (
      WidgetTester tester,
    ) async {
      final List<DateTime?> reported = <DateTime?>[];

      await pump(
        tester,
        NebaDateTimePicker(
          defaultMonth: DateTime(2026, 7),
          minDate: DateTime(2026, 7, 27, 9, 30),
          onValueChange: reported.add,
        ),
      );
      await open(tester);
      await tester.tap(cell('Monday, July 27, 2026'));
      await settle(tester);

      expect(reported.last, DateTime(2026, 7, 27, 9, 30));
    });

    testWidgets('reads minDate to the second: its day stays open and its morning greys out', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaDateTimePicker(
          defaultValue: DateTime(2026, 7, 27, 12),
          minDate: DateTime(2026, 7, 27, 9, 30),
          hour12: false,
        ),
      );
      await open(tester);

      expect(
        tester.getSemantics(cell('Monday, July 27, 2026')),
        dayCell('Monday, July 27, 2026', focused: true, selected: true),
      );
      expect(
        tester.getSemantics(cell('Sunday, July 26, 2026')),
        dayCell('Sunday, July 26, 2026', enabled: false),
      );
      expect(await nodeOf(tester, 'Hour', '08'), option('08', enabled: false));
      expect(await nodeOf(tester, 'Hour', '09'), option('09'));
    });

    // On 1 November 2026 the clocks in New York go back an hour; the rows are
    // compared on the wall clock, which gives the same answer in every zone.
    testWidgets('reads minDate on the wall clock on a day the clocks change', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaDateTimePicker(
          defaultValue: DateTime(2026, 11, 1, 12),
          minDate: DateTime(2026, 11, 1, 9, 30),
          hour12: false,
        ),
      );
      await open(tester);

      expect(await nodeOf(tester, 'Hour', '08'), option('08', enabled: false));
      expect(await nodeOf(tester, 'Hour', '09'), option('09'));
    });

    testWidgets('greys out Now when this moment is blocked', (WidgetTester tester) async {
      await pump(tester, NebaDateTimePicker(maxDate: DateTime(2020)));
      await open(tester);

      expect(
        tester
            .widget<NebaButton>(
              find.ancestor(of: find.text('Now'), matching: find.byType(NebaButton)),
            )
            .onPressed,
        isNull,
      );
    });
  });

  group('states', () {
    testWidgets('empties the value through the ×', (WidgetTester tester) async {
      final List<DateTime?> reported = <DateTime?>[];

      await pump(
        tester,
        NebaDateTimePicker(
          placeholder: const Text('Pick a moment'),
          defaultValue: julyHalfTwo,
          clearable: true,
          onValueChange: reported.add,
        ),
      );
      await tester.tap(find.bySemanticsLabel('Clear'));
      await settle(tester);

      expect(reported, <DateTime?>[null]);
      expect(find.text('Pick a moment'), findsOneWidget);
    });

    testWidgets('does not open when read-only', (WidgetTester tester) async {
      await pump(tester, NebaDateTimePicker(defaultValue: julyHalfTwo, readOnly: true));
      await tester.tap(find.byType(NebaFieldShell));
      await settle(tester);

      expect(popupOpen(), isFalse);
    });

    testWidgets('holds one width whatever moment it holds', (WidgetTester tester) async {
      Finder shell() => find.byType(NebaFieldShell);

      await pump(tester, NebaDateTimePicker(defaultValue: DateTime(2026, 5, 1, 1, 5)));
      final double early = tester.getSize(shell()).width;

      await pump(
        tester,
        NebaDateTimePicker(key: const Key('late'), defaultValue: DateTime(2026, 9, 28, 22, 58)),
      );

      expect(tester.getSize(shell()).width, early);
    });
  });

  group('label placement', () {
    testWidgets('names the trigger from a notched label', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaDateTimePicker(labelPlacement: NebaLabelPlacement.notch, label: Text('Runs at')),
      );

      expect(find.byType(NebaNotch), findsOneWidget);
      expect(tester.getSemantics(find.byType(NebaFieldWidth)).label, 'Runs at');
    });
  });
}
