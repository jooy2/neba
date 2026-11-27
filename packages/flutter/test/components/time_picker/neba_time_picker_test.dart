// NebaTimePicker: the suite the React package runs on TimePicker, asked the
// way Flutter asks it — the columns it builds, what a screen reader hears of
// them and what a press and a key do — rather than the listboxes, the
// options and the ARIA it writes. The trigger is the date picker's, and what
// it shares with it is tested with NebaDatePicker.

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/calendar.dart';
import 'package:neba/src/internal/date.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/notch.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles danger = tokens.roles(NebaColor.danger);
  final DateTime halfTwo = DateTime(2026, 7, 27, 14, 30);

  tearDown(resetNebaDateNames);

  // At the top of a window tall enough for the clock under it.
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

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byType(NebaFieldShell));
    await settle(tester);
  }

  // A column is found by what a screen reader calls it, and a row in it by
  // what it says: every row is built, scrolled out of view or not.
  Finder column(String name) => find.bySemanticsLabel(name);

  Finder row(String name, String label) {
    return find.descendant(of: column(name), matching: find.text(label));
  }

  Finder box(String name, String label) {
    return find.ancestor(of: row(name, label), matching: find.byType(NebaInteractive)).first;
  }

  int rowsIn(String name) {
    return find
        .descendant(of: column(name), matching: find.byType(NebaInteractive))
        .evaluate()
        .length;
  }

  // A row's node, once the row is scrolled into view.
  Future<SemanticsNode> nodeOf(WidgetTester tester, String name, String label) async {
    await tester.ensureVisible(row(name, label));
    await tester.pump();

    return tester.getSemantics(row(name, label));
  }

  Future<void> press(WidgetTester tester, String name, String label) async {
    await tester.ensureVisible(row(name, label));
    await tester.pump();
    await tester.tap(row(name, label));
    await settle(tester);
  }

  Rect? focused() => FocusManager.instance.primaryFocus?.rect;

  FocusNode triggerNode(WidgetTester tester) {
    return Focus.of(
      tester.element(
        find.descendant(of: find.byType(NebaFieldShell), matching: find.byType(Row)).at(1),
      ),
    );
  }

  bool clockOpen() => find.byType(NebaTimeGrid).evaluate().isNotEmpty;

  // A row's node: a button named by what it says, chosen or not, and
  // focusable whether or not it can be chosen.
  Matcher option(String label, {bool selected = false, bool enabled = true, bool focused = false}) {
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

  group('rendering', () {
    testWidgets('is a button named by its label that says the time it holds', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaTimePicker(label: const Text('Starts at'), defaultValue: halfTwo));

      expect(
        tester.getSemantics(find.byType(NebaFieldWidth)),
        matchesSemantics(
          label: 'Starts at',
          value: '2:30 PM',
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

    testWidgets('shows the placeholder while nothing is chosen, muted', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTimePicker(placeholder: Text('Pick a time')));

      expect(
        DefaultTextStyle.of(tester.element(find.text('Pick a time'))).style.color,
        tokens.mutedFg,
      );
    });

    testWidgets('writes the time, with its seconds when they are shown, or by a format', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaTimePicker(defaultValue: halfTwo));
      expect(find.text('2:30 PM'), findsOneWidget);

      await pump(
        tester,
        NebaTimePicker(
          key: const Key('seconds'),
          defaultValue: DateTime(2026, 7, 27, 14, 30, 5),
          showSeconds: true,
        ),
      );
      expect(find.text('2:30:05 PM'), findsOneWidget);

      await pump(
        tester,
        NebaTimePicker(
          key: const Key('format'),
          defaultValue: halfTwo,
          format: (DateTime value) => '${value.hour}h${value.minute}',
        ),
      );
      expect(find.text('14h30'), findsOneWidget);
    });

    testWidgets('writes the time in the names registered for its locale', (
      WidgetTester tester,
    ) async {
      registerNebaDateNames(
        'ko',
        NebaDateNames(
          months: NebaDateNames.english.months,
          shortMonths: NebaDateNames.english.shortMonths,
          weekdays: NebaDateNames.english.weekdays,
          shortWeekdays: NebaDateNames.english.shortWeekdays,
          am: '오전',
          pm: '오후',
          time: '{dayPeriod} {dialHour}:{minute}',
        ),
      );

      await pump(tester, NebaTimePicker(defaultValue: halfTwo, locale: const Locale('ko')));
      expect(find.text('오후 2:30'), findsOneWidget);

      await open(tester);
      expect(row('AM/PM', '오후'), findsOneWidget);
    });

    testWidgets('wears a clock glyph, or none', (WidgetTester tester) async {
      await pump(tester, const NebaTimePicker());
      expect(find.byType(NebaFieldAdornment), findsOneWidget);

      await pump(tester, const NebaTimePicker(showStartIcon: false));
      expect(find.byType(NebaFieldAdornment), findsNothing);
    });

    testWidgets('builds nothing of the clock until it is open', (WidgetTester tester) async {
      await pump(tester, const NebaTimePicker());

      expect(clockOpen(), isFalse);
    });
  });

  group('the columns', () {
    testWidgets('offers hours, minutes and a meridiem on a 12-hour dial', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaTimePicker(defaultValue: halfTwo));
      await open(tester);

      expect(column('Hour'), findsOneWidget);
      expect(column('Minute'), findsOneWidget);
      expect(column('AM/PM'), findsOneWidget);
      expect(column('Second'), findsNothing);
      // 12, 1, 2 … 11: the order a 12-hour dial is read in.
      expect(rowsIn('Hour'), 12);
      expect(row('Hour', '12'), findsOneWidget);
      expect(row('Hour', '0'), findsNothing);
    });

    testWidgets('drops the meridiem and runs to 24 when hour12 is off', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaTimePicker(defaultValue: halfTwo, hour12: false));
      await open(tester);

      expect(column('AM/PM'), findsNothing);
      expect(rowsIn('Hour'), 24);
      expect(row('Hour', '00'), findsOneWidget);
    });

    testWidgets('adds the seconds, and thins a column out by its step', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaTimePicker(defaultValue: halfTwo, minuteStep: 15, showSeconds: true, secondStep: 20),
      );
      await open(tester);

      expect(rowsIn('Minute'), 4);
      expect(rowsIn('Second'), 3);
    });

    testWidgets('marks the rows the value is on', (WidgetTester tester) async {
      await pump(tester, NebaTimePicker(defaultValue: halfTwo));
      await open(tester);

      expect(await nodeOf(tester, 'Minute', '30'), option('30', selected: true));
      expect(await nodeOf(tester, 'Minute', '31'), option('31'));
      expect(await nodeOf(tester, 'AM/PM', 'PM'), option('PM', selected: true));
    });

    testWidgets('fills a chosen row in the family and sets it in semibold', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaTimePicker(defaultValue: halfTwo));
      await open(tester);

      final DecoratedBox fill = tester.widget<DecoratedBox>(
        find.ancestor(of: row('Minute', '30'), matching: find.byType(DecoratedBox)).first,
      );

      expect((fill.decoration as BoxDecoration).color, tokens.roles(NebaColor.primary).fill);
      expect(
        DefaultTextStyle.of(tester.element(row('Minute', '30'))).style.fontWeight,
        FontWeight.w600,
      );
    });

    testWidgets('scrolls each chosen row into view when it opens', (WidgetTester tester) async {
      await pump(tester, NebaTimePicker(defaultValue: DateTime(2026, 7, 27, 14, 45)));
      await open(tester);

      final Rect minutes = tester.getRect(column('Minute'));
      final Rect chosen = tester.getRect(box('Minute', '45'));

      expect(chosen.top, greaterThanOrEqualTo(minutes.top));
      expect(chosen.bottom, lessThanOrEqualTo(minutes.bottom));
    });

    testWidgets('says the whole time in a live region beside the columns', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaTimePicker(defaultValue: halfTwo));
      await open(tester);

      expect(find.bySemanticsLabel('2:30 PM'), findsOneWidget);
    });
  });

  group('choosing a time', () {
    testWidgets('reports the hour that was pressed and keeps the rest', (
      WidgetTester tester,
    ) async {
      final List<DateTime?> reported = <DateTime?>[];

      await pump(tester, NebaTimePicker(defaultValue: halfTwo, onValueChange: reported.add));
      await open(tester);
      await press(tester, 'Hour', '5');

      // 5 on a PM dial is 17:00, and the minutes are untouched.
      expect(reported, <DateTime?>[DateTime(2026, 7, 27, 17, 30)]);
      expect(find.text('5:30 PM'), findsOneWidget);
    });

    testWidgets('moves the whole time across the meridiem', (WidgetTester tester) async {
      final List<DateTime?> reported = <DateTime?>[];

      await pump(tester, NebaTimePicker(defaultValue: halfTwo, onValueChange: reported.add));
      await open(tester);
      await press(tester, 'AM/PM', 'AM');

      expect(reported, <DateTime?>[DateTime(2026, 7, 27, 2, 30)]);
    });

    testWidgets('stops once per column and walks a column with the arrow keys', (
      WidgetTester tester,
    ) async {
      final List<DateTime?> reported = <DateTime?>[];

      await pump(tester, NebaTimePicker(defaultValue: halfTwo, onValueChange: reported.add));
      await open(tester);

      expect(focused(), tester.getRect(box('Hour', '2')));

      // What Tab does: the next stop is the minutes' chosen row.
      FocusManager.instance.primaryFocus!.nextFocus();
      await tester.pump();
      expect(focused(), tester.getRect(box('Minute', '30')));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focused(), tester.getRect(box('Minute', '31')));
      expect(reported, isEmpty);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);
      expect(reported, <DateTime?>[DateTime(2026, 7, 27, 14, 31)]);

      // The next stop after the minutes is the meridiem, past every minute.
      FocusManager.instance.primaryFocus!.nextFocus();
      await tester.pump();
      expect(focused(), tester.getRect(box('AM/PM', 'PM')));
    });

    testWidgets('reaches the ends of a column with Home and End, scrolled into view', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaTimePicker(defaultValue: halfTwo));
      await open(tester);

      FocusManager.instance.primaryFocus!.nextFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();

      final Rect minutes = tester.getRect(column('Minute'));

      expect(focused(), tester.getRect(box('Minute', '59')));
      expect(tester.getRect(box('Minute', '59')).bottom, lessThanOrEqualTo(minutes.bottom));

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();

      expect(focused(), tester.getRect(box('Minute', '00')));
      expect(tester.getRect(box('Minute', '00')).top, minutes.top);
    });

    testWidgets('stays open while the columns are read, and closes on Done', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaTimePicker(defaultValue: halfTwo));
      await open(tester);
      await press(tester, 'Hour', '5');

      expect(clockOpen(), isTrue);

      await tester.tap(find.text('Done'));
      await settle(tester);

      expect(clockOpen(), isFalse);
    });

    testWidgets('closes as soon as a column is touched with closeOnSelect, and has no Done', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaTimePicker(defaultValue: halfTwo, closeOnSelect: true));
      await open(tester);

      expect(find.text('Done'), findsNothing);

      await press(tester, 'Hour', '5');

      expect(clockOpen(), isFalse);
    });

    testWidgets('moves a time chosen before minTime up to the bound', (WidgetTester tester) async {
      final List<DateTime?> reported = <DateTime?>[];

      await pump(
        tester,
        NebaTimePicker(
          minTime: DateTime(2026, 1, 1, 9, 30),
          defaultValue: DateTime(2026, 7, 27, 10, 15),
          onValueChange: reported.add,
        ),
      );
      await open(tester);
      await press(tester, 'Hour', '9');

      expect(reported.last, DateTime(2026, 7, 27, 9, 30));
    });

    testWidgets('writes onto the day referenceDate names', (WidgetTester tester) async {
      final List<DateTime?> reported = <DateTime?>[];

      await pump(
        tester,
        NebaTimePicker(referenceDate: DateTime(2026, 1, 2), onValueChange: reported.add),
      );
      await open(tester);
      await press(tester, 'Minute', '45');

      expect(reported, <DateTime?>[DateTime(2026, 1, 2, 0, 45)]);
    });

    testWidgets('writes a picked hour on the hour, today, with no value and no referenceDate', (
      WidgetTester tester,
    ) async {
      final List<DateTime?> reported = <DateTime?>[];
      final DateTime today = NebaDate.today();

      await pump(tester, NebaTimePicker(onValueChange: reported.add));
      await open(tester);
      await press(tester, 'Hour', '9');

      expect(reported, <DateTime?>[DateTime(today.year, today.month, today.day, 9)]);
    });

    testWidgets('takes the time now from the footer, and closes', (WidgetTester tester) async {
      DateTime? chosen;

      await pump(
        tester,
        NebaTimePicker(
          referenceDate: DateTime(2026, 1, 2),
          onValueChange: (DateTime? value) => chosen = value,
        ),
      );
      await open(tester);
      await tester.tap(find.text('Now'));
      await settle(tester);

      final DateTime now = DateTime.now();

      expect(chosen?.day, 2);
      expect(chosen?.hour, now.hour);
      expect(chosen?.second, 0);
      expect(clockOpen(), isFalse);
    });
  });

  group('bounds', () {
    testWidgets('keeps an hour that still holds an allowed minute', (WidgetTester tester) async {
      await pump(
        tester,
        NebaTimePicker(
          defaultValue: DateTime(2026, 7, 27, 9, 45),
          minTime: DateTime(2026, 7, 27, 9, 30),
          hour12: false,
        ),
      );
      await open(tester);

      expect(await nodeOf(tester, 'Hour', '09'), option('09', selected: true, focused: true));
      expect(await nodeOf(tester, 'Hour', '08'), option('08', enabled: false));
      expect(await nodeOf(tester, 'Minute', '15'), option('15', enabled: false));
      expect(await nodeOf(tester, 'Minute', '30'), option('30'));
    });

    testWidgets('blocks what shouldDisableTime rejects, and greys it out', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaTimePicker(
          defaultValue: halfTwo,
          hour12: false,
          shouldDisableTime: (DateTime value, NebaTimeUnit unit) =>
              unit == NebaTimeUnit.hour && value.hour == 13,
        ),
      );
      await open(tester);

      expect(await nodeOf(tester, 'Hour', '13'), option('13', enabled: false));
      expect(DefaultTextStyle.of(tester.element(row('Hour', '13'))).style.color, tokens.disabledFg);
    });

    testWidgets('greys out the shortcut to now when now is blocked', (WidgetTester tester) async {
      await pump(
        tester,
        NebaTimePicker(
          shouldDisableTime: (DateTime value, NebaTimeUnit unit) => unit == NebaTimeUnit.second,
        ),
      );
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
    testWidgets('empties the value through the ×, without opening', (WidgetTester tester) async {
      final List<DateTime?> reported = <DateTime?>[];

      await pump(
        tester,
        NebaTimePicker(
          placeholder: const Text('Pick a time'),
          defaultValue: halfTwo,
          clearable: true,
          onValueChange: reported.add,
        ),
      );
      await tester.tap(find.bySemanticsLabel('Clear'));
      await settle(tester);

      expect(reported, <DateTime?>[null]);
      expect(find.text('Pick a time'), findsOneWidget);
      expect(clockOpen(), isFalse);
    });

    testWidgets('does not open when read-only, and keeps the focus', (WidgetTester tester) async {
      await pump(tester, NebaTimePicker(defaultValue: halfTwo, readOnly: true));
      await tester.tap(find.byType(NebaFieldShell));
      await settle(tester);

      expect(clockOpen(), isFalse);
      expect(triggerNode(tester).canRequestFocus, isTrue);
    });

    testWidgets('does not open when disabled', (WidgetTester tester) async {
      await pump(tester, NebaTimePicker(defaultValue: halfTwo, disabled: true));
      await tester.tap(find.byType(NebaFieldShell));
      await settle(tester);

      expect(clockOpen(), isFalse);
    });

    testWidgets('turns the family over to danger with an error', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTimePicker(label: Text('Starts at'), error: Text('A time is required.')),
      );

      expect(
        tester
            .widget<NebaSheet>(
              find
                  .descendant(of: find.byType(NebaFieldShell), matching: find.byType(NebaSheet))
                  .first,
            )
            .edge,
        danger.line,
      );
    });

    testWidgets('opens on Enter with the hours focused, and Escape gives the focus back', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaTimePicker(defaultValue: halfTwo));
      triggerNode(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      expect(clockOpen(), isTrue);
      expect(focused(), tester.getRect(box('Hour', '2')));

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      expect(clockOpen(), isFalse);
      expect(triggerNode(tester).hasPrimaryFocus, isTrue);
    });

    testWidgets('holds one width whatever time it holds', (WidgetTester tester) async {
      Finder sheet() =>
          find.descendant(of: find.byType(NebaFieldShell), matching: find.byType(NebaSheet));

      await pump(tester, NebaTimePicker(defaultValue: DateTime(2026, 7, 27, 1, 5)));
      final double early = tester.getSize(sheet().first).width;

      await pump(
        tester,
        NebaTimePicker(key: const Key('late'), defaultValue: DateTime(2026, 7, 27, 22, 58)),
      );

      expect(tester.getSize(sheet().first).width, early);
    });
  });

  group('label placement', () {
    testWidgets('names the trigger from a notched label', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTimePicker(labelPlacement: NebaLabelPlacement.notch, label: Text('Starts at')),
      );

      expect(find.byType(NebaNotch), findsOneWidget);
      expect(tester.getSemantics(find.byType(NebaFieldWidth)).label, 'Starts at');
    });

    testWidgets('keeps a floating label in the notch beside the clock glyph', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTimePicker(labelPlacement: NebaLabelPlacement.float, label: Text('Starts at')),
      );

      expect(tester.widget<NebaNotch>(find.byType(NebaNotch)).resting, isFalse);
    });
  });
}
